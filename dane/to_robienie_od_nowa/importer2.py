import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import os
import sys

# --- KONFIGURACJA ---
DB_HOST = "localhost"
DB_PORT = "5432"
DB_USER = "postgres"      # Twój użytkownik postgres
DB_PASSWORD = "haslo"  # Twoje hasło do postgresa
DB_NAME = "biblioteka_zrobiona_od_nowa"    # Nazwa nowej bazy danych

# Katalog z plikami CSV (musi być ten sam, co w generatorze)
DATA_DIR = 'dane_biblioteczne'

# Schemat SQL (dokładnie taki jak w Twoim poleceniu)
SQL_SCHEMA = """
CREATE TABLE filie (
    id_filii SERIAL PRIMARY KEY,
    adres character varying(255) NOT NULL UNIQUE,
    nazwa_filii character varying(150) NOT NULL,
    glowny_bibliotekarz character varying(100)
);

CREATE TABLE kategorie (
    id_kategorii SERIAL PRIMARY KEY,
    nazwa_kategorii character varying(100) NOT NULL UNIQUE
);

CREATE TABLE rodzaje_kar (
    id_rodzaju_kary SERIAL PRIMARY KEY,
    nazwa_kary character varying(100) NOT NULL,
    opis text
);

CREATE TABLE uzytkownicy (
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

CREATE TABLE ksiazki (
    id_ksiazki SERIAL PRIMARY KEY,
    nr_isbn character varying(20) NOT NULL,
    numer_inwentarzowy integer NOT NULL,
    tytul character varying(255) NOT NULL,
    autor character varying(255) NOT NULL,
    id_kategorii integer REFERENCES kategorie(id_kategorii),
    id_filii integer REFERENCES public.filie(id_filii),
    rok_wydania integer,
    numer_edycji character varying(50),
    liczba_stron integer,
    dostepna_online boolean DEFAULT false,
    opis text,
    status character varying(20) DEFAULT 'dostępny',
    CONSTRAINT unikalny_egzemplarz UNIQUE (nr_isbn, numer_inwentarzowy)
);

CREATE TABLE wypozyczenia (
    id_wypozyczenia SERIAL PRIMARY KEY,
    id_osoby integer NOT NULL REFERENCES uzytkownicy(id_osoby) ON DELETE CASCADE,
    id_ksiazki integer NOT NULL REFERENCES ksiazki(id_ksiazki) ON DELETE CASCADE,
    data_wypozyczenia date NOT NULL,
    planowana_data_zwrotu date NOT NULL
);

CREATE TABLE zwroty (
    id_wypozyczenia integer PRIMARY KEY REFERENCES wypozyczenia(id_wypozyczenia) ON DELETE CASCADE,
    data_zwrotu date NOT NULL
);

CREATE TABLE kary (
    id_kary SERIAL PRIMARY KEY,
    id_osoby integer NOT NULL REFERENCES uzytkownicy(id_osoby),
    id_rodzaju_kary integer NOT NULL REFERENCES rodzaje_kar(id_rodzaju_kary),
    id_wypozyczenia integer REFERENCES wypozyczenia(id_wypozyczenia),
    kwota numeric(7,2),
    data_nalozenia date NOT NULL,
    data_oplacenia date,
    status character varying(20) DEFAULT 'aktywna'
);

CREATE TABLE komentarze (
    id_komentarza SERIAL PRIMARY KEY,
    nr_isbn character varying(20) NOT NULL,
    id_osoby integer NOT NULL REFERENCES uzytkownicy(id_osoby),
    ocena integer CHECK (ocena >= 1 AND ocena <= 10),
    tresc text,
    data_dodania timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE rezerwacje (
    id_rezerwacji SERIAL PRIMARY KEY,
    nr_isbn character varying(20) NOT NULL,
    id_osoby integer NOT NULL REFERENCES uzytkownicy(id_osoby),
    id_filii integer NOT NULL REFERENCES filie(id_filii),
    data_rezerwacji timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(20) DEFAULT 'oczekująca',
    wygasa_dnia date
);

CREATE TABLE wejscia_wyjscia (
    id_wejscia SERIAL PRIMARY KEY,
    id_osoby integer NOT NULL REFERENCES uzytkownicy(id_osoby),
    id_filii integer NOT NULL REFERENCES filie(id_filii),
    data_wejscia timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    data_wyjscia timestamp without time zone DEFAULT NULL
);
"""

# Lista plików i odpowiadających im tabel w kolejności importu (zależności FK!)
# (Nazwa pliku w folderze, Nazwa tabeli w bazie)
FILES_TO_IMPORT = [
    ('kategorie.csv', 'kategorie'),
    ('filie.csv', 'filie'),
    ('rodzaje_kar.csv', 'rodzaje_kar'),
    ('uzytkownicy.csv', 'uzytkownicy'),
    ('ksiazki.csv', 'ksiazki'),
    ('wypozyczenia.csv', 'wypozyczenia'),
    ('zwroty.csv', 'zwroty'),
    ('kary.csv', 'kary'),
    ('komentarze.csv', 'komentarze'),
    ('rezerwacje.csv', 'rezerwacje'),
    ('wejscia_wyjscia.csv', 'wejscia_wyjscia')
]

