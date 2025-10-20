import csv
import random
from datetime import datetime, timedelta

# --- PARAMETRY ---
LICZBA_WYPOZYCZEN = 1500     # możesz zmienić, np. 3000
MAX_ID_KSIAZKI = 3516
MAX_ID_OSOBY = 4999
MAX_WYPOZYCZEN_NA_OSOBE = 5

# --- FUNKCJA POMOCNICZA: LOSOWA DATA W ZAKRESIE ---
def losowa_data(start, end):
    delta = end - start
    return start + timedelta(days=random.randint(0, delta.days))

# --- GENEROWANIE WYPOŻYCZEŃ ---
def generuj_wypozyczenia():
    start_date = datetime(2023, 1, 1)
    end_date = datetime(2025, 10, 1)

    wypozyczenia = []
    zajete_ksiazki = set()
    aktywne_osoby = {i: 0 for i in range(MAX_ID_OSOBY + 1)}

    id_wypozyczenia = 1
    while len(wypozyczenia) < LICZBA_WYPOZYCZEN:
        id_osoby = random.randint(0, MAX_ID_OSOBY)
        if aktywne_osoby[id_osoby] >= MAX_WYPOZYCZEN_NA_OSOBE:
            continue  # osoba ma już 5 książek
        id_ksiazki = random.randint(1, MAX_ID_KSIAZKI)
        if id_ksiazki in zajete_ksiazki:
            continue  # książka już wypożyczona

        data_wyp = losowa_data(start_date, end_date)
        wypozyczenia.append({
            "id_wypozyczenia": id_wypozyczenia,
            "id_osoby": id_osoby,
            "data_wypozyczenia": data_wyp.strftime("%Y-%m-%d"),
            "id_ksiazki": id_ksiazki
        })

        zajete_ksiazki.add(id_ksiazki)
        aktywne_osoby[id_osoby] += 1
        id_wypozyczenia += 1

    return wypozyczenia

# --- GENEROWANIE ZWROTÓW ---
def generuj_zwroty(wypozyczenia):
    zwroty = []
    for w in wypozyczenia:
        data_wyp = datetime.strptime(w["data_wypozyczenia"], "%Y-%m-%d")
        # książka zwrócona między 1 a 60 dni później
        data_zwrotu = data_wyp + timedelta(days=random.randint(1, 60))
        # nie przekraczamy dzisiejszej daty
        if data_zwrotu > datetime.now():
            data_zwrotu = datetime.now() - timedelta(days=random.randint(0, 5))
        zwroty.append({
            "id_wypozyczenia": w["id_wypozyczenia"],
            "data_zwrotu": data_zwrotu.strftime("%Y-%m-%d"),
            "id_ksiazki": w["id_ksiazki"]
        })
    return zwroty

# --- GŁÓWNY PROGRAM ---
wypozyczenia = generuj_wypozyczenia()
zwroty = generuj_zwroty(wypozyczenia)

# --- ZAPIS CSV ---
with open("wypozyczenia.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=["id_wypozyczenia", "id_osoby", "data_wypozyczenia", "id_ksiazki"])
    writer.writeheader()
    writer.writerows(wypozyczenia)

with open("zwroty.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=["id_wypozyczenia", "data_zwrotu", "id_ksiazki"])
    writer.writeheader()
    writer.writerows(zwroty)

print("✅ Wygenerowano pliki: wypozyczenia.csv i zwroty.csv")
print(f"📚 Liczba wypożyczeń: {len(wypozyczenia)}")
