from random import choice, randint

# Wczytywanie imion żeńskich
imiona_zenskie = []
with open("imiona_zenskie.txt", "r", encoding="utf-8") as dane:
    for wiersz in dane:
        wiersz = wiersz.strip()
        imiona_zenskie.append(wiersz)

# Wczytywanie imion męskich (wcześniej był błąd – otwierałeś ponownie imiona_żeńskie!)
imiona_meskie = []
with open("imiona_meskie.txt", "r", encoding="utf-8") as dane:
    for wiersz in dane:
        wiersz = wiersz.strip()
        imiona_meskie.append(wiersz)

# Wczytywanie nazwisk żeńskich
nazwiska_zenskie = []
with open("nazwiska_zenskie.txt", "r", encoding="utf-8") as dane:
    for wiersz in dane:
        wiersz = wiersz.strip()
        nazwiska_zenskie.append(wiersz)

# Wczytywanie nazwisk męskich
nazwiska_meskie = []
with open("nazwiska_meskie.txt", "r", encoding="utf-8") as dane:
    for wiersz in dane:
        wiersz = wiersz.strip()
        nazwiska_meskie.append(wiersz)

# Tworzenie pliku CSV
with open("osoby.csv", "w", encoding="utf-8") as f:
    f.write("id,imie,nazwisko,plec\n")
    for i in range(5000):
        if i == 331:
            f.write(f"{i},Dzwonimierz,Talarski,MEZCZYZNA\n")
            continue

        bartek = randint(1, 100)  # Losowy współczynnik dla NIEOKRESLONY
        if bartek == 1:
            f.write(f"{i},{choice(imiona_meskie + imiona_zenskie)},{choice(nazwiska_meskie + nazwiska_zenskie)},NIEOKRESLONY\n")
            continue

        # Losowanie płci
        if randint(0, 1) == 1:
            f.write(f"{i},{choice(imiona_meskie)},{choice(nazwiska_meskie)},MEZCZYZNA\n")
        else:
            f.write(f"{i},{choice(imiona_zenskie)},{choice(nazwiska_zenskie)},KOBIETA\n")
