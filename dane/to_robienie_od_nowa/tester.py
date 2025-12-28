import unittest
import psycopg2
import sys

# --- KONFIGURACJA ---
DB_NAME = "biblioteka_zrobiona_od_nowa"
DB_USER = "postgres"
DB_PASSWORD = "haslo"  # Zmień na swoje
DB_HOST = "localhost"

class TestBibliotekaDB(unittest.TestCase):
    
    @classmethod
    def setUpClass(cls):
        """Uruchamiane raz przed wszystkimi testami. Nawiązuje połączenie."""
        try:
            cls.conn = psycopg2.connect(
                dbname=DB_NAME,
                user=DB_USER,
                password=DB_PASSWORD,
                host=DB_HOST
            )
            cls.conn.set_client_encoding('UTF8') # Wymuszenie UTF-8 po stronie klienta
            cls.cursor = cls.conn.cursor()
            print(f"\n[INFO] Połączono z bazą '{DB_NAME}' pomyślnie.")
        except Exception as e:
            print(f"\n[CRITICAL] Nie można połączyć się z bazą danych: {e}")
            sys.exit(1)

    @classmethod
    def tearDownClass(cls):
        """Zamyka połączenie po zakończeniu testów."""
        if cls.conn:
            cls.cursor.close()
            cls.conn.close()
            print("\n[INFO] Połączenie z bazą zamknięte.")

    def setUp(self):
        """Przed każdym testem cofamy transakcję, żeby testy były niezależne."""
        self.conn.rollback()

    def test_01_konfiguracja_kodowania_bazy(self):
        """Sprawdza czy baza danych jest fizycznie zakodowana w UTF8."""
        print("\n--- Test 1: Weryfikacja kodowania bazy danych ---")
        
        self.cursor.execute(
            "SELECT pg_encoding_to_char(encoding) FROM pg_database WHERE datname = %s", 
            (DB_NAME,)
        )
        kodowanie = self.cursor.fetchone()[0]
        
        print(f"Baza '{DB_NAME}' ma kodowanie: {kodowanie}")
        self.assertEqual(kodowanie, 'UTF8', "Błąd: Baza danych nie jest w UTF8!")

    def test_02_ilosc_rekordow(self):
        """Sprawdza czy wszystkie tabele mają więcej niż 0 rekordów."""
        print("\n--- Test 2: Sprawdzanie czy tabele nie są puste ---")
        
        tabele = [
            'filie', 'kategorie', 'rodzaje_kar', 'uzytkownicy', 
            'ksiazki', 'wypozyczenia', 'zwroty', 'kary', 
            'komentarze', 'rezerwacje', 'wejscia_wyjscia'
        ]
        
        for tabela in tabele:
            self.cursor.execute(f"SELECT COUNT(*) FROM {tabela}")
            count = self.cursor.fetchone()[0]
            print(f"Tabela '{tabela:.<20}' rekordów: {count}")
            self.assertGreater(count, 0, f"Błąd: Tabela {tabela} jest pusta!")

    def test_03_test_polskich_znakow_insert_select(self):
        """
        Wstawia tymczasowo rekord z trudnymi polskimi znakami i odczytuje go.
        Weryfikuje czy 'krzaczki' nie powstają na styku Python <-> Postgres.
        """
        print("\n--- Test 3: Test 'Zażółć gęślą jaźń' (Kodowanie znaków) ---")
        
        test_string = "Zażółć gęślą jaźń - TEST KODOWANIA"
        
        # Wstawiamy nową kategorię testową (transakcja zostanie wycofana w setUp/tearDown)
        try:
            self.cursor.execute(
                "INSERT INTO kategorie (nazwa_kategorii) VALUES (%s) RETURNING nazwa_kategorii",
                (test_string,)
            )
            wynik = self.cursor.fetchone()[0]
            
            print(f"Wysłano do bazy: '{test_string}'")
            print(f"Odebrano z bazy: '{wynik}'")
            
            self.assertEqual(wynik, test_string, "Błąd kodowania! Odebrany tekst różni się od wysłanego.")
        except psycopg2.IntegrityError:
            self.fail("Nie udało się wstawić testowego rekordu (być może constraint unique?)")

    def test_04_spojnosc_danych_i_klucze_obce(self):
        """
        Sprawdza czy można wykonać JOIN między tabelami. 
        Jeśli klucze obce są zepsute lub typy danych złe, to się wywali.
        """
        print("\n--- Test 4: Test relacji (JOIN Książki + Kategorie + Filie) ---")
        
        sql = """
        SELECT k.tytul, kat.nazwa_kategorii, f.nazwa_filii
        FROM ksiazki k
        JOIN kategorie kat ON k.id_kategorii = kat.id_kategorii
        JOIN filie f ON k.id_filii = f.id_filii
        LIMIT 5
        """
        try:
            self.cursor.execute(sql)
            rows = self.cursor.fetchall()
            self.assertGreater(len(rows), 0, "Błąd: Zapytanie JOIN zwróciło 0 wyników.")
            print("Przykładowe połączone dane:")
            for row in rows:
                print(f" - {row}")
        except Exception as e:
            self.fail(f"Błąd zapytania SQL (problem ze strukturą?): {e}")

    def test_05_ograniczenia_bazy_constraint(self):
        """
        Sprawdza czy baza pilnuje dozwolonych wartości (np. Płeć).
        Próba wstawienia błędnej wartości powinna rzucić błąd.
        """
        print("\n--- Test 5: Test Integrity Constraints (Płeć) ---")
        
        sql = """
        INSERT INTO uzytkownicy (imie, nazwisko, plec, login, email, hash_hasla, sol_do_hasla)
        VALUES ('Test', 'User', 'KOSMITA', 'test.alien', 'alien@test.pl', 'hash', 'salt')
        """
        try:
            self.cursor.execute(sql)
            # Jeśli przeszło, to źle! Baza powinna to odrzucić.
            self.fail("Błąd: Baza pozwoliła wstawić płeć 'KOSMITA', mimo CHECK constraint!")
        except psycopg2.errors.CheckViolation:
            print("Sukces: Baza poprawnie odrzuciła niedozwoloną wartość 'KOSMITA'.")
            self.conn.rollback() # Musimy wycofać błędną transakcję
        except Exception as e:
            self.fail(f"Oczekiwano błędu CheckViolation, ale otrzymano inny: {type(e).__name__}")

    def test_06_logika_biznesowa_daty(self):
        """Sprawdza, czy nie ma anomalii czasowych (np. Wyjście przed Wejściem)."""
        print("\n--- Test 6: Weryfikacja logiki dat (Wejście vs Wyjście) ---")
        
        # Sprawdź czy istnieją rekordy gdzie data_wyjscia < data_wejscia
        sql = "SELECT count(*) FROM wejscia_wyjscia WHERE data_wyjscia < data_wejscia"
        self.cursor.execute(sql)
        bledne_rekordy = self.cursor.fetchone()[0]
        
        if bledne_rekordy > 0:
            print(f"Znaleziono {bledne_rekordy} błędnych rekordów czasu!")
        
        self.assertEqual(bledne_rekordy, 0, "Błąd: Istnieją rekordy, gdzie data wyjścia jest wcześniejsza niż wejścia!")
        print("Wszystkie daty wejść i wyjść są logicznie poprawne.")

    def test_07_czy_istnieja_polskie_znaki_w_danych(self):
        """
        Skanuje tabelę imion, aby upewnić się, że Faker wygenerował polskie znaki
        i że baza poprawnie je zwraca.
        """
        print("\n--- Test 7: Skanowanie istniejących danych pod kątem polskich znaków ---")
        
        # Szukamy imion zawierających znaki spoza ASCII
        sql = "SELECT imie FROM uzytkownicy WHERE imie ~ '[^a-zA-Z]' LIMIT 5"
        self.cursor.execute(sql)
        imiona = self.cursor.fetchall()
        
        print("Znalezione przykładowe imiona z polskimi znakami:")
        found_polish_char = False
        for (imie,) in imiona:
            print(f" - {imie}")
            # Sprawdzenie czy string zawiera polskie znaki
            if any(char in "ąęćłńóśźżĄĘĆŁŃÓŚŹŻ" for char in imie):
                found_polish_char = True
        
        if not found_polish_char:
            print("[OSTRZEŻENIE] Nie znaleziono w próbce typowych polskich znaków. "
                  "Może to być przypadek losowy Fakera, ale warto sprawdzić.")
        else:
            print("Potwierdzono obecność polskich znaków w bazie.")

if __name__ == '__main__':
    # Uruchomienie testów z verbosity=2 (szczegółowy output)
    unittest.main(verbosity=2)