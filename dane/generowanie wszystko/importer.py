import psycopg2
import os
import sys

# === KONFIGURACJA BAZY DANYCH ===
# Zmień te dane na swoje!
DB_HOST = "localhost"
DB_NAME = "biblioteka_uzupelniona"  # Upewnij się, że taka baza istnieje
DB_USER = "postgres"
DB_PASS = "haslo"
DB_PORT = "5432"

# Folder z plikami CSV
CSV_DIR = 'duze_dane'

# Definicja struktury SQL (DDL)
# Naprawiono kodowanie znaków (dost©pny -> dostępny) i dodano brakujące triggery
DDL_SCRIPT = """
-- Czyszczenie starego schematu
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;

-- Funkcje i Triggery
CREATE OR REPLACE FUNCTION public.fn_after_wypozyczenie_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE ksiazki SET status = 'wypożyczony' WHERE id_ksiazki = NEW.id_ksiazki;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_after_zwrot_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    wypozyczona_ksiazka_id INT;
BEGIN
    SELECT id_ksiazki INTO wypozyczona_ksiazka_id FROM wypozyczenia WHERE id_wypozyczenia = NEW.id_wypozyczenia;
    UPDATE ksiazki SET status = 'dostępny' WHERE id_ksiazki = wypozyczona_ksiazka_id;
    RETURN NEW;
END;
$$;

-- Tabele
CREATE TABLE public.filie (
    id_filii SERIAL PRIMARY KEY,
    adres character varying(255) NOT NULL UNIQUE,
    nazwa_filii character varying(150) NOT NULL,
    glowny_bibliotekarz character varying(100)
);

CREATE TABLE public.kategorie (
    id_kategorii SERIAL PRIMARY KEY,
    nazwa_kategorii character varying(100) NOT NULL UNIQUE
);

CREATE TABLE public.rodzaje_kar (
    id_rodzaju_kary SERIAL PRIMARY KEY,
    nazwa_kary character varying(100) NOT NULL,
    opis text
);

CREATE TABLE public.uzytkownicy (
    id_osoby SERIAL PRIMARY KEY,
    imie character varying(50) NOT NULL,
    nazwisko character varying(50) NOT NULL,
    plec character varying(15) CHECK (plec IN ('MEZCZYZNA', 'KOBIETA', 'NIEOKRESLONY')),
    login character varying(50) NOT NULL UNIQUE,
    email character varying(100) NOT NULL UNIQUE,
    hash_hasla character varying(255) NOT NULL,
    sol_do_hasla character varying(255) NOT NULL,
    pytanie_pomocnicze text,
    hash_odpowiedzi character varying(255),
    url_profilowe character varying(255),
    data_zalozenia_konta timestamp without time zone,
    aktywne boolean DEFAULT true
);

CREATE TABLE public.ksiazki (
    id_ksiazki SERIAL PRIMARY KEY,
    nr_isbn character varying(20) NOT NULL,
    numer_inwentarzowy integer NOT NULL,
    tytul character varying(255) NOT NULL,
    autor character varying(255) NOT NULL,
    id_kategorii integer REFERENCES public.kategorie(id_kategorii),
    id_filii integer REFERENCES public.filie(id_filii),
    rok_wydania integer,
    numer_edycji character varying(50),
    liczba_stron integer,
    dostepna_online boolean DEFAULT false,
    opis text,
    status character varying(20) DEFAULT 'dostępny',
    CONSTRAINT unikalny_egzemplarz UNIQUE (nr_isbn, numer_inwentarzowy)
);

CREATE TABLE public.wypozyczenia (
    id_wypozyczenia SERIAL PRIMARY KEY,
    id_osoby integer NOT NULL REFERENCES public.uzytkownicy(id_osoby) ON DELETE CASCADE,
    id_ksiazki integer NOT NULL REFERENCES public.ksiazki(id_ksiazki) ON DELETE CASCADE,
    data_wypozyczenia date NOT NULL,
    planowana_data_zwrotu date NOT NULL
    -- Usunięto UNIQUE(id_ksiazki), ponieważ to uniemożliwiałoby historię wypożyczeń tej samej książki
    -- Zamiast tego logika aplikacji powinna sprawdzać status.
);

-- Trigger dla wypożyczeń
CREATE TRIGGER tr_after_wypozyczenie
AFTER INSERT ON public.wypozyczenia
FOR EACH ROW EXECUTE FUNCTION public.fn_after_wypozyczenie_insert();

CREATE TABLE public.zwroty (
    id_wypozyczenia integer PRIMARY KEY REFERENCES public.wypozyczenia(id_wypozyczenia) ON DELETE CASCADE,
    data_zwrotu date NOT NULL
);

-- Trigger dla zwrotów
CREATE TRIGGER tr_after_zwrot
AFTER INSERT ON public.zwroty
FOR EACH ROW EXECUTE FUNCTION public.fn_after_zwrot_insert();

CREATE TABLE public.kary (
    id_kary SERIAL PRIMARY KEY,
    id_osoby integer NOT NULL REFERENCES public.uzytkownicy(id_osoby),
    id_rodzaju_kary integer NOT NULL REFERENCES public.rodzaje_kar(id_rodzaju_kary),
    id_wypozyczenia integer REFERENCES public.wypozyczenia(id_wypozyczenia),
    kwota numeric(7,2),
    data_nalozenia date NOT NULL,
    data_oplacenia date,
    status character varying(20) DEFAULT 'aktywna'
);

CREATE TABLE public.komentarze (
    id_komentarza SERIAL PRIMARY KEY,
    nr_isbn character varying(20) NOT NULL,
    id_osoby integer NOT NULL REFERENCES public.uzytkownicy(id_osoby),
    ocena integer CHECK (ocena >= 1 AND ocena <= 10),
    tresc text,
    data_dodania timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.rezerwacje (
    id_rezerwacji SERIAL PRIMARY KEY,
    nr_isbn character varying(20) NOT NULL,
    id_osoby integer NOT NULL REFERENCES public.uzytkownicy(id_osoby),
    id_filii integer NOT NULL REFERENCES public.filie(id_filii),
    data_rezerwacji timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(20) DEFAULT 'oczekująca',
    wygasa_dnia date
);

CREATE TABLE public.wejscia (
    id_wejscia SERIAL PRIMARY KEY,
    id_osoby integer NOT NULL REFERENCES public.uzytkownicy(id_osoby),
    id_filii integer NOT NULL REFERENCES public.filie(id_filii),
    data_wejscia timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
"""

