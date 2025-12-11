# Python code to generate CSV files for each table from the SQL dump schema.
# It uses Faker to create plausible and logically consistent data, writes CSVs to /mnt/data/library_csvs/,
# and bundles them into /mnt/data/library_csvs.zip for download.
# After generation, previews of a few tables are displayed.
from faker import Faker
import random
import csv
import os
from datetime import datetime, timedelta, date
from decimal import Decimal, ROUND_HALF_UP
import pathlib
import zipfile
import pandas as pd

Faker.seed(42)
random.seed(42)
fake = Faker('pl_PL')

OUT_DIR = "./"
os.makedirs(OUT_DIR, exist_ok=True)

# Config: counts (you can tweak these numbers)
N_USERS = 2000
N_FILIE = 10
N_KATEGORIE = 40
N_RODZAJE_KAR = 5
N_KSIAZKI = 30000
N_WYPOZYCZENIA = 500
N_ZWROTY = 420   # should be <= N_WYPOZYCZENIA
N_REZERWACJE = 180
N_KARY = 60
N_KOMENTARZE = 320
N_WEJSCIA = 1200

# Helper functions
def rand_date(start_days_ago=365*5, end_days_ago=0):
    start = date.today() - timedelta(days=start_days_ago)
    end = date.today() - timedelta(days=end_days_ago)
    delta = (end - start).days
    return start + timedelta(days=random.randint(0, max(0, delta)))

def rand_datetime(start_days_ago=365*5, end_days_ago=0):
    d = rand_date(start_days_ago, end_days_ago)
    t = timedelta(seconds=random.randint(0, 86400-1))
    return datetime.combine(d, datetime.min.time()) + t

