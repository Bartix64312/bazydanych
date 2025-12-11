import csv
import random
import argparse
import os
import hashlib
from datetime import datetime, timedelta
from faker import Faker

# Inicjalizacja generatora danych
fake = Faker('pl_PL')

class LibraryDataGenerator:
    def __init__(self, output_dir, counts, seed=None):
        self.output_dir = output_dir
        self.counts = counts
        
        # Ustawienie ziarna losowości dla powtarzalności (opcjonalne)
        if seed:
            Faker.seed(seed)
            random.seed(seed)

        if not os.path.exists(self.output_dir):
            os.makedirs(self.output_dir)
            
        # Przechowywanie danych w pamięci do utrzymania relacji
        self.data = {
            'filie': [],
            'kategorie': [],
            'tytuly_master': [],
            'ksiazki': [],
            'uzytkownicy': [],
            'wypozyczenia': [],
            'zwroty': [],
            'kary': []
        }

    def save_csv(self, filename, dataset):
        if not dataset:
            return
        
        filepath = os.path.join(self.output_dir, filename)
        fieldnames = dataset[0].keys()
        
        with open(filepath, mode='w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(dataset)
        
        print(f"[OK] Zapisano {len(dataset)} rekordów do pliku: {filepath}")

    def generate_dictionaries(self):
        print("Generowanie słowników (filie, kategorie, kary)...")
        
        # Filie
        for i in range(1, self.counts['filie'] + 1):
            self.data['filie'].append({
                'id_filii': i,
                'adres': fake.address().replace('\n', ', '),
                'nazwa_filii': f"Filia Biblioteczna nr {i}",
                'glowny_bibliotekarz': fake.name()
            })
            
        # Kategorie (generujemy losowe nazwy jeśli brakuje predefiniowanych)
        base_categories = ['Powieść', 'Kryminał', 'Fantastyka', 'Nauka', 'Biografia', 'Historia', 'Horror', 'Romans']
        for i in range(1, self.counts['kategorie'] + 1):
            if i <= len(base_categories):
                nazwa = base_categories[i-1]
            else:
                nazwa = f"Kategoria {fake.word().capitalize()} {i}"
                
            self.data['kategorie'].append({
                'id_kategorii': i,
                'nazwa_kategorii': nazwa
            })

        # Rodzaje kar (stałe)
        rodzaje_kar = [
            (1, 'Przetrzymanie', 'Zwrot po terminie'),
            (2, 'Zgubienie', 'Zgubienie książki'),
            (3, 'Zniszczenie', 'Uszkodzenie mechaniczne'),
        ]
        self.rodzaje_kar_list = [{'id_rodzaju_kary': i, 'nazwa_kary': n, 'opis': o} for i, n, o in rodzaje_kar]
        self.save_csv('rodzaje_kar.csv', self.rodzaje_kar_list)
        self.save_csv('filie.csv', self.data['filie'])
        self.save_csv('kategorie.csv', self.data['kategorie'])

    def generate_users(self):
        print(f"Generowanie {self.counts['uzytkownicy']} użytkowników...")
        plec_opts = ['MEZCZYZNA', 'KOBIETA', 'NIEOKRESLONY']
        
        for i in range(1, self.counts['uzytkownicy'] + 1):
            plec = random.choice(plec_opts)
            if plec == 'MEZCZYZNA':
                imie, nazwisko = fake.first_name_male(), fake.last_name_male()
            elif plec == 'KOBIETA':
                imie, nazwisko = fake.first_name_female(), fake.last_name_female()
            else:
                imie, nazwisko = fake.first_name(), fake.last_name()

            # Hashowanie hasła (symulacja)
            salt = fake.uuid4()
            haslo_hash = hashlib.sha256(("haslo" + salt).encode()).hexdigest()

            self.data['uzytkownicy'].append({
                'id_osoby': i,
                'imie': imie,
                'nazwisko': nazwisko,
                'plec': plec,
                'login': f"user{i}",
                'email': f"user{i}@{fake.free_email_domain()}",
                'hash_hasla': haslo_hash,
                'sol_do_hasla': salt,
                'pytanie_pomocnicze': "Imię pierwszego zwierzaka?",
                'hash_odpowiedzi': "Burek",
                'url_profilowe': None,
                'data_zalozenia_konta': fake.date_time_between(start_date='-5y', end_date='now'),
                'aktywne': True
            })
        self.save_csv('uzytkownicy.csv', self.data['uzytkownicy'])

    def generate_books(self):
        print(f"Generowanie {self.counts['tytuly']} tytułów i {self.counts['egzemplarze']} egzemplarzy...")
        
        # 1. Generowanie bazy tytułów (abstrakcyjne książki)
        for _ in range(self.counts['tytuly']):
            self.data['tytuly_master'].append({
                'isbn': fake.isbn13(),
                'tytul': fake.sentence(nb_words=4).rstrip('.'),
                'autor': fake.name(),
                'id_kategorii': random.randint(1, self.counts['kategorie']),
                'rok': fake.year(),
                'strony': random.randint(100, 1000)
            })

        # 2. Generowanie fizycznych egzemplarzy
        for i in range(1, self.counts['egzemplarze'] + 1):
            master = random.choice(self.data['tytuly_master'])
            self.data['ksiazki'].append({
                'id_ksiazki': i,
                'nr_isbn': master['isbn'],
                'numer_inwentarzowy': 100000 + i,
                'tytul': master['tytul'],
                'autor': master['autor'],
                'id_kategorii': master['id_kategorii'],
                'id_filii': random.randint(1, self.counts['filie']),
                'rok_wydania': master['rok'],
                'numer_edycji': '1',
                'liczba_stron': master['strony'],
                'dostepna_online': False,
                'opis': 'Opis książki...',
                'status': 'dostępny'  # Zaktualizujemy to przy wypożyczeniach
            })
        
        # Tworzymy słownik dostępności do szybkiego sprawdzania
        self.ksiazka_dostepna = {k['id_ksiazki']: True for k in self.data['ksiazki']}

    def generate_loans_history(self):
        print(f"Generowanie {self.counts['wypozyczenia']} wypożyczeń (historia + aktywne)...")
        
        start_sim_date = datetime.now() - timedelta(days=365*2) # 2 lata wstecz
        today = datetime.now()
        
        kary_id_counter = 1
        
        for i in range(1, self.counts['wypozyczenia'] + 1):
            id_ksiazki = random.randint(1, self.counts['egzemplarze'])
            id_osoby = random.randint(1, self.counts['uzytkownicy'])
            
            # Data wypożyczenia
            data_wyp = fake.date_time_between(start_date=start_sim_date, end_date='now')
            planowany_zwrot = data_wyp + timedelta(days=30)
            
            wypozyczenie = {
                'id_wypozyczenia': i,
                'id_osoby': id_osoby,
                'id_ksiazki': id_ksiazki,
                'data_wypozyczenia': data_wyp.date(),
                'planowana_data_zwrotu': planowany_zwrot.date()
            }
            self.data['wypozyczenia'].append(wypozyczenie)

            # Logika zwrotu
            # Jeśli data wypożyczenia jest bardzo bliska dzisiaj, jest szansa że książka jest jeszcze u czytelnika
            dni_od_wypozyczenia = (today - data_wyp).days
            
            jest_zwrocona = True
            if dni_od_wypozyczenia < 30:
                # 30% szans, że nowa książka jest jeszcze czytana
                jest_zwrocona = random.choice([True, True, False]) 
            
            # Ale uwaga: Jeśli książka była wypożyczona dawno temu, ale wylosowaliśmy tę samą książkę
            # w nowszym wypożyczeniu (wcześniej w pętli), to ta "stara" musi być zwrócona.
            # Dla uproszczenia w tym skrypcie traktujemy każde wypożyczenie jako niezależne zdarzenie historyczne,
            # a o statusie "dostępny" decyduje ostatnie losowanie dla danej książki.
            
            if jest_zwrocona:
                # Zwrócona w terminie lub po
                offset = random.randint(5, 45) # od 5 do 45 dni po wypożyczeniu
                data_zwrotu = data_wyp + timedelta(days=offset)
                
                # Nie możemy zwrócić w przyszłości
                if data_zwrotu > today:
                    data_zwrotu = today

                self.data['zwroty'].append({
                    'id_wypozyczenia': i,
                    'data_zwrotu': data_zwrotu.date()
                })
                
                self.ksiazka_dostepna[id_ksiazki] = True

                # Generowanie kary
                if data_zwrotu.date() > planowany_zwrot.date():
                    spoznienie = (data_zwrotu.date() - planowany_zwrot.date()).days
                    self.data['kary'].append({
                        'id_kary': kary_id_counter,
                        'id_osoby': id_osoby,
                        'id_rodzaju_kary': 1, # Przetrzymanie
                        'id_wypozyczenia': i,
                        'kwota': round(spoznienie * 0.50, 2),
                        'data_nalozenia': data_zwrotu.date(),
                        'data_oplacenia': data_zwrotu.date() if random.choice([True, False]) else None,
                        'status': 'aktywna'
                    })
                    kary_id_counter += 1
            else:
                # Nie zwrócona -> książka niedostępna
                self.ksiazka_dostepna[id_ksiazki] = False
        
        # Aktualizacja statusów w pliku książki
        for k in self.data['ksiazki']:
            if not self.ksiazka_dostepna[k['id_ksiazki']]:
                k['status'] = 'wypożyczony'

        self.save_csv('ksiazki.csv', self.data['ksiazki'])
        self.save_csv('wypozyczenia.csv', self.data['wypozyczenia'])
        self.save_csv('zwroty.csv', self.data['zwroty'])
        self.save_csv('kary.csv', self.data['kary'])

    def generate_extras(self):
        print("Generowanie rezerwacji, wejść i komentarzy...")
        
        # Rezerwacje
        rezerwacje = []
        for i in range(1, self.counts['rezerwacje'] + 1):
            rezerwacje.append({
                'id_rezerwacji': i,
                'nr_isbn': random.choice(self.data['tytuly_master'])['isbn'],
                'id_osoby': random.randint(1, self.counts['uzytkownicy']),
                'id_filii': random.randint(1, self.counts['filie']),
                'data_rezerwacji': fake.date_time_this_year(),
                'status': 'oczekująca',
                'wygasa_dnia': fake.date_between(start_date='+1d', end_date='+10d')
            })
        self.save_csv('rezerwacje.csv', rezerwacje)

        # Wejścia
        wejscia = []
        for i in range(1, self.counts['wejscia'] + 1):
            wejscia.append({
                'id_wejscia': i,
                'id_osoby': random.randint(1, self.counts['uzytkownicy']),
                'id_filii': random.randint(1, self.counts['filie']),
                'data_wejscia': fake.date_time_this_year()
            })
        self.save_csv('wejscia.csv', wejscia)

        # Komentarze
        komentarze = []
        for i in range(1, self.counts['komentarze'] + 1):
            komentarze.append({
                'id_komentarza': i,
                'nr_isbn': random.choice(self.data['tytuly_master'])['isbn'],
                'id_osoby': random.randint(1, self.counts['uzytkownicy']),
                'ocena': random.randint(1, 10),
                'tresc': fake.sentence(),
                'data_dodania': fake.date_time_this_year()
            })
        self.save_csv('komentarze.csv', komentarze)

    def run(self):
        print(f"=== ROZPOCZĘCIE GENEROWANIA DANYCH DO KATALOGU: {self.output_dir} ===")
        self.generate_dictionaries()
        self.generate_users()
        self.generate_books()
        self.generate_loans_history()
        self.generate_extras()
        print("\n=== ZAKOŃCZONO SUKCESEM ===")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Generator danych bibliotecznych do CSV.")
    
    # Definicja argumentów
    parser.add_argument('--users', type=int, default=100, help='Liczba użytkowników')
    parser.add_argument('--filie', type=int, default=3, help='Liczba filii')
    parser.add_argument('--categories', type=int, default=10, help='Liczba kategorii')
    parser.add_argument('--titles', type=int, default=200, help='Liczba unikalnych tytułów (ISBN)')
    parser.add_argument('--copies', type=int, default=500, help='Liczba fizycznych egzemplarzy książek')
    parser.add_argument('--loans', type=int, default=1000, help='Liczba wypożyczeń w historii')
    parser.add_argument('--reservations', type=int, default=50, help='Liczba rezerwacji')
    parser.add_argument('--comments', type=int, default=100, help='Liczba komentarzy')
    parser.add_argument('--visits', type=int, default=200, help='Liczba wejść do biblioteki')
    parser.add_argument('--output', type=str, default='biblioteka_custom_csv', help='Nazwa folderu wyjściowego')
    parser.add_argument('--seed', type=int, default=None, help='Ziarno losowości (opcjonalne)')

    args = parser.parse_args()

    # Mapowanie argumentów na słownik
    config_counts = {
        'uzytkownicy': args.users,
        'filie': args.filie,
        'kategorie': args.categories,
        'tytuly': args.titles,
        'egzemplarze': args.copies,
        'wypozyczenia': args.loans,
        'rezerwacje': args.reservations,
        'komentarze': args.comments,
        'wejscia': args.visits
    }

    generator = LibraryDataGenerator(args.output, config_counts, args.seed)
    generator.run()