# Lista plików w kolejności importu (ze względu na klucze obce)
IMPORT_ORDER = [
    'filie.csv',
    'kategorie.csv',
    'rodzaje_kar.csv',
    'uzytkownicy.csv',
    'ksiazki.csv',
    'wypozyczenia.csv',
    'zwroty.csv',
    'kary.csv',
    'rezerwacje.csv',
    'komentarze.csv',
    'wejscia.csv'
]

# Mapowanie tabeli na nazwę sekwencji do resetu
SEQUENCES_TO_RESET = {
    'filie': 'filie_id_filii_seq',
    'kategorie': 'kategorie_id_kategorii_seq',
    'rodzaje_kar': 'rodzaje_kar_id_rodzaju_kary_seq',
    'uzytkownicy': 'uzytkownicy_id_osoby_seq',
    'ksiazki': 'ksiazki_id_ksiazki_seq',
    'wypozyczenia': 'wypozyczenia_id_wypozyczenia_seq',
    'kary': 'kary_id_kary_seq',
    'komentarze': 'komentarze_id_komentarza_seq',
    'rezerwacje': 'rezerwacje_id_rezerwacji_seq',
    'wejscia': 'wejscia_id_wejscia_seq'
}

def create_structure(conn):
    print("--- Tworzenie struktury bazy danych ---")
    try:
        cur = conn.cursor()
        cur.execute(DDL_SCRIPT)
        conn.commit()
        print("Struktura utworzona pomyślnie (Stary schemat public usunięty).")
    except Exception as e:
        conn.rollback()
        print(f"Błąd podczas tworzenia struktury: {e}")
        sys.exit(1)

def import_data(conn):
    print("\n--- Importowanie danych z CSV ---")
    cur = conn.cursor()
    
    # Wyłączamy triggery na czas importu, żeby nie dublować logiki (np. zmiany statusów, które już są w CSV)
    # Ewentualnie możemy je zostawić, jeśli dane w CSV nie są idealnie zsynchronizowane ze statusami,
    # ale tutaj zakładamy, że generator zrobił dobrą robotę.
    # Dla bezpieczeństwa wyłączymy, bo statusy książek są już ustawione w pliku ksiazki.csv.
    cur.execute("SET session_replication_role = 'replica';")

    for filename in IMPORT_ORDER:
        table_name = filename.replace('.csv', '')
        file_path = os.path.join(CSV_DIR, filename)
        
        if not os.path.exists(file_path):
            print(f"Pominięto (brak pliku): {filename}")
            continue
            
        print(f"Importowanie: {table_name}...")
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                # COPY expert jest bardzo szybki i radzi sobie z nagłówkami CSV
                sql = f"COPY {table_name} FROM STDIN WITH CSV HEADER DELIMITER ',' NULL ''"
                cur.copy_expert(sql, f)
                conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"Błąd przy imporcie {filename}: {e}")
            sys.exit(1)

    # Włączamy triggery z powrotem
    cur.execute("SET session_replication_role = 'origin';")
    conn.commit()
    print("Import zakończony.")

def reset_sequences(conn):
    print("\n--- Aktualizacja sekwencji (Auto-increment) ---")
    cur = conn.cursor()
    
    for table, seq_name in SEQUENCES_TO_RESET.items():
        pk_col = f"id_{table[:-1]}" if table.endswith('e') else f"id_{table[:-1]}" # Prosta heurystyka
        if table == 'uzytkownicy': pk_col = 'id_osoby'
        if table == 'ksiazki': pk_col = 'id_ksiazki'
        if table == 'filie': pk_col = 'id_filii'
        if table == 'kategorie': pk_col = 'id_kategorii'
        if table == 'rodzaje_kar': pk_col = 'id_rodzaju_kary'
        if table == 'zwroty': continue # Brak sekwencji, klucz to FK
        
        try:
            # SQL ustawiający wartość sekwencji na max(id) + 1
            sql = f"SELECT setval('{seq_name}', COALESCE((SELECT MAX({pk_col}) FROM {table}), 1), true);"
            cur.execute(sql)
            print(f"Zaktualizowano sekwencję dla: {table}")
        except Exception as e:
            conn.rollback()
            print(f"Ostrzeżenie: Nie udało się zaktualizować sekwencji dla {table}: {e}")
    
    conn.commit()

def main():
    if not os.path.exists(CSV_DIR):
        print(f"Błąd: Nie znaleziono folderu {CSV_DIR}. Uruchom najpierw generator danych.")
        sys.exit(1)

    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASS,
            port=DB_PORT
        )
        print(f"Połączono z bazą: {DB_NAME}")
    except psycopg2.Error as e:
        print(f"Błąd połączenia z bazą: {e}")
        sys.exit(1)

    create_structure(conn)
    import_data(conn)
    reset_sequences(conn)
    
    conn.close()
    print("\nGotowe! Baza danych została zainicjalizowana i wypełniona danymi.")

if __name__ == "__main__":
    main()