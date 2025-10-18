from random import choice,randint
imiona_zenskie=[]
with open("dane\imiona_zenskie.txt","r") as dane:
    for wiersz in dane:
        wiersz=wiersz.strip()
        imiona_zenskie.append(wiersz)
imiona_meskie=[]
with open("dane\imiona_zenskie.txt","r") as dane:
    for wiersz in dane:
        wiersz=wiersz.strip()
        imiona_meskie.append(wiersz)
nazwiska_zenskie=[]
with open("nazwiska_zenskie.txt","r") as dane:
    for wiersz in dane:
        wiersz=wiersz.strip()
        nazwiska_zenskie.append(wiersz)
nazwiska_meskie=[]
with open("nazwiska_meskie.txt","r") as dane:
    for wiersz in dane:
        wiersz=wiersz.strip()
        nazwiska_meskie.append(wiersz)
f=open("osoby.csv",'w')
f.write("id,imie,nazwisko,plec\n")
for i in range(5000):
    if i==331:
        f.write(str(i)+f",Dzwonimierz,Talarski,MEZCZYZNA\n")
        continue
    bartek=randint(1,100)#he said that this is better name
    if bartek==1:
        f.write(str(i)+f",{choice(imiona_meskie+imiona_zenskie)},{choice(nazwiska_meskie+nazwiska_zenskie)},NIEOKRESLONY\n")
        continue
    boolean=randint(0,1)
    if boolean==1:
        f.write(str(i)+f",{choice(imiona_meskie)},{choice(nazwiska_meskie)},MEZCZYZNA\n")
    else:
        f.write(str(i)+f",{choice(imiona_zenskie)},{choice(nazwiska_zenskie)},KOBIETA\n")