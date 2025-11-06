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
*(Tutaj możesz wstawić zaktualizowany diagram swojej bazy danych, jeśli go posiadasz)*

---
Ten projekt jest gotowy do integracji z aplikacją webową lub desktopową, zapewniając solidny backend dla nowoczesnego systemu bibliotecznego.