def create_database():
    """Tworzy bazę danych z kodowaniem UTF8."""
    print(f"--- Łączenie z Postgres w celu utworzenia bazy '{DB_NAME}' ---")
    try:
        # Łączymy się do domyślnej bazy 'postgres', aby utworzyć nową
        conn = psycopg2.connect(
            host=DB_HOST, port=DB_PORT, user=DB_USER, password=DB_PASSWORD, dbname="postgres"
        )
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        conn.set_client_encoding('UTF8')
        cursor = conn.cursor()

        # Sprawdź czy baza istnieje i usuń ją (opcjonalne, dla czystego startu)
        cursor.execute(f"DROP DATABASE IF EXISTS {DB_NAME}")
        print(f"Usunięto starą bazę '{DB_NAME}' (jeśli istniała).")

        # Utwórz bazę z kodowaniem UTF8
        cursor.execute(f"CREATE DATABASE {DB_NAME} WITH ENCODING 'UTF8'")
        print(f"Utworzono bazę danych '{DB_NAME}' z kodowaniem UTF8.")

        cursor.close()
        conn.close()
    except Exception as e:
        print(f"Błąd podczas tworzenia bazy danych: {e}")
        sys.exit(1)

def create_schema_and_import():
    """Tworzy tabele i importuje dane."""
    print(f"\n--- Łączenie z nową bazą '{DB_NAME}' ---")
    try:
        conn = psycopg2.connect(
            host=DB_HOST, port=DB_PORT, user=DB_USER, password=DB_PASSWORD, dbname=DB_NAME
        )
        # Ustawienie kodowania klienta na UTF8
        conn.set_client_encoding('UTF8')
        cursor = conn.cursor()

        # 1. Tworzenie tabel
        print("Tworzenie struktury tabel...")
        cursor.execute(SQL_SCHEMA)
        conn.commit()
        print("Tabele zostały utworzone.")

        # 2. Import danych
        print("\nRozpoczynanie importu danych z plików CSV...")
        
        for filename, tablename in FILES_TO_IMPORT:
            file_path = os.path.join(DATA_DIR, filename)
            
            if not os.path.exists(file_path):
                print(f"BŁĄD: Plik {file_path} nie istnieje. Pomijam tabelę {tablename}.")
                continue

            print(f"Importowanie: {filename} -> tabela '{tablename}'...")
            
            # Otwieramy plik z wymuszonym kodowaniem UTF-8
            with open(file_path, 'r', encoding='utf-8') as f:
                # Używamy copy_expert dla maksymalnej wydajności i bezpieczeństwa typów
                # HEADER oznacza, że pierwsza linia pliku csv to nagłówki
                sql = f"COPY {tablename} FROM STDIN WITH CSV HEADER DELIMITER ','"
                cursor.copy_expert(sql, f)
            
            print(f"  -> Sukces.")

        # 3. Aktualizacja sekwencji (SERIAL)
        # Ponieważ importujemy dane z ID, sekwencje w Postgresie nie aktualizują się same.
        # Trzeba je ustawić na max(id), żeby kolejne INSERTY nie powodowały błędu 'duplicate key'.
        print("\nAktualizacja sekwencji (auto-increment)...")
        sequences = [
            ('filie', 'id_filii'),
            ('kategorie', 'id_kategorii'),
            ('rodzaje_kar', 'id_rodzaju_kary'),
            ('uzytkownicy', 'id_osoby'),
            ('ksiazki', 'id_ksiazki'),
            ('wypozyczenia', 'id_wypozyczenia'),
            ('kary', 'id_kary'),
            ('komentarze', 'id_komentarza'),
            ('rezerwacje', 'id_rezerwacji'),
            ('wejscia_wyjscia', 'id_wejscia')
        ]
        
        for table, id_col in sequences:
            # Ustawia sekwencję na MAX(id) + 1
            seq_name = f"{table}_{id_col}_seq"
            sql_seq = f"SELECT setval(pg_get_serial_sequence('{table}', '{id_col}'), COALESCE(MAX({id_col}), 1)) FROM {table};"
            cursor.execute(sql_seq)
        
        conn.commit()
        print("Sekwencje zaktualizowane.")

        cursor.close()
        conn.close()
        print("\n--- ZAKOŃCZONO SUKCESEM ---")

    except Exception as e:
        print(f"Błąd podczas operacji na bazie: {e}")
        if conn:
            conn.rollback()

if __name__ == "__main__":
    # 1. Utwórz bazę
    create_database()
    # 2. Utwórz tabele i zaimportuj dane
    create_schema_and_import()