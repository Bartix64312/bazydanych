import csv
import random
from faker import Faker
from datetime import datetime, timedelta
import hashlib
import os

# Konfiguracja generatora
fake = Faker('pl_PL')
Faker.seed(42)  # Dla powtarzalności wyników
random.seed(42)

# Konfiguracja ilości danych
NUM_FILII = 5
NUM_KATEGORII = 15
NUM_RODZAJE_KAR = 4
NUM_UZYTKOWNIKOW = 200
NUM_KSIAZEK_TYTULOW = 300  # Różne tytuły (ISBN)
NUM_EGZEMPLARZY = 1000     # Fizyczne książki
NUM_WYPOZYCZEN = 2000      # Historia wypożyczeń
NUM_WEJSC = 500
NUM_REZERWACJI = 100
NUM_KOMENTARZY = 300

# Folder na pliki
OUTPUT_DIR = 'biblioteka_csv'
if not os.path.exists(OUTPUT_DIR):
    os.makedirs(OUTPUT_DIR)

def save_csv(filename, fieldnames, data):
    path = os.path.join(OUTPUT_DIR, filename)
    with open(path, mode='w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, delimiter=',')
        writer.writeheader()
        writer.writerows(data)
    print(f"Wygenerowano: {path} ({len(data)} rekordów)")

# --- 1. Słowniki i dane niezależne ---

# Filie
filie = []
for i in range(1, NUM_FILII + 1):
    filie.append({
        'id_filii': i,
        'adres': fake.address().replace('\n', ', '),
        'nazwa_filii': f"Filia nr {i} - {fake.city_suffix()}",
        'glowny_bibliotekarz': fake.name()
    })
save_csv('filie.csv', filie[0].keys(), filie)

# Kategorie
kategorie_nazwy = ['Powieść', 'Kryminał', 'Fantastyka', 'Nauka', 'Biografia', 'Historia', 
                   'Dla dzieci', 'Horror', 'Romans', 'Podróże', 'Kulinaria', 'Informatyka', 
                   'Psychologia', 'Sztuka', 'Reportaż']
kategorie = []
for i, nazwa in enumerate(kategorie_nazwy, 1):
    kategorie.append({
        'id_kategorii': i,
        'nazwa_kategorii': nazwa
    })
save_csv('kategorie.csv', kategorie[0].keys(), kategorie)

# Rodzaje kar
rodzaje_kar_dane = [
    (1, 'Przetrzymanie', 'Kara za zwrot po terminie'),
    (2, 'Zgubienie', 'Kara za zgubienie egzemplarza'),
    (3, 'Zniszczenie', 'Kara za znaczne uszkodzenie książki'),
    (4, 'Brak kodu', 'Uszkodzenie kodu kreskowego/inwentarzowego')
]
rodzaje_kar = [{'id_rodzaju_kary': i, 'nazwa_kary': n, 'opis': o} for i, n, o in rodzaje_kar_dane]
save_csv('rodzaje_kar.csv', rodzaje_kar[0].keys(), rodzaje_kar)

# --- 2. Użytkownicy ---

uzytkownicy = []
plec_opts = ['MEZCZYZNA', 'KOBIETA', 'NIEOKRESLONY']

for i in range(1, NUM_UZYTKOWNIKOW + 1):
    plec = random.choice(plec_opts)
    if plec == 'MEZCZYZNA':
        imie = fake.first_name_male()
        nazwisko = fake.last_name_male()
    elif plec == 'KOBIETA':
        imie = fake.first_name_female()
        nazwisko = fake.last_name_female()
    else:
        imie = fake.first_name()
        nazwisko = fake.last_name()

    login = f"{imie[:3].lower()}{nazwisko[:3].lower()}{random.randint(10,99)}"
    # Unikalność loginu prosta
    login = f"{login}_{i}" 
    
    salt = fake.uuid4()
    haslo_raw = "haslo123"
    hash_hasla = hashlib.sha256((haslo_raw + salt).encode()).hexdigest()

    uzytkownicy.append({
        'id_osoby': i,
        'imie': imie,
        'nazwisko': nazwisko,
        'plec': plec,
        'login': login,
        'email': fake.email(),
        'hash_hasla': hash_hasla,
        'sol_do_hasla': salt,
        'pytanie_pomocnicze': fake.sentence(),
        'hash_odpowiedzi': fake.sha1(),
        'url_profilowe': fake.image_url(),
        'data_zalozenia_konta': fake.date_time_between(start_date='-5y', end_date='now'),
        'aktywne': random.choice([True, True, True, False]) # Większość aktywna
    })
save_csv('uzytkownicy.csv', uzytkownicy[0].keys(), uzytkownicy)

# --- 3. Książki (Master Data + Egzemplarze) ---

# Generowanie "tytułów" (abstrakcyjna książka)
tytuly_master = []
for _ in range(NUM_KSIAZEK_TYTULOW):
    tytuly_master.append({
        'isbn': fake.isbn13(),
        'tytul': fake.sentence(nb_words=4).rstrip('.'),
        'autor': fake.name(),
        'id_kategorii': random.randint(1, len(kategorie)),
        'rok': fake.year(),
        'strony': random.randint(100, 900)
    })

ksiazki = []
# Śledzenie statusu książki (czy jest obecnie wypożyczona) dla logiki wypożyczeń
ksiazka_dostepnosc = {} # id_ksiazki -> bool (True = dostępna)

for i in range(1, NUM_EGZEMPLARZY + 1):
    master = random.choice(tytuly_master)
    ksiazki.append({
        'id_ksiazki': i,
        'nr_isbn': master['isbn'],
        'numer_inwentarzowy': random.randint(100000, 999999), # Uproszczenie
        'tytul': master['tytul'],
        'autor': master['autor'],
        'id_kategorii': master['id_kategorii'],
        'id_filii': random.randint(1, NUM_FILII),
        'rok_wydania': master['rok'],
        'numer_edycji': f"Edycja {random.randint(1,5)}",
        'liczba_stron': master['strony'],
        'dostepna_online': random.choice([True, False]),
        'opis': fake.text(max_nb_chars=100).replace('\n', ' '),
        'status': 'dostępny' # Domyślnie, zaktualizujemy po wygenerowaniu wypożyczeń
    })
    ksiazka_dostepnosc[i] = True

# --- 4. Wypożyczenia i Zwroty (Logika chronologiczna) ---

wypozyczenia = []
zwroty = []
kary = []
kary_id_counter = 1

# Symulacja czasu - od 2 lat temu do dziś
start_date = datetime.now() - timedelta(days=730)
end_date = datetime.now()

current_wypozyczenie_id = 1

# Sortujemy książki losowo, żeby rozrzucić historię
ksiazki_ids = list(ksiazka_dostepnosc.keys())

for _ in range(NUM_WYPOZYCZEN):
    id_ksiazki = random.choice(ksiazki_ids)
    id_osoby = random.randint(1, NUM_UZYTKOWNIKOW)
    
    # Losowa data wypożyczenia w przeszłości
    data_wyp = fake.date_time_between(start_date='-2y', end_date='now')
    # Planowany zwrot za 30 dni
    planowany_zwrot = data_wyp + timedelta(days=30)
    
    wypozyczenia.append({
        'id_wypozyczenia': current_wypozyczenie_id,
        'id_osoby': id_osoby,
        'id_ksiazki': id_ksiazki,
        'data_wypozyczenia': data_wyp.date(),
        'planowana_data_zwrotu': planowany_zwrot.date()
    })
    
    # Decyzja czy książka została zwrócona
    # 90% szans że zwrócona, chyba że data wypożyczenia jest bardzo świeża (ostatnie 30 dni)
    czy_zwrocona = True
    if (end_date - data_wyp).days < 30:
        czy_zwrocona = random.choice([True, False]) # 50/50 dla nowych
    else:
        czy_zwrocona = random.choices([True, False], weights=[95, 5])[0] # Stare zazwyczaj zwrócone

    if czy_zwrocona:
        # Data zwrotu: może być przed terminem, w terminie lub po
        delta = random.randint(-10, 45) # od 10 dni przed do 15 dni po terminie
        data_zwrotu = planowany_zwrot + timedelta(days=delta)
        
        # Korekta: data zwrotu nie może być z przyszłości
        if data_zwrotu > end_date:
            data_zwrotu = end_date
        
        # Korekta: data zwrotu musi być po wypożyczeniu
        if data_zwrotu <= data_wyp:
            data_zwrotu = data_wyp + timedelta(days=1)

        zwroty.append({
            'id_wypozyczenia': current_wypozyczenie_id,
            'data_zwrotu': data_zwrotu.date()
        })
        
        # Książka jest znów dostępna
        ksiazka_dostepnosc[id_ksiazki] = True
        
        # Generowanie kary za spóźnienie
        if data_zwrotu > planowany_zwrot:
            dni_spoznienia = (data_zwrotu - planowany_zwrot).days
            kwota = dni_spoznienia * 0.50 # 50 groszy za dzień
            if kwota > 0:
                kary.append({
                    'id_kary': kary_id_counter,
                    'id_osoby': id_osoby,
                    'id_rodzaju_kary': 1, # Przetrzymanie
                    'id_wypozyczenia': current_wypozyczenie_id,
                    'kwota': round(kwota, 2),
                    'data_nalozenia': data_zwrotu.date(),
                    'data_oplacenia': random.choice([None, (data_zwrotu + timedelta(days=2)).date()]),
                    'status': random.choice(['aktywna', 'opłacona'])
                })
                kary_id_counter += 1
    else:
        # Książka nie została zwrócona - aktualizujemy status w tabeli książki
        # Wypożyczenie musi być "ostatnie" dla tej książki, żeby status był wypożyczony
        # W tym uproszczonym generatorze nadpiszemy status na "wypożyczony"
        # jeśli pętla trafiła na tę książkę jako ostatnią akcję.
        # Dla 100% poprawności należałoby grupować wypożyczenia per książka i sortować chronologicznie.
        # Tutaj przyjmiemy uproszczenie: jeśli wylosowaliśmy "niezwrócona", oznaczamy jako niedostępna.
        ksiazka_dostepnosc[id_ksiazki] = False

    current_wypozyczenie_id += 1

# Aktualizacja statusów książek na podstawie symulacji
for k in ksiazki:
    if not ksiazka_dostepnosc[k['id_ksiazki']]:
        k['status'] = 'wypożyczony'

save_csv('ksiazki.csv', ksiazki[0].keys(), ksiazki)
save_csv('wypozyczenia.csv', wypozyczenia[0].keys(), wypozyczenia)
save_csv('zwroty.csv', zwroty[0].keys(), zwroty)
save_csv('kary.csv', kary[0].keys() if kary else [], kary)

# --- 5. Pozostałe tabele ---

# Rezerwacje
rezerwacje = []
for i in range(1, NUM_REZERWACJI + 1):
    data_rez = fake.date_time_between(start_date='-1m', end_date='now')
    rezerwacje.append({
        'id_rezerwacji': i,
        'nr_isbn': random.choice(tytuly_master)['isbn'], # Rezerwujemy tytuł (ISBN), nie konkretny egzemplarz ID
        'id_osoby': random.randint(1, NUM_UZYTKOWNIKOW),
        'id_filii': random.randint(1, NUM_FILII),
        'data_rezerwacji': data_rez,
        'status': random.choice(['oczekująca', 'zrealizowana', 'anulowana']),
        'wygasa_dnia': (data_rez + timedelta(days=7)).date()
    })
save_csv('rezerwacje.csv', rezerwacje[0].keys(), rezerwacje)

# Komentarze
komentarze = []
for i in range(1, NUM_KOMENTARZY + 1):
    komentarze.append({
        'id_komentarza': i,
        'nr_isbn': random.choice(tytuly_master)['isbn'],
        'id_osoby': random.randint(1, NUM_UZYTKOWNIKOW),
        'ocena': random.randint(1, 10),
        'tresc': fake.sentence(nb_words=10),
        'data_dodania': fake.date_time_between(start_date='-1y', end_date='now')
    })
save_csv('komentarze.csv', komentarze[0].keys(), komentarze)

# Wejścia
wejscia = []
for i in range(1, NUM_WEJSC + 1):
    wejscia.append({
        'id_wejscia': i,
        'id_osoby': random.randint(1, NUM_UZYTKOWNIKOW),
        'id_filii': random.randint(1, NUM_FILII),
        'data_wejscia': fake.date_time_between(start_date='-3m', end_date='now')
    })
save_csv('wejscia.csv', wejscia[0].keys(), wejscia)

print("\nZakończono generowanie wszystkich plików CSV.")