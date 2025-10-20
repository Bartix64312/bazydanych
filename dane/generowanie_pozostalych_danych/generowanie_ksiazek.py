from faker import Faker
import random
import csv

fake = Faker('pl_PL')

def generate_books(num_records=400):
    books = []
    unique_books = []

    # najpierw generujemy unikalne książki (np. 100 różnych tytułów)
    num_unique = num_records // 4  # każda książka ma ok. 4 egzemplarze
    for _ in range(num_unique):
        title = fake.sentence(nb_words=random.randint(2, 5)).rstrip('.')
        author = fake.name()
        isbn = fake.isbn13(separator="-")
        unique_books.append((isbn, title, author))

    id_counter = 1
    for isbn, title, author in unique_books:
        # losujemy ile egzemplarzy będzie tej książki (1–6)
        for copy_num in range(1, random.randint(2, 7)):
            if len(books) >= num_records:
                break
            books.append({
                "id_ksiazki": id_counter,
                "nr_isbn": isbn,
                "nr_egzemplarza": copy_num,
                "tytul": title,
                "autor": author
            })
            id_counter += 1
        if len(books) >= num_records:
            break

    return books

# generujemy i zapisujemy do pliku CSV
books = generate_books(4000)

with open("ksiazki.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=["id_ksiazki", "nr_isbn", "nr_egzemplarza", "tytul", "autor"])
    writer.writeheader()
    writer.writerows(books)

print("✅ Wygenerowano plik 'ksiazki.csv' z 4000 rekordami.")
