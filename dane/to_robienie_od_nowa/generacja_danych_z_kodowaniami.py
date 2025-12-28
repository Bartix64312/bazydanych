import csv
import random
import hashlib
import unicodedata
import os
from faker import Faker
from datetime import datetime, timedelta

# Konfiguracja
fake = Faker('pl_PL')
Faker.seed(123)  # Dla powtarzalności wyników
random.seed(123)

OUTPUT_DIR = 'dane_biblioteczne'
if not os.path.exists(OUTPUT_DIR):
    os.makedirs(OUTPUT_DIR)

# Liczba rekordów do wygenerowania
NUM_FILIE = 10
NUM_KATEGORIE = 10
NUM_UZYTKOWNICY = 1000
NUM_KSIAZKI = 3000  # Fizyczne egzemplarze
NUM_WYPOZYCZENIA = 5000
NUM_KOMENTARZE = 500
NUM_REZERWACJE = 300
NUM_WEJSCIA = 2000

# Funkcja pomocnicza do usuwania polskich znaków (do emaili i loginów)
def usun_polskie_znaki(text):
    text = text.lower()
    return ''.join(c for c in unicodedata.normalize('NFD', text)
                   if unicodedata.category(c) != 'Mn')

def zapisz_csv(filename, header, data):
    path = os.path.join(OUTPUT_DIR, filename)
    with open(path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(data)
    print(f"Wygenerowano: {filename} ({len(data)} rekordów)")

# --- 1. KATEGORIE ---
print("Generowanie kategorii...")
kategorie_lista = [
    "Fantastyka", "Kryminał", "Biografia", "Historyczna", 
    "Nauka", "Horror", "Romans", "Podróże", "Informatyka", "Poezja"
]
# Zapewnienie unikalności i odpowiedniej liczby
kategorie_data = []
for i, nazwa in enumerate(kategorie_lista, 1):
    kategorie_data.append([i, nazwa])

zapisz_csv('kategorie.csv', ['id_kategorii', 'nazwa_kategorii'], kategorie_data)

# --- 2. FILIE ---
print("Generowanie filii...")
filie_data = []
for i in range(1, NUM_FILIE + 1):
    adres = fake.address().replace('\n', ', ')
    nazwa = f"Filia Biblioteczna nr {i} - {fake.city()}"
    bibliotekarz = fake.name()
    filie_data.append([i, adres, nazwa, bibliotekarz])

zapisz_csv('filie.csv', ['id_filii', 'adres', 'nazwa_filii', 'glowny_bibliotekarz'], filie_data)

# --- 3. RODZAJE KAR ---
print("Generowanie rodzajów kar...")
rodzaje_kar_def = [
    (1, "Przetrzymanie", "Kara za zwrot książki po terminie"),
    (2, "Zniszczenie", "Kara za trwałe uszkodzenie książki"),
    (3, "Zgubienie", "Opłata za zgubiony egzemplarz")
]
zapisz_csv('rodzaje_kar.csv', ['id_rodzaju_kary', 'nazwa_kary', 'opis'], rodzaje_kar_def)

# --- 4. UŻYTKOWNICY ---
print("Generowanie użytkowników...")
uzytkownicy_data = []
loginy_set = set()
emaile_set = set()

for i in range(1, NUM_UZYTKOWNICY + 1):
    plec_raw = random.choice(['M', 'F'])
    if plec_raw == 'M':
        imie = fake.first_name_male()
        nazwisko = fake.last_name_male()
        plec = 'MEZCZYZNA'
    else:
        imie = fake.first_name_female()
        nazwisko = fake.last_name_female()
        plec = 'KOBIETA'
    
    imie_clean = usun_polskie_znaki(imie)
    nazwisko_clean = usun_polskie_znaki(nazwisko)
    
    # Generowanie unikalnego loginu i maila
    base_login = f"{imie_clean}.{nazwisko_clean}"
    login = base_login
    counter = 1
    while login in loginy_set:
        login = f"{base_login}{counter}"
        counter += 1
    loginy_set.add(login)
    
    email = f"{login}@{fake.free_email_domain()}"
    
    # Hashing
    haslo_raw = email # Zgodnie z poleceniem hashujemy maila jako hasło
    sol = fake.sha256()[:16]
    # Proste hashowanie sha256
    hash_hasla = hashlib.sha256(haslo_raw.encode('utf-8')).hexdigest()
    
    pytanie = fake.sentence()
    hash_odp = hashlib.sha256(fake.word().encode('utf-8')).hexdigest()
    url = fake.image_url()
    data_zal = fake.date_time_between(start_date='-5y', end_date='now')
    aktywne = True

    uzytkownicy_data.append([
        i, imie, nazwisko, plec, login, email, 
        hash_hasla, sol, pytanie, hash_odp, url, data_zal, aktywne
    ])

zapisz_csv('uzytkownicy.csv', [
    'id_osoby', 'imie', 'nazwisko', 'plec', 'login', 'email', 
    'hash_hasla', 'sol_do_hasla', 'pytanie_pomocnicze', 'hash_odpowiedzi', 
    'url_profilowe', 'data_zalozenia_konta', 'aktywne'
], uzytkownicy_data)

# --- 5. KSIĄŻKI ---
print("Generowanie książek...")
ksiazki_data = []
# Generujemy pulę "Dzieł" (ISBN + Tytuł + Autor), żeby różne egzemplarze miały te same dane
pula_dziel = []
for _ in range(50): # 50 unikalnych tytułów
    pula_dziel.append({
        'isbn': fake.isbn13().replace("-", ""),
        'tytul': fake.sentence(nb_words=4).rstrip('.'),
        'autor': fake.name(),
        'kategoria': random.randint(1, NUM_KATEGORIE),
        'rok': random.randint(1950, 2024),
        'strony': random.randint(100, 800),
        'opis': fake.text(max_nb_chars=100)
    })

for i in range(1, NUM_KSIAZKI + 1):
    dzielo = random.choice(pula_dziel)
    nr_inwentarzowy = random.randint(1000, 99999) # Uproszczenie, zakładam małą szansę na kolizję w demo
    
    # Unikalność pary ISBN + Nr Inwentarzowy (prostą metodą prób, w realu lepiej użyć licznika)
    while any(k[1] == dzielo['isbn'] and k[2] == nr_inwentarzowy for k in ksiazki_data):
        nr_inwentarzowy += 1

    filia_id = random.randint(1, NUM_FILIE)
    status = random.choice(['dostępny', 'wypożyczony', 'w konserwacji'])
    
    ksiazki_data.append([
        i, dzielo['isbn'], nr_inwentarzowy, dzielo['tytul'], dzielo['autor'],
        dzielo['kategoria'], filia_id, dzielo['rok'], "Wydanie I",
        dzielo['strony'], random.choice([True, False]), dzielo['opis'], status
    ])

zapisz_csv('ksiazki.csv', [
    'id_ksiazki', 'nr_isbn', 'numer_inwentarzowy', 'tytul', 'autor', 
    'id_kategorii', 'id_filii', 'rok_wydania', 'numer_edycji', 
    'liczba_stron', 'dostepna_online', 'opis', 'status'
], ksiazki_data)

# --- 6. WYPOŻYCZENIA I 7. ZWROTY ---
print("Generowanie wypożyczeń i zwrotów...")
wypozyczenia_data = []
zwroty_data = []
kary_data = []
id_kary_counter = 1

for i in range(1, NUM_WYPOZYCZENIA + 1):
    user_id = random.randint(1, NUM_UZYTKOWNICY)
    book_id = random.randint(1, NUM_KSIAZKI)
    
    # Data wypożyczenia w ciągu ostatnich 2 lat
    data_wyp = fake.date_between(start_date='-2y', end_date='today')
    planowana_data = data_wyp + timedelta(days=30)
    
    wypozyczenia_data.append([i, user_id, book_id, data_wyp, planowana_data])
    
    # Czy książka została zwrócona? (80% szans)
    if random.random() < 0.8:
        # Data zwrotu: od 1 dnia po wypożyczeniu do 60 dni po
        dni_uzytkowania = random.randint(1, 60)
        data_zwrotu = data_wyp + timedelta(days=dni_uzytkowania)
        
        # Ograniczenie: nie zwracamy w przyszłości
        if data_zwrotu > datetime.now().date():
            data_zwrotu = datetime.now().date()
            
        zwroty_data.append([i, data_zwrotu])

        # --- GENEROWANIE KAR (dla zwróconych) ---
        # Jeśli zwrócono po terminie (planowana < data_zwrotu)
        if data_zwrotu > planowana_data:
            dni_spoznienia = (data_zwrotu - planowana_data).days
            kwota = round(dni_spoznienia * 0.50, 2) # 50 groszy za dzień
            kary_data.append([
                id_kary_counter, user_id, 1, i, kwota, data_zwrotu, None, 'do zapłaty'
            ])
            id_kary_counter += 1

zapisz_csv('wypozyczenia.csv', ['id_wypozyczenia', 'id_osoby', 'id_ksiazki', 'data_wypozyczenia', 'planowana_data_zwrotu'], wypozyczenia_data)
zapisz_csv('zwroty.csv', ['id_wypozyczenia', 'data_zwrotu'], zwroty_data)

# Dodatkowe losowe kary za zniszczenie (niezależne od wypożyczeń w tym prostym modelu lub podpięte pod losowe wypożyczenie)
for _ in range(10):
    wyp_id = random.randint(1, NUM_WYPOZYCZENIA)
    # Znajdź usera z tego wypożyczenia
    u_id = wypozyczenia_data[wyp_id-1][1]
    data_nal = wypozyczenia_data[wyp_id-1][3] + timedelta(days=random.randint(5, 20))
    kary_data.append([
        id_kary_counter, u_id, 2, wyp_id, random.choice([20.00, 45.50, 15.00]), data_nal, data_nal + timedelta(days=2), 'opłacona'
    ])
    id_kary_counter += 1

zapisz_csv('kary.csv', [
    'id_kary', 'id_osoby', 'id_rodzaju_kary', 'id_wypozyczenia', 
    'kwota', 'data_nalozenia', 'data_oplacenia', 'status'
], kary_data)

# --- 9. KOMENTARZE ---
print("Generowanie komentarzy...")
komentarze_data = []
for i in range(1, NUM_KOMENTARZE + 1):
    # Wybieramy ISBN z puli książek
    isbn = random.choice(ksiazki_data)[1]
    user_id = random.randint(1, NUM_UZYTKOWNICY)
    ocena = random.randint(1, 10)
    tresc = fake.sentence()
    data_dod = fake.date_time_between(start_date='-1y', end_date='now')
    
    komentarze_data.append([i, isbn, user_id, ocena, tresc, data_dod])

zapisz_csv('komentarze.csv', ['id_komentarza', 'nr_isbn', 'id_osoby', 'ocena', 'tresc', 'data_dodania'], komentarze_data)

# --- 10. REZERWACJE ---
print("Generowanie rezerwacji...")
rezerwacje_data = []
for i in range(1, NUM_REZERWACJE + 1):
    isbn = random.choice(ksiazki_data)[1]
    user_id = random.randint(1, NUM_UZYTKOWNICY)
    filia_id = random.randint(1, NUM_FILIE)
    data_rez = fake.date_time_between(start_date='-1m', end_date='now')
    wygasa = data_rez + timedelta(days=3)
    status = random.choice(['oczekująca', 'zrealizowana', 'anulowana'])
    
    rezerwacje_data.append([i, isbn, user_id, filia_id, data_rez, status, wygasa.date()])

zapisz_csv('rezerwacje.csv', [
    'id_rezerwacji', 'nr_isbn', 'id_osoby', 'id_filii', 
    'data_rezerwacji', 'status', 'wygasa_dnia'
], rezerwacje_data)

# --- 11. WEJŚCIA / WYJŚCIA ---
print("Generowanie logów wejść/wyjść...")
wejscia_data = []
for i in range(1, NUM_WEJSCIA + 1):
    user_id = random.randint(1, NUM_UZYTKOWNICY)
    filia_id = random.randint(1, NUM_FILIE)
    
    # Data wejścia
    data_wej = fake.date_time_between(start_date='-3m', end_date='now')
    
    # Data wyjścia (musi być późniejsza)
    czas_pobytu = random.randint(5, 240) # minuty
    data_wyj = data_wej + timedelta(minutes=czas_pobytu)
    
    wejscia_data.append([i, user_id, filia_id, data_wej, data_wyj])

zapisz_csv('wejscia_wyjscia.csv', ['id_wejscia', 'id_osoby', 'id_filii', 'data_wejscia', 'data_wyjscia'], wejscia_data)

print(f"\nGotowe! Pliki CSV zostały zapisane w katalogu '{OUTPUT_DIR}'.")