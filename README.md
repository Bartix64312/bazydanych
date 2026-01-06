# System Zarządzania Biblioteką

Projekt bazy danych do zarządzania nowoczesną biblioteką, zaimplementowany w PostgreSQL. Baza danych została rozbudowana o szereg zaawansowanych funkcji, które przekształcają ją z prostego rejestru książek w kompleksowy system do obsługi czytelników, zasobów i operacji bibliotecznych.

## Kluczowe Funkcjonalności

### 1. Rozbudowany System Kont Użytkowników
- **Pełna autentykacja:** Tabela `Uzytkownicy` została wzbogacona o pola niezbędne do logowania (`login`, `hash_hasla`, `sol_do_hasla`).
- **Odzyskiwanie hasła:** Dodano mechanizmy do odzyskiwania dostępu do konta (`pytanie_pomocnicze`, `hash_odpowiedzi`).
- **Profile użytkowników:** Możliwość przechowywania dodatkowych informacji, takich jak adres e-mail i zdjęcie profilowe (`url_profilowe`).
- **Zarządzanie kontem:** Flaga `aktywne` umożliwia administratorom tymczasowe lub stałe blokowanie kont.

### 2. Zaawansowane Zarządzanie Zasobami
- **Struktura wielooddziałowa:** Wprowadzono tabelę `Filie`, która pozwala na zarządzanie wieloma oddziałami biblioteki.
- **Kategoryzacja zbiorów:** Tabela `Kategorie` umożliwia przypisywanie książek do różnych gatunków i dziedzin.
- **Szczegółowe dane o egzemplarzach:** Tabela `ksiazki` została rozszerzona o pola takie jak `rok_wydania`, `numer_edycji`, `liczba_stron`, co pozwala na precyzyjne katalogowanie każdego fizycznego egzemplarza.
- **Obsługa e-booków:** Pole `dostepna_online` umożliwia oznaczanie zasobów cyfrowych.

### 3. Automatyzacja i Logika Biznesowa
- **Automatyczne śledzenie statusu:** Zaimplementowano **triggery bazodanowe** (`after_wypozyczenie_insert`, `after_zwrot_insert`), które automatycznie zmieniają status egzemplarza (`dostępny`, `wypożyczony`) w momencie wypożyczenia i zwrotu.
- **System rezerwacji:** Tabela `Rezerwacje` pozwala użytkownikom na zamawianie książek online i odbieranie ich w wybranej filii.
- **System kar:** Wprowadzono moduł do zarządzania karami, składający się z tabel `Rodzaje_kar` (słownik) i `Kary` (rejestr nałożonych opłat i blokad).

### 4. Funkcje Społecznościowe i Analityczne
- **Oceny i komentarze:** Tabela `Komentarze` umożliwia czytelnikom ocenianie i recenzowanie książek, budując społeczność wokół biblioteki.
- **Monitorowanie frekwencji:** Tabela `Wejscia` rejestruje każdą wizytę użytkownika w filii (np. po zeskanowaniu karty bibliotecznej), co pozwala na zbieranie danych analitycznych.

### 5. Integralność i Bezpieczeństwo Danych
- **Relacje i klucze obce:** Zdefiniowano klucze obce, aby zapewnić spójność i integralność danych w całej bazie.
- **Ograniczenia (`Constraints`):** Zastosowano ograniczenia `NOT NULL` i `UNIQUE`, aby zapobiec wprowadzaniu niekompletnych lub zduplikowanych danych.

## Schemat Bazy Danych

<img width="1377" height="1366" alt="schematbazdanych" src="[https://github.com/user-attachments/assets/343d7e80-afa4-4897-b47b-fc3ff2d8f0e1](https://github.com/Bartix64312/bazydanych/blob/main/schemat.png)" />