def money(min_val=5, max_val=200):
    v = Decimal(random.uniform(min_val, max_val)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
    return str(v)

def maybe_none(prob=0.3):
    return random.random() < prob

# 1) filie
filie = []
for i in range(1, N_FILIE+1):
    filie.append({
        "id_filii": i,
        "adres": fake.address().replace("\n", ", "),
        "nazwa_filii": f"Filia {i} - {fake.city()}",
        "glowny_bibliotekarz": fake.name()
    })

# 2) kategorie
kategorie = []
for i in range(1, N_KATEGORIE+1):
    kategorie.append({
        "id_kategorii": i,
        "nazwa_kategorii": fake.word().capitalize()
    })

# 3) rodzaje_kar
rodzaje_kar = []
for i in range(1, N_RODZAJE_KAR+1):
    rodzaje_kar.append({
        "id_rodzaju_kary": i,
        "nazwa_kary": f"Kara {i}",
        "opis": fake.sentence(nb_words=8)
    })

# 4) users (uzytkownicy)
plec_choices = ['MEZCZYZNA', 'KOBIETA', 'NIEOKRESLONY']
uzytkownicy = []
logins = set()
for i in range(1, N_USERS+1):
    name = fake.first_name()
    surname = fake.last_name()
    login = (name[0] + surname).lower()
    # ensure unique login
    suffix = 1
    base = login
    while login in logins:
        suffix += 1
        login = f"{base}{suffix}"
    logins.add(login)
    created = rand_datetime(365*5, 0)
    salt = fake.hexify(text='^' * 16)  # random hex-ish
    password_hash = fake.sha256(raw_output=False)
    uzytkownicy.append({
        "id_osoby": i,
        "imie": name,
        "nazwisko": surname,
        "plec": random.choice(plec_choices),
        "login": login,
        "email": f"{login}@{fake.free_email_domain()}",
        "hash_hasla": password_hash,
        "sol_do_hasla": salt,
        "pytanie_pomocnicze": fake.sentence(nb_words=6),
        "hash_odpowiedzi": fake.sha1() if maybe_none(0.7) else "",
        "url_profilowe": "" if maybe_none(0.6) else fake.image_url(),
        "data_zalozenia_konta": created.strftime("%Y-%m-%d %H:%M:%S"),
        "aktywne": random.choice([True]*9 + [False])  # most active
    })

# 5) ksiazki
ksiazki = []
# we'll create some duplicate ISBNs to simulate multiple copies
isbn_pool = [fake.isbn13(separator='-') for _ in range(max(50, N_KSIAZKI//4))]

for i in range(1, N_KSIAZKI+1):
    isbn = random.choice(isbn_pool)
    ksiazki.append({
        "id_ksiazki": i,
        "nr_isbn": isbn,
        "numer_inwentarzowy": random.randint(1, 9999),
        "tytul": fake.sentence(nb_words=3).rstrip('.'),
        "autor": fake.name(),
        "id_kategorii": random.choice(kategorie)["id_kategorii"] if maybe_none(0.9) else "",
        "id_filii": random.choice(filie)["id_filii"] if maybe_none(0.95) else "",
        "rok_wydania": random.randint(1950, 2024) if maybe_none(0.8) else "",
        "numer_edycji": str(random.randint(1,5)) if maybe_none(0.4) else "",
        "liczba_stron": random.randint(50, 900) if maybe_none(0.85) else "",
        "dostepna_online": random.choice([False]*9 + [True]),
        "opis": fake.paragraph(nb_sentences=2) if maybe_none(0.6) else "",
        "status": "dostepny"
    })

# 6) wypozyczenia - must reference existing users and ksiazki
wypozyczenia = []
wyp_by_id = {}
for i in range(1, N_WYPOZYCZENIA+1):
    person = random.choice(uzytkownicy)
    book = random.choice(ksiazki)
    data_w = rand_date(365*2, 0)  # last 2 years
    planowana = data_w + timedelta(days=random.randint(7, 60))
    wyp = {
        "id_wypozyczenia": i,
        "id_osoby": person["id_osoby"],
        "id_ksiazki": book["id_ksiazki"],
        "data_wypozyczenia": data_w.strftime("%Y-%m-%d"),
        "planowana_data_zwrotu": planowana.strftime("%Y-%m-%d")
    }
    wypozyczenia.append(wyp)
    wyp_by_id[i] = wyp
    # mark book as wypozyczony, will be set back by zwroty later
    book["status"] = "wypozyczony"

# 7) zwroty - select a subset of wypozyczenia to be returned
zwroty = []
returned_ids = set(random.sample(range(1, N_WYPOZYCZENIA+1), k=min(N_ZWROTY, N_WYPOZYCZENIA)))
for wid in sorted(returned_ids):
    wyp = wyp_by_id[wid]
    wyp_date = datetime.strptime(wyp["data_wypozyczenia"], "%Y-%m-%d").date()
    # return date on or after wypozyczenia
    ret_date = wyp_date + timedelta(days=random.randint(1, 90))
    zwroty.append({
        "id_wypozyczenia": wid,
        "data_zwrotu": ret_date.strftime("%Y-%m-%d")
    })
    # set the book to available
    ks_id = wyp["id_ksiazki"]
    ksiazki[ks_id-1]["status"] = "dostepny"

# 8) rezerwacje
rezerwacje = []
for i in range(1, N_REZERWACJE+1):
    book = random.choice(ksiazki)
    person = random.choice(uzytkownicy)
    filia = random.choice(filie)
    dr = rand_datetime(365, 0)
    wygasa = (datetime.strptime(dr.strftime("%Y-%m-%d"), "%Y-%m-%d").date() + timedelta(days=random.randint(1,30)))
    rezerwacje.append({
        "id_rezerwacji": i,
        "nr_isbn": book["nr_isbn"],
        "id_osoby": person["id_osoby"],
        "id_filii": filia["id_filii"],
        "data_rezerwacji": dr.strftime("%Y-%m-%d %H:%M:%S"),
        "status": random.choice(["oczekujaca", "zrealizowana", "anulowana"]),
        "wygasa_dnia": wygasa.strftime("%Y-%m-%d")
    })

# 9) kary
kary = []
for i in range(1, N_KARY+1):
    person = random.choice(uzytkownicy)
    rodz = random.choice(rodzaje_kar)
    # sometimes tie to a wypozyczenie
    wyp_id = random.choice(list(wyp_by_id.keys())) if maybe_none(0.6) else ""
    data_nalozenia = rand_date(365*2, 0)
    paid = maybe_none(0.5)
    data_oplacenia = (data_nalozenia + timedelta(days=random.randint(1, 400))).strftime("%Y-%m-%d") if paid else ""
    kary.append({
        "id_kary": i,
        "id_osoby": person["id_osoby"],
        "id_rodzaju_kary": rodz["id_rodzaju_kary"],
        "id_wypozyczenia": wyp_id,
        "kwota": money(5, 150),
        "data_nalozenia": data_nalozenia.strftime("%Y-%m-%d"),
        "data_oplacenia": data_oplacenia,
        "status": "opłacona" if paid else "aktywna"
    })

# 10) komentarze
komentarze = []
for i in range(1, N_KOMENTARZE+1):
    book = random.choice(ksiazki)
    person = random.choice(uzytkownicy)
    komentarze.append({
        "id_komentarza": i,
        "nr_isbn": book["nr_isbn"],
        "id_osoby": person["id_osoby"],
        "ocena": random.randint(1,10),
        "tresc": fake.sentence(nb_words=10),
        "data_dodania": rand_datetime(365*2, 0).strftime("%Y-%m-%d %H:%M:%S")
    })

# 11) wejscia
wejscia = []
for i in range(1, N_WEJSCIA+1):
    person = random.choice(uzytkownicy)
    fil = random.choice(filie)
    wej = {
        "id_wejscia": i,
        "id_osoby": person["id_osoby"],
        "id_filii": fil["id_filii"],
        "data_wejscia": rand_datetime(365, 0).strftime("%Y-%m-%d %H:%M:%S")
    }
    wejscia.append(wej)

# CSV writer helper
def write_csv(path, rows, headers):
    with open(path, "w", newline='', encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=headers, extrasaction='ignore')
        writer.writeheader()
        for r in rows:
            writer.writerow(r)

# Write all CSVs matching schema column order
write_csv(os.path.join(OUT_DIR, "filie.csv"), filie, ["id_filii","adres","nazwa_filii","glowny_bibliotekarz"])
write_csv(os.path.join(OUT_DIR, "kategorie.csv"), kategorie, ["id_kategorii","nazwa_kategorii"])
write_csv(os.path.join(OUT_DIR, "rodzaje_kar.csv"), rodzaje_kar, ["id_rodzaju_kary","nazwa_kary","opis"])
write_csv(os.path.join(OUT_DIR, "uzytkownicy.csv"), uzytkownicy, ["id_osoby","imie","nazwisko","plec","login","email","hash_hasla","sol_do_hasla","pytanie_pomocnicze","hash_odpowiedzi","url_profilowe","data_zalozenia_konta","aktywne"])
write_csv(os.path.join(OUT_DIR, "ksiazki.csv"), ksiazki, ["id_ksiazki","nr_isbn","numer_inwentarzowy","tytul","autor","id_kategorii","id_filii","rok_wydania","numer_edycji","liczba_stron","dostepna_online","opis","status"])
write_csv(os.path.join(OUT_DIR, "wypozyczenia.csv"), wypozyczenia, ["id_wypozyczenia","id_osoby","id_ksiazki","data_wypozyczenia","planowana_data_zwrotu"])
write_csv(os.path.join(OUT_DIR, "zwroty.csv"), zwroty, ["id_wypozyczenia","data_zwrotu"])
write_csv(os.path.join(OUT_DIR, "rezerwacje.csv"), rezerwacje, ["id_rezerwacji","nr_isbn","id_osoby","id_filii","data_rezerwacji","status","wygasa_dnia"])
write_csv(os.path.join(OUT_DIR, "kary.csv"), kary, ["id_kary","id_osoby","id_rodzaju_kary","id_wypozyczenia","kwota","data_nalozenia","data_oplacenia","status"])
write_csv(os.path.join(OUT_DIR, "komentarze.csv"), komentarze, ["id_komentarza","nr_isbn","id_osoby","ocena","tresc","data_dodania"])
write_csv(os.path.join(OUT_DIR, "wejscia.csv"), wejscia, ["id_wejscia","id_osoby","id_filii","data_wejscia"])

# Create zip bundle
zip_path = "/mnt/data/library_csvs.zip"
with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as zf:
    for fname in os.listdir(OUT_DIR):
        zf.write(os.path.join(OUT_DIR, fname), arcname=fname)

# Show previews using caas_jupyter_tools.display_dataframe_to_user
pd_filie = pd.DataFrame(filie).head(10)
pd_ksiazki = pd.DataFrame(ksiazki).head(10)
pd_wyp = pd.DataFrame(wypozyczenia).head(10)

print(f"Pliki CSV zapisano w: {OUT_DIR}")
print(f"Spakowane archiwum: {zip_path}")