## 1. Funkcje Składowane (Functions)
Funkcje te są wymagane do działania triggerów oraz sprawdzania dostępności książek.
W bazie zdefiniowano 4 funkcje. Jedna jest funkcją logiczną (sprawdzającą dostępność), a trzy pozostałe to funkcje wyzwalaczy (trigger functions).
```sql

--Procedura

CREATE OR REPLACE PROCEDURE public.zablokuj_dluznikow(p_dni_zwloki INT DEFAULT 30)
LANGUAGE plpgsql
AS $$
DECLARE
    v_liczba INT;
BEGIN
    WITH zablokowani AS (
        UPDATE uzytkownicy u
        SET aktywne = false
        FROM kary k
        WHERE u.id_osoby = k.id_osoby
          AND k.data_oplacenia IS NULL
          AND k.data_nalozenia < (CURRENT_DATE - p_dni_zwloki)
          AND u.aktywne = true
        RETURNING u.id_osoby
    )
    SELECT count(*) INTO v_liczba FROM zablokowani;

    RAISE NOTICE 'Zablokowano osob: %', v_liczba;
END;
$$;
CREATE OR REPLACE FUNCTION public.ile_dostepnych_egzemplarzy(p_isbn character varying)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_ilosc integer;
BEGIN
    SELECT COUNT(*) INTO v_ilosc
    FROM ksiazki
    WHERE nr_isbn = p_isbn 
    AND LOWER(TRIM(status)) = 'dostępny' limit 1;

    RETURN v_ilosc;
END;
$$;
-- Funkcja sprawdzenia ile użytkownik ma kary:
CREATE OR REPLACE FUNCTION public.oblicz_szacowana_kare(p_id_wypozyczenia INT)
RETURNS numeric(10, 2)
LANGUAGE plpgsql
AS $$
DECLARE
    v_planowana DATE;
    v_faktyczna DATE;
    v_koniec DATE;
    v_dni_spoznienia INT;
    v_stawka numeric(10, 2) := 0.50; -- Stawka za dzień zwłoki
BEGIN
    -- Pobierz daty
    SELECT w.planowana_data_zwrotu, z.data_zwrotu
    INTO v_planowana, v_faktyczna
    FROM wypozyczenia w
    LEFT JOIN zwroty z ON w.id_wypozyczenia = z.id_wypozyczenia
    WHERE w.id_wypozyczenia = p_id_wypozyczenia;

    -- Jeśli nie ma takiego wypożyczenia
    IF NOT FOUND THEN
        RETURN 0.00;
    END IF;

    -- Ustal datę końcową (zwrot lub dzisiaj)
    IF v_faktyczna IS NOT NULL THEN
        v_koniec := v_faktyczna;
    ELSE
        v_koniec := CURRENT_DATE;
    END IF;

    -- Oblicz różnicę
    v_dni_spoznienia := v_koniec - v_planowana;

    -- Jeśli oddano przed czasem, kara to 0
    IF v_dni_spoznienia <= 0 THEN
        RETURN 0.00;
    ELSE
        RETURN v_dni_spoznienia * v_stawka;
    END IF;
END;
$$;

-- Funkcja triggera: Aktualizacja statusu książki po wypożyczeniu
CREATE OR REPLACE FUNCTION public.fn_after_wypozyczenie_insert() 
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE ksiazki SET status = 'wypożyczony' WHERE id_ksiazki = NEW.id_ksiazki;
    RETURN NEW;
END;
$$;

-- Funkcja triggera: Aktualizacja statusu książki po zwrocie
CREATE OR REPLACE FUNCTION public.fn_after_zwrot_insert() 
RETURNS trigger
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

-- Funkcja triggera: Walidacja daty zwrotu
CREATE OR REPLACE FUNCTION public.sprawdz_date_zwrotu() 
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_data_wypozyczenia DATE;
BEGIN
    SELECT data_wypozyczenia INTO v_data_wypozyczenia
    FROM wypozyczenia
    WHERE id_wypozyczenia = NEW.id_wypozyczenia;

    IF NEW.data_zwrotu < v_data_wypozyczenia THEN
        RAISE EXCEPTION 'Błąd: Data zwrotu (%) nie może być wcześniejsza niż data wypożyczenia (%)', NEW.data_zwrotu, v_data_wypozyczenia;
    END IF;

    RETURN NEW;
END;
$$;




```
## 2.Wyzwalacze (Triggers)
Automatyzują zmianę statusów książek i dbają o spójność dat.
```sql
-- 1. Trigger walidujący datę zwrotu (podpięty pod tabelę 'zwroty')
CREATE TRIGGER trg_walidacja_daty_zwrotu 
BEFORE INSERT OR UPDATE ON public.zwroty 
FOR EACH ROW EXECUTE FUNCTION public.sprawdz_date_zwrotu();

-- 2. Trigger aktualizujący status książki po wypożyczeniu (podpięty pod 'wypozyczenia')
CREATE TRIGGER trg_after_wypozyczenie 
AFTER INSERT ON public.wypozyczenia 
FOR EACH ROW EXECUTE FUNCTION public.fn_after_wypozyczenie_insert();

-- 3. Trigger aktualizujący status książki po zwrocie (podpięty pod 'zwroty')
CREATE TRIGGER trg_after_zwrot 
AFTER INSERT ON public.zwroty 
FOR EACH ROW EXECUTE FUNCTION public.fn_after_zwrot_insert();

-- 4.Limit wypożyczeń 5 ksiązek
CREATE OR REPLACE FUNCTION public.sprawdz_limit_wypozyczen()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_liczba_aktywnych INT;
    v_limit INT := 5; 
BEGIN
    -- Liczenie w jednej linii (bezpieczne)
    SELECT COUNT(*) INTO v_liczba_aktywnych FROM public.wypozyczenia LEFT JOIN public.zwroty ON public.wypozyczenia.id_wypozyczenia = public.zwroty.id_wypozyczenia WHERE public.wypozyczenia.id_osoby = NEW.id_osoby AND public.zwroty.data_zwrotu IS NULL;

    IF v_liczba_aktywnych >= v_limit THEN
        RAISE EXCEPTION 'LIMIT ERROR: Max 5 books per user reached.';
    END IF;

    RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_limit_wypozyczen ON public.wypozyczenia;

CREATE TRIGGER trg_limit_wypozyczen
BEFORE INSERT ON public.wypozyczenia
FOR EACH ROW EXECUTE FUNCTION public.sprawdz_limit_wypozyczen();
```
## 3.Widoki
Wdrożono dwa widoki ułatwiające raportowanie:
```sql

--1. Widok Dłużników (osoby, które nie oddały książek w terminie)
CREATE OR REPLACE VIEW public.view_dluznicy AS
 SELECT u.imie,
    u.nazwisko,
    u.email,
    k.tytul,
    w.planowana_data_zwrotu,
    (CURRENT_DATE - w.planowana_data_zwrotu) AS dni_spoznienia
   FROM (((public.wypozyczenia w
     JOIN public.uzytkownicy u ON ((w.id_osoby = u.id_osoby)))
     JOIN public.ksiazki k ON ((w.id_ksiazki = k.id_ksiazki)))
     LEFT JOIN public.zwroty z ON ((w.id_wypozyczenia = z.id_wypozyczenia)))
  WHERE ((z.data_zwrotu IS NULL) AND (w.planowana_data_zwrotu < CURRENT_DATE));

-- 2. Widok Top Książki (najczęściej wypożyczane pozycje)
CREATE OR REPLACE VIEW public.view_top_ksiazki AS
 SELECT k.tytul,
    kat.nazwa_kategorii,
    count(w.id_wypozyczenia) AS ilosc_wypozyczen
   FROM ((public.ksiazki k
     JOIN public.kategorie kat ON ((k.id_kategorii = kat.id_kategorii)))
     JOIN public.wypozyczenia w ON ((k.id_ksiazki = w.id_ksiazki)))
  GROUP BY k.tytul, kat.nazwa_kategorii
  ORDER BY (count(w.id_wypozyczenia)) DESC;
```
## 4.Elementy Zabezpieczające (Constraints / CHECK)
Baza posiada wbudowane w tabele reguły (Constraints), które dbają o jakość danych. 
```sql
-- 1. Ograniczenie oceny w komentarzach (musi być między 1 a 10)
ALTER TABLE public.komentarze
    ADD CONSTRAINT komentarze_ocena_check CHECK (((ocena >= 1) AND (ocena <= 10)));

-- 2. Ograniczenie płci użytkownika (enum w formie checka)
ALTER TABLE public.uzytkownicy
    ADD CONSTRAINT osoby_plec_check CHECK (((plec)::text = ANY (ARRAY[('MEZCZYZNA'::character varying)::text, ('KOBIETA'::character varying)::text, ('NIEOKRESLONY'::character varying)::text])));

-- 3. Logika daty w wypożyczeniach (planowany zwrot nie może być przed wypożyczeniem)
ALTER TABLE public.wypozyczenia
    ADD CONSTRAINT check_planowana_data CHECK ((planowana_data_zwrotu >= data_wypozyczenia));

-- 4. Unikalne loginy i emaile
ALTER TABLE public.uzytkownicy ADD CONSTRAINT uq_email UNIQUE (email);
ALTER TABLE public.uzytkownicy ADD CONSTRAINT uq_login UNIQUE (login);

-- 5. Unikalność fizycznego egzemplarza książki (ISBN + numer inwentarzowy)
ALTER TABLE public.ksiazki ADD CONSTRAINT unikalny_egzemplarz UNIQUE (nr_isbn, numer_inwentarzowy);
```
## 5.Uprawnienia (Granty)
```sql
-- Nadanie uprawnień dla roli 'bibliotekarz' (pełny dostęp do kluczowych tabel)
GRANT ALL ON TABLE public.filie TO bibliotekarz;
GRANT ALL ON TABLE public.kary TO bibliotekarz;
GRANT ALL ON TABLE public.kategorie TO bibliotekarz;
GRANT ALL ON TABLE public.komentarze TO bibliotekarz;
GRANT ALL ON TABLE public.ksiazki TO bibliotekarz;
GRANT ALL ON TABLE public.rezerwacje TO bibliotekarz;
GRANT ALL ON TABLE public.rodzaje_kar TO bibliotekarz;
GRANT ALL ON TABLE public.uzytkownicy TO bibliotekarz;
GRANT ALL ON TABLE public.wypozyczenia TO bibliotekarz;
GRANT ALL ON TABLE public.zwroty TO bibliotekarz;
GRANT ALL ON TABLE public.view_dluznicy TO bibliotekarz;
GRANT ALL ON TABLE public.view_top_ksiazki TO bibliotekarz;
GRANT ALL ON TABLE public.wejscia_wyjscia TO bibliotekarz;
-- Sekwencje
GRANT ALL ON SEQUENCE public.filie_id_filii_seq TO bibliotekarz;
GRANT ALL ON SEQUENCE public.kary_id_kary_seq TO bibliotekarz;
GRANT ALL ON SEQUENCE public.kategorie_id_kategorii_seq TO bibliotekarz;
GRANT ALL ON SEQUENCE public.komentarze_id_komentarza_seq TO bibliotekarz;
GRANT ALL ON SEQUENCE public.rezerwacje_id_rezerwacji_seq TO bibliotekarz;
GRANT ALL ON SEQUENCE public.rodzaje_kar_id_rodzaju_kary_seq TO bibliotekarz;
grant all on sequence public.wejscia_wyjscia_id_wejscia_seq to bibliotekarz;

-- Nadanie uprawnień dla roli 'gosc_biblioteki' (tylko odczyt katalogów)
GRANT SELECT ON TABLE public.filie TO gosc_biblioteki;
GRANT SELECT ON TABLE public.kategorie TO gosc_biblioteki;
GRANT SELECT ON TABLE public.ksiazki TO gosc_biblioteki;
```






