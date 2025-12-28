--
-- PostgreSQL database dump
--

\restrict sHLN4kdDFxmF0kHxkGT8eq8mEEnyyOT1n8DeC5MvBVbLRYdF1PviRLPjj52Jy6v

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: czy_ksiazka_dostepna(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.czy_ksiazka_dostepna(p_isbn character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_ilosc INT;
BEGIN
    SELECT COUNT(*) INTO v_ilosc 
    FROM ksiazki 
    WHERE nr_isbn = p_isbn AND status = 'dostępny';
    
    IF v_ilosc > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$;


ALTER FUNCTION public.czy_ksiazka_dostepna(p_isbn character varying) OWNER TO postgres;

--
-- Name: fn_after_wypozyczenie_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_after_wypozyczenie_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE ksiazki SET status = 'wypoľyczony' WHERE id_ksiazki = NEW.id_ksiazki;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_after_wypozyczenie_insert() OWNER TO postgres;

--
-- Name: fn_after_zwrot_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_after_zwrot_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    wypozyczona_ksiazka_id INT;
BEGIN
    SELECT id_ksiazki INTO wypozyczona_ksiazka_id FROM wypozyczenia WHERE id_wypozyczenia = NEW.id_wypozyczenia;
    UPDATE ksiazki SET status = 'dost©pny' WHERE id_ksiazki = wypozyczona_ksiazka_id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_after_zwrot_insert() OWNER TO postgres;

--
-- Name: sprawdz_date_zwrotu(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sprawdz_date_zwrotu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_data_wypozyczenia DATE;
BEGIN
    -- Pobieramy datę wypożyczenia dla oddawanej książki
    SELECT data_wypozyczenia INTO v_data_wypozyczenia
    FROM wypozyczenia
    WHERE id_wypozyczenia = NEW.id_wypozyczenia;

    -- Sprawdzamy, czy data zwrotu nie jest wcześniejsza
    IF NEW.data_zwrotu < v_data_wypozyczenia THEN
        RAISE EXCEPTION 'Błąd: Data zwrotu (%) nie może być wcześniejsza niż data wypożyczenia (%)', NEW.data_zwrotu, v_data_wypozyczenia;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sprawdz_date_zwrotu() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: filie; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.filie (
    id_filii integer NOT NULL,
    adres character varying(255) NOT NULL,
    nazwa_filii character varying(150) NOT NULL,
    glowny_bibliotekarz character varying(100)
);


ALTER TABLE public.filie OWNER TO postgres;

--
-- Name: filie_id_filii_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.filie_id_filii_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.filie_id_filii_seq OWNER TO postgres;

--
-- Name: filie_id_filii_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.filie_id_filii_seq OWNED BY public.filie.id_filii;


--
-- Name: kary; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kary (
    id_kary integer NOT NULL,
    id_osoby integer NOT NULL,
    id_rodzaju_kary integer NOT NULL,
    id_wypozyczenia integer,
    kwota numeric(7,2),
    data_nalozenia date NOT NULL,
    data_oplacenia date,
    status character varying(20) DEFAULT 'aktywna'::character varying
);


ALTER TABLE public.kary OWNER TO postgres;

--
-- Name: kary_id_kary_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kary_id_kary_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.kary_id_kary_seq OWNER TO postgres;

--
-- Name: kary_id_kary_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kary_id_kary_seq OWNED BY public.kary.id_kary;


--
-- Name: kategorie; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kategorie (
    id_kategorii integer NOT NULL,
    nazwa_kategorii character varying(100) NOT NULL
);


ALTER TABLE public.kategorie OWNER TO postgres;

--
-- Name: kategorie_id_kategorii_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kategorie_id_kategorii_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.kategorie_id_kategorii_seq OWNER TO postgres;

--
-- Name: kategorie_id_kategorii_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kategorie_id_kategorii_seq OWNED BY public.kategorie.id_kategorii;


--
-- Name: komentarze; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.komentarze (
    id_komentarza integer NOT NULL,
    nr_isbn character varying(20) NOT NULL,
    id_osoby integer NOT NULL,
    ocena integer,
    tresc text,
    data_dodania timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT komentarze_ocena_check CHECK (((ocena >= 1) AND (ocena <= 10)))
);


ALTER TABLE public.komentarze OWNER TO postgres;

--
-- Name: komentarze_id_komentarza_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.komentarze_id_komentarza_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.komentarze_id_komentarza_seq OWNER TO postgres;

--
-- Name: komentarze_id_komentarza_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.komentarze_id_komentarza_seq OWNED BY public.komentarze.id_komentarza;


--
-- Name: ksiazki; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ksiazki (
    id_ksiazki integer NOT NULL,
    nr_isbn character varying(20) NOT NULL,
    numer_inwentarzowy integer CONSTRAINT ksiazki_nr_egzemplarza_not_null NOT NULL,
    tytul character varying(255) NOT NULL,
    autor character varying(255) NOT NULL,
    id_kategorii integer,
    id_filii integer,
    rok_wydania integer,
    numer_edycji character varying(50),
    liczba_stron integer,
    dostepna_online boolean DEFAULT false,
    opis text,
    status character varying(20) DEFAULT 'dost©pny'::character varying
);


ALTER TABLE public.ksiazki OWNER TO postgres;

--
-- Name: rezerwacje; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rezerwacje (
    id_rezerwacji integer NOT NULL,
    nr_isbn character varying(20) NOT NULL,
    id_osoby integer NOT NULL,
    id_filii integer NOT NULL,
    data_rezerwacji timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(20) DEFAULT 'oczekujĄca'::character varying,
    wygasa_dnia date
);


ALTER TABLE public.rezerwacje OWNER TO postgres;

--
-- Name: rezerwacje_id_rezerwacji_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rezerwacje_id_rezerwacji_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rezerwacje_id_rezerwacji_seq OWNER TO postgres;

--
-- Name: rezerwacje_id_rezerwacji_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rezerwacje_id_rezerwacji_seq OWNED BY public.rezerwacje.id_rezerwacji;


--
-- Name: rodzaje_kar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rodzaje_kar (
    id_rodzaju_kary integer NOT NULL,
    nazwa_kary character varying(100) NOT NULL,
    opis text
);


ALTER TABLE public.rodzaje_kar OWNER TO postgres;

--
-- Name: rodzaje_kar_id_rodzaju_kary_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rodzaje_kar_id_rodzaju_kary_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rodzaje_kar_id_rodzaju_kary_seq OWNER TO postgres;

--
-- Name: rodzaje_kar_id_rodzaju_kary_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rodzaje_kar_id_rodzaju_kary_seq OWNED BY public.rodzaje_kar.id_rodzaju_kary;


--
-- Name: uzytkownicy; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.uzytkownicy (
    id_osoby integer CONSTRAINT osoby_id_osoby_not_null NOT NULL,
    imie character varying(50) CONSTRAINT osoby_imie_not_null NOT NULL,
    nazwisko character varying(50) CONSTRAINT osoby_nazwisko_not_null NOT NULL,
    plec character varying(15),
    login character varying(50) NOT NULL,
    email character varying(100) NOT NULL,
    hash_hasla character varying(255) NOT NULL,
    sol_do_hasla character varying(255) NOT NULL,
    pytanie_pomocnicze text,
    hash_odpowiedzi character varying(255),
    url_profilowe character varying(255),
    data_zalozenia_konta timestamp without time zone,
    aktywne boolean DEFAULT true,
    CONSTRAINT osoby_plec_check CHECK (((plec)::text = ANY (ARRAY[('MEZCZYZNA'::character varying)::text, ('KOBIETA'::character varying)::text, ('NIEOKRESLONY'::character varying)::text])))
);


ALTER TABLE public.uzytkownicy OWNER TO postgres;

--
-- Name: wypozyczenia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wypozyczenia (
    id_wypozyczenia integer NOT NULL,
    id_osoby integer NOT NULL,
    id_ksiazki integer NOT NULL,
    data_wypozyczenia date NOT NULL,
    planowana_data_zwrotu date NOT NULL,
    CONSTRAINT check_planowana_data CHECK ((planowana_data_zwrotu >= data_wypozyczenia))
);


ALTER TABLE public.wypozyczenia OWNER TO postgres;

--
-- Name: zwroty; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zwroty (
    id_wypozyczenia integer NOT NULL,
    data_zwrotu date NOT NULL
);


ALTER TABLE public.zwroty OWNER TO postgres;

--
-- Name: view_dluznicy; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_dluznicy AS
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


ALTER VIEW public.view_dluznicy OWNER TO postgres;

--
-- Name: view_top_ksiazki; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_top_ksiazki AS
 SELECT k.tytul,
    kat.nazwa_kategorii,
    count(w.id_wypozyczenia) AS ilosc_wypozyczen
   FROM ((public.ksiazki k
     JOIN public.kategorie kat ON ((k.id_kategorii = kat.id_kategorii)))
     JOIN public.wypozyczenia w ON ((k.id_ksiazki = w.id_ksiazki)))
  GROUP BY k.tytul, kat.nazwa_kategorii
  ORDER BY (count(w.id_wypozyczenia)) DESC;


ALTER VIEW public.view_top_ksiazki OWNER TO postgres;

--
-- Name: wejscia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wejscia (
    id_wejscia integer NOT NULL,
    id_osoby integer NOT NULL,
    id_filii integer NOT NULL,
    data_wejscia timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.wejscia OWNER TO postgres;

--
-- Name: wejscia_id_wejscia_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.wejscia_id_wejscia_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.wejscia_id_wejscia_seq OWNER TO postgres;

--
-- Name: wejscia_id_wejscia_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.wejscia_id_wejscia_seq OWNED BY public.wejscia.id_wejscia;


--
-- Name: filie id_filii; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.filie ALTER COLUMN id_filii SET DEFAULT nextval('public.filie_id_filii_seq'::regclass);


--
-- Name: kary id_kary; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kary ALTER COLUMN id_kary SET DEFAULT nextval('public.kary_id_kary_seq'::regclass);


--
-- Name: kategorie id_kategorii; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kategorie ALTER COLUMN id_kategorii SET DEFAULT nextval('public.kategorie_id_kategorii_seq'::regclass);


--
-- Name: komentarze id_komentarza; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.komentarze ALTER COLUMN id_komentarza SET DEFAULT nextval('public.komentarze_id_komentarza_seq'::regclass);


--
-- Name: rezerwacje id_rezerwacji; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rezerwacje ALTER COLUMN id_rezerwacji SET DEFAULT nextval('public.rezerwacje_id_rezerwacji_seq'::regclass);


--
-- Name: rodzaje_kar id_rodzaju_kary; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rodzaje_kar ALTER COLUMN id_rodzaju_kary SET DEFAULT nextval('public.rodzaje_kar_id_rodzaju_kary_seq'::regclass);


--
-- Name: wejscia id_wejscia; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wejscia ALTER COLUMN id_wejscia SET DEFAULT nextval('public.wejscia_id_wejscia_seq'::regclass);


--
-- Data for Name: filie; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.filie (id_filii, adres, nazwa_filii, glowny_bibliotekarz) FROM stdin;
1	ul. Główna 1, Warszawa	Filia Centralna	Anna Kowalska
2	ul. Leśna 15, Kraków	Filia Południe	Jan Nowak
3	ul. Morska 4, Gdańsk	Filia Północ	Krystyna Morska
4	ul. Długa 99, Wrocław	Filia Zachód	Piotr Zieliński
5	ul. Wschodnia 3, Lublin	Filia Wschód	Maria Wschodnia
\.


--
-- Data for Name: kary; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kary (id_kary, id_osoby, id_rodzaju_kary, id_wypozyczenia, kwota, data_nalozenia, data_oplacenia, status) FROM stdin;
\.


--
-- Data for Name: kategorie; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kategorie (id_kategorii, nazwa_kategorii) FROM stdin;
1	Powieść obyczajowa
2	Kryminał
3	Fantastyka
4	Science Fiction
5	Biografia
6	Reportaż
7	Informatyka
8	Historia
9	Psychologia
10	Dla dzieci
11	Horror
12	Poezja
13	Powieść
16	Nauka
\.


--
-- Data for Name: komentarze; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.komentarze (id_komentarza, nr_isbn, id_osoby, ocena, tresc, data_dodania) FROM stdin;
1	978-0-8364-6474-0	982	3	Zaskakujące zakończenie.	2024-12-31 01:38:19.939207
2	978-0-8364-6474-0	982	2	Trudno się czyta.	2025-03-22 01:39:36.189868
3	978-0-8364-6474-0	982	9	Zaskakujące zakończenie.	2025-02-12 13:09:30.414008
4	978-0-8364-6474-0	982	5	Nudna, nie polecam.	2025-03-09 21:52:53.194828
5	978-0-8364-6474-0	982	2	Zaskakujące zakończenie.	2025-10-23 14:57:03.734099
6	978-0-8364-6474-0	982	2	Zaskakujące zakończenie.	2025-03-16 00:56:47.575893
7	978-0-8364-6474-0	982	8	Klasyka gatunku.	2025-05-14 13:28:38.612212
8	978-0-8364-6474-0	982	3	Wciągająca fabuła.	2025-07-27 08:40:14.821842
9	978-0-8364-6474-0	982	8	Polecam każdemu.	2025-07-23 00:53:42.922497
10	978-0-8364-6474-0	982	2	Klasyka gatunku.	2025-03-14 18:03:53.788015
11	978-0-8364-6474-0	982	7	Klasyka gatunku.	2025-03-04 16:23:11.424919
12	978-0-8364-6474-0	982	3	Nudna, nie polecam.	2025-09-06 12:52:49.273385
13	978-0-8364-6474-0	982	1	Klasyka gatunku.	2025-10-28 15:05:06.86967
14	978-0-8364-6474-0	982	2	Wciągająca fabuła.	2025-11-15 21:34:42.543174
15	978-0-8364-6474-0	982	6	Strata czasu.	2025-02-24 11:43:36.366076
16	978-0-8364-6474-0	982	8	Wciągająca fabuła.	2025-02-03 06:50:47.174534
17	978-0-8364-6474-0	982	8	Świetna książka!	2025-01-03 07:08:09.536311
18	978-0-8364-6474-0	982	7	Świetna książka!	2025-03-26 16:26:59.297974
19	978-0-8364-6474-0	982	8	Polecam każdemu.	2025-02-26 00:54:55.122807
20	978-0-8364-6474-0	982	1	Trudno się czyta.	2025-09-10 05:12:51.637738
21	978-0-8364-6474-0	982	7	Polecam każdemu.	2025-01-29 13:02:41.287856
22	978-0-8364-6474-0	982	6	Klasyka gatunku.	2025-10-27 16:07:48.158903
23	978-0-8364-6474-0	982	5	Polecam każdemu.	2025-04-26 16:35:30.035573
24	978-0-8364-6474-0	982	1	Trudno się czyta.	2025-10-05 19:38:24.139706
25	978-0-8364-6474-0	982	4	Trudno się czyta.	2025-10-31 12:54:03.388746
26	978-0-8364-6474-0	982	1	Świetna książka!	2024-12-19 00:16:22.345663
27	978-0-8364-6474-0	982	4	Nudna, nie polecam.	2025-05-10 16:54:46.10459
28	978-0-8364-6474-0	982	7	Świetna książka!	2025-11-14 21:05:27.100123
29	978-0-8364-6474-0	982	7	Polecam każdemu.	2025-07-27 00:29:52.77735
30	978-0-8364-6474-0	982	6	Zaskakujące zakończenie.	2025-05-14 12:18:35.138024
31	978-0-8364-6474-0	982	4	Wciągająca fabuła.	2025-06-05 00:15:57.162777
32	978-0-8364-6474-0	982	3	Zaskakujące zakończenie.	2025-08-19 01:26:02.664955
33	978-0-8364-6474-0	982	7	Strata czasu.	2025-04-22 22:10:39.4659
34	978-0-8364-6474-0	982	10	Zaskakujące zakończenie.	2025-12-14 12:16:37.784535
35	978-0-8364-6474-0	982	7	Strata czasu.	2025-09-07 21:26:11.771212
36	978-0-8364-6474-0	982	2	Zaskakujące zakończenie.	2025-11-28 15:49:16.329487
37	978-0-8364-6474-0	982	6	Zaskakujące zakończenie.	2025-07-07 13:47:38.65425
38	978-0-8364-6474-0	982	8	Świetna książka!	2025-08-24 11:48:39.069651
39	978-0-8364-6474-0	982	3	Klasyka gatunku.	2025-10-05 09:55:10.951005
40	978-0-8364-6474-0	982	10	Strata czasu.	2025-06-18 03:28:21.185104
41	978-0-8364-6474-0	982	10	Wciągająca fabuła.	2025-10-30 09:55:14.334162
42	978-0-8364-6474-0	982	3	Świetna książka!	2025-02-26 13:28:22.969427
43	978-0-8364-6474-0	982	10	Strata czasu.	2025-04-24 06:19:08.510855
44	978-0-8364-6474-0	982	3	Nudna, nie polecam.	2025-07-27 18:19:30.664014
45	978-0-8364-6474-0	982	5	Polecam każdemu.	2025-01-27 15:27:23.711955
46	978-0-8364-6474-0	982	9	Świetna książka!	2025-02-11 17:19:26.010244
47	978-0-8364-6474-0	982	1	Klasyka gatunku.	2025-04-19 10:23:02.454938
48	978-0-8364-6474-0	982	1	Wciągająca fabuła.	2025-09-01 14:59:01.897535
49	978-0-8364-6474-0	982	2	Nudna, nie polecam.	2025-08-04 06:08:58.475073
50	978-0-8364-6474-0	982	2	Nudna, nie polecam.	2025-11-23 08:48:28.591615
51	978-0-8364-6474-0	982	8	Nudna, nie polecam.	2025-11-12 20:20:57.349279
52	978-0-8364-6474-0	982	7	Klasyka gatunku.	2025-04-23 03:47:18.377147
53	978-0-8364-6474-0	982	4	Świetna książka!	2025-03-06 11:34:22.698262
54	978-0-8364-6474-0	982	5	Świetna książka!	2025-03-15 02:27:42.859504
55	978-0-8364-6474-0	982	10	Zaskakujące zakończenie.	2025-02-10 04:08:06.346678
56	978-0-8364-6474-0	982	6	Zaskakujące zakończenie.	2025-03-10 17:25:10.745278
57	978-0-8364-6474-0	982	6	Zaskakujące zakończenie.	2025-03-08 12:50:05.91428
58	978-0-8364-6474-0	982	3	Świetna książka!	2025-07-19 14:54:01.947784
59	978-0-8364-6474-0	982	2	Zaskakujące zakończenie.	2025-07-03 17:27:59.208931
60	978-0-8364-6474-0	982	6	Polecam każdemu.	2025-08-20 18:58:50.437616
61	978-0-8364-6474-0	982	4	Strata czasu.	2024-12-29 22:08:39.504039
62	978-0-8364-6474-0	982	6	Świetna książka!	2025-02-06 03:01:59.102106
63	978-0-8364-6474-0	982	2	Nudna, nie polecam.	2025-05-19 04:50:28.932256
64	978-0-8364-6474-0	982	3	Trudno się czyta.	2025-08-27 05:36:27.350026
65	978-0-8364-6474-0	982	9	Klasyka gatunku.	2024-12-21 12:50:07.536357
66	978-0-8364-6474-0	982	3	Wciągająca fabuła.	2025-04-14 23:44:41.646179
67	978-0-8364-6474-0	982	3	Zaskakujące zakończenie.	2025-10-03 14:33:05.252239
68	978-0-8364-6474-0	982	9	Klasyka gatunku.	2025-01-12 11:31:48.684549
69	978-0-8364-6474-0	982	1	Nudna, nie polecam.	2025-02-28 00:27:40.823209
70	978-0-8364-6474-0	982	1	Strata czasu.	2025-03-12 16:37:34.440978
71	978-0-8364-6474-0	982	9	Klasyka gatunku.	2025-06-02 19:05:10.504727
72	978-0-8364-6474-0	982	4	Wciągająca fabuła.	2024-12-18 12:33:13.127669
73	978-0-8364-6474-0	982	2	Wciągająca fabuła.	2025-04-24 17:07:41.642341
74	978-0-8364-6474-0	982	8	Nudna, nie polecam.	2025-10-22 23:07:23.669506
75	978-0-8364-6474-0	982	4	Trudno się czyta.	2025-07-06 09:48:26.951963
76	978-0-8364-6474-0	982	3	Nudna, nie polecam.	2025-01-26 07:10:26.83748
77	978-0-8364-6474-0	982	1	Świetna książka!	2025-03-12 13:12:21.484575
78	978-0-8364-6474-0	982	7	Polecam każdemu.	2025-03-19 08:11:26.068634
79	978-0-8364-6474-0	982	2	Klasyka gatunku.	2025-07-18 09:16:16.765821
80	978-0-8364-6474-0	982	10	Polecam każdemu.	2025-08-27 18:06:48.057738
81	978-0-8364-6474-0	982	5	Polecam każdemu.	2025-02-11 04:43:43.831461
82	978-0-8364-6474-0	982	7	Klasyka gatunku.	2025-07-21 17:12:58.616014
83	978-0-8364-6474-0	982	1	Klasyka gatunku.	2025-10-15 21:27:22.118811
84	978-0-8364-6474-0	982	1	Nudna, nie polecam.	2025-09-26 16:40:45.200941
85	978-0-8364-6474-0	982	9	Wciągająca fabuła.	2025-06-05 05:58:59.579212
86	978-0-8364-6474-0	982	9	Nudna, nie polecam.	2025-11-02 02:32:09.148518
87	978-0-8364-6474-0	982	5	Świetna książka!	2025-07-06 11:40:43.365383
88	978-0-8364-6474-0	982	6	Świetna książka!	2025-11-01 10:40:03.787449
89	978-0-8364-6474-0	982	9	Polecam każdemu.	2025-04-08 12:48:05.30283
90	978-0-8364-6474-0	982	2	Świetna książka!	2025-12-02 13:45:23.748518
91	978-0-8364-6474-0	982	3	Nudna, nie polecam.	2025-07-17 11:16:32.03442
92	978-0-8364-6474-0	982	9	Wciągająca fabuła.	2025-05-31 04:45:41.568632
93	978-0-8364-6474-0	982	3	Klasyka gatunku.	2025-01-05 21:45:59.551828
94	978-0-8364-6474-0	982	10	Polecam każdemu.	2025-02-03 18:47:04.04553
95	978-0-8364-6474-0	982	9	Polecam każdemu.	2025-04-26 13:22:36.429442
96	978-0-8364-6474-0	982	1	Zaskakujące zakończenie.	2025-06-10 19:24:47.347718
97	978-0-8364-6474-0	982	8	Klasyka gatunku.	2025-06-23 09:37:12.19362
98	978-0-8364-6474-0	982	5	Wciągająca fabuła.	2025-05-31 21:15:03.45291
99	978-0-8364-6474-0	982	4	Klasyka gatunku.	2025-02-16 06:07:35.773057
100	978-0-8364-6474-0	982	9	Strata czasu.	2025-01-07 17:40:58.615921
101	978-0-8364-6474-0	982	4	Nudna, nie polecam.	2025-04-17 23:46:59.629402
102	978-0-8364-6474-0	982	2	Zaskakujące zakończenie.	2025-03-16 05:21:41.722068
103	978-0-8364-6474-0	982	5	Strata czasu.	2025-04-26 19:21:45.78702
104	978-0-8364-6474-0	982	7	Trudno się czyta.	2025-04-16 06:15:28.689995
105	978-0-8364-6474-0	982	10	Zaskakujące zakończenie.	2025-06-05 03:33:19.411377
106	978-0-8364-6474-0	982	3	Świetna książka!	2025-04-17 23:35:41.209651
107	978-0-8364-6474-0	982	6	Wciągająca fabuła.	2025-04-03 21:21:52.043167
108	978-0-8364-6474-0	982	8	Wciągająca fabuła.	2025-03-07 20:41:08.599537
109	978-0-8364-6474-0	982	9	Nudna, nie polecam.	2025-09-04 11:09:30.369631
110	978-0-8364-6474-0	982	7	Świetna książka!	2025-11-05 12:45:20.10888
111	978-0-8364-6474-0	982	1	Świetna książka!	2025-02-23 19:42:20.825339
112	978-0-8364-6474-0	982	8	Strata czasu.	2025-12-17 12:23:35.491913
113	978-0-8364-6474-0	982	3	Strata czasu.	2025-08-09 23:13:01.726006
114	978-0-8364-6474-0	982	6	Wciągająca fabuła.	2025-09-19 22:43:02.067526
115	978-0-8364-6474-0	982	6	Zaskakujące zakończenie.	2025-04-21 21:23:53.490942
116	978-0-8364-6474-0	982	9	Wciągająca fabuła.	2025-03-05 07:40:17.196136
117	978-0-8364-6474-0	982	7	Strata czasu.	2025-08-18 23:32:32.532062
118	978-0-8364-6474-0	982	8	Polecam każdemu.	2025-04-18 00:39:28.234431
119	978-0-8364-6474-0	982	2	Świetna książka!	2025-12-13 02:33:16.049759
120	978-0-8364-6474-0	982	1	Świetna książka!	2025-10-09 02:53:26.648503
\.


--
-- Data for Name: ksiazki; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ksiazki (id_ksiazki, nr_isbn, numer_inwentarzowy, tytul, autor, id_kategorii, id_filii, rok_wydania, numer_edycji, liczba_stron, dostepna_online, opis, status) FROM stdin;
\.


--
-- Data for Name: rezerwacje; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rezerwacje (id_rezerwacji, nr_isbn, id_osoby, id_filii, data_rezerwacji, status, wygasa_dnia) FROM stdin;
1	978-0-941793-73-5	4166	3	2025-11-18 08:34:46.599059	wygasła	2025-12-21
2	978-0-941793-73-5	4166	3	2025-11-22 01:54:05.582658	zrealizowana	2025-12-19
3	978-0-941793-73-5	4166	3	2025-11-23 16:30:38.199522	oczekująca	2025-12-18
4	978-0-941793-73-5	4166	3	2025-11-18 00:30:50.75104	zrealizowana	2025-12-19
5	978-0-941793-73-5	4166	3	2025-12-15 01:38:30.939878	oczekująca	2025-12-23
6	978-0-941793-73-5	4166	3	2025-12-13 09:26:46.312281	wygasła	2025-12-23
7	978-0-941793-73-5	4166	3	2025-12-08 11:42:06.393698	anulowana	2025-12-23
8	978-0-941793-73-5	4166	3	2025-12-06 02:39:24.485009	wygasła	2025-12-20
9	978-0-941793-73-5	4166	3	2025-12-01 21:48:53.377329	zrealizowana	2025-12-24
10	978-0-941793-73-5	4166	3	2025-11-23 03:00:01.043579	oczekująca	2025-12-17
11	978-0-941793-73-5	4166	3	2025-12-11 17:09:46.486576	zrealizowana	2025-12-17
12	978-0-941793-73-5	4166	3	2025-11-28 00:40:45.979628	zrealizowana	2025-12-17
13	978-0-941793-73-5	4166	3	2025-11-19 00:40:06.863631	anulowana	2025-12-23
14	978-0-941793-73-5	4166	3	2025-12-17 00:17:07.222633	zrealizowana	2025-12-18
15	978-0-941793-73-5	4166	3	2025-12-05 03:36:28.406938	anulowana	2025-12-18
16	978-0-941793-73-5	4166	3	2025-12-06 03:14:19.15928	wygasła	2025-12-17
17	978-0-941793-73-5	4166	3	2025-12-03 08:18:37.498733	zrealizowana	2025-12-21
18	978-0-941793-73-5	4166	3	2025-11-19 02:06:50.753007	anulowana	2025-12-17
19	978-0-941793-73-5	4166	3	2025-12-01 16:51:24.597269	zrealizowana	2025-12-24
20	978-0-941793-73-5	4166	3	2025-11-29 14:16:29.422381	zrealizowana	2025-12-19
21	978-0-941793-73-5	4166	3	2025-12-02 01:13:13.182459	zrealizowana	2025-12-22
22	978-0-941793-73-5	4166	3	2025-12-10 19:32:31.582468	zrealizowana	2025-12-22
23	978-0-941793-73-5	4166	3	2025-12-03 22:14:45.847199	oczekująca	2025-12-18
24	978-0-941793-73-5	4166	3	2025-12-14 09:35:31.730414	zrealizowana	2025-12-21
25	978-0-941793-73-5	4166	3	2025-12-08 01:56:30.157598	oczekująca	2025-12-22
26	978-0-941793-73-5	4166	3	2025-11-25 16:45:56.042113	oczekująca	2025-12-19
27	978-0-941793-73-5	4166	3	2025-12-14 07:59:16.371128	oczekująca	2025-12-20
28	978-0-941793-73-5	4166	3	2025-12-03 03:19:48.119349	zrealizowana	2025-12-20
29	978-0-941793-73-5	4166	3	2025-11-21 06:07:53.473726	zrealizowana	2025-12-19
30	978-0-941793-73-5	4166	3	2025-12-16 12:36:19.380193	wygasła	2025-12-22
31	978-0-941793-73-5	4166	3	2025-11-20 16:29:37.045292	oczekująca	2025-12-21
32	978-0-941793-73-5	4166	3	2025-12-04 02:53:14.468806	zrealizowana	2025-12-21
33	978-0-941793-73-5	4166	3	2025-11-19 18:34:03.138735	oczekująca	2025-12-18
34	978-0-941793-73-5	4166	3	2025-11-28 10:11:38.475651	zrealizowana	2025-12-18
35	978-0-941793-73-5	4166	3	2025-11-18 08:53:34.337173	zrealizowana	2025-12-23
36	978-0-941793-73-5	4166	3	2025-12-14 10:51:58.752193	wygasła	2025-12-21
37	978-0-941793-73-5	4166	3	2025-11-27 19:10:53.818897	wygasła	2025-12-22
38	978-0-941793-73-5	4166	3	2025-12-02 22:20:18.322917	anulowana	2025-12-23
39	978-0-941793-73-5	4166	3	2025-11-22 13:52:45.489048	oczekująca	2025-12-18
40	978-0-941793-73-5	4166	3	2025-12-13 09:44:10.022715	zrealizowana	2025-12-24
41	978-0-941793-73-5	4166	3	2025-11-20 05:09:08.535983	anulowana	2025-12-18
42	978-0-941793-73-5	4166	3	2025-12-02 13:40:03.016975	anulowana	2025-12-23
43	978-0-941793-73-5	4166	3	2025-11-20 18:36:09.420861	zrealizowana	2025-12-24
44	978-0-941793-73-5	4166	3	2025-11-24 03:09:08.763324	oczekująca	2025-12-19
45	978-0-941793-73-5	4166	3	2025-11-23 20:22:50.49266	wygasła	2025-12-22
46	978-0-941793-73-5	4166	3	2025-11-20 00:37:06.208007	oczekująca	2025-12-24
47	978-0-941793-73-5	4166	3	2025-12-03 13:14:10.940317	oczekująca	2025-12-19
48	978-0-941793-73-5	4166	3	2025-12-01 14:09:33.646003	zrealizowana	2025-12-24
49	978-0-941793-73-5	4166	3	2025-11-26 15:07:10.001508	oczekująca	2025-12-19
50	978-0-941793-73-5	4166	3	2025-11-26 11:19:47.128614	wygasła	2025-12-21
51	978-0-941793-73-5	4166	3	2025-12-01 11:36:51.880946	wygasła	2025-12-22
52	978-0-941793-73-5	4166	3	2025-12-10 04:36:00.295082	wygasła	2025-12-21
53	978-0-941793-73-5	4166	3	2025-12-12 03:55:41.866204	oczekująca	2025-12-18
54	978-0-941793-73-5	4166	3	2025-11-25 20:14:02.874491	zrealizowana	2025-12-17
55	978-0-941793-73-5	4166	3	2025-11-24 08:13:13.451153	wygasła	2025-12-18
56	978-0-941793-73-5	4166	3	2025-11-24 09:52:30.857235	oczekująca	2025-12-23
57	978-0-941793-73-5	4166	3	2025-12-04 15:53:21.767014	oczekująca	2025-12-24
58	978-0-941793-73-5	4166	3	2025-12-13 11:28:03.932975	oczekująca	2025-12-22
59	978-0-941793-73-5	4166	3	2025-11-19 18:38:56.255021	zrealizowana	2025-12-24
60	978-0-941793-73-5	4166	3	2025-11-25 23:54:56.498318	wygasła	2025-12-20
61	978-0-941793-73-5	4166	3	2025-11-20 07:43:40.928531	oczekująca	2025-12-18
62	978-0-941793-73-5	4166	3	2025-11-27 11:29:55.306655	zrealizowana	2025-12-19
63	978-0-941793-73-5	4166	3	2025-12-12 23:57:34.75883	wygasła	2025-12-24
64	978-0-941793-73-5	4166	3	2025-12-03 21:51:45.526204	oczekująca	2025-12-24
65	978-0-941793-73-5	4166	3	2025-12-08 17:57:49.938073	zrealizowana	2025-12-23
66	978-0-941793-73-5	4166	3	2025-12-10 15:16:49.957295	oczekująca	2025-12-23
67	978-0-941793-73-5	4166	3	2025-11-28 09:02:46.487852	oczekująca	2025-12-21
68	978-0-941793-73-5	4166	3	2025-11-28 09:38:35.07052	anulowana	2025-12-21
69	978-0-941793-73-5	4166	3	2025-12-07 14:42:54.081176	wygasła	2025-12-22
70	978-0-941793-73-5	4166	3	2025-12-06 19:08:24.445876	anulowana	2025-12-17
71	978-0-941793-73-5	4166	3	2025-11-27 20:06:19.251535	oczekująca	2025-12-21
72	978-0-941793-73-5	4166	3	2025-12-16 02:06:32.120284	oczekująca	2025-12-22
73	978-0-941793-73-5	4166	3	2025-11-30 20:12:53.887891	anulowana	2025-12-24
74	978-0-941793-73-5	4166	3	2025-12-07 08:16:26.486386	anulowana	2025-12-18
75	978-0-941793-73-5	4166	3	2025-12-12 04:44:05.028318	wygasła	2025-12-19
76	978-0-941793-73-5	4166	3	2025-11-25 04:25:46.178121	zrealizowana	2025-12-18
77	978-0-941793-73-5	4166	3	2025-11-22 16:26:03.627977	anulowana	2025-12-19
78	978-0-941793-73-5	4166	3	2025-12-11 18:45:43.650492	zrealizowana	2025-12-22
79	978-0-941793-73-5	4166	3	2025-12-05 10:52:10.126632	anulowana	2025-12-24
80	978-0-941793-73-5	4166	3	2025-11-23 06:03:48.152092	oczekująca	2025-12-20
81	978-0-941793-73-5	4166	3	2025-12-08 02:05:08.229618	zrealizowana	2025-12-21
82	978-0-941793-73-5	4166	3	2025-11-30 03:29:01.434325	wygasła	2025-12-20
83	978-0-941793-73-5	4166	3	2025-11-18 06:44:56.951184	zrealizowana	2025-12-18
84	978-0-941793-73-5	4166	3	2025-12-17 05:52:26.90856	zrealizowana	2025-12-23
85	978-0-941793-73-5	4166	3	2025-12-09 08:14:46.343978	zrealizowana	2025-12-20
86	978-0-941793-73-5	4166	3	2025-12-07 06:31:28.900422	oczekująca	2025-12-23
87	978-0-941793-73-5	4166	3	2025-12-02 19:46:22.270449	anulowana	2025-12-20
88	978-0-941793-73-5	4166	3	2025-12-06 12:44:57.659263	zrealizowana	2025-12-20
89	978-0-941793-73-5	4166	3	2025-11-21 19:10:25.336333	zrealizowana	2025-12-21
90	978-0-941793-73-5	4166	3	2025-11-18 07:47:29.218782	zrealizowana	2025-12-17
91	978-0-941793-73-5	4166	3	2025-11-29 08:58:46.320875	oczekująca	2025-12-23
92	978-0-941793-73-5	4166	3	2025-12-10 22:41:39.147377	oczekująca	2025-12-18
93	978-0-941793-73-5	4166	3	2025-12-15 18:27:55.355872	oczekująca	2025-12-22
94	978-0-941793-73-5	4166	3	2025-12-12 06:59:44.838297	oczekująca	2025-12-20
95	978-0-941793-73-5	4166	3	2025-11-18 23:13:37.598823	anulowana	2025-12-19
96	978-0-941793-73-5	4166	3	2025-12-11 09:30:04.513868	zrealizowana	2025-12-18
97	978-0-941793-73-5	4166	3	2025-12-10 17:15:49.420882	anulowana	2025-12-17
98	978-0-941793-73-5	4166	3	2025-11-25 15:52:42.591182	zrealizowana	2025-12-20
99	978-0-941793-73-5	4166	3	2025-11-28 21:20:39.257461	anulowana	2025-12-18
100	978-0-941793-73-5	4166	3	2025-11-20 07:35:28.475693	oczekująca	2025-12-20
101	978-0-941793-73-5	4166	3	2025-11-20 15:56:29.051017	wygasła	2025-12-24
102	978-0-941793-73-5	4166	3	2025-12-09 17:10:31.033367	anulowana	2025-12-22
103	978-0-941793-73-5	4166	3	2025-12-14 22:17:15.221436	anulowana	2025-12-17
104	978-0-941793-73-5	4166	3	2025-12-04 05:09:49.243133	zrealizowana	2025-12-22
105	978-0-941793-73-5	4166	3	2025-11-17 15:44:04.680159	zrealizowana	2025-12-18
106	978-0-941793-73-5	4166	3	2025-11-20 15:48:18.789943	oczekująca	2025-12-18
107	978-0-941793-73-5	4166	3	2025-12-07 14:58:51.686587	anulowana	2025-12-18
108	978-0-941793-73-5	4166	3	2025-11-28 03:09:08.12413	zrealizowana	2025-12-17
109	978-0-941793-73-5	4166	3	2025-12-10 10:03:03.830116	anulowana	2025-12-24
110	978-0-941793-73-5	4166	3	2025-12-09 00:12:00.029671	oczekująca	2025-12-23
111	978-0-941793-73-5	4166	3	2025-12-02 11:09:44.920001	zrealizowana	2025-12-23
112	978-0-941793-73-5	4166	3	2025-12-06 12:51:25.964101	oczekująca	2025-12-24
113	978-0-941793-73-5	4166	3	2025-12-13 23:01:26.543022	zrealizowana	2025-12-19
114	978-0-941793-73-5	4166	3	2025-11-30 14:27:13.754953	oczekująca	2025-12-21
115	978-0-941793-73-5	4166	3	2025-12-10 14:18:09.595445	wygasła	2025-12-23
116	978-0-941793-73-5	4166	3	2025-12-08 05:17:07.980092	anulowana	2025-12-18
117	978-0-941793-73-5	4166	3	2025-12-04 05:30:27.074059	wygasła	2025-12-19
118	978-0-941793-73-5	4166	3	2025-12-17 02:48:57.074045	wygasła	2025-12-19
119	978-0-941793-73-5	4166	3	2025-11-19 15:03:10.455354	zrealizowana	2025-12-23
120	978-0-941793-73-5	4166	3	2025-12-02 10:37:56.663123	oczekująca	2025-12-21
121	978-0-941793-73-5	4166	3	2025-12-16 13:23:16.952477	oczekująca	2025-12-18
122	978-0-941793-73-5	4166	3	2025-12-02 18:15:12.054505	wygasła	2025-12-23
123	978-0-941793-73-5	4166	3	2025-12-14 16:47:40.207983	wygasła	2025-12-22
124	978-0-941793-73-5	4166	3	2025-11-19 15:44:27.733277	anulowana	2025-12-18
125	978-0-941793-73-5	4166	3	2025-11-23 19:57:52.99312	wygasła	2025-12-19
126	978-0-941793-73-5	4166	3	2025-12-16 14:39:35.647766	oczekująca	2025-12-21
127	978-0-941793-73-5	4166	3	2025-12-09 02:47:12.701522	oczekująca	2025-12-23
128	978-0-941793-73-5	4166	3	2025-12-08 16:51:48.435107	zrealizowana	2025-12-20
129	978-0-941793-73-5	4166	3	2025-12-14 19:54:14.404382	wygasła	2025-12-21
130	978-0-941793-73-5	4166	3	2025-11-21 00:28:48.362795	oczekująca	2025-12-22
\.


--
-- Data for Name: rodzaje_kar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rodzaje_kar (id_rodzaju_kary, nazwa_kary, opis) FROM stdin;
1	Przetrzymanie	Naliczone za każdy dzień zwłoki po terminie zwrotu.
2	Zniszczenie	Opłata za uszkodzenie fizyczne książki (zalanie, rozdarcie).
3	Zgubienie	Opłata stanowiąca równowartość zgubionej pozycji + koszt manipulacyjny.
4	Przetrzymanie	Kara za zwłokę w zwrocie.
5	Zniszczenie	Kara za uszkodzenie fizyczne.
6	Zgubienie	Zwrot kosztów zgubionej pozycji.
\.


--
-- Data for Name: uzytkownicy; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.uzytkownicy (id_osoby, imie, nazwisko, plec, login, email, hash_hasla, sol_do_hasla, pytanie_pomocnicze, hash_odpowiedzi, url_profilowe, data_zalozenia_konta, aktywne) FROM stdin;
0	Roderyk	Krajna	MEZCZYZNA	user0	user0@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1	Gracjan	Dytmar	MEZCZYZNA	user1	user1@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2	Avihieia	Leyser	KOBIETA	user2	user2@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3	Rużena	Bunma	KOBIETA	user3	user3@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4	Meihan	Krzyżosiak	KOBIETA	user4	user4@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
5	Żasmina	Masiarczyk	KOBIETA	user5	user5@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
6	Judilyn	Brzenska	KOBIETA	user6	user6@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
7	Sharyn	Dragańczyk	KOBIETA	user7	user7@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
8	Zbigniew	Drybczewski	MEZCZYZNA	user8	user8@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
9	Bert	Nakielski	MEZCZYZNA	user9	user9@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
10	Hamza	Hile	MEZCZYZNA	user10	user10@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
11	Svyatoslava	Supino	KOBIETA	user11	user11@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
12	Mirod	Pijewski	MEZCZYZNA	user12	user12@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
13	Wolimir	Szwaczkowski	MEZCZYZNA	user13	user13@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
14	Teodor	Szwech	MEZCZYZNA	user14	user14@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
15	Franciszek	Ostapowicz	MEZCZYZNA	user15	user15@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
16	Olgierd	Samojlik	MEZCZYZNA	user16	user16@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
17	Samuel	Dobrołowicz	MEZCZYZNA	user17	user17@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
18	Dawid	Bohaczyk	MEZCZYZNA	user18	user18@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
19	Otto	Wójs	MEZCZYZNA	user19	user19@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
20	Franzeska	Pospiechowa	KOBIETA	user20	user20@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
21	Herbert	Skubis	MEZCZYZNA	user21	user21@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
22	Rużena	Zuck	KOBIETA	user22	user22@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
23	Roland	Boś	MEZCZYZNA	user23	user23@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
24	Akvile	Piskor-ignatowicz	KOBIETA	user24	user24@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
25	Emanuel	Rzepiela	MEZCZYZNA	user25	user25@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
26	Aishet	Möllerström	KOBIETA	user26	user26@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
27	Miłowan	Skupina	MEZCZYZNA	user27	user27@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
28	Annasz	Niciński	MEZCZYZNA	user28	user28@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
29	Caitlyn	Żyłka	NIEOKRESLONY	user29	user29@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
30	Wespazjan	Kremser	MEZCZYZNA	user30	user30@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
31	Meya	Burzec-burzyńska	KOBIETA	user31	user31@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
32	Viarika	Małkińska	KOBIETA	user32	user32@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
33	Eni	Cejrowska	KOBIETA	user33	user33@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
34	Saikal	Szukałowicz	KOBIETA	user34	user34@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
35	Wahid	Trojanowski	MEZCZYZNA	user35	user35@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
36	Oresia	Mihov	KOBIETA	user36	user36@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
37	Dajmir	Peričić	MEZCZYZNA	user37	user37@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
38	Kochan	Ostendorf	MEZCZYZNA	user38	user38@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
39	Miłogost	Armatys	MEZCZYZNA	user39	user39@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
40	Vitalina	Blewa	KOBIETA	user40	user40@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
41	Wilhelm	Rogórz	MEZCZYZNA	user41	user41@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
42	Shokhida	Stankevičiūtė	KOBIETA	user42	user42@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
43	Krzysztof	Plesiński	MEZCZYZNA	user43	user43@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
44	Maria-cristina	Huliaikina	KOBIETA	user44	user44@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
45	Rezi	Ukalski	MEZCZYZNA	user45	user45@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
46	Roger	Suchan	MEZCZYZNA	user46	user46@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
47	Dzwonimierz	Jargieło	MEZCZYZNA	user47	user47@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
48	Jingle	Lew kiedrowska	KOBIETA	user48	user48@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
49	Johanna	Ostroverkhova	KOBIETA	user49	user49@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
50	Cyprian	Kopczak	MEZCZYZNA	user50	user50@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
51	Sura	Qosja	KOBIETA	user51	user51@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
52	Ffion	Ordza	KOBIETA	user52	user52@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
53	Lesław	Musur	MEZCZYZNA	user53	user53@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
54	Maisy	Galec	KOBIETA	user54	user54@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
55	Oguljemal	Kleissa	KOBIETA	user55	user55@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
56	Uswatun	Szpilma	KOBIETA	user56	user56@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
57	Linet	Maruda	KOBIETA	user57	user57@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
58	Makhabat	Ivantsok	KOBIETA	user58	user58@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
59	Żarko	Rytter	MEZCZYZNA	user59	user59@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
60	Jiun	Shvaika	KOBIETA	user60	user60@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
61	Suhee	Solopun	KOBIETA	user61	user61@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
62	Sheyma	Melcer-kusz	KOBIETA	user62	user62@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
63	Subheksha	Dos santos lemos	KOBIETA	user63	user63@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
64	Lilja	Rozpodniuk	KOBIETA	user64	user64@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
65	Nesli̇şah	Wandziura	KOBIETA	user65	user65@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
66	Borys	Bonawenturczak	MEZCZYZNA	user66	user66@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
67	Marionella	D'amario	KOBIETA	user67	user67@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
68	Miralda	Sądur	KOBIETA	user68	user68@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
69	Natalia-maria	Rydel-johnston	KOBIETA	user69	user69@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
70	Wahid	Misiakiewicz	MEZCZYZNA	user70	user70@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
71	Eugeniusz	Folwarski	MEZCZYZNA	user71	user71@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
72	Yeliena	Winke	KOBIETA	user72	user72@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
73	Nahal	Onufran	KOBIETA	user73	user73@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
74	Jiang	Zaremba-najda	KOBIETA	user74	user74@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
75	Walerian	Adrianek	MEZCZYZNA	user75	user75@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
76	Rosłan	Czepłowski	MEZCZYZNA	user76	user76@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
77	Somin	Lisanowa	KOBIETA	user77	user77@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
78	Heide-maria	Walentiak	KOBIETA	user78	user78@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
79	Anzhela	Eisenberger-caban	KOBIETA	user79	user79@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
80	Eteri	Schendziolek	KOBIETA	user80	user80@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
81	Błażej	Dziuban	MEZCZYZNA	user81	user81@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
82	Anatol	Sienokosow	MEZCZYZNA	user82	user82@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
83	Jacek	Hładki	MEZCZYZNA	user83	user83@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
84	Igor	Oliński	MEZCZYZNA	user84	user84@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
85	Songhyun	Truba	KOBIETA	user85	user85@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
86	Ivica	Mauerová	NIEOKRESLONY	user86	user86@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
87	Vimla	Cherneiko	KOBIETA	user87	user87@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
88	Sylwan	Oziembło	MEZCZYZNA	user88	user88@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
89	Cesia	Madalyr	KOBIETA	user89	user89@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
90	Tobiasz	Szymankiewicz	MEZCZYZNA	user90	user90@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
91	Wanida	Notarieva	KOBIETA	user91	user91@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
92	Rysława	Lebezhanska	KOBIETA	user92	user92@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
93	Vasilka	Sagi	KOBIETA	user93	user93@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
94	Adriana cristina	Remion	KOBIETA	user94	user94@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
95	Rafif	Haberek	KOBIETA	user95	user95@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
96	Fryc	Jobda	MEZCZYZNA	user96	user96@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
97	Yuleisi	Żałobowska	KOBIETA	user97	user97@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
98	Andreia	Květová	KOBIETA	user98	user98@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
99	Mojmir	Lubiński	MEZCZYZNA	user99	user99@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
100	Florentyn	Łazarski	MEZCZYZNA	user100	user100@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
101	Oswald	Czak	MEZCZYZNA	user101	user101@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
102	Ramune	Miats	KOBIETA	user102	user102@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
103	Bogumir	Gółkiewicz	MEZCZYZNA	user103	user103@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
104	Dżamil	Paterski	MEZCZYZNA	user104	user104@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
105	Lupita	Kolodrivska	KOBIETA	user105	user105@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
106	Isabel maria	Dalka-czoprowska	KOBIETA	user106	user106@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
107	Beat	Mąkos	MEZCZYZNA	user107	user107@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
108	Xuefen	Huss	KOBIETA	user108	user108@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
109	Nieva	Serniuk	KOBIETA	user109	user109@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
110	Juri	Pynka	MEZCZYZNA	user110	user110@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
111	Krystian	Chalecki	MEZCZYZNA	user111	user111@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
112	Witołd	Stawinoga	MEZCZYZNA	user112	user112@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
113	Tęgomir	Gaskill	MEZCZYZNA	user113	user113@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
114	Eugeniia	Chakkour	KOBIETA	user114	user114@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
115	Ludomił	Raifura	MEZCZYZNA	user115	user115@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
116	Manfred	Ipnarski	MEZCZYZNA	user116	user116@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
117	Medard	Bade	MEZCZYZNA	user117	user117@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
118	Thuc anh	Tarkhova	KOBIETA	user118	user118@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
119	Leonard	Łucki	MEZCZYZNA	user119	user119@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
120	Lenart	Mitruk	MEZCZYZNA	user120	user120@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
121	Varsenik	Zdobyliak	KOBIETA	user121	user121@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
122	Magnus	Grajczyk	MEZCZYZNA	user122	user122@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
123	Bożydar	Lawitz	MEZCZYZNA	user123	user123@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
124	Sędomir	Torchała	MEZCZYZNA	user124	user124@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
125	Solidea	Kishinska	KOBIETA	user125	user125@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
126	Ji min	Pantyukhina	KOBIETA	user126	user126@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
127	Ananiasz	Trykacz	MEZCZYZNA	user127	user127@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
128	Kamil	Daraż	KOBIETA	user128	user128@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
129	Radowit	Chachuła	MEZCZYZNA	user129	user129@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
130	Władysław	Sygut	MEZCZYZNA	user130	user130@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
131	Tomasz	Precht	MEZCZYZNA	user131	user131@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
132	Schanel	Zalewska-małek	KOBIETA	user132	user132@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
133	Ewald	Mirczewski	MEZCZYZNA	user133	user133@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
134	Cireaşa	Shchekolkina	KOBIETA	user134	user134@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
135	Tobiasz	Rynarzewski	MEZCZYZNA	user135	user135@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
136	Stephania	Tedeshvili	KOBIETA	user136	user136@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
137	Jaromir	Herreman	MEZCZYZNA	user137	user137@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
138	Enikő	Baranowska-mróz	KOBIETA	user138	user138@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
139	August	Wasyljew	MEZCZYZNA	user139	user139@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
140	Żelisław	Basmenji	MEZCZYZNA	user140	user140@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
141	Roman	Konończuk	MEZCZYZNA	user141	user141@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
142	Hulsum	Kosylkyna	KOBIETA	user142	user142@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
143	Prajakta	Wondrak	KOBIETA	user143	user143@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
144	Ksawery	Mikiel	MEZCZYZNA	user144	user144@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
145	Irene	Janus da palma	KOBIETA	user145	user145@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
146	Mikołaj	Kosmydel	MEZCZYZNA	user146	user146@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
147	Dżulia	Khaitova	KOBIETA	user147	user147@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
148	Margrit	Haddour	KOBIETA	user148	user148@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
149	Bogusław	Orzełowski	MEZCZYZNA	user149	user149@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
150	Juliána	Kysilivska	KOBIETA	user150	user150@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
151	Catalina	Unfericht	KOBIETA	user151	user151@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
152	Bich hong	Proniewicz	KOBIETA	user152	user152@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
153	Lareb	Topornytska	KOBIETA	user153	user153@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
154	Tulimir	Bronkowski	MEZCZYZNA	user154	user154@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
155	Sarolta	Yuzvyshyn	KOBIETA	user155	user155@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
156	Laurencjusz	Wojtaniewski	MEZCZYZNA	user156	user156@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
157	Konsuelo	Gorlaga	KOBIETA	user157	user157@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
158	Dżuletta	Pregler	KOBIETA	user158	user158@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
159	Laurencjusz	Krocz	MEZCZYZNA	user159	user159@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
160	Radosław	Skoplak	MEZCZYZNA	user160	user160@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
161	Romuald	Gorajek	MEZCZYZNA	user161	user161@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
162	Nikodem	Gorzki	MEZCZYZNA	user162	user162@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
163	Yaren	Koryliuk	KOBIETA	user163	user163@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
164	Wenancjusz	Rodewald	MEZCZYZNA	user164	user164@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
165	Iryna-sofiia	Fenders	KOBIETA	user165	user165@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
166	Casiana	Sidiak	KOBIETA	user166	user166@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
167	Cäcilia	Kępa-żurek	KOBIETA	user167	user167@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
168	Radogost	Frydek	MEZCZYZNA	user168	user168@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
169	Thi tra my	Tarandzio	KOBIETA	user169	user169@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
170	Mojżesz	Falkenberg	MEZCZYZNA	user170	user170@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
171	Sanah	Sztybel	KOBIETA	user171	user171@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
172	Chourouk	Tsos	KOBIETA	user172	user172@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
173	Nikodem	Masur	MEZCZYZNA	user173	user173@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
174	Dulguun	Dzedushkina	KOBIETA	user174	user174@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
175	Lucile	Młodynia	KOBIETA	user175	user175@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
176	Yanan	Kobzenko	KOBIETA	user176	user176@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
177	Wojsław	D'antonio	MEZCZYZNA	user177	user177@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
178	Danisław	Pankau	MEZCZYZNA	user178	user178@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
179	Gomathi	Maziejko	KOBIETA	user179	user179@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
180	Gardomir	Spozyto	MEZCZYZNA	user180	user180@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
181	Hriska	Latanowicz-dos santos	KOBIETA	user181	user181@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
182	Dyter	Szaciłło	MEZCZYZNA	user182	user182@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
183	Noga	Habbal	KOBIETA	user183	user183@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
184	Tanzil	Satsiuk	KOBIETA	user184	user184@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
185	Polonia	Kassir	KOBIETA	user185	user185@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
186	Effrosyni	Szarama	KOBIETA	user186	user186@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
187	Łukasz	Chodzyński	MEZCZYZNA	user187	user187@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
188	Asifa	Sierzchuła	KOBIETA	user188	user188@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
189	Zhenying	Kukulis	KOBIETA	user189	user189@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
190	Krzysztof	Wilczarski	MEZCZYZNA	user190	user190@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
191	Dārta	Rexhepaj	KOBIETA	user191	user191@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
192	Lizeth	Jakubusek	KOBIETA	user192	user192@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
193	Niloufer	Gic	KOBIETA	user193	user193@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
194	Hanelore	Hnidovska	KOBIETA	user194	user194@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
195	Thuy trang	Obodzinska	KOBIETA	user195	user195@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
196	Klemens	Krala	MEZCZYZNA	user196	user196@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
197	Jerzy	Wittbrodt	MEZCZYZNA	user197	user197@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
198	Aleks	Maluszycki	MEZCZYZNA	user198	user198@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
199	Bodosław	Bienias	MEZCZYZNA	user199	user199@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
200	Claudia rocio	Ficke	KOBIETA	user200	user200@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
201	Brielle	Blagynia	KOBIETA	user201	user201@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
202	Shova	Ślipczuk	KOBIETA	user202	user202@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
203	Rafał	Opałko	MEZCZYZNA	user203	user203@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
204	Margarit	Barnden	KOBIETA	user204	user204@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
205	Wojciech	Wyrzycki	MEZCZYZNA	user205	user205@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
206	Emeli	Piri	KOBIETA	user206	user206@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
207	Lągina	Miakhkota	KOBIETA	user207	user207@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
208	Ami	Drabeniuk	KOBIETA	user208	user208@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
209	Apalinaryia	Pietraniuk	KOBIETA	user209	user209@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
210	Thi huong	Betsun	KOBIETA	user210	user210@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
211	Ildefons	Suśniak	MEZCZYZNA	user211	user211@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
212	Nevena	Eitel	KOBIETA	user212	user212@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
213	Nebahat	Sieczka-chróścicka	KOBIETA	user213	user213@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
214	Frida	Höfner	KOBIETA	user214	user214@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
215	Omotola	Piesztal	KOBIETA	user215	user215@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
216	Shuhui	Zanoża	KOBIETA	user216	user216@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
217	Lali maya	Hamilka	KOBIETA	user217	user217@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
218	Kim ngan	Krauz	KOBIETA	user218	user218@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
219	Iwon	Blumert	MEZCZYZNA	user219	user219@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
220	Melanya	Sihydyn	KOBIETA	user220	user220@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
221	Mercédesz	Hasanah	KOBIETA	user221	user221@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
222	Norman	Humeniuk	MEZCZYZNA	user222	user222@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
223	Natan	Pokrzywka	MEZCZYZNA	user223	user223@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
224	Cyprian	Łotysz	MEZCZYZNA	user224	user224@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
225	Klymentyna	Korenik	KOBIETA	user225	user225@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
226	Anatol	Denis	MEZCZYZNA	user226	user226@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
227	Rafał	Tomczak	MEZCZYZNA	user227	user227@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
228	Lubisław	Greczyn	MEZCZYZNA	user228	user228@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
229	Ałła	Marcotte	KOBIETA	user229	user229@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
230	Mariaelena	Bonisławska	KOBIETA	user230	user230@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
231	Lechosław	Świeciak	MEZCZYZNA	user231	user231@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
232	Nat	Drąszcz	KOBIETA	user232	user232@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
233	Elly	Cielusta	KOBIETA	user233	user233@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
234	Feliks	Jacuta	MEZCZYZNA	user234	user234@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
235	Wahid	Buss	MEZCZYZNA	user235	user235@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
236	Jasuf	Wencek	MEZCZYZNA	user236	user236@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
237	Jekaterīna	Klingofer	KOBIETA	user237	user237@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
238	Jędrzej	Thol	MEZCZYZNA	user238	user238@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
239	Awietta	Schirch	KOBIETA	user239	user239@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
240	Dale	Hilburger	KOBIETA	user240	user240@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
241	Tatjána	Maltseva	KOBIETA	user241	user241@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
242	Florian	Dyngus	MEZCZYZNA	user242	user242@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
243	Godfryg	Orchowski	MEZCZYZNA	user243	user243@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
244	Kwietosław	Gabara	MEZCZYZNA	user244	user244@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
245	Agapit	Gomułkiewicz	MEZCZYZNA	user245	user245@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
246	Ndidi	Talbierz	KOBIETA	user246	user246@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
247	Kajfasz	Kabba	MEZCZYZNA	user247	user247@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
248	Zygmunta	Mira	MEZCZYZNA	user248	user248@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
249	Jianfen	Tamashchuk	KOBIETA	user249	user249@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
250	Zenab	Strohmová	KOBIETA	user250	user250@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
251	Rosevilla	Bibina	KOBIETA	user251	user251@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
252	Ryszard	Bachman-mazek	MEZCZYZNA	user252	user252@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
253	Ambroży	Chwojnicki	MEZCZYZNA	user253	user253@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
254	Lexy	Streliana	KOBIETA	user254	user254@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
255	Sophiya	Itrich	KOBIETA	user255	user255@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
256	Benitha	Signorile	KOBIETA	user256	user256@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
257	Ya-hsuan	Klucewicz	KOBIETA	user257	user257@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
258	Felicjan	Zubalewicz	MEZCZYZNA	user258	user258@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
259	Hasan	Matejko	MEZCZYZNA	user259	user259@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
260	Rafał	Lubryka	MEZCZYZNA	user260	user260@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
261	Adhara	Dworańska	KOBIETA	user261	user261@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
262	Sulibor	Cetera	MEZCZYZNA	user262	user262@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
263	Jerzyna	Pawlitzki	KOBIETA	user263	user263@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
264	Aiym	Kierzniewska	KOBIETA	user264	user264@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
265	Maria carolina	Steier	KOBIETA	user265	user265@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
266	Shiella	Kopieczna	KOBIETA	user266	user266@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
267	Miłomir	Łubczonek	MEZCZYZNA	user267	user267@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
268	Tadeusz	Zygmuntowicz	MEZCZYZNA	user268	user268@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
269	Placyd	Kapliński	MEZCZYZNA	user269	user269@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
270	Zoica	Łucyn	KOBIETA	user270	user270@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
271	Wrocisław	Dykty	MEZCZYZNA	user271	user271@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
272	Ahafiia	Kociołkowska	KOBIETA	user272	user272@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
273	Vilena	Borusińska	KOBIETA	user273	user273@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
274	Ekateryna	Ben said	KOBIETA	user274	user274@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
275	Ezaw	Klasura	MEZCZYZNA	user275	user275@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
276	Ludolf	Stusiński	MEZCZYZNA	user276	user276@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
277	Brenda	Omulecka	KOBIETA	user277	user277@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
278	Navdeep kaur	Berezovskaya	KOBIETA	user278	user278@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
279	Vincent	Korbiel	KOBIETA	user279	user279@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
280	Iarina	Filicha	NIEOKRESLONY	user280	user280@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
281	Arkadiia	Pcionek	KOBIETA	user281	user281@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
282	Ha my	Zielińska-janik	KOBIETA	user282	user282@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
283	Bensu	Berhausen	KOBIETA	user283	user283@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
284	Maurycjusz	Kropacz	MEZCZYZNA	user284	user284@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
285	Mirtha	Cheliadyn	KOBIETA	user285	user285@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
286	Anioł	Sandowycz	MEZCZYZNA	user286	user286@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
287	Milan	Makała	MEZCZYZNA	user287	user287@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
288	Petroniusz	Titorenko	MEZCZYZNA	user288	user288@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
289	Niharika	Broznytska	KOBIETA	user289	user289@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
290	Chiori	Bryła	KOBIETA	user290	user290@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
291	Sviylana	Balazhna	KOBIETA	user291	user291@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
292	Juri	Migut	MEZCZYZNA	user292	user292@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
293	Blażena	Szuchnicka	KOBIETA	user293	user293@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
294	Raikhan	Delimarska	KOBIETA	user294	user294@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
295	Solomiia-vasylyna	Ćustić	KOBIETA	user295	user295@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
296	Gracjan	Pietrecki	MEZCZYZNA	user296	user296@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
297	Wissal	Dydoń	KOBIETA	user297	user297@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
298	Yukiyo	Gasparean	KOBIETA	user298	user298@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
299	Rejane	Kravchata	KOBIETA	user299	user299@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
300	Manjula	Skosyrieva	KOBIETA	user300	user300@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
301	Tetana	Varyk	KOBIETA	user301	user301@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
302	Olyvia	Ziemińska	KOBIETA	user302	user302@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
303	Zlatka	Volostnykh	KOBIETA	user303	user303@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
304	Yustsina	Nechmyria	KOBIETA	user304	user304@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
305	Shovkat	Sichova	KOBIETA	user305	user305@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
306	Thị gái	Mazany	KOBIETA	user306	user306@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
307	Rudolf	Uljasz	MEZCZYZNA	user307	user307@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
308	Nicolly	Stysial otaviano	KOBIETA	user308	user308@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
309	Lėja	Badenchuk	KOBIETA	user309	user309@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
310	Ferdynand	Ropela	MEZCZYZNA	user310	user310@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
311	Thi tâm	Galle	KOBIETA	user311	user311@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
312	Revathi	Rawka	KOBIETA	user312	user312@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
313	Zahide	Maile	KOBIETA	user313	user313@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
314	Carmelita	Żelazow	KOBIETA	user314	user314@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
315	Zora	Prużańska	KOBIETA	user315	user315@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
316	Ferdynand	Łączka	MEZCZYZNA	user316	user316@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
317	Diosa	Kachina	KOBIETA	user317	user317@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
318	Konradyn	Garncarek	MEZCZYZNA	user318	user318@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
319	Nguyet	Zagajczyk	KOBIETA	user319	user319@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
320	Wisław	Zając	MEZCZYZNA	user320	user320@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
321	Maggie	Elert-kopeć	KOBIETA	user321	user321@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
322	Zaituna	Kałat	KOBIETA	user322	user322@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
323	Hubert	Cegiełko	MEZCZYZNA	user323	user323@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
324	Korneli	Biłyk	MEZCZYZNA	user324	user324@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
325	Wszebor	Nocon	MEZCZYZNA	user325	user325@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
326	Candace	Skobylko	KOBIETA	user326	user326@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
327	Nera	Hudyna	KOBIETA	user327	user327@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
328	Dzwonimierz	Pytkiewicz	MEZCZYZNA	user328	user328@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
329	Zilia	Masier	KOBIETA	user329	user329@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
330	Adelard	Roth	MEZCZYZNA	user330	user330@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
331	Dzwonimierz	Talarski	MEZCZYZNA	user331	user331@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
332	Julian	Szczugiel	MEZCZYZNA	user332	user332@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
333	Yuliia-solomiia	Degasiuk	KOBIETA	user333	user333@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
334	Gelya	Samovyndiuk	KOBIETA	user334	user334@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
335	Tytus	Kolmajer	MEZCZYZNA	user335	user335@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
336	Sanam	Korin	KOBIETA	user336	user336@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
337	Nava	Mackenzie ross	KOBIETA	user337	user337@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
338	Jarowit	Mandrusz	MEZCZYZNA	user338	user338@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
339	Wit	Gapiński	MEZCZYZNA	user339	user339@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
340	Bronisław	Szperna	MEZCZYZNA	user340	user340@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
341	Jackelyn	Mariana	KOBIETA	user341	user341@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
342	Ajana	Pytaś	NIEOKRESLONY	user342	user342@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
343	Walentyn	Dedolik	MEZCZYZNA	user343	user343@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
344	Mirod	Piętowski	MEZCZYZNA	user344	user344@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
345	Radomir	Markot	MEZCZYZNA	user345	user345@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
346	Singrid	Olszewska-koń	KOBIETA	user346	user346@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
347	Ambroży	Biolik	MEZCZYZNA	user347	user347@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
348	Sław	Szczugiel	MEZCZYZNA	user348	user348@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
349	Lineth	Skopas	KOBIETA	user349	user349@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
350	Amyrah	Mataj	KOBIETA	user350	user350@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
351	Otokar	Pietralik	MEZCZYZNA	user351	user351@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
352	Teofil	Piwnik	MEZCZYZNA	user352	user352@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
353	Gülbahar	Pospieszała	KOBIETA	user353	user353@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
354	Anatol	Mincberg	MEZCZYZNA	user354	user354@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
355	Lambert	Muchalski	MEZCZYZNA	user355	user355@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
356	Olaedo	Papish	KOBIETA	user356	user356@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
357	Elizabeta	Todorczuk	KOBIETA	user357	user357@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
358	Lawia	Chukhina	KOBIETA	user358	user358@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
359	Mariia-marta	Asanashvili	KOBIETA	user359	user359@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
360	Mijgona	Morchało	KOBIETA	user360	user360@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
361	Enkhsaikhan	Wysocka-turek	KOBIETA	user361	user361@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
362	Evrim	Wężyk	KOBIETA	user362	user362@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
363	Dzwonimierz	Stępka	MEZCZYZNA	user363	user363@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
364	Melany	Smurawska	KOBIETA	user364	user364@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
365	Lesław	Zelak	MEZCZYZNA	user365	user365@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
366	Lubomił	Wypich	MEZCZYZNA	user366	user366@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
367	Domasław	Komendecki	MEZCZYZNA	user367	user367@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
368	Thi hai yen	Holumbiievska	KOBIETA	user368	user368@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
369	Honorat	Strzelec	MEZCZYZNA	user369	user369@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
370	Lua	Wollaston	KOBIETA	user370	user370@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
371	Mehnaz	Standowicz	KOBIETA	user371	user371@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
372	Dayana paola	Wozipiwo	KOBIETA	user372	user372@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
373	Alissia	Borodii	KOBIETA	user373	user373@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
374	Waldtrauta	Kornaha	KOBIETA	user374	user374@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
375	Eliasz	Mecler	MEZCZYZNA	user375	user375@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
376	Eligiusz	Pilch	MEZCZYZNA	user376	user376@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
377	Lenart	Rutowicz	MEZCZYZNA	user377	user377@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
378	Mirabell	Cierpioł	KOBIETA	user378	user378@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
379	Carmella	Toborowicz	KOBIETA	user379	user379@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
380	Maria lourdes	Borzestowska	KOBIETA	user380	user380@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
381	Bolebor	Matanowski	MEZCZYZNA	user381	user381@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
382	Pankracy	Gojtowski	MEZCZYZNA	user382	user382@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
383	Shuyi	Reguła	KOBIETA	user383	user383@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
384	Piotr	Kierek	MEZCZYZNA	user384	user384@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
385	Mojżesz	Kołtunik	MEZCZYZNA	user385	user385@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
386	Juri	Jarombek	MEZCZYZNA	user386	user386@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
387	Zulaykho	Hagar	KOBIETA	user387	user387@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
388	Emőke	Bachorek	KOBIETA	user388	user388@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
389	Nadiia-alina	Akolińska	KOBIETA	user389	user389@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
390	Hasnaa	Eksztejn	KOBIETA	user390	user390@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
391	Wespazjan	Gorzki	MEZCZYZNA	user391	user391@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
392	Maftunakhon	Polikh	KOBIETA	user392	user392@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
393	Zdzisław	Stremlau	MEZCZYZNA	user393	user393@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
394	Chenyi	Kleizand	KOBIETA	user394	user394@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
395	Szymon	Jurgawka	MEZCZYZNA	user395	user395@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
396	Bogdan	Pomianowski	MEZCZYZNA	user396	user396@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
397	Liljana	Melcarek	KOBIETA	user397	user397@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
398	Eter	Nakatova	KOBIETA	user398	user398@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
399	Gaweł	Twardowski	MEZCZYZNA	user399	user399@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
400	Alía	Fernandez martinez	KOBIETA	user400	user400@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
401	Munkhzaya	Salden	KOBIETA	user401	user401@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
402	Teofil	Jakubiel	MEZCZYZNA	user402	user402@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
403	Vialetta	Latosi	KOBIETA	user403	user403@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
404	Maria fernanda	Zakurdai	KOBIETA	user404	user404@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
405	Huixin	Dluhoborska	KOBIETA	user405	user405@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
406	Dżan	Tesz	MEZCZYZNA	user406	user406@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
407	Sofroniusz	Sobczyński	MEZCZYZNA	user407	user407@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
408	Rafał	Gryczka	MEZCZYZNA	user408	user408@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
409	Thania	Kurynovich	KOBIETA	user409	user409@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
410	Żytomir	Gronostajski	MEZCZYZNA	user410	user410@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
411	Edibe	Samotey	KOBIETA	user411	user411@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
412	Bogumił	Lejk	MEZCZYZNA	user412	user412@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
413	Nurzhan	Rakuzy	KOBIETA	user413	user413@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
414	Daniel	Frąckowiak	MEZCZYZNA	user414	user414@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
415	Elmira	Znalezińska	KOBIETA	user415	user415@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
416	Arkady	Cafasso	MEZCZYZNA	user416	user416@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
417	Téa	Dobiejewska	KOBIETA	user417	user417@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
418	Lambert	Maliszewski	MEZCZYZNA	user418	user418@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
419	Kitti	Chlopas	KOBIETA	user419	user419@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
420	Olaf	Kawiorski	MEZCZYZNA	user420	user420@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
421	Rupali	Namejko	KOBIETA	user421	user421@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
422	Ellia	Dobrovychan	KOBIETA	user422	user422@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
423	Łucjan	Woitun	MEZCZYZNA	user423	user423@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
424	Anwen	Yasonova	KOBIETA	user424	user424@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
425	Ładysław	Koteja	MEZCZYZNA	user425	user425@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
426	Witołd	Jelonek	MEZCZYZNA	user426	user426@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
427	Bogusz	Czarnogórski	MEZCZYZNA	user427	user427@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
428	Seza	Gadjieva	KOBIETA	user428	user428@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
429	Żelisław	Wełnogórski	MEZCZYZNA	user429	user429@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
430	Rezi	Warneński	MEZCZYZNA	user430	user430@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
431	Mija	Niewiora	KOBIETA	user431	user431@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
432	Ewelina	Fomienko	KOBIETA	user432	user432@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
433	Kasjusz	Jakowuk	MEZCZYZNA	user433	user433@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
434	Chociemir	Strychacz	MEZCZYZNA	user434	user434@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
435	Yeuheniya	Sołyszko	NIEOKRESLONY	user435	user435@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
436	Józefa	Nietubicz	KOBIETA	user436	user436@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
437	Bijal	Carboni	KOBIETA	user437	user437@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
438	Giorgi	Zamoić	KOBIETA	user438	user438@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
439	Piotr	Sabała	MEZCZYZNA	user439	user439@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
440	Ajdin	Perkiel	MEZCZYZNA	user440	user440@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
441	Nisan	Wankow	KOBIETA	user441	user441@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
442	Lucjan	Rzepczyński	MEZCZYZNA	user442	user442@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
443	Polikarp	Józak	MEZCZYZNA	user443	user443@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
444	Oksana-diana	Swierc-musiał	KOBIETA	user444	user444@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
445	Sevinch	Fenc	KOBIETA	user445	user445@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
446	Annasz	Hryncewicz	MEZCZYZNA	user446	user446@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
447	Dila	Strynahliuk	KOBIETA	user447	user447@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
448	Albin	Zeltman	MEZCZYZNA	user448	user448@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
449	Fryderyk	Pioterczak	MEZCZYZNA	user449	user449@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
450	Karya	Bîrcea	KOBIETA	user450	user450@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
451	Aravinda	Lukynych	KOBIETA	user451	user451@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
452	Olinda	Maldys	KOBIETA	user452	user452@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
453	Wiktor	Szlemp	MEZCZYZNA	user453	user453@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
454	Faris	Kałucki	MEZCZYZNA	user454	user454@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
455	Noeline	Verdebout	KOBIETA	user455	user455@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
456	Odon	Mańkiewicz	MEZCZYZNA	user456	user456@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
457	Konrad	Śpiechowicz	MEZCZYZNA	user457	user457@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
458	Zenobiusz	Bój	MEZCZYZNA	user458	user458@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
459	Suri	Doner	KOBIETA	user459	user459@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
460	Pakosław	Koźba	MEZCZYZNA	user460	user460@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
461	Liem	Kysilova	KOBIETA	user461	user461@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
462	Madelein	Reshnivetska	KOBIETA	user462	user462@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
463	Tomisław	Szlagowski	MEZCZYZNA	user463	user463@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
464	Eliot	Buksa	MEZCZYZNA	user464	user464@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
465	Antonius	Kwietniewski	MEZCZYZNA	user465	user465@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
466	Elifsu	Uhlu	KOBIETA	user466	user466@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
467	Wirgiliusz	Wyczałkowski	MEZCZYZNA	user467	user467@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
468	Świętibor	Fortkowski	MEZCZYZNA	user468	user468@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
469	Niiara	Seth	KOBIETA	user469	user469@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
470	Myroslawa	Kotsehub	KOBIETA	user470	user470@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
471	Aagya	Badarlan	KOBIETA	user471	user471@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
472	Mariiana	Polovenko	KOBIETA	user472	user472@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
473	Nikolia	Dlouhá	KOBIETA	user473	user473@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
474	Miłorad	Torepko	MEZCZYZNA	user474	user474@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
475	Miłosław	Pietrzyk	MEZCZYZNA	user475	user475@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
476	Shixuan	Görlich	KOBIETA	user476	user476@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
477	Sergiusz	Dumański	MEZCZYZNA	user477	user477@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
478	Viktoryja	Pereklita	KOBIETA	user478	user478@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
479	Roger	Lyska	MEZCZYZNA	user479	user479@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
480	Romanika	Kizichenko	KOBIETA	user480	user480@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
481	Jasmin	Kotlińska-niewiadomska	KOBIETA	user481	user481@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
482	California	Janczak-tworek	KOBIETA	user482	user482@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
483	Żelisław	Kosmatka	MEZCZYZNA	user483	user483@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
484	Yudita	Herko	KOBIETA	user484	user484@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
485	Wenancjusz	Napieralski	MEZCZYZNA	user485	user485@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
486	Bronisław	Predygier	MEZCZYZNA	user486	user486@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
487	Godzisław	Haczykowski	MEZCZYZNA	user487	user487@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
488	Nicefor	Fox	MEZCZYZNA	user488	user488@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
489	Yun-ting	Brusniak	KOBIETA	user489	user489@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
490	Remy	Hruzievych	KOBIETA	user490	user490@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
491	Giedrė	Katerla	KOBIETA	user491	user491@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
492	Izydor	Owiżyc	MEZCZYZNA	user492	user492@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
493	Thuane	Janasz-siwek	KOBIETA	user493	user493@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
494	Chwalimir	Superat	MEZCZYZNA	user494	user494@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
495	Abbe	Moorman	KOBIETA	user495	user495@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
496	Marylene	Saathoff	KOBIETA	user496	user496@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
497	Benedykt	Saulewicz	MEZCZYZNA	user497	user497@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
498	Edward	Szczyrk	MEZCZYZNA	user498	user498@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
499	Wenancjusz	Klisz	MEZCZYZNA	user499	user499@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
500	Thipsuda	Talarko	KOBIETA	user500	user500@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
501	Fryderyk	Indrychowski	MEZCZYZNA	user501	user501@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
502	Jaromir	Kołpa	MEZCZYZNA	user502	user502@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
503	Stoyanka	Purwiniecka	KOBIETA	user503	user503@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
504	Hariet	Zbihle	KOBIETA	user504	user504@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
505	Borysław	Żychowicz	MEZCZYZNA	user505	user505@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
506	Yuko	Pietrzak-szałkowska	KOBIETA	user506	user506@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
507	Winicja	Gerlich	KOBIETA	user507	user507@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
508	Juanru	Wierzbik	KOBIETA	user508	user508@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
509	Antonius	Czaczkowski	MEZCZYZNA	user509	user509@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
510	Uma kumari	Mattei	KOBIETA	user510	user510@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
511	Nneoma	Hołowaczyk	KOBIETA	user511	user511@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
512	Elissavet	Patiño turowski	KOBIETA	user512	user512@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
513	Ziemowit	Jonaszak	MEZCZYZNA	user513	user513@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
514	Wacław	Mytych	MEZCZYZNA	user514	user514@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
515	Josefine	Eltringham	KOBIETA	user515	user515@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
516	Pakosław	Strzykowski	MEZCZYZNA	user516	user516@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
517	Gracjanna	Dziadel	KOBIETA	user517	user517@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
518	Ernest	Patel	MEZCZYZNA	user518	user518@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
519	Maksymilian	Hrebenyuk	KOBIETA	user519	user519@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
520	Wenuta	Judcovski	KOBIETA	user520	user520@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
521	Tvalmaisa	Kulibaba	KOBIETA	user521	user521@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
522	Hubert	Walentek	MEZCZYZNA	user522	user522@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
523	Alfons	Młudziński	MEZCZYZNA	user523	user523@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
524	Feliks	Szpulak	MEZCZYZNA	user524	user524@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
525	Przemysł	Cioś	MEZCZYZNA	user525	user525@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
526	Ludmił	Byszczuk	MEZCZYZNA	user526	user526@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
527	Florentyn	Siewkowski	MEZCZYZNA	user527	user527@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
528	Galya	Olawuni	KOBIETA	user528	user528@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
529	Hamza	Sabadasz	MEZCZYZNA	user529	user529@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
530	Mariia-tereza	Kuropaś	NIEOKRESLONY	user530	user530@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
531	Mariarita	Machoś	KOBIETA	user531	user531@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
532	Ajka	Gołomb	KOBIETA	user532	user532@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
533	Arijana	Mojduszka	KOBIETA	user533	user533@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
534	Sanda	Mohylniak	KOBIETA	user534	user534@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
535	Ecri̇n	Gała-dziedzic	KOBIETA	user535	user535@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
536	Molly	Veres	KOBIETA	user536	user536@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
537	Tuyết	Sharapata	KOBIETA	user537	user537@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
538	Syrina	Awsztol	KOBIETA	user538	user538@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
539	Fryc	Czajor	MEZCZYZNA	user539	user539@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
540	Iwon	Kostyk	MEZCZYZNA	user540	user540@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
541	Eligiusz	Bruzgul	MEZCZYZNA	user541	user541@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
542	Maitê	Pliatsuk	KOBIETA	user542	user542@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
543	Bilge	Yaari	KOBIETA	user543	user543@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
544	Renat	Litwin	MEZCZYZNA	user544	user544@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
545	Sabin	Gruell	KOBIETA	user545	user545@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
546	Kamil	Maszynowski	MEZCZYZNA	user546	user546@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
547	Edwin	Imbiorkiewicz	MEZCZYZNA	user547	user547@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
548	Maurycy	Ridha	MEZCZYZNA	user548	user548@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
549	Artemi	Ogiewka	KOBIETA	user549	user549@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
550	Iben	Mitwicka	KOBIETA	user550	user550@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
551	Leopold	Kadlčik	MEZCZYZNA	user551	user551@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
552	Cylina	Perediela	KOBIETA	user552	user552@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
553	Dargosław	Nentwich	MEZCZYZNA	user553	user553@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
554	Gultakin	Panciera	KOBIETA	user554	user554@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
555	Lucica	Chromcow	KOBIETA	user555	user555@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
556	Seongeun	Żywólko	KOBIETA	user556	user556@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
557	Kajusz	Sibiński	MEZCZYZNA	user557	user557@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
558	Walentyn	Derewiński	MEZCZYZNA	user558	user558@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
559	Hemali	Mechlewicz	KOBIETA	user559	user559@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
560	Arzu	Makovitska	KOBIETA	user560	user560@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
561	Paweena	Dąbrowska-bień	KOBIETA	user561	user561@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
562	Józef	Ikwanty	MEZCZYZNA	user562	user562@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
563	Jinxing	Kuhnt	KOBIETA	user563	user563@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
564	Apollo	Obiecunas	MEZCZYZNA	user564	user564@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
565	Manuel	Maciorowski	MEZCZYZNA	user565	user565@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
566	Yahong	Valdovska	KOBIETA	user566	user566@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
567	Ścibor	Szyćko	MEZCZYZNA	user567	user567@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
568	Sue	Fedinchyk	KOBIETA	user568	user568@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
569	Kondrat	Pałucha	MEZCZYZNA	user569	user569@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
570	Ludomir	Dziudziel	MEZCZYZNA	user570	user570@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
571	Lucjan	Uliczny	MEZCZYZNA	user571	user571@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
572	Bożidar	Katyszewski	MEZCZYZNA	user572	user572@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
573	Bijaya	Gorian	KOBIETA	user573	user573@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
574	Soniia	Molchanets	KOBIETA	user574	user574@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
575	Marcin	Saatz	MEZCZYZNA	user575	user575@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
576	Thị sen	Varkina	KOBIETA	user576	user576@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
577	Minhye	Fryzowska	KOBIETA	user577	user577@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
578	Megumi	Chaładuda	KOBIETA	user578	user578@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
579	Rufus	Słodowicz	MEZCZYZNA	user579	user579@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
580	Świętomir	Hosa	MEZCZYZNA	user580	user580@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
581	Beverley	Kuropieska	KOBIETA	user581	user581@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
582	Gabor	Gronczewski	MEZCZYZNA	user582	user582@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
583	Artur	Kłus	MEZCZYZNA	user583	user583@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
584	Baigalmaa	Romanowska-pietrzak	KOBIETA	user584	user584@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
585	Marceli	Wawrzykowski	MEZCZYZNA	user585	user585@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
586	Adolfa	Delkowski	KOBIETA	user586	user586@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
587	Kailyn	Malachiński	NIEOKRESLONY	user587	user587@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
588	Maricar	Majewska-napierała	KOBIETA	user588	user588@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
589	Eftalia	Szmid	KOBIETA	user589	user589@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
590	Bogumił	Martinka	MEZCZYZNA	user590	user590@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
591	Adam	Rakoca	MEZCZYZNA	user591	user591@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
592	Konstanty	Golasz	MEZCZYZNA	user592	user592@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
593	Jonasz	Angier	MEZCZYZNA	user593	user593@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
594	Idaliana	Krawczyk-wilk	KOBIETA	user594	user594@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
595	Nurit	Duran	KOBIETA	user595	user595@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
596	Garam	Horbazha	KOBIETA	user596	user596@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
597	Godfryd	Dorożyński	MEZCZYZNA	user597	user597@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
598	Ireneusz	Dzierżyński	MEZCZYZNA	user598	user598@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
599	Thea	Iniutkina	KOBIETA	user599	user599@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
600	Yakha	Mora mora	KOBIETA	user600	user600@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
601	Jacek	Lelewer	MEZCZYZNA	user601	user601@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
602	Zygmunta	Sierantowicz	MEZCZYZNA	user602	user602@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
603	Nestor	Stotko	MEZCZYZNA	user603	user603@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
604	Sascha	Bujac	KOBIETA	user604	user604@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
605	Witold	Opasała	MEZCZYZNA	user605	user605@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
606	Patrycjusz	Kluziński	MEZCZYZNA	user606	user606@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
607	Shterna	Fostiy	KOBIETA	user607	user607@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
608	Cecyl	Dereszyński	MEZCZYZNA	user608	user608@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
609	Gwalbert	Sadoch	MEZCZYZNA	user609	user609@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
610	Chociemir	Kisteczek	MEZCZYZNA	user610	user610@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
611	Ezechiel	Flejszman	MEZCZYZNA	user611	user611@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
612	Aruana	Pokoshchan	KOBIETA	user612	user612@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
613	Ally	Klimak	KOBIETA	user613	user613@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
614	Augustyn	Chudy	MEZCZYZNA	user614	user614@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
615	Dangira	Matsaienko	KOBIETA	user615	user615@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
616	Beniamin	Pochyluk	MEZCZYZNA	user616	user616@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
617	Kajetan	Nikitin	MEZCZYZNA	user617	user617@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
618	Soeun	Luhovyk	KOBIETA	user618	user618@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
619	Kryspin	Maksimowski	MEZCZYZNA	user619	user619@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
620	Joachim	Dziemieńczuk	MEZCZYZNA	user620	user620@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
621	Leopold	Stachoń	MEZCZYZNA	user621	user621@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
622	Yike	Łojas-andrzejewska	KOBIETA	user622	user622@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
623	Zygmunta	Drzymał	MEZCZYZNA	user623	user623@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
624	Miron	Sot	MEZCZYZNA	user624	user624@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
625	Dobiesław	Połukord	MEZCZYZNA	user625	user625@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
626	Hayley	Priadka	KOBIETA	user626	user626@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
627	Avery	Sergjeiusz	KOBIETA	user627	user627@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
628	Yanjun	Khainak	KOBIETA	user628	user628@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
629	Teofil	Szkurłat	MEZCZYZNA	user629	user629@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
630	Benedykt	Fedorszczak	MEZCZYZNA	user630	user630@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
631	Hanelora	Ovinova	KOBIETA	user631	user631@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
632	Ryszarda	Furjan	KOBIETA	user632	user632@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
633	Paskalina	Zankiv	KOBIETA	user633	user633@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
634	Allana	Miku	KOBIETA	user634	user634@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
635	Hugo	Lux	MEZCZYZNA	user635	user635@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
636	Miroład	Lura	MEZCZYZNA	user636	user636@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
637	Łazarz	Łuc	MEZCZYZNA	user637	user637@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
638	Sigal	Hulińska	KOBIETA	user638	user638@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
639	Jingxia	Muthu	KOBIETA	user639	user639@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
640	Roderyk	Gredka	MEZCZYZNA	user640	user640@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
641	Ezechiel	Pańczak	MEZCZYZNA	user641	user641@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
642	Tara	Muskała	NIEOKRESLONY	user642	user642@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
643	Milan	Khomont	KOBIETA	user643	user643@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
644	Arkadiia	Golenkevitch	KOBIETA	user644	user644@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
645	Suwon	Kurzentkowska	KOBIETA	user645	user645@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
646	Onyebuchi	Sampson	KOBIETA	user646	user646@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
647	Yanira	Kulczyńska-trzeciak	KOBIETA	user647	user647@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
648	Dżemil	Popiak	MEZCZYZNA	user648	user648@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
649	Anelora	Myza	KOBIETA	user649	user649@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
650	Zhuk	Szauro	KOBIETA	user650	user650@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
651	Protazy	Wałcerz	MEZCZYZNA	user651	user651@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
652	Sharon	Zavarynska	KOBIETA	user652	user652@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
653	Konradyn	Zdrzewielski	MEZCZYZNA	user653	user653@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
654	Kosma	Gołębczyk	MEZCZYZNA	user654	user654@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
655	Ryszard	Wiciun	MEZCZYZNA	user655	user655@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
656	Wisław	Kikmunter	MEZCZYZNA	user656	user656@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
657	Emme	Buraczynek	KOBIETA	user657	user657@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
658	Darika	Pancerzynski albiach	KOBIETA	user658	user658@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
659	Prokop	Dyl	MEZCZYZNA	user659	user659@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
660	Poliana	Skamel	KOBIETA	user660	user660@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
661	Hanusz	Burasowicz	MEZCZYZNA	user661	user661@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
662	Edward	Matulko	MEZCZYZNA	user662	user662@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
663	Myślimir	Latoszewicz	MEZCZYZNA	user663	user663@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
664	Gniewomir	Babicki	MEZCZYZNA	user664	user664@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
665	Ngoc nha uyen	Sańka	KOBIETA	user665	user665@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
666	Tytus	Pułkowski	MEZCZYZNA	user666	user666@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
667	Felicjan	Elwicki	MEZCZYZNA	user667	user667@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
668	Zwinisław	Zygmond	MEZCZYZNA	user668	user668@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
669	Przybysław	Rudny	MEZCZYZNA	user669	user669@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
670	Loren	Rossman	KOBIETA	user670	user670@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
671	Hadrian	Husakowski	MEZCZYZNA	user671	user671@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
672	Bromir	Samulewicz	MEZCZYZNA	user672	user672@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
673	Bailey	Gonorovska	KOBIETA	user673	user673@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
674	Pavlina	Sayed	KOBIETA	user674	user674@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
675	Cichosław	Mielczyński	MEZCZYZNA	user675	user675@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
676	Gaweł	Omelaniuk	MEZCZYZNA	user676	user676@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
677	Fateme	Borbulak	KOBIETA	user677	user677@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
678	Szymon	Matura	MEZCZYZNA	user678	user678@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
679	Baldwin	Szypowski	MEZCZYZNA	user679	user679@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
680	Miron	Bromberger	MEZCZYZNA	user680	user680@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
681	Reine	Lenartowicz	KOBIETA	user681	user681@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
682	Valeska	Swatkiewicz	KOBIETA	user682	user682@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
683	Zendaya	Sokolski	KOBIETA	user683	user683@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
684	Orian	Kołodziejek	MEZCZYZNA	user684	user684@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
685	Józefat	Zaweracz	MEZCZYZNA	user685	user685@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
686	Hanusz	Kiełek	MEZCZYZNA	user686	user686@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
687	Gwido	Kuchaj	MEZCZYZNA	user687	user687@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
688	Afek	Lorber	KOBIETA	user688	user688@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
689	Karishma	Iefymova	KOBIETA	user689	user689@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
690	Ellisa	Hadai	KOBIETA	user690	user690@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
691	Khazan	Ćmielowska	KOBIETA	user691	user691@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
692	Witold	Starzyński	MEZCZYZNA	user692	user692@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
693	Dargomir	Nożyński	MEZCZYZNA	user693	user693@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
694	Anastazy	Pazik	MEZCZYZNA	user694	user694@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
695	Jaana	Drepina	KOBIETA	user695	user695@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
696	Dominik	Bugajniak	MEZCZYZNA	user696	user696@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
697	Władysław	Kroczek	MEZCZYZNA	user697	user697@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
698	Teodozjusz	Krywald	MEZCZYZNA	user698	user698@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
699	Husajn	Maślanik	MEZCZYZNA	user699	user699@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
700	Dalinda	Fürguth	KOBIETA	user700	user700@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
701	Wiesław	Gałachowski	MEZCZYZNA	user701	user701@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
702	Serwacy	Kwaśny	MEZCZYZNA	user702	user702@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
703	Fikrie	Łanczkowska	KOBIETA	user703	user703@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
704	Alwin	Durlik	MEZCZYZNA	user704	user704@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
705	Lisett	Orazayeva	KOBIETA	user705	user705@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
706	Wera	Dobrzyjałowicz	KOBIETA	user706	user706@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
707	Arnold	Maksanty	MEZCZYZNA	user707	user707@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
708	Erwin	Pansewicz	MEZCZYZNA	user708	user708@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
709	Klaudiusz	Teperek	MEZCZYZNA	user709	user709@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
710	Dorian	Ponoś	MEZCZYZNA	user710	user710@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
711	Erazm	Wenda	MEZCZYZNA	user711	user711@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
712	Ładysław	Barwinek	MEZCZYZNA	user712	user712@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
713	Dilnara	Karnyska	KOBIETA	user713	user713@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
714	Radija	Olszewska-dąbrowska	KOBIETA	user714	user714@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
715	Elyne	Duda-lisowska	KOBIETA	user715	user715@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
716	Netnapa	Sienicka-kupicha	KOBIETA	user716	user716@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
717	Raha	Unhurian	KOBIETA	user717	user717@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
718	Walter	Zaraś	MEZCZYZNA	user718	user718@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
719	Marian	Jaeschke	MEZCZYZNA	user719	user719@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
720	Gerard	Borowik-przysiężny	MEZCZYZNA	user720	user720@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
721	Jaeeun	Rylik-tkacz	KOBIETA	user721	user721@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
722	Aleksy	Ostaszyk	MEZCZYZNA	user722	user722@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
723	Dżemil	Snopkiewicz	MEZCZYZNA	user723	user723@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
724	Urban	Nebeling	MEZCZYZNA	user724	user724@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
725	Snejana	Kozłovtceva	KOBIETA	user725	user725@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
726	Wojsław	Irzykowski	MEZCZYZNA	user726	user726@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
727	Abdon	Raganiewicz	MEZCZYZNA	user727	user727@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
728	Mirosz	Przemyślański	MEZCZYZNA	user728	user728@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
729	Remigiusz	Pikor	MEZCZYZNA	user729	user729@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
730	Urshula	Svoiak	KOBIETA	user730	user730@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
731	Subisław	Anyszko	MEZCZYZNA	user731	user731@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
732	Gilat	Singel	KOBIETA	user732	user732@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
733	Gurpreet kaur	Jaworska-wszelaka	KOBIETA	user733	user733@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
734	Sokny	Strychowska	KOBIETA	user734	user734@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3862	Amutha	Miroslaw	KOBIETA	user3862	user3862@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
735	Meenakshi	Ivaskevych	KOBIETA	user735	user735@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
736	Sun sim	Nedobora	KOBIETA	user736	user736@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
737	Bartosz	Sapkowski	MEZCZYZNA	user737	user737@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
738	Mahlet	Blyndu	KOBIETA	user738	user738@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
739	Bruno	Żarnowski	MEZCZYZNA	user739	user739@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
740	Franciszek	Składnik	MEZCZYZNA	user740	user740@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
741	Wacław	Stefurak	MEZCZYZNA	user741	user741@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
742	Deizy	Tümer	KOBIETA	user742	user742@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
743	Szczepan	Bielenda	MEZCZYZNA	user743	user743@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
744	Iwon	Kurpisz	MEZCZYZNA	user744	user744@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
745	Ciechosław	Przezdzięk	MEZCZYZNA	user745	user745@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
746	Alfred	Agaciak	MEZCZYZNA	user746	user746@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
747	Nomathemba	Duszczenko	KOBIETA	user747	user747@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
748	Kasper	Kotapski	MEZCZYZNA	user748	user748@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
749	Mindra	Contreras osorio	KOBIETA	user749	user749@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
750	Ye'ela	Fourt	KOBIETA	user750	user750@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
751	Lubelihle	Jarząbczyk	KOBIETA	user751	user751@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
752	Borzywoj	Brojer	MEZCZYZNA	user752	user752@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
753	Jessyca	Zawalniak	KOBIETA	user753	user753@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
754	Haya	Heksel wójcik	KOBIETA	user754	user754@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
755	Ramsha	Kokaljari	KOBIETA	user755	user755@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
756	Xiaoxi	Duranowska	KOBIETA	user756	user756@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
757	Dżamil	Wielewski	MEZCZYZNA	user757	user757@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
758	Krystiana	Liwora	KOBIETA	user758	user758@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
759	Mounia	Wencławek	KOBIETA	user759	user759@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
760	Malita	Elmborg	KOBIETA	user760	user760@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
761	Borysław	Markwat	MEZCZYZNA	user761	user761@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
762	Emi̇ne	Kaliwoszka	KOBIETA	user762	user762@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
763	Jie	Bakata	KOBIETA	user763	user763@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
764	Dobiesław	Lamut	MEZCZYZNA	user764	user764@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
765	Kajetan	Krachulec	MEZCZYZNA	user765	user765@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
766	Thu	Šmidl	KOBIETA	user766	user766@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
767	Walid	Pruszko	MEZCZYZNA	user767	user767@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
768	Zipi	Adaeva	KOBIETA	user768	user768@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
769	Mieczyslawa	Rudzińska-nowak	KOBIETA	user769	user769@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
770	Malene	Savolia	KOBIETA	user770	user770@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
771	Ajdin	Madaj	MEZCZYZNA	user771	user771@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
772	Onyinyechi	Tananis	KOBIETA	user772	user772@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
773	Krishna kumari	Zarada	NIEOKRESLONY	user773	user773@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
774	Ioulietta	Parfińska	KOBIETA	user774	user774@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
775	Robert	Simoni	MEZCZYZNA	user775	user775@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
776	Barabasz	Parczewski	MEZCZYZNA	user776	user776@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
777	Bożimir	Heitzman	MEZCZYZNA	user777	user777@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
778	Włodzimierz	Cenkier	MEZCZYZNA	user778	user778@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
779	Dzwonimierz	Korkosz	MEZCZYZNA	user779	user779@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
780	Jhoan	Toczyski	KOBIETA	user780	user780@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
781	Felicjan	Pogrzebski	MEZCZYZNA	user781	user781@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
782	Wielisław	Radyszewski	MEZCZYZNA	user782	user782@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
783	Lechosław	Bolechowski	MEZCZYZNA	user783	user783@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
784	Feliks	Szepieniec	MEZCZYZNA	user784	user784@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
785	Anca	Przepiórska	KOBIETA	user785	user785@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
786	Ajgul	Szaja	KOBIETA	user786	user786@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
787	Alon	Malych	KOBIETA	user787	user787@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
788	August	Schlamberger	MEZCZYZNA	user788	user788@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
789	Wenancjusz	Jurmanowicz	MEZCZYZNA	user789	user789@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
790	Sweet	Anholenko	KOBIETA	user790	user790@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
791	Yanfei	Karolewska-szulc	KOBIETA	user791	user791@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
792	Zhiidegul	Getmantseva	KOBIETA	user792	user792@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
793	Ludomił	Sewera	MEZCZYZNA	user793	user793@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
794	Tristan	Księżyk	MEZCZYZNA	user794	user794@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
795	Natthaphat	Berus	KOBIETA	user795	user795@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
796	Khalida	Artiukhina	KOBIETA	user796	user796@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
797	Nikodem	Till	MEZCZYZNA	user797	user797@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
798	Sędomir	Aderek	MEZCZYZNA	user798	user798@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
799	Raveena	Shchedrykova	KOBIETA	user799	user799@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
800	Aliaksandr	Maidebura	KOBIETA	user800	user800@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
801	Daryna	Bakrin	KOBIETA	user801	user801@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
802	Kristīne	Kurzemska	KOBIETA	user802	user802@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
803	Horacy	Młynarczykowski	MEZCZYZNA	user803	user803@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
804	Dżem	Pietruk	MEZCZYZNA	user804	user804@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
805	Cătǎlina	Pihar	KOBIETA	user805	user805@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
806	Arenika	Taranko	KOBIETA	user806	user806@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
807	Seniora	Zbozhniuk	KOBIETA	user807	user807@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
808	Elija	Kavbasiuk	KOBIETA	user808	user808@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
809	Bogumir	Trzęsała	MEZCZYZNA	user809	user809@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
810	Kasper	Kopczewski	MEZCZYZNA	user810	user810@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
811	Thi thanh hai	Mogylevets	NIEOKRESLONY	user811	user811@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
812	Angie katherine	Claessens	KOBIETA	user812	user812@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
813	Fortunat	Gomza	MEZCZYZNA	user813	user813@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
814	Chenoa	Brzyśkiewicz	KOBIETA	user814	user814@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
815	Yongwei	Waleńcik	KOBIETA	user815	user815@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
816	Ardak	Kulenta	NIEOKRESLONY	user816	user816@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
817	Fortunat	Białokozowicz	MEZCZYZNA	user817	user817@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
818	Inocenty	Quach	MEZCZYZNA	user818	user818@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
819	Dżesyka	Stapert	KOBIETA	user819	user819@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
820	Ilan	Rędziniak	KOBIETA	user820	user820@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
821	Thị bích thủy	Ketchie	KOBIETA	user821	user821@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
822	Ludowit	Muracki	MEZCZYZNA	user822	user822@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
823	Hipolit	Śmietana-kardasiewicz	MEZCZYZNA	user823	user823@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
824	Świętibor	Czebatura	MEZCZYZNA	user824	user824@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
825	Marinetta	Marchelak	KOBIETA	user825	user825@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
826	Herman	Pomes	MEZCZYZNA	user826	user826@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
827	Tomasza	Madej de brito goinhas	KOBIETA	user827	user827@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
828	Maria-aurora	Prałat	KOBIETA	user828	user828@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
829	Hipolit	Lemieszczak	MEZCZYZNA	user829	user829@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
830	Kornel-korni	Hildebrand	MEZCZYZNA	user830	user830@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
831	Evren	Hudzhyn	KOBIETA	user831	user831@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
832	Sanita	Zacharias	KOBIETA	user832	user832@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
833	Kilian	Tycki	MEZCZYZNA	user833	user833@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
834	Otokar	Stasiaczyk	MEZCZYZNA	user834	user834@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
835	Więczesława	Tomkiel	KOBIETA	user835	user835@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
836	Onufry	Walec	MEZCZYZNA	user836	user836@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
837	Wirgiliusz	Godszling	MEZCZYZNA	user837	user837@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
838	Amadeusz	Glądała	MEZCZYZNA	user838	user838@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
839	Donald	Szocik	MEZCZYZNA	user839	user839@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
840	Sultan	Pawłuszyn	KOBIETA	user840	user840@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
841	Ma. cecilia	Pecher	KOBIETA	user841	user841@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
842	Rajmund	Szypiło	MEZCZYZNA	user842	user842@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
843	Sylwiusz	Capek	MEZCZYZNA	user843	user843@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
844	Dobrogost	Łabęda	MEZCZYZNA	user844	user844@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
845	Gunel	Nanetashvili	KOBIETA	user845	user845@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
846	Yeimy	Zielińska-olejnik	KOBIETA	user846	user846@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
847	Budzisław	Dziurka	MEZCZYZNA	user847	user847@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
848	Beren	Tarfińska	KOBIETA	user848	user848@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
849	Khatin	Kamal mohamed ali	KOBIETA	user849	user849@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
850	Abel	Hajdecki	MEZCZYZNA	user850	user850@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
851	Herma	Hary	KOBIETA	user851	user851@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
852	Chwalimir	Jeżewski	MEZCZYZNA	user852	user852@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
853	Genė	Sybastiańska	KOBIETA	user853	user853@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
854	Ranin	Paškvan	KOBIETA	user854	user854@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
855	Nasanjargal	Paszka-helm	KOBIETA	user855	user855@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
856	Denis	Sitkowiak	MEZCZYZNA	user856	user856@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
857	Ulduz	Hrybko	KOBIETA	user857	user857@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
858	Syriusz	Heit	MEZCZYZNA	user858	user858@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
859	Hieronim	Matheoszat	MEZCZYZNA	user859	user859@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
860	Łucjan	Glodek	MEZCZYZNA	user860	user860@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
861	Syriusz	Zerbin	MEZCZYZNA	user861	user861@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
862	Witold	Kubla	MEZCZYZNA	user862	user862@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
863	Bonifacy	Savin	MEZCZYZNA	user863	user863@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
864	Faustyn	Bedychaj	MEZCZYZNA	user864	user864@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
865	Rajner	Płachta	MEZCZYZNA	user865	user865@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
866	Gulbarchyn	Sussek	KOBIETA	user866	user866@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
867	Ananiasz	Mizeracki	MEZCZYZNA	user867	user867@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
868	Hedi	Pułka-przygucka	KOBIETA	user868	user868@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
869	Świętosław	Szczepanik	MEZCZYZNA	user869	user869@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
870	Antonius	Kondysiak	MEZCZYZNA	user870	user870@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
871	Yaǧmur	Wicijowska	KOBIETA	user871	user871@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
872	Hilary	Geer	KOBIETA	user872	user872@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
873	Nijole	Panaskina	KOBIETA	user873	user873@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
874	Winfred	Dabeka	KOBIETA	user874	user874@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
875	Yong hui	Van olst	KOBIETA	user875	user875@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
876	Leopold	Zawadzanko	MEZCZYZNA	user876	user876@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
877	Nihad	Puras	KOBIETA	user877	user877@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
878	Nicoleta	Cypryjanik	KOBIETA	user878	user878@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
879	Sotiria	Syrovenko	KOBIETA	user879	user879@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
880	Mariel	Hudzar	KOBIETA	user880	user880@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
881	Krishna	Vinchur	KOBIETA	user881	user881@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
882	Przedpełk	Wieraszka	MEZCZYZNA	user882	user882@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
883	Harriette	Waratus	KOBIETA	user883	user883@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
884	Walter	Klikar	MEZCZYZNA	user884	user884@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
885	Kellie	Korpanty	KOBIETA	user885	user885@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
886	Rozanetta	Fijarczyk	KOBIETA	user886	user886@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
887	Daliah	Pliszczyński	NIEOKRESLONY	user887	user887@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
888	Gauhar	Alsabih	KOBIETA	user888	user888@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
889	Hairong	Wiesebach	KOBIETA	user889	user889@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
890	Liutsyia	Gielnicka	KOBIETA	user890	user890@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
891	Delia-evelina	Kashchen	KOBIETA	user891	user891@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
892	Kisa	Mutmann	KOBIETA	user892	user892@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
893	Aikumis	Gaskoń	KOBIETA	user893	user893@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
894	Khazhar	Haj belgacem	KOBIETA	user894	user894@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
895	Bodosław	Wondraszek	MEZCZYZNA	user895	user895@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
896	Yaima	Ogiełda	KOBIETA	user896	user896@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
897	Anastazy	Pyszniak	MEZCZYZNA	user897	user897@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
898	Sariya	Zhminka	KOBIETA	user898	user898@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
899	Mei-ling	Jachymska	KOBIETA	user899	user899@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
900	Niecisław	Witocha	MEZCZYZNA	user900	user900@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
901	Kanimir	Wenskowski	MEZCZYZNA	user901	user901@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
902	Yilei	Strikkert	KOBIETA	user902	user902@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
903	Jian	Cronin	KOBIETA	user903	user903@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
904	Tytus	Merecki	MEZCZYZNA	user904	user904@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
905	Magdalina	Hmura	KOBIETA	user905	user905@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
906	Otniel	Dumkiewicz	MEZCZYZNA	user906	user906@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
907	Doron	Hennoszczenko	KOBIETA	user907	user907@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
908	Syuzanna	Strajch	KOBIETA	user908	user908@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
909	Strzeżymir	Kozdoj	MEZCZYZNA	user909	user909@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
910	Florian	Mruk	MEZCZYZNA	user910	user910@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
911	Ludmił	Stypiński	MEZCZYZNA	user911	user911@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
912	Wisława	Apanasik	KOBIETA	user912	user912@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
913	Krishna kumari	Sztandera	KOBIETA	user913	user913@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
914	Enid	Kostitska	KOBIETA	user914	user914@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
915	Bogumił	Bujno	MEZCZYZNA	user915	user915@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
916	Sobiesław	Rdułtowski	MEZCZYZNA	user916	user916@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
917	Ksienia	Jacubovich	KOBIETA	user917	user917@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
918	Sofroniusz	Pogoda	MEZCZYZNA	user918	user918@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
919	Wenmei	Usatenko	KOBIETA	user919	user919@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
920	Aspram	Wieruchowska	KOBIETA	user920	user920@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
921	Wei-hsuan	Khachikian	KOBIETA	user921	user921@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
922	Sedef	Liamina	KOBIETA	user922	user922@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
923	Efrem	Wician	MEZCZYZNA	user923	user923@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
924	Juliusz	Kakaryga	MEZCZYZNA	user924	user924@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
925	Hriska	Wamser	KOBIETA	user925	user925@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
926	Ludowit	Wojturski	MEZCZYZNA	user926	user926@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
927	Emilía	Prostakova	KOBIETA	user927	user927@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
928	Raniya	Hojar	KOBIETA	user928	user928@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
929	Kastor	Izydorski	MEZCZYZNA	user929	user929@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
930	Justyn	Roliński	MEZCZYZNA	user930	user930@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
931	Nomvelo	Rindflajsz	KOBIETA	user931	user931@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
932	Miłowan	Luszczak	MEZCZYZNA	user932	user932@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
933	Więczesława	Gierlip	KOBIETA	user933	user933@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
934	Witold	Tyniecki	MEZCZYZNA	user934	user934@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
935	Tra giang	Mąkiewicz	KOBIETA	user935	user935@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
936	Fryc	Dolecki-kur	MEZCZYZNA	user936	user936@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
937	Eun kyung	Unilowski	KOBIETA	user937	user937@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
938	Melis	Krzykowska	KOBIETA	user938	user938@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
939	Hanusia	Dolna	KOBIETA	user939	user939@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
940	Vija	Ougarete	KOBIETA	user940	user940@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
941	Tymoteusz	Bym	MEZCZYZNA	user941	user941@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
942	Karmen	Philosoph	KOBIETA	user942	user942@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
943	Anastazy	Czarniak	MEZCZYZNA	user943	user943@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
944	Robert	Wójt	MEZCZYZNA	user944	user944@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
945	Bromir	Kisieliński	MEZCZYZNA	user945	user945@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
946	Dhanmaya	Sippelius	KOBIETA	user946	user946@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
947	Miroład	Toton	MEZCZYZNA	user947	user947@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
948	Aysi̇ma	Pieczywek	NIEOKRESLONY	user948	user948@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
949	Sławomir	Patro	MEZCZYZNA	user949	user949@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
950	Donat	Dudko	MEZCZYZNA	user950	user950@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
951	Kajetan	Elwertowski	MEZCZYZNA	user951	user951@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
952	Herakles	Pyz	MEZCZYZNA	user952	user952@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
953	Donna	Syrovatka	KOBIETA	user953	user953@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
954	Tobiasz	Sarzało	MEZCZYZNA	user954	user954@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
955	Lieona	Rogozheva	KOBIETA	user955	user955@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
956	Sędzisław	Syrotiuk	MEZCZYZNA	user956	user956@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
957	Lucjan	Doroch	MEZCZYZNA	user957	user957@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
958	Kajusz	Rodenko	MEZCZYZNA	user958	user958@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
959	Miłobąd	Stembalski	MEZCZYZNA	user959	user959@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
960	Leidy tatiana	Bertashevska	KOBIETA	user960	user960@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
961	Fulya	Durharian	KOBIETA	user961	user961@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
962	Si̇ne	Kleinszmit	KOBIETA	user962	user962@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
963	Bartłomiej	Skurczak	MEZCZYZNA	user963	user963@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
964	Jeremiasz	Włodarczak	MEZCZYZNA	user964	user964@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
965	Kaludia	Bekolli	KOBIETA	user965	user965@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
966	Leilla	Lipieniecka	KOBIETA	user966	user966@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
967	Ainaz	Dehu	KOBIETA	user967	user967@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
968	Emil	Fedoruk	MEZCZYZNA	user968	user968@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
969	Artur	Obodzień	MEZCZYZNA	user969	user969@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
970	Bogusz	Łubnicki	MEZCZYZNA	user970	user970@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
971	Keya	Grelka	KOBIETA	user971	user971@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
972	Alieksa	Diriieva	KOBIETA	user972	user972@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
973	Mandipa	Povarova	KOBIETA	user973	user973@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
974	Yiyoon	Koszelnik-kluska	KOBIETA	user974	user974@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
975	Barbara	Awierianów	KOBIETA	user975	user975@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
976	Hebe	Kekalo	KOBIETA	user976	user976@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
977	Miłogost	Hutyriak	MEZCZYZNA	user977	user977@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
978	Honorat	Zambrowski	MEZCZYZNA	user978	user978@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
979	Gracjan	Tenerowicz	MEZCZYZNA	user979	user979@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
980	Toshiko	Dovhenko	KOBIETA	user980	user980@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
981	Seoyoung	Driagina	KOBIETA	user981	user981@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
982	Patryk	Ziębacz	MEZCZYZNA	user982	user982@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
983	Apshara	Miesała	KOBIETA	user983	user983@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
984	Łukasz	Wołocznik	MEZCZYZNA	user984	user984@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
985	Gulnara	Korneta	KOBIETA	user985	user985@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
986	Deepshikha	Hyrowska	KOBIETA	user986	user986@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
987	Witold	Mietlicki	MEZCZYZNA	user987	user987@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
988	Żarko	Belicki	MEZCZYZNA	user988	user988@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
989	Samjhana	Rozpądek-bogucka	KOBIETA	user989	user989@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
990	Iwanka	Hajduczek	KOBIETA	user990	user990@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
991	Żytomir	Stochmiałek	MEZCZYZNA	user991	user991@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
992	Erazm	Bortniak	MEZCZYZNA	user992	user992@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
993	Agapit	Grymuza	MEZCZYZNA	user993	user993@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
994	Sławek	Wąsowicz	MEZCZYZNA	user994	user994@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
995	Lisa	Gittelman	KOBIETA	user995	user995@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
996	Agaton	Łoboziak	MEZCZYZNA	user996	user996@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
997	Atia	Sandel	KOBIETA	user997	user997@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
998	Sairan	Superniok	KOBIETA	user998	user998@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
999	Jenny	Blicq	KOBIETA	user999	user999@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1000	Hye suk	Gudym	KOBIETA	user1000	user1000@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1001	Yi yi	Spławska-wiatr	KOBIETA	user1001	user1001@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1002	Fedorchuk	Perkun	KOBIETA	user1002	user1002@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1003	Thi mai	Sembok	KOBIETA	user1003	user1003@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1004	Sykstus	Liponoga	MEZCZYZNA	user1004	user1004@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1005	Kasjusz	Brzeskot	MEZCZYZNA	user1005	user1005@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1006	Kemal	Ingler	MEZCZYZNA	user1006	user1006@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1007	Dzhessika	Tisovska	KOBIETA	user1007	user1007@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1008	Haiana	Szmucer	KOBIETA	user1008	user1008@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1009	Yuliana-viktoriia	Küppers	KOBIETA	user1009	user1009@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1010	Chwalisław	Morgała	MEZCZYZNA	user1010	user1010@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1011	Konradyn	Okuń	MEZCZYZNA	user1011	user1011@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1012	Rosa	Karwicki	KOBIETA	user1012	user1012@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1013	Teodozjusz	Fota	MEZCZYZNA	user1013	user1013@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1014	Seweryn	Bautsch	MEZCZYZNA	user1014	user1014@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1015	Godfryg	Sier	MEZCZYZNA	user1015	user1015@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1016	Barno	Reuben	KOBIETA	user1016	user1016@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1017	Mónica	Działkowska	KOBIETA	user1017	user1017@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1018	Neli	Bologa	KOBIETA	user1018	user1018@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1019	Sukmaya	Wiślak	KOBIETA	user1019	user1019@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1020	Kasper	Matyniak	MEZCZYZNA	user1020	user1020@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1021	Saja	Jurgawka	NIEOKRESLONY	user1021	user1021@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1022	Kanokwan	Skorupiński	NIEOKRESLONY	user1022	user1022@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1023	Miłowan	Sukmanowski	MEZCZYZNA	user1023	user1023@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1024	Rand	Prass	KOBIETA	user1024	user1024@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1025	Bonifacy	Furmańczuk	MEZCZYZNA	user1025	user1025@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1026	Cassandre	Rakovský	KOBIETA	user1026	user1026@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1027	Ludwik	Selmaj	MEZCZYZNA	user1027	user1027@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1028	Reda	Malaj	KOBIETA	user1028	user1028@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1029	Anhela	Likhacheva	KOBIETA	user1029	user1029@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1030	Marylia	Mandycz	KOBIETA	user1030	user1030@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1031	Rhiann	Szydłowiecka	KOBIETA	user1031	user1031@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1032	Besa	Chernoivanenko	KOBIETA	user1032	user1032@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1033	Ejebay	Leśna	KOBIETA	user1033	user1033@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1034	Dzhyna	Scholey	KOBIETA	user1034	user1034@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1035	Bernard	Saczyński	MEZCZYZNA	user1035	user1035@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1036	Robynne	Stolarkiewicz	KOBIETA	user1036	user1036@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1037	Arnold	Ochmański	MEZCZYZNA	user1037	user1037@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1038	Odon	Jopek	MEZCZYZNA	user1038	user1038@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1039	Arkadiusz	Jarośkiewicz	MEZCZYZNA	user1039	user1039@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1040	Qinqin	Keeney	KOBIETA	user1040	user1040@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1041	Konstancjusz	Tutak	MEZCZYZNA	user1041	user1041@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1042	Przemysł	Hrebień	MEZCZYZNA	user1042	user1042@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1043	Uchenna	Nobis-marusic	KOBIETA	user1043	user1043@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1044	Wojsław	Demcio	MEZCZYZNA	user1044	user1044@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1045	Tulimir	Kalbrum	MEZCZYZNA	user1045	user1045@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1046	Grzymisław	Tarraf	MEZCZYZNA	user1046	user1046@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1047	Julianna	Zadeberny	KOBIETA	user1047	user1047@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1048	Norbert	Grobelka	MEZCZYZNA	user1048	user1048@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1049	Guldara	Odnovolyk	KOBIETA	user1049	user1049@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1050	Evelina	Lewitska	KOBIETA	user1050	user1050@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1051	Thơm	Kostyuchok	KOBIETA	user1051	user1051@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1052	Thị phương mai	Dynel	KOBIETA	user1052	user1052@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1053	Sylwiusz	Bartoszek	MEZCZYZNA	user1053	user1053@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1054	Ludmił	Forościej	MEZCZYZNA	user1054	user1054@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1055	Chwalimir	Drwęcki	MEZCZYZNA	user1055	user1055@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1056	Efrem	Ludkiewicz	MEZCZYZNA	user1056	user1056@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1057	Szczepan	Fajge	MEZCZYZNA	user1057	user1057@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1058	Walery	Aleksa	MEZCZYZNA	user1058	user1058@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1059	Asem	Mylianyk	KOBIETA	user1059	user1059@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1060	Sulisław	Szymalski	MEZCZYZNA	user1060	user1060@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1061	Robert	Wowk	MEZCZYZNA	user1061	user1061@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1062	Reinhild	Hurhach	KOBIETA	user1062	user1062@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1063	Jassmina	Sadowska-gacek	KOBIETA	user1063	user1063@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1064	Louiza	Goldstein herrera	KOBIETA	user1064	user1064@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1065	Cecyl	Pawluczyk	MEZCZYZNA	user1065	user1065@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1066	Dżanet	Bnayat	KOBIETA	user1066	user1066@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1067	Adnan	Bylka	MEZCZYZNA	user1067	user1067@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1068	Cristina-andreea	Kokhanchuk	KOBIETA	user1068	user1068@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1069	Aisel	Meinke	KOBIETA	user1069	user1069@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1070	Ankita	Dhami	KOBIETA	user1070	user1070@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1071	Gellie	Usyk	KOBIETA	user1071	user1071@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1072	Cezary	Sebastiański	MEZCZYZNA	user1072	user1072@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1073	Stoigniew	Kudłak	MEZCZYZNA	user1073	user1073@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1074	Wielisław	Syćko	MEZCZYZNA	user1074	user1074@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1075	Ewangeli	Wizła	KOBIETA	user1075	user1075@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1076	Sudeshna	Tarnówka-bałabuch	KOBIETA	user1076	user1076@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1077	Gwalbert	Moczydłowski	MEZCZYZNA	user1077	user1077@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1078	Luborad	Blank	MEZCZYZNA	user1078	user1078@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1079	Aissatu	Badran	KOBIETA	user1079	user1079@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1080	Gena	Nordström	KOBIETA	user1080	user1080@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1081	Greta	Juliańska	KOBIETA	user1081	user1081@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1082	Lyena	Herszfeld	KOBIETA	user1082	user1082@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1083	Lechosław	Posełkiewicz	MEZCZYZNA	user1083	user1083@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1084	Lujza	Bazyshena	KOBIETA	user1084	user1084@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1085	Huyen chi	Kłos-militowska	KOBIETA	user1085	user1085@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1086	Mieczysław	Zatylny	MEZCZYZNA	user1086	user1086@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1087	Mirawa	Klyhina	KOBIETA	user1087	user1087@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1088	Lisana	Kłosiak	KOBIETA	user1088	user1088@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1089	Gerwazy	Wiencierz	MEZCZYZNA	user1089	user1089@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1090	Songyee	Tridhart	KOBIETA	user1090	user1090@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1091	Brigite	Bud-gusaim	KOBIETA	user1091	user1091@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1092	Leta	Prontenko	KOBIETA	user1092	user1092@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1093	Alojzy	Jokiel	MEZCZYZNA	user1093	user1093@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1094	Damazy	Drabiszczak	MEZCZYZNA	user1094	user1094@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1095	Łukasz	Chyclak	MEZCZYZNA	user1095	user1095@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1096	Kondrat	Šehi	MEZCZYZNA	user1096	user1096@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1097	Aitolgon	Tyburowska	KOBIETA	user1097	user1097@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1098	Thi thu nga	Podskarbi-kurdziel	KOBIETA	user1098	user1098@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1099	Jakub	Kolat	MEZCZYZNA	user1099	user1099@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1100	Malies	Skuchypets	KOBIETA	user1100	user1100@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1101	Bożan	Przebięda	MEZCZYZNA	user1101	user1101@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1102	Pelagiusz	Wiliński	MEZCZYZNA	user1102	user1102@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1103	Blerona	Kotman	KOBIETA	user1103	user1103@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1104	Gislinde	Guerrero torres	KOBIETA	user1104	user1104@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1105	Oswald	Kasperski	MEZCZYZNA	user1105	user1105@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1106	Eun mi	Oszajca	KOBIETA	user1106	user1106@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1107	Miłosz	Prasek	MEZCZYZNA	user1107	user1107@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1108	Arsena	Kozek	KOBIETA	user1108	user1108@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1109	Dymitr	Goszczyk	MEZCZYZNA	user1109	user1109@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1110	Kasper	Kryszewski	MEZCZYZNA	user1110	user1110@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1111	Roch	Pieloch	MEZCZYZNA	user1111	user1111@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1112	Husajn	Błażko	MEZCZYZNA	user1112	user1112@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1113	Myślimir	Ziernik	MEZCZYZNA	user1113	user1113@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1114	Nagham	Von ahn	KOBIETA	user1114	user1114@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1115	Hồng nhung	Hamada abdelfattah	KOBIETA	user1115	user1115@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1116	Mansura	Kot-chmielewska	KOBIETA	user1116	user1116@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1117	Teobald	Strugacz	MEZCZYZNA	user1117	user1117@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1118	Gennifer	Braunschweig	KOBIETA	user1118	user1118@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1119	Nataniel	Nguyen duc	MEZCZYZNA	user1119	user1119@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1120	Odon	Zerkowski	MEZCZYZNA	user1120	user1120@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1121	Priscillia	Synja	KOBIETA	user1121	user1121@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1122	Kristiāna	Halaishyn	KOBIETA	user1122	user1122@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1123	Efrem	Beauvale	MEZCZYZNA	user1123	user1123@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1124	Raluca-ioana	Paryła	KOBIETA	user1124	user1124@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1125	Maryn	Czermiński	MEZCZYZNA	user1125	user1125@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1126	Markiela	De cruz	KOBIETA	user1126	user1126@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1127	Kirana	Protaś-kowalska	KOBIETA	user1127	user1127@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1128	Joëlle	Meladze	KOBIETA	user1128	user1128@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1129	Eliot	Mecger	MEZCZYZNA	user1129	user1129@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1130	Edgar	Czuruń	MEZCZYZNA	user1130	user1130@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1131	Gerhild	Katunga	KOBIETA	user1131	user1131@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1132	Cecyl	Zadencki	MEZCZYZNA	user1132	user1132@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1133	Onufry	Ziembicki	MEZCZYZNA	user1133	user1133@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1134	Heleen	Żywiec	KOBIETA	user1134	user1134@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1135	Aichurok	Apasova	KOBIETA	user1135	user1135@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1136	Hektor	Gomuła	MEZCZYZNA	user1136	user1136@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1137	Sara sofia	Matusiak-kuczborska	KOBIETA	user1137	user1137@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1138	Pratishtha	Bosakowska	KOBIETA	user1138	user1138@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1139	Chwalibóg	Odijk	MEZCZYZNA	user1139	user1139@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1140	Milania	Fatiyeva	KOBIETA	user1140	user1140@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1141	Bagdat	Efimova	KOBIETA	user1141	user1141@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1142	Eurela	Serho	KOBIETA	user1142	user1142@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1143	Świętosława	Milczarzewicz	KOBIETA	user1143	user1143@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1144	Shantel	Koreiba	KOBIETA	user1144	user1144@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1145	Klaudiya	Elisha	KOBIETA	user1145	user1145@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1146	Ana lucia	Pron	KOBIETA	user1146	user1146@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1147	Ziemowit	Plech	MEZCZYZNA	user1147	user1147@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1148	Svieta	Zadorin	KOBIETA	user1148	user1148@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1149	Cyryl	Biryło	MEZCZYZNA	user1149	user1149@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1150	Juliia	Firmuga	KOBIETA	user1150	user1150@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1151	Kornwika	Szymańska-sadowska	KOBIETA	user1151	user1151@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1152	Hasan	Gumienny	MEZCZYZNA	user1152	user1152@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1153	Ruoyu	Markiewicz-kot	KOBIETA	user1153	user1153@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1154	Mikołaj	Matyszczak	MEZCZYZNA	user1154	user1154@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1155	Adelka	Sopata	NIEOKRESLONY	user1155	user1155@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1156	Anastazy	Kroteń	MEZCZYZNA	user1156	user1156@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1157	Heidemaria	Adaeva	KOBIETA	user1157	user1157@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1158	Hugon	Brzęczek	MEZCZYZNA	user1158	user1158@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1159	Witosław	Szyborski	MEZCZYZNA	user1159	user1159@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1160	Thuy hong	Shevah	KOBIETA	user1160	user1160@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1161	Lubogost	Berdyszak	MEZCZYZNA	user1161	user1161@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1162	Wincenty	Goldsmith	MEZCZYZNA	user1162	user1162@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1163	Natan	Strelchyk	MEZCZYZNA	user1163	user1163@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1164	Teofil	Muzaj	MEZCZYZNA	user1164	user1164@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1165	Ursyn	Mładejowski	MEZCZYZNA	user1165	user1165@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1166	Zhargalma	Wieszaczewska	KOBIETA	user1166	user1166@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1167	Eline	Harenda	KOBIETA	user1167	user1167@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1168	Rachil	Dolinowska	NIEOKRESLONY	user1168	user1168@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1169	Klea	Gröne	KOBIETA	user1169	user1169@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1170	Miłosz	Skawski	MEZCZYZNA	user1170	user1170@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1171	Włodzimierz	Dłużniewski	MEZCZYZNA	user1171	user1171@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1172	Rezi	Muziński	MEZCZYZNA	user1172	user1172@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1173	Zenobiusz	Hajn	MEZCZYZNA	user1173	user1173@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1174	Axana	Maszner	KOBIETA	user1174	user1174@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1175	Mojżesz	Zozula	MEZCZYZNA	user1175	user1175@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1176	Tram anh	Senktas	KOBIETA	user1176	user1176@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1177	Abraham	Deringer	MEZCZYZNA	user1177	user1177@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1178	Haiping	Tumidajska	KOBIETA	user1178	user1178@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1179	Xena	Yanovets	KOBIETA	user1179	user1179@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1180	Fela	Luhvishchyk	KOBIETA	user1180	user1180@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1181	Korneliia	Birkos	KOBIETA	user1181	user1181@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1182	Thi dien	Walis	KOBIETA	user1182	user1182@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1183	Anielia	Nekhaichyk	KOBIETA	user1183	user1183@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1184	Fortune	Sroczynska	KOBIETA	user1184	user1184@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1185	Gamida	Miduch	KOBIETA	user1185	user1185@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1186	Bazyli	Smalara	MEZCZYZNA	user1186	user1186@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1187	Fotina	Bagro	KOBIETA	user1187	user1187@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1188	Kilian	Rabos	MEZCZYZNA	user1188	user1188@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1189	Inarta	Domingos	KOBIETA	user1189	user1189@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1190	Dargomir	Łachmacki	MEZCZYZNA	user1190	user1190@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1191	Seyedeh	Kopicara	KOBIETA	user1191	user1191@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1192	Qingyang	Adewoye	KOBIETA	user1192	user1192@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1193	Jiaojiao	Vursol	KOBIETA	user1193	user1193@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1194	Wafaa	Koszów	KOBIETA	user1194	user1194@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1195	Benigia	Omiecka	KOBIETA	user1195	user1195@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1196	Kanimir	Plicner	MEZCZYZNA	user1196	user1196@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1197	Gaj	Pochyła	MEZCZYZNA	user1197	user1197@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1198	Jozafat	Zbikowski	MEZCZYZNA	user1198	user1198@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1199	Lew	Hejda	MEZCZYZNA	user1199	user1199@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1200	Ann michelle	Bodziakowska	KOBIETA	user1200	user1200@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1201	Dariusz	Lauko	MEZCZYZNA	user1201	user1201@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1202	Agapit	Hadaś	MEZCZYZNA	user1202	user1202@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1203	Ahjin	Dejniak	NIEOKRESLONY	user1203	user1203@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1204	Ronald	Chachuła	MEZCZYZNA	user1204	user1204@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1205	Włodzimierz	Tilcz	MEZCZYZNA	user1205	user1205@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1206	Szymon	Affek	MEZCZYZNA	user1206	user1206@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1207	Yueyao	Przecherko	KOBIETA	user1207	user1207@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1208	Amari	Kriewald	KOBIETA	user1208	user1208@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1209	Inbal	Basara	KOBIETA	user1209	user1209@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1210	Godfryg	Myśliwski	MEZCZYZNA	user1210	user1210@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1211	Jeremiasz	Tatys	MEZCZYZNA	user1211	user1211@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1212	Korneli	Osicki	MEZCZYZNA	user1212	user1212@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1213	Analuna	Kielo	KOBIETA	user1213	user1213@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1214	Yuleisi	Sójecka	KOBIETA	user1214	user1214@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1215	Dominik	Ochliński	MEZCZYZNA	user1215	user1215@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1216	Rajner	Młodecki	MEZCZYZNA	user1216	user1216@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1217	Laisa	Scofercea	KOBIETA	user1217	user1217@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1218	August	Bawół	MEZCZYZNA	user1218	user1218@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1219	Marian	Kaliski	MEZCZYZNA	user1219	user1219@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1220	Nicefor	Piętak	MEZCZYZNA	user1220	user1220@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1221	Panna	Czarnomiedza	KOBIETA	user1221	user1221@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1222	Stoyanka	Yaremenko	KOBIETA	user1222	user1222@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1223	Lew	Winczakowski	MEZCZYZNA	user1223	user1223@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1224	Padila	Izakowska	KOBIETA	user1224	user1224@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1225	Sambor	Szpuniar	MEZCZYZNA	user1225	user1225@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1226	Albin	Mentecki	MEZCZYZNA	user1226	user1226@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1227	Owidiusz	Cecelak	MEZCZYZNA	user1227	user1227@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1228	Aichurok	Dyrdina	KOBIETA	user1228	user1228@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1229	Dalbor	Kulesz	MEZCZYZNA	user1229	user1229@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1230	Virgie	Miśnik	KOBIETA	user1230	user1230@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1231	Justyn	Basiak	MEZCZYZNA	user1231	user1231@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1232	Miłosław	Sytniczuk	MEZCZYZNA	user1232	user1232@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1233	Mariarca	Anav	KOBIETA	user1233	user1233@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1234	Bich	Siemież	KOBIETA	user1234	user1234@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1235	Esi̇la	Więckowicz	KOBIETA	user1235	user1235@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1236	Beniamin	Hajduczenia	MEZCZYZNA	user1236	user1236@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1237	Wawrzyniec	Iwaniak	MEZCZYZNA	user1237	user1237@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1238	Roula	Kotassa	KOBIETA	user1238	user1238@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1239	Albert	Retych	MEZCZYZNA	user1239	user1239@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1240	Ireneusz	Michailidis	MEZCZYZNA	user1240	user1240@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1241	Matin	Rudnyeva	KOBIETA	user1241	user1241@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1242	Protazy	Sidelnik	MEZCZYZNA	user1242	user1242@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1243	Konrad	Fulara	MEZCZYZNA	user1243	user1243@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1244	Inocenty	Chełmicki	MEZCZYZNA	user1244	user1244@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1245	Niecisław	Beda	MEZCZYZNA	user1245	user1245@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1246	Dzwonimierz	Liszkiewicz	MEZCZYZNA	user1246	user1246@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1247	Kryspin	Stroiński	MEZCZYZNA	user1247	user1247@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1248	Bodosław	Szafarowicz	MEZCZYZNA	user1248	user1248@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1249	Aleutsina	Monchenko	KOBIETA	user1249	user1249@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1250	Baltazar	Banaczek	MEZCZYZNA	user1250	user1250@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1251	Tachmina	Darvai	KOBIETA	user1251	user1251@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1252	Heliodor	Pyrczak	MEZCZYZNA	user1252	user1252@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1253	Tęgomir	Chwałko	MEZCZYZNA	user1253	user1253@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1254	Faris	Aksjonow	MEZCZYZNA	user1254	user1254@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1255	Godfryd	Chodacki	MEZCZYZNA	user1255	user1255@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1256	Anzelm	Pantak	MEZCZYZNA	user1256	user1256@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1257	Petia	Rawski	KOBIETA	user1257	user1257@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1258	Jacek	Majowski	MEZCZYZNA	user1258	user1258@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1259	Bernardka	Korliuchenko	KOBIETA	user1259	user1259@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1260	Aouatif	Sulkowicz	KOBIETA	user1260	user1260@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1261	Tuoi	Wielb	KOBIETA	user1261	user1261@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1262	Gabor	Wypijewski	MEZCZYZNA	user1262	user1262@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1263	Ha linh	Pozyrewska	KOBIETA	user1263	user1263@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1264	Serafin	Przybiliński	MEZCZYZNA	user1264	user1264@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1265	Basti	Juraske	KOBIETA	user1265	user1265@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1266	Rezi	Kilinowski	MEZCZYZNA	user1266	user1266@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1267	Mściwoj	Łoin	MEZCZYZNA	user1267	user1267@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1268	Thị hợi	Slobodniuc	KOBIETA	user1268	user1268@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1269	Jensen	Pashchyna	KOBIETA	user1269	user1269@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1270	Oli	Prokopiszyn	KOBIETA	user1270	user1270@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1271	Alysia	Sziffer	KOBIETA	user1271	user1271@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1272	Radosław	Motor	MEZCZYZNA	user1272	user1272@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1273	Costanza	Ślot	KOBIETA	user1273	user1273@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1274	Amieliia	Zozulea	KOBIETA	user1274	user1274@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1275	Teobald	Manin	MEZCZYZNA	user1275	user1275@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1276	Medianca	Zandał	KOBIETA	user1276	user1276@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1277	Sędzisław	Terlega	MEZCZYZNA	user1277	user1277@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1278	Annastasiia	Zgółka	KOBIETA	user1278	user1278@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1279	Maurycjusz	Darwish	MEZCZYZNA	user1279	user1279@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1280	Hugo	Klimeczko	MEZCZYZNA	user1280	user1280@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1281	Juri	Grajber	MEZCZYZNA	user1281	user1281@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1282	Gaweł	Bawer	MEZCZYZNA	user1282	user1282@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1283	Tejal	Resl	KOBIETA	user1283	user1283@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1284	Nasif	Maciążka	MEZCZYZNA	user1284	user1284@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1285	Zvezdelina	Burzan	KOBIETA	user1285	user1285@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1286	Boguchwał	Trzaska-durski	MEZCZYZNA	user1286	user1286@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1287	Madita	Herynh	KOBIETA	user1287	user1287@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1288	Leszek	Ignacek	MEZCZYZNA	user1288	user1288@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1289	Marta-alina	Wona	KOBIETA	user1289	user1289@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1290	Zenon	Gondro	MEZCZYZNA	user1290	user1290@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1291	Olgierd	Byrdy	MEZCZYZNA	user1291	user1291@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1292	Beat	Ambrożewicz	MEZCZYZNA	user1292	user1292@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1293	Giunash	Obervaniuk	KOBIETA	user1293	user1293@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1294	Romeo	Rakota	MEZCZYZNA	user1294	user1294@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1295	Henia	Poprych	KOBIETA	user1295	user1295@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1296	Roman	Błach	MEZCZYZNA	user1296	user1296@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1297	Miron	Rogiński	MEZCZYZNA	user1297	user1297@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1298	Więcesława	Chokshi	KOBIETA	user1298	user1298@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1299	Shaista	Shtykhaliuk	KOBIETA	user1299	user1299@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1300	Wiktor	Schooley	MEZCZYZNA	user1300	user1300@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1301	Lihee	Bober-sowa	KOBIETA	user1301	user1301@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1302	Bożidar	Ślęzak	MEZCZYZNA	user1302	user1302@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1303	Dargosław	Epsztein	MEZCZYZNA	user1303	user1303@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1304	Iryka	Rütten	KOBIETA	user1304	user1304@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1305	Sabokhat	Choroszczo	KOBIETA	user1305	user1305@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1306	Zlata	Grzymalska	KOBIETA	user1306	user1306@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1307	Ludwik	Deszczka	MEZCZYZNA	user1307	user1307@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1308	Kamil	Dawydiuk	MEZCZYZNA	user1308	user1308@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1309	Ginalyn	Ruhmann	KOBIETA	user1309	user1309@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1310	Danislava	Avraam	KOBIETA	user1310	user1310@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1311	Radosław	Jarus	MEZCZYZNA	user1311	user1311@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1312	Elianis	Fonariova	KOBIETA	user1312	user1312@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1313	Suzan	Ruśka	KOBIETA	user1313	user1313@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1314	Ingeborg	Chlebiecka	KOBIETA	user1314	user1314@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1315	Maryn	Gajdzicki	MEZCZYZNA	user1315	user1315@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1316	Kalliope	Medykovska	KOBIETA	user1316	user1316@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1317	Świętosław	Surawski	MEZCZYZNA	user1317	user1317@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1318	Agapit	Całka	MEZCZYZNA	user1318	user1318@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1319	Anastazy	Matar	MEZCZYZNA	user1319	user1319@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1320	Anastazy	Holender	MEZCZYZNA	user1320	user1320@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1321	Mokhichekhra	Maskaleva	KOBIETA	user1321	user1321@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1322	Lidyia	Valka	KOBIETA	user1322	user1322@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1323	Gaj	Rokicki afonso	MEZCZYZNA	user1323	user1323@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1324	Żytomir	Suwaj	MEZCZYZNA	user1324	user1324@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1325	Tamiła	Wegner	KOBIETA	user1325	user1325@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1326	Łukasz	Lechman	MEZCZYZNA	user1326	user1326@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1327	Heng	Shorodok	KOBIETA	user1327	user1327@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1328	Zygmunta	Kozimor-ledochowski	MEZCZYZNA	user1328	user1328@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1329	Edgar	Gimza	MEZCZYZNA	user1329	user1329@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1330	Fryc	Kiepal	MEZCZYZNA	user1330	user1330@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1331	Wei	Benha	KOBIETA	user1331	user1331@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1332	Andrea patricia	Wdowczak	KOBIETA	user1332	user1332@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1333	Ashwaq	Burzyńska-sikora	KOBIETA	user1333	user1333@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1334	Tugsjargal	Verinkina	KOBIETA	user1334	user1334@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1335	Ayka	Rezantseva	KOBIETA	user1335	user1335@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1336	Sesilia	Khadisova	KOBIETA	user1336	user1336@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1337	Salomon	Majdziński	MEZCZYZNA	user1337	user1337@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1338	Zeynep sude	Lanting	KOBIETA	user1338	user1338@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1339	Krystian	Gulcz	MEZCZYZNA	user1339	user1339@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1340	Jacenty	Lemieszek-bury	MEZCZYZNA	user1340	user1340@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1341	Murat	Kosmal	MEZCZYZNA	user1341	user1341@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1342	Albert	Czerzniewski	MEZCZYZNA	user1342	user1342@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1343	Mursal	Charabin	KOBIETA	user1343	user1343@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1344	Katalaya	Kotarek	KOBIETA	user1344	user1344@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1345	Chrystian	Biłat	MEZCZYZNA	user1345	user1345@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1346	Walery	Piszczak	MEZCZYZNA	user1346	user1346@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1347	Stefan	Kuchmiichuk	MEZCZYZNA	user1347	user1347@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1348	Barbare	Amatucci	KOBIETA	user1348	user1348@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1349	Lillia	Iwacik	KOBIETA	user1349	user1349@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1350	Samson	Pabich	MEZCZYZNA	user1350	user1350@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1351	Zenobiusz	Słoboda	MEZCZYZNA	user1351	user1351@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1352	Elenka	Doronowska	KOBIETA	user1352	user1352@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1353	Botagoz	Bohuzh	KOBIETA	user1353	user1353@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1354	Łazarz	Żabczyński	MEZCZYZNA	user1354	user1354@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1355	Alieksandra	Janik-maj	KOBIETA	user1355	user1355@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1356	Lilianne	Taramas	KOBIETA	user1356	user1356@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1357	Maurycy	Lebek	MEZCZYZNA	user1357	user1357@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1358	Winifred	Karisova	KOBIETA	user1358	user1358@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1359	Zlata-adelina	Tvarok	KOBIETA	user1359	user1359@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1360	Zhaklin	Rojkiewicz	KOBIETA	user1360	user1360@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1361	Maryiam	Jaseniuk	KOBIETA	user1361	user1361@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1362	Yuntong	Widórska	KOBIETA	user1362	user1362@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1363	Miłowit	Słabiniak	MEZCZYZNA	user1363	user1363@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1364	Mieszko	Męczyński	MEZCZYZNA	user1364	user1364@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1365	Kätlin	Maziarkina	KOBIETA	user1365	user1365@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1366	Tadeusz	Kaltenberg	MEZCZYZNA	user1366	user1366@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1367	Miłowan	Ryder	MEZCZYZNA	user1367	user1367@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1368	Dobrogost	Śniegowski	MEZCZYZNA	user1368	user1368@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1369	Emika	Kawłatow	KOBIETA	user1369	user1369@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1370	Radowit	Zdun	MEZCZYZNA	user1370	user1370@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1371	Celestyn	Shewakramani	MEZCZYZNA	user1371	user1371@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1372	Bożimir	Latawiec	MEZCZYZNA	user1372	user1372@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1373	Protazy	Machola	MEZCZYZNA	user1373	user1373@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1374	Vladilena	Pazyuk	KOBIETA	user1374	user1374@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1375	Jaein	Prokop-pokrywka	KOBIETA	user1375	user1375@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1376	Bassma	Hirshveld	KOBIETA	user1376	user1376@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1377	Vi	Machowska-krawczyk	KOBIETA	user1377	user1377@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1378	Jarowit	Jaroni	MEZCZYZNA	user1378	user1378@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1379	Sulibor	Gaworski	MEZCZYZNA	user1379	user1379@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1380	Aspram	Chitadze	KOBIETA	user1380	user1380@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1381	Ionah	Zagrobelna	KOBIETA	user1381	user1381@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1382	Emelly	Procharska	KOBIETA	user1382	user1382@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1383	Harleen	Yuliastari	KOBIETA	user1383	user1383@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1384	Izajasz	Gocal	MEZCZYZNA	user1384	user1384@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1385	Gursharanjit	Rukomanova	KOBIETA	user1385	user1385@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1386	Monica alejandra	Żara	KOBIETA	user1386	user1386@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1387	Bakhytkul	Letnianka	KOBIETA	user1387	user1387@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1388	Teia	Pikis	KOBIETA	user1388	user1388@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1389	Wenetka	Kubeyeva	KOBIETA	user1389	user1389@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1390	Aleksander	Boldyriev	MEZCZYZNA	user1390	user1390@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1391	Inabat	Szczepańska-michalska	KOBIETA	user1391	user1391@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1392	Feryda	Skwarszczow	KOBIETA	user1392	user1392@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1393	Tzu-ying	Fleps	KOBIETA	user1393	user1393@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1394	Linh chi	Narwani	KOBIETA	user1394	user1394@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1395	Grzegorz	Fałczyński	MEZCZYZNA	user1395	user1395@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1396	Keerti	Mamlieieva	KOBIETA	user1396	user1396@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1397	Zefiryn	Tylus	MEZCZYZNA	user1397	user1397@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1398	Abelard	Oblej	MEZCZYZNA	user1398	user1398@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1399	Manju	Kirzynowska	KOBIETA	user1399	user1399@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1400	Iliia	Basnet	KOBIETA	user1400	user1400@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1401	Omar	Pater-ziemięcki	MEZCZYZNA	user1401	user1401@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1402	Adam	Szejki	MEZCZYZNA	user1402	user1402@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1403	Juditha	Spirzak	KOBIETA	user1403	user1403@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1404	Jevgēnija	Krzyżanowska-kawa	KOBIETA	user1404	user1404@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1405	Wespazjan	Janas	MEZCZYZNA	user1405	user1405@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1406	Claris	Helias	KOBIETA	user1406	user1406@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1407	Namya	Palkowski	KOBIETA	user1407	user1407@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1408	Hieronim	Sekretarczyk	MEZCZYZNA	user1408	user1408@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1409	Ładysław	Kasza	MEZCZYZNA	user1409	user1409@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1410	Wojciech	Cnotka	MEZCZYZNA	user1410	user1410@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1411	Pabian	Kalmanowicz	MEZCZYZNA	user1411	user1411@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1412	Fozia	Shuturmynska	KOBIETA	user1412	user1412@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1413	Wojsław	Gubienia	MEZCZYZNA	user1413	user1413@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1414	Katsyaryna	Kubińska	KOBIETA	user1414	user1414@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1415	Monica del pilar	Hucman	KOBIETA	user1415	user1415@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1416	Gaganpreet	Woźniak-kujawa	KOBIETA	user1416	user1416@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1417	Grzymisława	Simmt	KOBIETA	user1417	user1417@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1418	Patryk	Grzyśka	MEZCZYZNA	user1418	user1418@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1419	Özgül	Kokhtiuk	KOBIETA	user1419	user1419@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1420	Savvina	Abdiyeva	KOBIETA	user1420	user1420@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1421	Nemezis	Shchyboruk	KOBIETA	user1421	user1421@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1422	Perpetue	Durnicka	KOBIETA	user1422	user1422@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1423	Pafnucy	Łochowicz	MEZCZYZNA	user1423	user1423@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1424	Bayartuya	Gonczar	NIEOKRESLONY	user1424	user1424@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1425	Lubomił	Łagoński	MEZCZYZNA	user1425	user1425@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1426	Ursyna	Nocun	KOBIETA	user1426	user1426@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1427	Avani	Yemialyanchyk	KOBIETA	user1427	user1427@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1428	Ewald	Bronarczyk	MEZCZYZNA	user1428	user1428@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1429	Stoigniew	Raźnik	MEZCZYZNA	user1429	user1429@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1430	Szczepan	Lilis	MEZCZYZNA	user1430	user1430@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1431	Armelle	Czajer	KOBIETA	user1431	user1431@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1432	Rania	Moczulis	KOBIETA	user1432	user1432@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1433	Huyên	Libizak	KOBIETA	user1433	user1433@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1434	Thi men	Maływojtek	KOBIETA	user1434	user1434@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1435	Ezaw	Kierych	MEZCZYZNA	user1435	user1435@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1436	Natan	Szonert	MEZCZYZNA	user1436	user1436@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1437	Berta	Digeva	KOBIETA	user1437	user1437@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1438	Norbert	Dziadecki	MEZCZYZNA	user1438	user1438@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1439	Ku	Chara	NIEOKRESLONY	user1439	user1439@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1440	Laura melissa	Jafari-dehdari	KOBIETA	user1440	user1440@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1441	Wojsław	Grynkiewicz	MEZCZYZNA	user1441	user1441@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1442	Penka	Kremezna	KOBIETA	user1442	user1442@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1443	Honorat	Zgrzeba	MEZCZYZNA	user1443	user1443@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1444	Pasqualina	Abitante	KOBIETA	user1444	user1444@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1445	Husajn	Bilański	MEZCZYZNA	user1445	user1445@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1446	Ezaw	Sychowski	MEZCZYZNA	user1446	user1446@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1447	Thi hoang	Mielkova	KOBIETA	user1447	user1447@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1448	Dobrosław	Cogiel	MEZCZYZNA	user1448	user1448@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1449	Samson	Stręfner	MEZCZYZNA	user1449	user1449@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1450	Zeyra	Bondurovska	KOBIETA	user1450	user1450@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1451	Konradyn	Zbierajewski	MEZCZYZNA	user1451	user1451@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1452	Witołd	Oleksak	MEZCZYZNA	user1452	user1452@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1453	Maria-aurora	Gutsevych	KOBIETA	user1453	user1453@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1454	Juliana	Sawala-uryasz	KOBIETA	user1454	user1454@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1455	Hi̇cran	Borshevska	KOBIETA	user1455	user1455@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1456	Starwit	Gierzek	MEZCZYZNA	user1456	user1456@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1457	Hektor	Chyt	MEZCZYZNA	user1457	user1457@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1458	Rozália	Szemrak	KOBIETA	user1458	user1458@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1459	Bożydar	Gojny	MEZCZYZNA	user1459	user1459@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1460	Stoigniew	Leyk	MEZCZYZNA	user1460	user1460@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1461	Yefymiia	Najdzicz	KOBIETA	user1461	user1461@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1462	Evielina	Kaczerowska	KOBIETA	user1462	user1462@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1463	Filip	Krankowski	MEZCZYZNA	user1463	user1463@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1464	Alwin	Paniutycz	MEZCZYZNA	user1464	user1464@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1465	Gaweł	Srebrzyński	MEZCZYZNA	user1465	user1465@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1466	Azenith	Maćkowska	KOBIETA	user1466	user1466@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1467	Michał	Szrek	MEZCZYZNA	user1467	user1467@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1468	Miłogost	Byszko	MEZCZYZNA	user1468	user1468@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1469	Florentyn	Kwilas	MEZCZYZNA	user1469	user1469@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1470	Przedpełk	Grośty	MEZCZYZNA	user1470	user1470@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1471	Anhela	Wenders	KOBIETA	user1471	user1471@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1472	Gilia	Gózdź	KOBIETA	user1472	user1472@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1473	Chwalimir	Leonarczyk	MEZCZYZNA	user1473	user1473@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1474	Claudina	Socik	KOBIETA	user1474	user1474@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1475	Crista	Sołowczuk	KOBIETA	user1475	user1475@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1476	Binbin	Saverinas	KOBIETA	user1476	user1476@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1477	Selina	Racino	KOBIETA	user1477	user1477@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1478	Michał	Mazzieri	MEZCZYZNA	user1478	user1478@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1479	Nuris	Tarkowski	KOBIETA	user1479	user1479@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1480	Faustyn	Tylutki	MEZCZYZNA	user1480	user1480@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1481	Wisław	Lesiński	MEZCZYZNA	user1481	user1481@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1482	Augustyn	Sośniak	MEZCZYZNA	user1482	user1482@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1483	Gwido	Danch	MEZCZYZNA	user1483	user1483@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1484	Hasan	Krawczoski	MEZCZYZNA	user1484	user1484@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1485	Henny	Kłymuś	KOBIETA	user1485	user1485@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1486	Vadym	Zonzinski bruten	KOBIETA	user1486	user1486@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1487	Ylva	Kasovska	KOBIETA	user1487	user1487@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1488	Radogost	Szadkowski	MEZCZYZNA	user1488	user1488@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1489	Hieronim	Rejmicz	MEZCZYZNA	user1489	user1489@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1490	Hipolit	Mandziak	MEZCZYZNA	user1490	user1490@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1491	Alfiia	Bodor	KOBIETA	user1491	user1491@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1492	Astrid	Pawluch	KOBIETA	user1492	user1492@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1493	Miroład	Daunke	MEZCZYZNA	user1493	user1493@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1494	Malachiasz	Wojciulewicz	MEZCZYZNA	user1494	user1494@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1495	Thao my	Grzewca	KOBIETA	user1495	user1495@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1496	Angila	Znajszły	KOBIETA	user1496	user1496@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1497	Teodozjusz	Bołtuć	MEZCZYZNA	user1497	user1497@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1498	Stoigniew	Żarek	MEZCZYZNA	user1498	user1498@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1499	Fabian	Horbanowicz	MEZCZYZNA	user1499	user1499@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1500	Rusudani	Férasse	KOBIETA	user1500	user1500@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1501	Żytomir	Szmyd	MEZCZYZNA	user1501	user1501@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1502	Stanisław	Tęsiorowski	MEZCZYZNA	user1502	user1502@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1503	Dżemil	Kupiec	MEZCZYZNA	user1503	user1503@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1504	Kain	Blicharski	MEZCZYZNA	user1504	user1504@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1505	Ludomił	Lichtblau	MEZCZYZNA	user1505	user1505@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1506	Andrada	Savisko	KOBIETA	user1506	user1506@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1507	Taly	Gvozdova	KOBIETA	user1507	user1507@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1508	Jingru	Shin	KOBIETA	user1508	user1508@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1509	Dobrogost	Dolepa	MEZCZYZNA	user1509	user1509@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1510	Ivietta	Yunker	KOBIETA	user1510	user1510@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1511	Szymon	Pąśko	MEZCZYZNA	user1511	user1511@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1512	Leopold	Patykiewicz	MEZCZYZNA	user1512	user1512@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1513	Zdenka	Mitina	KOBIETA	user1513	user1513@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1514	Sulibor	Hudziec	MEZCZYZNA	user1514	user1514@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1515	Dawid	Ludkowski	MEZCZYZNA	user1515	user1515@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1516	Yam	Sonina	KOBIETA	user1516	user1516@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1517	Kevine	Mazur-dudzińska	KOBIETA	user1517	user1517@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1518	Donald	Kruszakin	MEZCZYZNA	user1518	user1518@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1519	Lucía	Picińska	KOBIETA	user1519	user1519@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1520	Bogumina	Tadla	KOBIETA	user1520	user1520@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1521	Ezaw	Stampka	MEZCZYZNA	user1521	user1521@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1522	Khanh ngan	Szofer-araya	KOBIETA	user1522	user1522@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1523	Nguyen	Efner	KOBIETA	user1523	user1523@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1524	Chunlian	Welyhorska	KOBIETA	user1524	user1524@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1525	Szymon	Denisewicz	MEZCZYZNA	user1525	user1525@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1526	Cecylian	Wiarek	MEZCZYZNA	user1526	user1526@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1527	Ecri̇n	Szuba-wójcik	KOBIETA	user1527	user1527@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1528	Teodozjusz	Obiegałka	MEZCZYZNA	user1528	user1528@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1529	Gilbert	Jozinović	MEZCZYZNA	user1529	user1529@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1530	Dhan	Rabyniuk	KOBIETA	user1530	user1530@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1531	Julian	Kociuban	MEZCZYZNA	user1531	user1531@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1532	Milahres	Martinez nieto	KOBIETA	user1532	user1532@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1533	Šarlota	Weichelt	KOBIETA	user1533	user1533@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1534	Sebastian	Lubański	MEZCZYZNA	user1534	user1534@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1535	Ruzanna	Sibirtseva	KOBIETA	user1535	user1535@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1536	Fela	Özsoy	KOBIETA	user1536	user1536@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1537	María del pilar	Dimke	KOBIETA	user1537	user1537@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1538	Donita	Petrunyk	KOBIETA	user1538	user1538@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1539	Karma	Pochwała	KOBIETA	user1539	user1539@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1540	Edward	Samuła	MEZCZYZNA	user1540	user1540@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1541	Wirginiusz	Gobucki	MEZCZYZNA	user1541	user1541@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1542	Agaton	Bej	MEZCZYZNA	user1542	user1542@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1543	Ksenya	Krasicka	KOBIETA	user1543	user1543@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1544	Louisa	Derebizova	KOBIETA	user1544	user1544@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1545	Lubisław	Benski	MEZCZYZNA	user1545	user1545@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1546	Miłosz	Szefliński	MEZCZYZNA	user1546	user1546@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1547	Witold	Zwienczak	MEZCZYZNA	user1547	user1547@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1548	Pikria	Katiushcheva	KOBIETA	user1548	user1548@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1549	Harvi	Mezhuev	KOBIETA	user1549	user1549@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1550	Alabama	Tutak-rutkowska	KOBIETA	user1550	user1550@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1551	Luminitsa	Rudia	KOBIETA	user1551	user1551@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1552	Józefat	Klonowicz	MEZCZYZNA	user1552	user1552@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1553	Jonatan	Śliwiński	MEZCZYZNA	user1553	user1553@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1554	Dionela	Puterko	KOBIETA	user1554	user1554@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1555	Marin	Szalc	MEZCZYZNA	user1555	user1555@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1556	Alazne	Legayeva	KOBIETA	user1556	user1556@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1557	Jovielyn	Godja	KOBIETA	user1557	user1557@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1558	Arkady	Horończyk	MEZCZYZNA	user1558	user1558@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1559	Shiqin	Chiduku	KOBIETA	user1559	user1559@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1560	Homa	Hudák	KOBIETA	user1560	user1560@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1561	Andre	Ryżowicz	KOBIETA	user1561	user1561@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1562	Protazy	Stiwe	MEZCZYZNA	user1562	user1562@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1563	Adnan	Saczyński	MEZCZYZNA	user1563	user1563@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1564	Alojzy	Konichał	MEZCZYZNA	user1564	user1564@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1565	Nathalie	Zaskwara	KOBIETA	user1565	user1565@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1566	Jur	Jurdziński	MEZCZYZNA	user1566	user1566@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1567	Odo	Preweda	MEZCZYZNA	user1567	user1567@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1568	Donat	Mylik	MEZCZYZNA	user1568	user1568@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1569	Haiwei	Wajdenfeld	KOBIETA	user1569	user1569@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1570	Thi hong tham	Wielgoławska	KOBIETA	user1570	user1570@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1571	Jozafat	Osoch	MEZCZYZNA	user1571	user1571@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1572	Shalimar	Wojda-wojciechowska	KOBIETA	user1572	user1572@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1573	Feliks	Ziajkiewicz	MEZCZYZNA	user1573	user1573@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1574	Liliya	Dowgwiłłowicz	KOBIETA	user1574	user1574@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1575	Svatava	Wawrzynów	KOBIETA	user1575	user1575@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1576	Zefir	Śmiałek	MEZCZYZNA	user1576	user1576@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1577	Subisław	Siebiesiuk	MEZCZYZNA	user1577	user1577@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1578	Princessa	Czerga	KOBIETA	user1578	user1578@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1579	Bruno	Kościuk	MEZCZYZNA	user1579	user1579@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1580	Marian	Boué	MEZCZYZNA	user1580	user1580@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1581	Nagat	Gołda	KOBIETA	user1581	user1581@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1582	Zygmunta	Łyskanowski	MEZCZYZNA	user1582	user1582@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1583	Laysa	Pieła	KOBIETA	user1583	user1583@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1584	Nelie	Welikson	KOBIETA	user1584	user1584@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1585	Kseniia	Gard	KOBIETA	user1585	user1585@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1586	Pemika	Sapishchuk	KOBIETA	user1586	user1586@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1587	Albrecht	Bedyk	MEZCZYZNA	user1587	user1587@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1588	Jangmu	Protaś-kowalska	KOBIETA	user1588	user1588@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1589	Nataniel	Wardęga	MEZCZYZNA	user1589	user1589@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1590	Żarko	Walko	MEZCZYZNA	user1590	user1590@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1591	Kelli	Razvadovskaya	KOBIETA	user1591	user1591@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1592	Anželika	Dyhdalevych	KOBIETA	user1592	user1592@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1593	Leo	Haratym	MEZCZYZNA	user1593	user1593@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1594	Armelia	Brake	KOBIETA	user1594	user1594@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1595	Luydmyla	Bimer	KOBIETA	user1595	user1595@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1596	Kendra	Humienna	KOBIETA	user1596	user1596@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1597	Lilanda	Tuczapska	KOBIETA	user1597	user1597@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1598	Alojzy	Godzisz	MEZCZYZNA	user1598	user1598@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1599	Arletta	Vainovska	KOBIETA	user1599	user1599@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1600	Abelard	Parobczyk	MEZCZYZNA	user1600	user1600@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1601	Akadia	Oufary	KOBIETA	user1601	user1601@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1602	Szymon	Ścieszkowski	MEZCZYZNA	user1602	user1602@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1603	Radomir	Niewczyk	MEZCZYZNA	user1603	user1603@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1604	Anouchka	Ursem	KOBIETA	user1604	user1604@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1605	Amélie	Bogdan	KOBIETA	user1605	user1605@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1606	Oktawian	Karnas	MEZCZYZNA	user1606	user1606@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1607	Anastazy	Gryzka	MEZCZYZNA	user1607	user1607@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1608	Katerin	Itman	KOBIETA	user1608	user1608@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1609	Thị phương nga	Gasparjan	KOBIETA	user1609	user1609@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1610	Lixin	Ulmanek	KOBIETA	user1610	user1610@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1611	Leizl	Strubelt	KOBIETA	user1611	user1611@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1612	Mojmir	Zulauf	MEZCZYZNA	user1612	user1612@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1613	Edward	Pezda	MEZCZYZNA	user1613	user1613@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1614	Wincenty	Vlach	MEZCZYZNA	user1614	user1614@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1615	Alyn	Vardapetyan	KOBIETA	user1615	user1615@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1616	Przemysław	Pec	MEZCZYZNA	user1616	user1616@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1617	Ludwik	Rach	MEZCZYZNA	user1617	user1617@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1618	Heliodor	Jaszcza	MEZCZYZNA	user1618	user1618@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1619	Radosław	Marszałek	MEZCZYZNA	user1619	user1619@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1620	Lubomił	Musialski	MEZCZYZNA	user1620	user1620@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1621	Roman	Cosma	MEZCZYZNA	user1621	user1621@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1622	Abelard	Bytys	MEZCZYZNA	user1622	user1622@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1623	Sammy	Turzai	KOBIETA	user1623	user1623@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1624	Teobald	Bożym	MEZCZYZNA	user1624	user1624@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1625	Dżamil	Bujarski	MEZCZYZNA	user1625	user1625@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1626	Cecyl	Nurzyński	MEZCZYZNA	user1626	user1626@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1627	Teodozjusz	Filiszewski	MEZCZYZNA	user1627	user1627@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1628	Yoni	Kremkowska	KOBIETA	user1628	user1628@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1629	Gracjan	Lędźwa	MEZCZYZNA	user1629	user1629@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1630	Hayarpi	Mirecka-kołt	KOBIETA	user1630	user1630@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1631	Bert	Kunecki	MEZCZYZNA	user1631	user1631@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1632	Paskal	Klin	MEZCZYZNA	user1632	user1632@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1633	Khayala	Smoląg	NIEOKRESLONY	user1633	user1633@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1634	Tunezja	Braig	KOBIETA	user1634	user1634@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1635	Miyu	Postowicz	KOBIETA	user1635	user1635@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1636	Pawanrat	Kuplovska	KOBIETA	user1636	user1636@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1637	Haeun	Klabuhn	KOBIETA	user1637	user1637@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1638	Szymon	Chiński	MEZCZYZNA	user1638	user1638@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1639	Faris	Kurcewicz	MEZCZYZNA	user1639	user1639@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1640	Wirgiliusz	Goliszewski	MEZCZYZNA	user1640	user1640@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1641	Ernestyna	Cherdakliieva	KOBIETA	user1641	user1641@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1642	Teodor	Tyrakowski	MEZCZYZNA	user1642	user1642@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1643	Miluška	Goryc	KOBIETA	user1643	user1643@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1644	Vesta	Kijek	KOBIETA	user1644	user1644@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1645	Dżemil	Korkus	MEZCZYZNA	user1645	user1645@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1646	Faustyna	Constantinidou	KOBIETA	user1646	user1646@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1647	Lubisław	Kalla	MEZCZYZNA	user1647	user1647@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1648	Gwidon	Ciekot	MEZCZYZNA	user1648	user1648@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1649	Olgierd	Gołdyń	MEZCZYZNA	user1649	user1649@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1650	Bazyli	Siol	MEZCZYZNA	user1650	user1650@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1651	Edwin	Knoch	MEZCZYZNA	user1651	user1651@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1652	Zachariasz	Mazan	MEZCZYZNA	user1652	user1652@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1653	Fatimat	Ratnikova	KOBIETA	user1653	user1653@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1654	Gniewomir	Prystaj	MEZCZYZNA	user1654	user1654@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1655	Flyura	Wicnudel	KOBIETA	user1655	user1655@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1656	Kwiatosław	Miliniewski	MEZCZYZNA	user1656	user1656@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1657	Maksymilian	Kosz	MEZCZYZNA	user1657	user1657@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1658	Jacenty	Patynowski	MEZCZYZNA	user1658	user1658@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1659	Bożydar	Oklejak	MEZCZYZNA	user1659	user1659@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1660	Idyta	Trystuła	KOBIETA	user1660	user1660@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1661	Safie	Czerwienko	KOBIETA	user1661	user1661@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1662	Emir	Szudrzyński	MEZCZYZNA	user1662	user1662@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1663	Ursyn	Paluszkiewicz	MEZCZYZNA	user1663	user1663@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1664	Jan	Śniadach	MEZCZYZNA	user1664	user1664@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1665	Di̇cle	Panfiluk	KOBIETA	user1665	user1665@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1666	Leonah	Zakrynychna	KOBIETA	user1666	user1666@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1667	Wrocisław	Błocki	MEZCZYZNA	user1667	user1667@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1668	Ezechiel	Davchevski	MEZCZYZNA	user1668	user1668@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1669	Parichart	Olinek	KOBIETA	user1669	user1669@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1670	Te-ju	Bohatyrenko	KOBIETA	user1670	user1670@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1671	Yenglik	Bertocchi	KOBIETA	user1671	user1671@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1672	Dobrila	Aref	KOBIETA	user1672	user1672@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1673	Behi̇ye	Oskędra	KOBIETA	user1673	user1673@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1674	Tu	Trayanava	KOBIETA	user1674	user1674@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1675	Dobrawa	Thephavongsa	KOBIETA	user1675	user1675@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1676	Ewaryst	Klember	MEZCZYZNA	user1676	user1676@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1677	Bogusz	Treska	MEZCZYZNA	user1677	user1677@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1678	Rejoyce	Szurani	KOBIETA	user1678	user1678@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1679	Maurycjusz	Both	MEZCZYZNA	user1679	user1679@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1680	Zvia	Sesiutchenkova	KOBIETA	user1680	user1680@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1681	Shruti	Koslowska	KOBIETA	user1681	user1681@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1682	Damian	Łokieć	MEZCZYZNA	user1682	user1682@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1683	Patrycjusz	Alzuszczak	MEZCZYZNA	user1683	user1683@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1684	Norbert	Świstek	MEZCZYZNA	user1684	user1684@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1685	Nezhdana	Uliczny	KOBIETA	user1685	user1685@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1686	Walfryda	Felkerzam	KOBIETA	user1686	user1686@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1687	Nectaria	Wichmanowska	KOBIETA	user1687	user1687@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1688	Jacklin	Śmigocka	KOBIETA	user1688	user1688@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1689	Sławomir	Sikora-matham	MEZCZYZNA	user1689	user1689@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1690	Radomir	Dragan	MEZCZYZNA	user1690	user1690@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1691	Eryka	Tsykylok	KOBIETA	user1691	user1691@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1692	Soon	Lubke	KOBIETA	user1692	user1692@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1693	Apollo	Żmujdzian	MEZCZYZNA	user1693	user1693@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1694	Amadeusz	Sobal	MEZCZYZNA	user1694	user1694@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1695	Elaine	Dźwierzyńska	KOBIETA	user1695	user1695@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1696	Kemal	Wędt	MEZCZYZNA	user1696	user1696@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1697	Amin	Glinkowski	KOBIETA	user1697	user1697@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1698	Judita	Tawrelis	KOBIETA	user1698	user1698@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1699	Sofroniusz	Kuziemkowski	MEZCZYZNA	user1699	user1699@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1700	Jung hee	Viriasova	KOBIETA	user1700	user1700@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1701	Saveta	Parshykova	KOBIETA	user1701	user1701@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1702	Tomisław	Łojowski	MEZCZYZNA	user1702	user1702@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1703	Colletta	Sopalla	NIEOKRESLONY	user1703	user1703@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1704	Thuy dung	Wallach	KOBIETA	user1704	user1704@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1705	Gwido	Komo-libio	MEZCZYZNA	user1705	user1705@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1706	Rahaf	Donahue	KOBIETA	user1706	user1706@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1707	Astera	Kunitskaya	KOBIETA	user1707	user1707@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1708	Ivana	Onufrejczyk	NIEOKRESLONY	user1708	user1708@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1709	Antonin	Bozymowski	MEZCZYZNA	user1709	user1709@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1710	Maurycy	Domańczyk	MEZCZYZNA	user1710	user1710@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1711	Cyryl	Pietrów	MEZCZYZNA	user1711	user1711@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1712	Guzial	Wielczyk	KOBIETA	user1712	user1712@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1713	Qingyu	Zawiłkowska	KOBIETA	user1713	user1713@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1714	Starwit	Dziadowiec	MEZCZYZNA	user1714	user1714@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1715	Kornel-korni	Bustrycki	MEZCZYZNA	user1715	user1715@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1716	Ariel	Ludwin	MEZCZYZNA	user1716	user1716@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1717	Lucjan	Brozdowski	MEZCZYZNA	user1717	user1717@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1718	Makary	Migocki	MEZCZYZNA	user1718	user1718@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1719	Erwin	Lampinen	MEZCZYZNA	user1719	user1719@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1720	Sylwester	Ryniak	MEZCZYZNA	user1720	user1720@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1721	Ornelia	Amusa	KOBIETA	user1721	user1721@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1722	Tolisława	Śmiejowska	KOBIETA	user1722	user1722@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1723	Hanusz	Zawada	MEZCZYZNA	user1723	user1723@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1724	Younah	Chmus	KOBIETA	user1724	user1724@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1725	Stoisław	Magdziarz ibrahim-el-nur	MEZCZYZNA	user1725	user1725@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1726	Dobroniega	Grzegosz	KOBIETA	user1726	user1726@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1727	Apollo	Szklanecki	MEZCZYZNA	user1727	user1727@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1728	Jur	Stepek	MEZCZYZNA	user1728	user1728@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1729	Květoslava	Kilewski	KOBIETA	user1729	user1729@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1730	Aleksy	Oksiński	MEZCZYZNA	user1730	user1730@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1731	Cirilla	Sadowska-czarnota	KOBIETA	user1731	user1731@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1732	Tambudzai	Andrykevych	KOBIETA	user1732	user1732@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1733	Huiqing	Tsytrikova	KOBIETA	user1733	user1733@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1734	Cindarella	Hasselmann	KOBIETA	user1734	user1734@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1735	Świętopełk	Ruda	MEZCZYZNA	user1735	user1735@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1736	Edmund	Brzeczkowski	MEZCZYZNA	user1736	user1736@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1737	Baltazar	Tumielewicz	MEZCZYZNA	user1737	user1737@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1738	Hà phương	Wittenbecher	KOBIETA	user1738	user1738@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1739	Shiho	Varda	KOBIETA	user1739	user1739@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1740	Karol	Stanulewicz	MEZCZYZNA	user1740	user1740@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1741	Ma'ayan	Zatelmajer	KOBIETA	user1741	user1741@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1742	Ana mae	Fabiańczuk	KOBIETA	user1742	user1742@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1743	Wespazjan	Gazdecki	MEZCZYZNA	user1743	user1743@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1744	Toma	Lalaiants	KOBIETA	user1744	user1744@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1745	Thanh truc	Granieczna	KOBIETA	user1745	user1745@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1746	Wisław	Charniak	MEZCZYZNA	user1746	user1746@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1747	Ładysław	Betge	MEZCZYZNA	user1747	user1747@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1748	Bingbing	Shykyriava	KOBIETA	user1748	user1748@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1749	Oleksanra	Vauléon	KOBIETA	user1749	user1749@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1750	Karmena	Gruetzmann	KOBIETA	user1750	user1750@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1751	Tarik	Sitański	MEZCZYZNA	user1751	user1751@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1752	Beibei	Militsch	KOBIETA	user1752	user1752@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1753	Olha-anhelina	Sushak	KOBIETA	user1753	user1753@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1754	Ezechiel	Dyrynda	MEZCZYZNA	user1754	user1754@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1755	Thi quy	Stockmann	KOBIETA	user1755	user1755@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1756	Gerard	Rajwa	MEZCZYZNA	user1756	user1756@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1757	Thao nhi	Kolchina	KOBIETA	user1757	user1757@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1758	Funmilayo	Griffith	KOBIETA	user1758	user1758@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1759	Bodosław	Ryniewicz	MEZCZYZNA	user1759	user1759@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1760	Pabian	Ksenycz	MEZCZYZNA	user1760	user1760@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1761	Bernadia	Clarke-ejuren	KOBIETA	user1761	user1761@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1762	Siyi	Hespodarikova	KOBIETA	user1762	user1762@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1763	Kemal	Kornes	MEZCZYZNA	user1763	user1763@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1764	Kryspin	Szafratowicz	MEZCZYZNA	user1764	user1764@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1765	Angeliya	Șclearuc	KOBIETA	user1765	user1765@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1766	Bartosz	Wajner	MEZCZYZNA	user1766	user1766@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1767	An nhien	Khmelevskaia	KOBIETA	user1767	user1767@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1768	Klemens	Bressan	MEZCZYZNA	user1768	user1768@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1769	Leehe	Szaluś	KOBIETA	user1769	user1769@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1770	Oswald	Grzegórzek	MEZCZYZNA	user1770	user1770@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1771	Ezaw	Brolik	MEZCZYZNA	user1771	user1771@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1772	Romuald	Mardyło	MEZCZYZNA	user1772	user1772@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1773	Uljana	Kretkowska	KOBIETA	user1773	user1773@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1774	Burçak	Sevyrynko	KOBIETA	user1774	user1774@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1775	Olivija	Łunarzewska	KOBIETA	user1775	user1775@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1776	Sylvia	Jankowska-janicka	KOBIETA	user1776	user1776@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1777	Sobiesław	Dapa	MEZCZYZNA	user1777	user1777@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1778	Erjona	Polegeshko	KOBIETA	user1778	user1778@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1779	Miłogost	Bimbir	MEZCZYZNA	user1779	user1779@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1780	Berrak	Treschanski	KOBIETA	user1780	user1780@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1781	Robynne	Hereni	KOBIETA	user1781	user1781@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1782	Loryne	Pleszka	KOBIETA	user1782	user1782@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1783	Bogumir	Gawron	MEZCZYZNA	user1783	user1783@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1784	Teodor	Gabel	MEZCZYZNA	user1784	user1784@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1785	Radina	Islamova	KOBIETA	user1785	user1785@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1786	Rotraud	Moreva	KOBIETA	user1786	user1786@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1787	Tomasz	Odwrocki	MEZCZYZNA	user1787	user1787@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1788	Przedpełk	Omyła	MEZCZYZNA	user1788	user1788@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1789	Fortunat	Kamianka	MEZCZYZNA	user1789	user1789@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1790	Boguchwał	Dzidek	MEZCZYZNA	user1790	user1790@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1791	Bayartuya	Pietrończyk	KOBIETA	user1791	user1791@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1792	Yafei	Brancewicz	KOBIETA	user1792	user1792@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1793	Adriyana	Pokrovetska	KOBIETA	user1793	user1793@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1794	Rezarta	Tsekhonia	KOBIETA	user1794	user1794@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1795	Olgierd	Baracz	MEZCZYZNA	user1795	user1795@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1796	Jada	Dada	KOBIETA	user1796	user1796@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1797	Imanuella	Kruszynski	KOBIETA	user1797	user1797@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1798	Placyd	Paczek	MEZCZYZNA	user1798	user1798@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1799	Seoyoun	Grondas	KOBIETA	user1799	user1799@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1800	Olgierd	Łukajewicz	MEZCZYZNA	user1800	user1800@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1801	Adelajda	Folik	KOBIETA	user1801	user1801@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1802	Berta	Kontrabecka	KOBIETA	user1802	user1802@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1803	Le mai	Holokoz	KOBIETA	user1803	user1803@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1804	Guljan	Cherniata	KOBIETA	user1804	user1804@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1805	Lubomir	Prajsner	MEZCZYZNA	user1805	user1805@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1806	Bingbing	Marcioha	KOBIETA	user1806	user1806@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1807	Kain	Pers	MEZCZYZNA	user1807	user1807@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1808	Justyn	Pasturkiewicz	MEZCZYZNA	user1808	user1808@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1809	Tiffanie	Suchy lipińska	KOBIETA	user1809	user1809@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1810	Jasuf	Popłoński	MEZCZYZNA	user1810	user1810@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1811	Celestyn	Szypniewski	MEZCZYZNA	user1811	user1811@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1812	Shamita	Haichova	KOBIETA	user1812	user1812@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1813	Myong suk	Troianovych	KOBIETA	user1813	user1813@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1814	Emanuel	Szumigraj	MEZCZYZNA	user1814	user1814@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1815	Wielisław	Bartoszyński	MEZCZYZNA	user1815	user1815@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1816	Doyoung	Berli	KOBIETA	user1816	user1816@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1817	Assylzhan	Sałata-sałacińska	KOBIETA	user1817	user1817@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1818	Aleksander	Wolak	MEZCZYZNA	user1818	user1818@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1819	Sławomierz	Bendykowski	MEZCZYZNA	user1819	user1819@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1820	Ni nyoman	Nabiullina	KOBIETA	user1820	user1820@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1821	Madalina	Dukata	KOBIETA	user1821	user1821@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1822	Ludolf	Śmiałowski	MEZCZYZNA	user1822	user1822@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1823	Sandi	Ledviy	KOBIETA	user1823	user1823@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1824	Güllü	Prełowska	KOBIETA	user1824	user1824@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1825	Eyşan	Ziplies	KOBIETA	user1825	user1825@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1826	Dobrogost	Grussy	MEZCZYZNA	user1826	user1826@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1827	Keith	Długińska	KOBIETA	user1827	user1827@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1828	Krzesimir	Rycewicz	MEZCZYZNA	user1828	user1828@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1829	Luo	Van der lee	KOBIETA	user1829	user1829@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1830	Avani	Tumash	KOBIETA	user1830	user1830@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1831	Aniceta	Rohner	KOBIETA	user1831	user1831@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1832	Gunel	Stępień-baran	KOBIETA	user1832	user1832@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1833	Walenty	Gałczyk	MEZCZYZNA	user1833	user1833@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1834	Lubomił	Szlaga	MEZCZYZNA	user1834	user1834@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1835	Przemysł	Nabakowski	MEZCZYZNA	user1835	user1835@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1836	Wirgiliusz	Morgulski	MEZCZYZNA	user1836	user1836@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1837	Orian	Pożyczka	MEZCZYZNA	user1837	user1837@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1838	Dawid	Mroczko	MEZCZYZNA	user1838	user1838@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1839	Krastina	Żaboklicka	KOBIETA	user1839	user1839@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1840	Korneliusz	Drewnowski	MEZCZYZNA	user1840	user1840@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1841	Telesfor	Broszczak	MEZCZYZNA	user1841	user1841@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1842	Roua	Bogdanova-filiarska	KOBIETA	user1842	user1842@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1843	Doroteya	Klymyak	KOBIETA	user1843	user1843@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1844	Alojzy	Rukść	MEZCZYZNA	user1844	user1844@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1845	Cecyl	Bobojć	MEZCZYZNA	user1845	user1845@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1846	Mirosz	Getka	MEZCZYZNA	user1846	user1846@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1847	Siya	Loughrey	KOBIETA	user1847	user1847@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1848	Felicjan	Matys	MEZCZYZNA	user1848	user1848@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1849	Beti	Łatuszyńska	KOBIETA	user1849	user1849@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1850	Gerard	Kurdzieko	MEZCZYZNA	user1850	user1850@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1851	Lucica	Bunieieva	KOBIETA	user1851	user1851@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1852	Venetta	Szemlej	KOBIETA	user1852	user1852@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1853	Hong trang	Kulakin	KOBIETA	user1853	user1853@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1854	Dobiesław	Trembowski	MEZCZYZNA	user1854	user1854@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1855	Yira	Tchinda	KOBIETA	user1855	user1855@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1856	Rajmund	Jungnickel	MEZCZYZNA	user1856	user1856@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1857	Rosłan	Fedorcio	MEZCZYZNA	user1857	user1857@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1858	Rudolf	Smychowski	MEZCZYZNA	user1858	user1858@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1859	Celestyn	Jamroży	MEZCZYZNA	user1859	user1859@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1860	Edgar	Makowiak	MEZCZYZNA	user1860	user1860@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1861	Siemowit	Oborski	MEZCZYZNA	user1861	user1861@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1862	Andrzej	Jurczak	MEZCZYZNA	user1862	user1862@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1863	Kamil	Karłowski	MEZCZYZNA	user1863	user1863@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1864	Ezaw	Chłud	MEZCZYZNA	user1864	user1864@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1865	Dolunay	Isakowa	KOBIETA	user1865	user1865@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1866	Agustin	Kondratenkova	KOBIETA	user1866	user1866@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1867	Arkadiusz	Chochura	MEZCZYZNA	user1867	user1867@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1868	Safet	Pichler	KOBIETA	user1868	user1868@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1869	Rufus	Penconek	MEZCZYZNA	user1869	user1869@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1870	Cezary	Sollich	MEZCZYZNA	user1870	user1870@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1871	Zefiryn	Szteke	MEZCZYZNA	user1871	user1871@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1872	Huöng	Poduszczak	KOBIETA	user1872	user1872@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1873	Otton	Kutszal	MEZCZYZNA	user1873	user1873@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1874	Jasuf	Szadziuk	MEZCZYZNA	user1874	user1874@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1875	Walery	Kobuszko	MEZCZYZNA	user1875	user1875@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1876	Kazimierz	Kreja	MEZCZYZNA	user1876	user1876@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1877	Kazimierz	Rola	MEZCZYZNA	user1877	user1877@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1878	Dariusz	Janeczek	MEZCZYZNA	user1878	user1878@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1879	Rosłan	Płotek	MEZCZYZNA	user1879	user1879@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1880	Bożidar	Blat	MEZCZYZNA	user1880	user1880@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1881	Jesmina	Dumynska	KOBIETA	user1881	user1881@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1882	Neyde	Wołosiuk	KOBIETA	user1882	user1882@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1883	Honorat	Szreder	MEZCZYZNA	user1883	user1883@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1884	Roger	Felis	MEZCZYZNA	user1884	user1884@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1885	Zorza	Kutesko-pawsey	KOBIETA	user1885	user1885@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1886	Yurika	Pereli	KOBIETA	user1886	user1886@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1887	Reshma	Vantsan	KOBIETA	user1887	user1887@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1888	Nani	Kliashtornaya	KOBIETA	user1888	user1888@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1889	Medard	Truchta	MEZCZYZNA	user1889	user1889@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1890	Rufus	Bałdowski	MEZCZYZNA	user1890	user1890@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1891	Xiaojing	Kubilisz	KOBIETA	user1891	user1891@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1892	Romuald	Prendczyński	MEZCZYZNA	user1892	user1892@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1893	Józefat	Widłak	MEZCZYZNA	user1893	user1893@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1894	Mayada	Wilnowicz-ćwieczkowska	KOBIETA	user1894	user1894@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1895	Zygfryd	Kochanek	MEZCZYZNA	user1895	user1895@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1896	Juri	Azarowski	MEZCZYZNA	user1896	user1896@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1897	Yujia	Šabanović	KOBIETA	user1897	user1897@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1898	Thị thu trang	Dzhigarova	KOBIETA	user1898	user1898@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1899	Fula	Katerynenko	KOBIETA	user1899	user1899@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1900	Wisław	Ludwiniak	MEZCZYZNA	user1900	user1900@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1901	Tristan	Barteczko	MEZCZYZNA	user1901	user1901@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1902	Edgar	Pantopulos	MEZCZYZNA	user1902	user1902@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1903	Ariadne	Litwa	KOBIETA	user1903	user1903@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1904	Agnesa	Kakhieieva	KOBIETA	user1904	user1904@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1905	Oluwafunmilola	Graboń	KOBIETA	user1905	user1905@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1906	Tarik	Dudczyk	MEZCZYZNA	user1906	user1906@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1907	Danko	Pienta	MEZCZYZNA	user1907	user1907@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1908	Désirée	Sukhanov kotelnykova	KOBIETA	user1908	user1908@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1909	Kyungah	Van herpen	KOBIETA	user1909	user1909@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1910	Thị ðiệp	Kureń	KOBIETA	user1910	user1910@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1911	Herman	Domżałowicz	MEZCZYZNA	user1911	user1911@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1912	Adelard	Waluchowski	MEZCZYZNA	user1912	user1912@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1913	Oswald	Kurdyk	MEZCZYZNA	user1913	user1913@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1914	Remigiusz	Thulie	MEZCZYZNA	user1914	user1914@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1915	Huijun	Hocyk-marcinowska	KOBIETA	user1915	user1915@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1916	Konstantyn	Stąpor	MEZCZYZNA	user1916	user1916@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1917	Bindu	Sörensen	KOBIETA	user1917	user1917@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1918	Sadhbh	Mięcikiewicz	KOBIETA	user1918	user1918@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1919	Alima	Pactwa	KOBIETA	user1919	user1919@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1920	Tinantin	Stelingowska	KOBIETA	user1920	user1920@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1921	Cichosław	Ciemka	MEZCZYZNA	user1921	user1921@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1922	Kyoung eun	Savoi	KOBIETA	user1922	user1922@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1923	Mousumi	Teologova	KOBIETA	user1923	user1923@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1924	Dżemil	Hildebrandt	MEZCZYZNA	user1924	user1924@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1925	Lumina	Biłda	KOBIETA	user1925	user1925@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1926	Szofia	Pankow	KOBIETA	user1926	user1926@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1927	Saghar	Winsze	KOBIETA	user1927	user1927@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1928	Ferdynanda	Mykychur	KOBIETA	user1928	user1928@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1929	Baldwin	Jeżowski	MEZCZYZNA	user1929	user1929@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1930	Zenaida	Rokotna	KOBIETA	user1930	user1930@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1931	Hayoon	Kavalionak	KOBIETA	user1931	user1931@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1932	Naty	Derzewska	KOBIETA	user1932	user1932@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1933	Hugo	Kudrawców	MEZCZYZNA	user1933	user1933@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1934	Syriusz	Mikulicz	MEZCZYZNA	user1934	user1934@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1935	Tristan	Panasik	MEZCZYZNA	user1935	user1935@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1936	Filipa	Cabigayan	KOBIETA	user1936	user1936@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1937	Sławomir	Korman	MEZCZYZNA	user1937	user1937@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1938	Wendelin	Nytra	MEZCZYZNA	user1938	user1938@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1939	Andreea-georgiana	Andryieuskaia	KOBIETA	user1939	user1939@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1940	Feliks	Jenorowski	MEZCZYZNA	user1940	user1940@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1941	Annasz	Gromada	MEZCZYZNA	user1941	user1941@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1942	Fabian	Giełazis	MEZCZYZNA	user1942	user1942@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1943	Kastor	Serwak	MEZCZYZNA	user1943	user1943@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1944	Enni	Plens	KOBIETA	user1944	user1944@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1945	Apollo	Czehryński	MEZCZYZNA	user1945	user1945@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1946	Anwesha	Kozak-tomaszewska	KOBIETA	user1946	user1946@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1947	Constancia	Żegadło	KOBIETA	user1947	user1947@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1948	Apollo	Barrek	MEZCZYZNA	user1948	user1948@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1949	Mariieta	Sniharenko	KOBIETA	user1949	user1949@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1950	Tine	Szmańkowska	KOBIETA	user1950	user1950@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1951	Floarea	Oskoryp	KOBIETA	user1951	user1951@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1952	Wendelin	Kinnek	MEZCZYZNA	user1952	user1952@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1953	Mengzhen	Halbsguth	KOBIETA	user1953	user1953@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1954	Reggie	Sedlyak	KOBIETA	user1954	user1954@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1955	Alojzy	Budzowski	MEZCZYZNA	user1955	user1955@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1956	Abraham	Rudzik	MEZCZYZNA	user1956	user1956@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1957	Tristan	Firstenhaupt	MEZCZYZNA	user1957	user1957@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1958	Adrian	Wasiel	MEZCZYZNA	user1958	user1958@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1959	Wespazjan	Mutkowski	MEZCZYZNA	user1959	user1959@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1960	August	Łukowicz	MEZCZYZNA	user1960	user1960@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1961	Agrypin	Sztekmiller	MEZCZYZNA	user1961	user1961@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1962	Thi minh trang	Kwapulińska	KOBIETA	user1962	user1962@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1963	Anju	Pulak	KOBIETA	user1963	user1963@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1964	Rubi	Kazachenka	KOBIETA	user1964	user1964@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1965	Martinella	Skots	KOBIETA	user1965	user1965@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1966	Radogost	Półgroszewicz	MEZCZYZNA	user1966	user1966@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1967	Ermelinda	Wojtasik	KOBIETA	user1967	user1967@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1968	Khloia	Łączyna	KOBIETA	user1968	user1968@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1969	Farai	Zamłynny	KOBIETA	user1969	user1969@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1970	Bolebor	Koblański	MEZCZYZNA	user1970	user1970@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1971	Witołd	Kupisz	MEZCZYZNA	user1971	user1971@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1972	Mojżesz	Łuczenczyn	MEZCZYZNA	user1972	user1972@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1973	Manuel	Pelica	MEZCZYZNA	user1973	user1973@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1974	Auta	Bulaya	KOBIETA	user1974	user1974@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1975	Włodzimierz	Grobelny	MEZCZYZNA	user1975	user1975@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1976	Maria juliana	Guitton	KOBIETA	user1976	user1976@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1977	Soiomiya	Yangol	KOBIETA	user1977	user1977@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1978	Rakshita	Meksi	KOBIETA	user1978	user1978@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1979	Juri	Omieljanowicz	MEZCZYZNA	user1979	user1979@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1980	Waldemar	Pęczek	MEZCZYZNA	user1980	user1980@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1981	Makary	Żyliński	MEZCZYZNA	user1981	user1981@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1982	Thị thu hoài	Chekamova	KOBIETA	user1982	user1982@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1983	Kanimir	Helka	MEZCZYZNA	user1983	user1983@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1984	Jung eun	Putava	KOBIETA	user1984	user1984@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1985	Eliane	Fąka	KOBIETA	user1985	user1985@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1986	Grodzisław	Kożuchowski	MEZCZYZNA	user1986	user1986@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1987	Fangfang	Wayman	KOBIETA	user1987	user1987@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1988	Emil	Brzuzek	MEZCZYZNA	user1988	user1988@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1989	Mehtap	Danshova	KOBIETA	user1989	user1989@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1990	Ki	Bociarska	KOBIETA	user1990	user1990@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1991	Korneliusz	Gwozdowicz	MEZCZYZNA	user1991	user1991@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1992	Ksienia	Pawuk	KOBIETA	user1992	user1992@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1993	Anastasia	Panasovska	KOBIETA	user1993	user1993@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1994	Thị yến	Glanzer	KOBIETA	user1994	user1994@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1995	Cynara	Czarnolewska-nowicka	KOBIETA	user1995	user1995@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1996	Radogost	Płoskowski	MEZCZYZNA	user1996	user1996@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1997	Dyter	Bzdzikot	MEZCZYZNA	user1997	user1997@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1998	Menaka	Bakulieva	KOBIETA	user1998	user1998@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
1999	Eligiusz	Ulita	MEZCZYZNA	user1999	user1999@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2000	Charity	Girt	KOBIETA	user2000	user2000@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2001	Jannatul	Kashenets	KOBIETA	user2001	user2001@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2002	Petroniusz	Ostróżka	MEZCZYZNA	user2002	user2002@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2003	Walerian	Łomaszkiewicz	MEZCZYZNA	user2003	user2003@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2004	Serwacy	Lasik	MEZCZYZNA	user2004	user2004@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2005	Dhriti	Tomová	KOBIETA	user2005	user2005@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2006	Anali	Kondriuk	KOBIETA	user2006	user2006@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2007	Zaja	Kochysh	KOBIETA	user2007	user2007@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2008	Feyza	Wosnica	KOBIETA	user2008	user2008@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2009	Nallely	Nikonorow	KOBIETA	user2009	user2009@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2010	Żarek	Łencki	MEZCZYZNA	user2010	user2010@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2011	Benedykt	Bryginowicz	MEZCZYZNA	user2011	user2011@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2012	Salima	Przeździenk	KOBIETA	user2012	user2012@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2013	Kamilya	Vodianina	KOBIETA	user2013	user2013@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2014	Bożimir	Hordyński	MEZCZYZNA	user2014	user2014@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2015	Sław	Gasperowicz	MEZCZYZNA	user2015	user2015@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2016	Špela	Juliantini	KOBIETA	user2016	user2016@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2017	Guliza	Bartejczuk	KOBIETA	user2017	user2017@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2018	Taruna	Dunaietska	KOBIETA	user2018	user2018@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2019	Aira	Bielinis	KOBIETA	user2019	user2019@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2020	Thi hong hanh	Bayraktutan	KOBIETA	user2020	user2020@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2021	Sylwester	Przeździk	MEZCZYZNA	user2021	user2021@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2022	Kyung hwa	Witkowska buys	KOBIETA	user2022	user2022@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2023	Aaminah	Alamin	KOBIETA	user2023	user2023@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2024	Ludolf	Ościłowski	MEZCZYZNA	user2024	user2024@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2025	Enissa	Mairko	KOBIETA	user2025	user2025@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2026	Sulisław	Pawliczak	MEZCZYZNA	user2026	user2026@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2027	Ji won	Kowalska-lubińska	KOBIETA	user2027	user2027@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2028	Yaël	Michałek-małek	KOBIETA	user2028	user2028@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2029	Jaropełk	Nichczyński	MEZCZYZNA	user2029	user2029@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2030	Teodor	Grosfeld	MEZCZYZNA	user2030	user2030@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2031	Manfred	Zawartka	MEZCZYZNA	user2031	user2031@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2032	Gyusyum	Golenya	KOBIETA	user2032	user2032@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2033	Paskalina	Petelczyc	KOBIETA	user2033	user2033@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2034	Sadika	Kiernas	KOBIETA	user2034	user2034@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2035	Ananiasz	Staworowski	MEZCZYZNA	user2035	user2035@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2036	Margerita	Krzekowska	KOBIETA	user2036	user2036@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2037	Gwido	Cielesz	MEZCZYZNA	user2037	user2037@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2038	Vikoriia	Abrycka	KOBIETA	user2038	user2038@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2039	Wit	Libawski	MEZCZYZNA	user2039	user2039@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2040	Szvitlána	Sahak	KOBIETA	user2040	user2040@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2041	Bogdan	Trudzik	MEZCZYZNA	user2041	user2041@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2042	Annasz	Matkowski	MEZCZYZNA	user2042	user2042@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2043	Bernardita	Rasolka	KOBIETA	user2043	user2043@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2044	Gerwazy	Kryszkiewicz	MEZCZYZNA	user2044	user2044@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2045	Yalan	Muża-grzenia	KOBIETA	user2045	user2045@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2046	Mojżesz	Machowiec	MEZCZYZNA	user2046	user2046@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2047	Jeremiasz	Dalmata	MEZCZYZNA	user2047	user2047@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2048	Edgar	Bosowski	MEZCZYZNA	user2048	user2048@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2049	Nevim	Zhupanyn	KOBIETA	user2049	user2049@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2050	Kaushila	Pletea	KOBIETA	user2050	user2050@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2051	Zefiryn	Kanetski	MEZCZYZNA	user2051	user2051@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2052	Sanna	Riabunets	KOBIETA	user2052	user2052@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2053	Saphira	Schreiter	KOBIETA	user2053	user2053@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2054	Hadassa	Tsizdyn	KOBIETA	user2054	user2054@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2055	Edzita	Khivrych	KOBIETA	user2055	user2055@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2056	Wisław	Czawkowski	MEZCZYZNA	user2056	user2056@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2057	Analy	Lewoszko	KOBIETA	user2057	user2057@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2058	Hanusz	Tomal	MEZCZYZNA	user2058	user2058@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2059	Tęgomir	Boba	MEZCZYZNA	user2059	user2059@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2060	Sebastian	Zgrych	MEZCZYZNA	user2060	user2060@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2061	Łucjan	Zalesko	MEZCZYZNA	user2061	user2061@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2062	Ivona	Danylchenko	KOBIETA	user2062	user2062@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2063	Joceline	Wiater	NIEOKRESLONY	user2063	user2063@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2064	Dyter	Nieżychowski	MEZCZYZNA	user2064	user2064@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2065	Tansel	Zych-mucha	KOBIETA	user2065	user2065@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2066	Odeya	Roseman	KOBIETA	user2066	user2066@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2067	Fryc	Łoszakiewicz	MEZCZYZNA	user2067	user2067@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2068	Shaloo	Zwicky	KOBIETA	user2068	user2068@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2069	Rawena	Trufan	KOBIETA	user2069	user2069@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2070	Bronisław	Gramek	MEZCZYZNA	user2070	user2070@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2071	Marceli	Teske	MEZCZYZNA	user2071	user2071@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2072	River	Obin	NIEOKRESLONY	user2072	user2072@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2073	Ścibor	Kwińczak	MEZCZYZNA	user2073	user2073@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2074	Hripsime	Nehliadiuk	KOBIETA	user2074	user2074@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2075	Evheniya	Behluli	KOBIETA	user2075	user2075@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2076	Hoai an	Nerublenko	KOBIETA	user2076	user2076@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2077	Albert	Çalişkan	MEZCZYZNA	user2077	user2077@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2078	Thi viet anh	Shpanko	KOBIETA	user2078	user2078@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2079	Ariel	Żurakowski	MEZCZYZNA	user2079	user2079@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2080	Jeremiasz	Baranek	MEZCZYZNA	user2080	user2080@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2081	Diana isabel	Pereduń	KOBIETA	user2081	user2081@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2082	Anzelm	Szefner	MEZCZYZNA	user2082	user2082@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2083	Gaj	Turkowicz	MEZCZYZNA	user2083	user2083@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2084	Reuma	Sydletska	KOBIETA	user2084	user2084@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2085	Tomisław	Karawan	MEZCZYZNA	user2085	user2085@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2086	Godfryd	Szumański	MEZCZYZNA	user2086	user2086@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2087	Heaven	Metodieva	KOBIETA	user2087	user2087@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2088	Thị kim ngọc	Lika	KOBIETA	user2088	user2088@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2089	Samuel	Roziewicz	MEZCZYZNA	user2089	user2089@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2090	Bartłomiej	Marasiński	MEZCZYZNA	user2090	user2090@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2091	Mekhrangiz	Ruslanova	KOBIETA	user2091	user2091@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2092	Rosłan	Spodymek	MEZCZYZNA	user2092	user2092@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2093	Siemowit	Oskierko	MEZCZYZNA	user2093	user2093@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2094	Sorcha	Kulpiecińska	KOBIETA	user2094	user2094@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2095	Hilary	Gamla	MEZCZYZNA	user2095	user2095@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2096	Narcyz	Hilles	MEZCZYZNA	user2096	user2096@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2097	Medard	Szepiłło	MEZCZYZNA	user2097	user2097@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2098	Gustaw	Pietrasik	MEZCZYZNA	user2098	user2098@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2099	Philippine	Koselska	KOBIETA	user2099	user2099@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2100	Zlatka	Kariuki	KOBIETA	user2100	user2100@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2101	Odo	Fajks	MEZCZYZNA	user2101	user2101@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2102	Kimmy	Grocka	KOBIETA	user2102	user2102@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2103	Roksandra	Solańska	KOBIETA	user2103	user2103@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2104	Manuel	Galbas	MEZCZYZNA	user2104	user2104@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2105	Cichosław	Chalaba	MEZCZYZNA	user2105	user2105@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2106	Wit	Taba	MEZCZYZNA	user2106	user2106@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2107	Thi quynh nga	Gąciarek	KOBIETA	user2107	user2107@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2108	Bakytkul	Herasevich	KOBIETA	user2108	user2108@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2109	Wojciech	Zuchajewicz	MEZCZYZNA	user2109	user2109@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2110	Gaj	Nemeczek	MEZCZYZNA	user2110	user2110@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2111	Petroniusz	Kruk	MEZCZYZNA	user2111	user2111@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2112	Lill	Kizilevich	KOBIETA	user2112	user2112@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2113	Minh ha	Jedlewska	KOBIETA	user2113	user2113@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2114	Mafalda	Kazubska	KOBIETA	user2114	user2114@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2115	Pafnucy	Sawośko	MEZCZYZNA	user2115	user2115@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2116	Sodgerel	Męciwoda	KOBIETA	user2116	user2116@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2117	Delgerjargal	Sargin	KOBIETA	user2117	user2117@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2118	Fangyi	Eholzer	KOBIETA	user2118	user2118@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2119	Yanet	Galagan	KOBIETA	user2119	user2119@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2120	Marllena	Indenko	KOBIETA	user2120	user2120@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2121	Telesfora	Frabińska	KOBIETA	user2121	user2121@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2122	Więcesław	Żórawski	MEZCZYZNA	user2122	user2122@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2123	Elodi	Lomovatska	KOBIETA	user2123	user2123@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2124	Fazilat	Bogaciuk	KOBIETA	user2124	user2124@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2125	Gerwazy	Szczółko	MEZCZYZNA	user2125	user2125@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2126	Thi loc	Szmygin	KOBIETA	user2126	user2126@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2127	Franciszek	Chałupa	MEZCZYZNA	user2127	user2127@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2128	Teodozjusz	Pietrusza	MEZCZYZNA	user2128	user2128@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2129	Erazm	Poślad	MEZCZYZNA	user2129	user2129@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2130	Krimhilda	Pohorodnia	KOBIETA	user2130	user2130@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2131	Ildefons	Henkelman	MEZCZYZNA	user2131	user2131@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2132	Philippa	Wancowicz	KOBIETA	user2132	user2132@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2133	Aleksander	Flaszyński	MEZCZYZNA	user2133	user2133@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2134	Lesław	Musiałkowski	MEZCZYZNA	user2134	user2134@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2135	Hadjer	Ciosk-gromadzińska	KOBIETA	user2135	user2135@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2136	Raula	Katusza	KOBIETA	user2136	user2136@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2137	Danting	Gemuła	KOBIETA	user2137	user2137@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2138	Thị thu thảo	Sygulla	KOBIETA	user2138	user2138@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2139	Wenata	Torhachova	KOBIETA	user2139	user2139@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2140	Renat	Cegła	MEZCZYZNA	user2140	user2140@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2141	Rosłan	Stasiła	MEZCZYZNA	user2141	user2141@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2142	Szczepan	Kościelak	MEZCZYZNA	user2142	user2142@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2143	Narcyz	Litwińczuk	MEZCZYZNA	user2143	user2143@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2144	Tomasz	Parzych	MEZCZYZNA	user2144	user2144@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2145	Vaness	Shyryayeva	KOBIETA	user2145	user2145@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2146	Kajfasz	Mokwa	MEZCZYZNA	user2146	user2146@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2147	Lubomił	Bissinger	MEZCZYZNA	user2147	user2147@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2148	Yuranis	Pacholczuk	KOBIETA	user2148	user2148@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2149	Lemara	Brazhko	KOBIETA	user2149	user2149@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2150	Radowit	Sibilski	MEZCZYZNA	user2150	user2150@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2151	Lukrecija	Bąberska	KOBIETA	user2151	user2151@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2152	Asol	Adomeit	KOBIETA	user2152	user2152@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2153	Chi	Borkowa	KOBIETA	user2153	user2153@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2154	Hadeel	Grodzewicz	KOBIETA	user2154	user2154@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2155	Gulzhanar	Hajmowicz	KOBIETA	user2155	user2155@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2156	Radogost	Opatrzyk	MEZCZYZNA	user2156	user2156@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2157	Dominik	Uryn	MEZCZYZNA	user2157	user2157@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2158	Grzegorza	Cieślukowska	KOBIETA	user2158	user2158@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2159	Salomon	Brukiewicz	MEZCZYZNA	user2159	user2159@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2160	Lobar	Zakaznikova	KOBIETA	user2160	user2160@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2161	Kaori	Osichna	KOBIETA	user2161	user2161@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2162	Mieszko	Korc	MEZCZYZNA	user2162	user2162@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2163	Zehra	Mendoza-bartoń	NIEOKRESLONY	user2163	user2163@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2164	Zefiryn	Szczepan	MEZCZYZNA	user2164	user2164@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2165	Mamert	Wiórkiewicz	MEZCZYZNA	user2165	user2165@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2166	Bożydar	Leeuwenburg	MEZCZYZNA	user2166	user2166@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2167	Cecyl	Kalembka	MEZCZYZNA	user2167	user2167@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2168	Asija	Karaś-tęcza	KOBIETA	user2168	user2168@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2169	Azer	Szeszkowska	KOBIETA	user2169	user2169@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2170	Rafał	Rzeżuski	MEZCZYZNA	user2170	user2170@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2171	Umai	Abdou	KOBIETA	user2171	user2171@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2172	Sevilen	Okunovych	KOBIETA	user2172	user2172@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2173	Hainala	Shabdanova	KOBIETA	user2173	user2173@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2174	Fema	Zhelishkevych	KOBIETA	user2174	user2174@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2175	Józef	Szymusiak	MEZCZYZNA	user2175	user2175@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2176	Mirosz	Dziekoła	MEZCZYZNA	user2176	user2176@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2177	María del pilar	Ochenkowski	NIEOKRESLONY	user2177	user2177@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2178	Iwon	Wybrański	MEZCZYZNA	user2178	user2178@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2179	Mayia	Vitun	KOBIETA	user2179	user2179@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2180	Yulduz	Zamielska	KOBIETA	user2180	user2180@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2181	Eliot	Tyzenhauz	MEZCZYZNA	user2181	user2181@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2182	Alfred	Michnowicz	MEZCZYZNA	user2182	user2182@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2183	Ludmił	Melniczuk	MEZCZYZNA	user2183	user2183@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2184	Meli̇ke	Fuhge	KOBIETA	user2184	user2184@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2185	Malek	Lesnytska	KOBIETA	user2185	user2185@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2186	Ridhi	Halabarodzka	KOBIETA	user2186	user2186@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2187	Kalindi	Zarobova	KOBIETA	user2187	user2187@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2188	Adam	Wzgarda	MEZCZYZNA	user2188	user2188@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2189	Anatol	Gorzyński	MEZCZYZNA	user2189	user2189@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2190	Jackie	Malinowska	KOBIETA	user2190	user2190@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2191	Protazy	Wstawski	MEZCZYZNA	user2191	user2191@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2192	Jona	Danch	MEZCZYZNA	user2192	user2192@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2193	Jacek	Kwasek	MEZCZYZNA	user2193	user2193@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2194	Rona	Guillo lohan	KOBIETA	user2194	user2194@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2195	Jaropełk	Czuwara	MEZCZYZNA	user2195	user2195@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2196	Lona	Biolley	KOBIETA	user2196	user2196@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2197	Mściwoj	Szympruch	MEZCZYZNA	user2197	user2197@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2198	Pabian	Kulimowski	MEZCZYZNA	user2198	user2198@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2199	Kincső	Gmerczyńska	KOBIETA	user2199	user2199@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2200	Radomir	Kordyjak	MEZCZYZNA	user2200	user2200@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2201	Meli̇ssa	Waanders	KOBIETA	user2201	user2201@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2202	Lucjan	Denysenko	MEZCZYZNA	user2202	user2202@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2203	Samson	Fabiański	MEZCZYZNA	user2203	user2203@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2204	Aneta	Czeszowic	KOBIETA	user2204	user2204@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2205	Vitalia	Bardi	KOBIETA	user2205	user2205@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2206	Lubosław	Karataş	MEZCZYZNA	user2206	user2206@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2207	Ine	Lopitz	KOBIETA	user2207	user2207@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2208	Mariia-valeriia	Fehlemann	KOBIETA	user2208	user2208@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2209	Juliani	Gatsi	KOBIETA	user2209	user2209@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2210	Tanushree	Chiorean	KOBIETA	user2210	user2210@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2211	Cecyl	Nitecki	MEZCZYZNA	user2211	user2211@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2212	Natan	Szatrowski	MEZCZYZNA	user2212	user2212@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2213	Geena	Duerschlag	KOBIETA	user2213	user2213@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2214	Wisław	Gracoń	MEZCZYZNA	user2214	user2214@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2215	Skyla	Jednaka	KOBIETA	user2215	user2215@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2216	Oktawian	Blachucik	MEZCZYZNA	user2216	user2216@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2217	Aleksy	Piwowarski	MEZCZYZNA	user2217	user2217@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2218	Świętomir	Bujonek	MEZCZYZNA	user2218	user2218@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2219	Hue	Brehida	KOBIETA	user2219	user2219@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2220	Yulia	Jachimovič	KOBIETA	user2220	user2220@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2221	Lubogost	Szpiec	MEZCZYZNA	user2221	user2221@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2222	Mariia-tetiana	Sokotun	KOBIETA	user2222	user2222@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2223	Kornel-korni	Kuniej	MEZCZYZNA	user2223	user2223@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2224	Bartłomiej	Pomes	MEZCZYZNA	user2224	user2224@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2225	Jolena	Wróblewska-olszewska	KOBIETA	user2225	user2225@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2226	Leonard	Wijaczka	MEZCZYZNA	user2226	user2226@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2227	Ceinwen	Micka	KOBIETA	user2227	user2227@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2228	Justyn	Loranc	MEZCZYZNA	user2228	user2228@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2229	Krystyn	Sadłowski	MEZCZYZNA	user2229	user2229@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2230	Alan	Starko	MEZCZYZNA	user2230	user2230@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2231	Wit	Buchajczyk	MEZCZYZNA	user2231	user2231@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2232	Szaja	Butrova	KOBIETA	user2232	user2232@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2233	Leszek	Sztajer	MEZCZYZNA	user2233	user2233@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2234	Sławomir	Kendziak	MEZCZYZNA	user2234	user2234@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2235	Belemir	Magnussen	KOBIETA	user2235	user2235@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2236	Szina	Karzarnowicz	KOBIETA	user2236	user2236@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2237	Celestyn	Maścibrzuch	MEZCZYZNA	user2237	user2237@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2238	Zohal	Rośko	KOBIETA	user2238	user2238@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2239	Ketut	Bertuola	KOBIETA	user2239	user2239@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2240	Hugon	Postawka	MEZCZYZNA	user2240	user2240@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2241	Miłorad	Naronowicz	MEZCZYZNA	user2241	user2241@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2242	Edzhe	Schevchenko	KOBIETA	user2242	user2242@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2243	Pirjo	Baryczko	KOBIETA	user2243	user2243@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2244	Dzwonimierz	Kotewa	MEZCZYZNA	user2244	user2244@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2245	Miroład	Rarus	MEZCZYZNA	user2245	user2245@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2246	Zefir	Brzoskiewicz	MEZCZYZNA	user2246	user2246@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2247	Aleksy	Chantsal	MEZCZYZNA	user2247	user2247@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2248	Gracjan	Piątkowski-furgał	MEZCZYZNA	user2248	user2248@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2249	Jacenty	Szytuła	MEZCZYZNA	user2249	user2249@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2250	Dyter	Amernik	MEZCZYZNA	user2250	user2250@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2251	Carmelita	Fainitska	KOBIETA	user2251	user2251@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2252	Lubomir	Iwanejko	MEZCZYZNA	user2252	user2252@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2253	Kaija	Selepyna	KOBIETA	user2253	user2253@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2254	Dzwonimierz	Strączyński	MEZCZYZNA	user2254	user2254@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2255	Dżemil	Cheda	MEZCZYZNA	user2255	user2255@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2256	Kristeen	Tobilevych	KOBIETA	user2256	user2256@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2257	Gaweł	Maksymenko	MEZCZYZNA	user2257	user2257@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2258	Szejwa	Plishakova	KOBIETA	user2258	user2258@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2259	Sruthi	Baszczawska	KOBIETA	user2259	user2259@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2260	Julian	Ciernioch	MEZCZYZNA	user2260	user2260@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2261	Anežka	Horodchuk	KOBIETA	user2261	user2261@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2262	Yunseo	Aboudaka	KOBIETA	user2262	user2262@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2263	Ting-hsuan	Ievstignieieva	KOBIETA	user2263	user2263@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2264	Kasjusz	Kacperczyk	MEZCZYZNA	user2264	user2264@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2265	Sary	Valeieva	KOBIETA	user2265	user2265@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2266	Żinaida	Prithiani	KOBIETA	user2266	user2266@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2267	Yonela	Aumann	KOBIETA	user2267	user2267@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2268	Bodosław	Gering	MEZCZYZNA	user2268	user2268@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2269	Medard	Perczyński-żelazek	MEZCZYZNA	user2269	user2269@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2270	Wiktor	Mądrzakowski	MEZCZYZNA	user2270	user2270@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2271	Orlana	Lahutseva	KOBIETA	user2271	user2271@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2272	Ti	Sprynsian	KOBIETA	user2272	user2272@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2273	Mamert	Kiertucki	MEZCZYZNA	user2273	user2273@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2274	Marian	Zasadny	MEZCZYZNA	user2274	user2274@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2275	Mateusz	Weissbrodt	MEZCZYZNA	user2275	user2275@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2276	Rajshree	Maliovana	KOBIETA	user2276	user2276@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2277	Cipa	Moshfeghi	KOBIETA	user2277	user2277@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2278	Władysław	Chłodowski	MEZCZYZNA	user2278	user2278@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2279	Wanesa	Wanglorz	KOBIETA	user2279	user2279@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2280	Wilhelm	Dziamecki	MEZCZYZNA	user2280	user2280@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2281	Yu-han	Sörensen	KOBIETA	user2281	user2281@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2282	Tomisław	Dostatni	MEZCZYZNA	user2282	user2282@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2283	Imen	Harle	KOBIETA	user2283	user2283@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2284	Anuarita	Schuppenies	KOBIETA	user2284	user2284@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2285	Karisa	Kotiia	KOBIETA	user2285	user2285@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2286	Thi minh ngoc	Lönnqvist	KOBIETA	user2286	user2286@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2287	Alojzy	Beinka	MEZCZYZNA	user2287	user2287@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2288	Fredysława	Sułowicz	KOBIETA	user2288	user2288@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2289	Tzu-ying	Cherlik	KOBIETA	user2289	user2289@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2290	Stanisław	Winkowski	MEZCZYZNA	user2290	user2290@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2291	Gwidon	Szastak	MEZCZYZNA	user2291	user2291@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2292	Nadezhda	Kunysz	NIEOKRESLONY	user2292	user2292@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2293	Sudaba	Linieitseva	KOBIETA	user2293	user2293@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2294	Seweryn	Seitz	MEZCZYZNA	user2294	user2294@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2295	Joëlle	Czeresnia kochen	KOBIETA	user2295	user2295@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2296	Ofir	Swieczka	KOBIETA	user2296	user2296@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2297	Mariangela	Jędrusik-róg	KOBIETA	user2297	user2297@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2298	Miłowan	Celarski	MEZCZYZNA	user2298	user2298@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2299	Maryn	Blazowski	MEZCZYZNA	user2299	user2299@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2300	Tatewik	Iastremska	KOBIETA	user2300	user2300@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2301	Thi hiep	Młudzińska	KOBIETA	user2301	user2301@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2302	Dzwonimierz	Motkowski	MEZCZYZNA	user2302	user2302@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2303	Dajmir	Szwed	MEZCZYZNA	user2303	user2303@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2304	Jarad	Krupa	MEZCZYZNA	user2304	user2304@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2305	Piotr	Drążkowski	MEZCZYZNA	user2305	user2305@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2306	Yalena	Dźwigoł	KOBIETA	user2306	user2306@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2307	Munirah	Przygienda	KOBIETA	user2307	user2307@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2308	Bonifacy	Korbel	MEZCZYZNA	user2308	user2308@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2309	Gościsław	Rosin	MEZCZYZNA	user2309	user2309@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2310	Anjitha	Kushneryk	KOBIETA	user2310	user2310@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2311	Megu	Yezan	KOBIETA	user2311	user2311@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2312	Bożidar	Aratyn	MEZCZYZNA	user2312	user2312@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2313	Owidiusz	Rynda	MEZCZYZNA	user2313	user2313@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2314	Viwiana	Malyniak	KOBIETA	user2314	user2314@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2315	Rosłan	Społowicz	MEZCZYZNA	user2315	user2315@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2316	Danko	Zerbst	MEZCZYZNA	user2316	user2316@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2317	Leon	Gragowski	MEZCZYZNA	user2317	user2317@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2318	Selmeg	Rahilewicz	KOBIETA	user2318	user2318@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2319	Leonard	Pikusa	MEZCZYZNA	user2319	user2319@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2320	Bożydar	Latuśkiewicz	MEZCZYZNA	user2320	user2320@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2321	Chwalisław	Bachrouch	MEZCZYZNA	user2321	user2321@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2322	Wissal	Hamaliy	KOBIETA	user2322	user2322@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2323	Anjela	Fenslau	KOBIETA	user2323	user2323@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2324	Bronisław	Micewicz	MEZCZYZNA	user2324	user2324@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2325	Meihan	Dwórnik	KOBIETA	user2325	user2325@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2326	Leon	Szwedo	MEZCZYZNA	user2326	user2326@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2327	Balli	Mbidzo	KOBIETA	user2327	user2327@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2328	Constantina	Jusiak	KOBIETA	user2328	user2328@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2329	Sędzisław	Łoboda	MEZCZYZNA	user2329	user2329@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2330	Chwalimir	Grek	MEZCZYZNA	user2330	user2330@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2331	Krystyn	Frańczak	MEZCZYZNA	user2331	user2331@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2332	Gerwazy	Wierzbicki	MEZCZYZNA	user2332	user2332@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2333	Cezar	Bobrzyk	MEZCZYZNA	user2333	user2333@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2334	Łucjan	Liwszic	MEZCZYZNA	user2334	user2334@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2335	Czesława	Nohr	KOBIETA	user2335	user2335@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2336	Donald	Painta	MEZCZYZNA	user2336	user2336@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2337	Walenty	Przyk	MEZCZYZNA	user2337	user2337@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2338	Shah	Chikun	KOBIETA	user2338	user2338@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2339	Ariel	Wiaderny	MEZCZYZNA	user2339	user2339@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2340	Antonin	Warot	MEZCZYZNA	user2340	user2340@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2341	Grodzisław	Świec	MEZCZYZNA	user2341	user2341@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2342	Wilhelm	Michałowicz	MEZCZYZNA	user2342	user2342@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2343	Hasan	Went	MEZCZYZNA	user2343	user2343@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2344	Lubomir	Kozacki	MEZCZYZNA	user2344	user2344@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2345	Krzesimir	Krzyna	MEZCZYZNA	user2345	user2345@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2346	Ibtissem	Solodukha	KOBIETA	user2346	user2346@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2347	Wawrzyniec	Sole-balcerowski	MEZCZYZNA	user2347	user2347@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2348	Farzana	Kromuszczyńska	KOBIETA	user2348	user2348@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2349	Lubogost	Gawrzydek	MEZCZYZNA	user2349	user2349@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2350	Kornel-korni	Mreła	MEZCZYZNA	user2350	user2350@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2351	Kit	Kocinas	KOBIETA	user2351	user2351@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2352	Priyadharsini	Obolikszto	KOBIETA	user2352	user2352@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2353	Witold	Rafalski	MEZCZYZNA	user2353	user2353@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2354	Riehina	Nermend	NIEOKRESLONY	user2354	user2354@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2355	Hyemi	Sykut	KOBIETA	user2355	user2355@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2356	Nicholle	Leperda	KOBIETA	user2356	user2356@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2357	Pelagiusz	Krugiełka	MEZCZYZNA	user2357	user2357@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2358	Yasemen	Kajna	KOBIETA	user2358	user2358@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2359	Hiacynt	Nadkański	MEZCZYZNA	user2359	user2359@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2360	Syla	Hlyviak	KOBIETA	user2360	user2360@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2361	Domasław	Otrompka	MEZCZYZNA	user2361	user2361@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2362	Miłowit	Gond	MEZCZYZNA	user2362	user2362@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2363	Bolelut	Mieszaniec	MEZCZYZNA	user2363	user2363@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2364	Baldwin	Hałubek	MEZCZYZNA	user2364	user2364@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2365	Zygmunt	Bielachowicz	MEZCZYZNA	user2365	user2365@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2366	Emeline	Gryling	KOBIETA	user2366	user2366@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2367	Karia	Łącka-kras	KOBIETA	user2367	user2367@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2368	Ashmy	Posvistak	KOBIETA	user2368	user2368@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2369	Juliette	Zyner	KOBIETA	user2369	user2369@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2370	Dyter	Kałmuk	MEZCZYZNA	user2370	user2370@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2371	Mahlet	Kripatska	KOBIETA	user2371	user2371@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2372	Bodosław	Pachulski	MEZCZYZNA	user2372	user2372@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2373	Ignacy	Zegarlicki	MEZCZYZNA	user2373	user2373@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2374	Kastor	Szybiński	MEZCZYZNA	user2374	user2374@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2375	Kryspin	Lentka	MEZCZYZNA	user2375	user2375@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2376	Bogumił	Kubas	MEZCZYZNA	user2376	user2376@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2377	Denisa	Lipen	KOBIETA	user2377	user2377@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2378	Alfred	Dutkanicz	MEZCZYZNA	user2378	user2378@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2379	Putali	Sochur	KOBIETA	user2379	user2379@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2380	Sungeun	Wojtyniak	KOBIETA	user2380	user2380@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2381	Romane	Holena	KOBIETA	user2381	user2381@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2382	Onufry	Procelewski	MEZCZYZNA	user2382	user2382@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2383	Alita	Kosz-koszewska	KOBIETA	user2383	user2383@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2384	Nasif	Justka	MEZCZYZNA	user2384	user2384@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2385	Sławomir	Wyczański	MEZCZYZNA	user2385	user2385@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2386	Anna-sofiya	Gamreklidze	KOBIETA	user2386	user2386@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2387	Lubomił	Dziadkowiec	MEZCZYZNA	user2387	user2387@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2388	Kordian	Horbatowski	MEZCZYZNA	user2388	user2388@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2389	Alberte	Sadyhova	KOBIETA	user2389	user2389@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2390	Tu linh	Kierblewska	KOBIETA	user2390	user2390@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2391	Borys	Pollina	MEZCZYZNA	user2391	user2391@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2392	Zwinisław	Szurgut	MEZCZYZNA	user2392	user2392@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2393	Starwit	Pieprz	MEZCZYZNA	user2393	user2393@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2394	Korneli	Mizgier	MEZCZYZNA	user2394	user2394@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2395	Aniceta	Kujawa-kowalska	KOBIETA	user2395	user2395@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2396	Chunmiao	Cieslewicz	KOBIETA	user2396	user2396@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2397	Anela	Cepchina	KOBIETA	user2397	user2397@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2398	Aradhya	Kadnychanska	KOBIETA	user2398	user2398@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2399	Yupha	Künel	KOBIETA	user2399	user2399@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2400	Wit	Badoń	MEZCZYZNA	user2400	user2400@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2401	Cichosław	Ichniewicz	MEZCZYZNA	user2401	user2401@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2402	Ścibor	Kuśnierczyk	MEZCZYZNA	user2402	user2402@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2403	Rozetta	Kondzolka	KOBIETA	user2403	user2403@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2404	Leeya	Fishman faingezicht	KOBIETA	user2404	user2404@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2405	Héléne	Burulic	KOBIETA	user2405	user2405@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2406	Anna-diana	Sopiak	KOBIETA	user2406	user2406@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2407	Dariusz	Bachcialski	MEZCZYZNA	user2407	user2407@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2408	Bircan	Stasak	KOBIETA	user2408	user2408@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2409	Carmel	Atci	KOBIETA	user2409	user2409@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2410	Aan	Nowobilska	KOBIETA	user2410	user2410@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2411	Ksaweryna	Fetler	KOBIETA	user2411	user2411@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2412	Marylou	Giesecke	KOBIETA	user2412	user2412@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2413	Wielisław	Wygralak	MEZCZYZNA	user2413	user2413@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2414	Herakles	Władymirski	MEZCZYZNA	user2414	user2414@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2415	Saule	Łabiuk	KOBIETA	user2415	user2415@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2416	Patryk	Wołoszynek	MEZCZYZNA	user2416	user2416@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2417	Devora	Talwińska	KOBIETA	user2417	user2417@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2418	Eryk	Grudnik	MEZCZYZNA	user2418	user2418@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2419	Wojciech	Paraniak	MEZCZYZNA	user2419	user2419@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2420	Roana	Pidbuzhska	KOBIETA	user2420	user2420@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2421	Yully	Myftaraj	KOBIETA	user2421	user2421@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2422	Wiesław	Żebczyński	MEZCZYZNA	user2422	user2422@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2423	Wacław	Lies	MEZCZYZNA	user2423	user2423@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2424	Dorra	Czebi-ogły	KOBIETA	user2424	user2424@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2425	Michał	Sulisz	MEZCZYZNA	user2425	user2425@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2426	Maria joão	Zboroń	KOBIETA	user2426	user2426@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2427	Thị hiển	Rundqvist	KOBIETA	user2427	user2427@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2428	Romika	Karchenia	KOBIETA	user2428	user2428@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2429	Ezaw	Raunke	MEZCZYZNA	user2429	user2429@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2430	Kamil	Kosek	MEZCZYZNA	user2430	user2430@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2431	Plamena	Skopetska	KOBIETA	user2431	user2431@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2432	Maéva	Kazmirowicz	KOBIETA	user2432	user2432@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2433	Nikodema	Buluş	KOBIETA	user2433	user2433@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2434	Norman	Możdżeń	MEZCZYZNA	user2434	user2434@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2435	Illya	Mikłusz	KOBIETA	user2435	user2435@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2436	Albrecht	Polowiec	MEZCZYZNA	user2436	user2436@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2437	Miłogost	Szubzda	MEZCZYZNA	user2437	user2437@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2438	Jannet	Kielecka-gołąb	KOBIETA	user2438	user2438@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2439	Ruut	Dąbroś	KOBIETA	user2439	user2439@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2440	Ireneusz	Wierkiewicz	MEZCZYZNA	user2440	user2440@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2441	Samirah	Fanderska	KOBIETA	user2441	user2441@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2442	Waltrauda	Langeland	KOBIETA	user2442	user2442@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2443	Hamza	Szuberga	MEZCZYZNA	user2443	user2443@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2444	Pakosław	Colik	MEZCZYZNA	user2444	user2444@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2445	Kornel-korni	Bodnarczuk	MEZCZYZNA	user2445	user2445@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2446	Pakita	Basaranowicz	KOBIETA	user2446	user2446@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2447	Xiyuan	Szymonowicz	KOBIETA	user2447	user2447@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2448	Derwit	Heflich	MEZCZYZNA	user2448	user2448@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2449	Rakhil	Harth	KOBIETA	user2449	user2449@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2450	Dzwonimierz	Jędrycha	MEZCZYZNA	user2450	user2450@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2451	Walter	Wylon	MEZCZYZNA	user2451	user2451@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2452	Kuzivakwashe	Prarat	KOBIETA	user2452	user2452@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2453	Beat	Sikut	MEZCZYZNA	user2453	user2453@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2454	Zachariasz	Chruszczewski	MEZCZYZNA	user2454	user2454@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2455	Gwido	Skrzyszewski	MEZCZYZNA	user2455	user2455@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2456	Ceres	Buglewicz	KOBIETA	user2456	user2456@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2457	Alissar	Saberi-esfarjani	KOBIETA	user2457	user2457@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2458	Alwin	Szymańczyk	MEZCZYZNA	user2458	user2458@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2459	Dzvenymyra	Nguyen anh	KOBIETA	user2459	user2459@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2460	Meng	Havrenko	KOBIETA	user2460	user2460@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2461	Radogost	Liber	MEZCZYZNA	user2461	user2461@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2462	Florentyn	Ozdowski	MEZCZYZNA	user2462	user2462@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2463	Secil	Kryshtanovska	KOBIETA	user2463	user2463@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2464	Ustynia	Makowe	KOBIETA	user2464	user2464@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2465	Nial	Hipsz	KOBIETA	user2465	user2465@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2466	Nanik	Bociąga	KOBIETA	user2466	user2466@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2467	Chrystal	Pakuła-szczęch	KOBIETA	user2467	user2467@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2468	Simla	Szpejankowska	KOBIETA	user2468	user2468@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2469	Kordian	Jakuć	MEZCZYZNA	user2469	user2469@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2470	Bert	Sztobryn	MEZCZYZNA	user2470	user2470@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2471	Elleonora	Šuláková	KOBIETA	user2471	user2471@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2472	Oygul	Morkva	KOBIETA	user2472	user2472@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2473	Jarowit	Jastrząb	MEZCZYZNA	user2473	user2473@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2474	Gerwazy	Tepper	MEZCZYZNA	user2474	user2474@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2475	Stanisław	Szeremeti	MEZCZYZNA	user2475	user2475@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2476	Severyna	Kathola	KOBIETA	user2476	user2476@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2477	Sooah	Verych	KOBIETA	user2477	user2477@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2478	Ciechosław	Basak	MEZCZYZNA	user2478	user2478@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2479	Rosłan	Gańko	MEZCZYZNA	user2479	user2479@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2480	Chwalimir	Kłokocki	MEZCZYZNA	user2480	user2480@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2481	Adela	Białeta	KOBIETA	user2481	user2481@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2482	Karol	Łojek	MEZCZYZNA	user2482	user2482@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2483	Katarzyna	Blazquez	KOBIETA	user2483	user2483@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2484	Dalbor	Astapczyk	MEZCZYZNA	user2484	user2484@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2485	Kheiransa	Kuczkowska-kurnatowska	KOBIETA	user2485	user2485@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2486	Gratsiela	Didenko	KOBIETA	user2486	user2486@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2487	Kajetan	Panchenko	MEZCZYZNA	user2487	user2487@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2488	Mojżesz	Kurcoń	MEZCZYZNA	user2488	user2488@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2489	Hyemi	Hovav	KOBIETA	user2489	user2489@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2490	Faustyn	Gościniak	MEZCZYZNA	user2490	user2490@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2491	Imelda	Tillak	KOBIETA	user2491	user2491@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2492	Modest	Barul	MEZCZYZNA	user2492	user2492@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2493	Boguchwał	Lutyński	MEZCZYZNA	user2493	user2493@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2494	Miracle	Popiwczuk	KOBIETA	user2494	user2494@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2495	Prot	Piangerelli	MEZCZYZNA	user2495	user2495@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2496	Ryszard	Oleksik	MEZCZYZNA	user2496	user2496@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2497	Oskar	Sitko	MEZCZYZNA	user2497	user2497@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2498	Zachariasz	Polisiakiewicz	MEZCZYZNA	user2498	user2498@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2499	Anamarija	Drzewowska	KOBIETA	user2499	user2499@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2500	Bartosz	Krystkowski	MEZCZYZNA	user2500	user2500@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2501	Waltraud	Kurdybanska	KOBIETA	user2501	user2501@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2502	Dieu my	Nykolchuk	KOBIETA	user2502	user2502@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2503	Cezary	Szczerkowski	MEZCZYZNA	user2503	user2503@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2504	Beyda	Tsutsyk	KOBIETA	user2504	user2504@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2505	Telesfor	Derda-nowakowski	MEZCZYZNA	user2505	user2505@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2506	Nathania	Surhan	KOBIETA	user2506	user2506@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2507	Darwit	Jęcka	MEZCZYZNA	user2507	user2507@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2508	Narimene	Duś	KOBIETA	user2508	user2508@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2509	Ruoyan	Carvalho	KOBIETA	user2509	user2509@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2510	Ładysław	Rykiel	MEZCZYZNA	user2510	user2510@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2511	Bonawentura	Mikhailau	MEZCZYZNA	user2511	user2511@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2512	Bernardita	Hrymnak	KOBIETA	user2512	user2512@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2513	Zdzisław	Luboński	MEZCZYZNA	user2513	user2513@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2514	Juranda	Murlowski	KOBIETA	user2514	user2514@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2515	Stoisław	Botwin	MEZCZYZNA	user2515	user2515@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2516	Eshli	Chomczuk	KOBIETA	user2516	user2516@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2517	Roch	Gumieniuk	MEZCZYZNA	user2517	user2517@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2518	Tomasz	Wyrobek	MEZCZYZNA	user2518	user2518@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2519	Abrielle	Pohyba	KOBIETA	user2519	user2519@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2520	Nurhan	Hudobina	KOBIETA	user2520	user2520@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2521	Emerald	Rezel	KOBIETA	user2521	user2521@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2522	Herman	Tomtała	MEZCZYZNA	user2522	user2522@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2523	Donald	Fornagiel	MEZCZYZNA	user2523	user2523@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2524	Lechia	Grailich	KOBIETA	user2524	user2524@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2525	Kajetan	Głodek	MEZCZYZNA	user2525	user2525@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2526	Kajetan	Cieślakiewicz	MEZCZYZNA	user2526	user2526@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2527	Uwase	Czarnecka-nowak	KOBIETA	user2527	user2527@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2528	Dzilara	Pichuha	KOBIETA	user2528	user2528@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2529	Yana-anna	Davitadze	KOBIETA	user2529	user2529@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2530	Azime	Świtalski	KOBIETA	user2530	user2530@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2531	Cecylian	Ryszka	MEZCZYZNA	user2531	user2531@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2532	Carolin	Krychevska	KOBIETA	user2532	user2532@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2533	Marcia	Filipowicz-sadowska	KOBIETA	user2533	user2533@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2534	Merlina	Blic	KOBIETA	user2534	user2534@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2535	Jagienka	Sklenarska	KOBIETA	user2535	user2535@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2536	Tchelet	Kropf	KOBIETA	user2536	user2536@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2537	Naili	Hombesch	KOBIETA	user2537	user2537@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2538	Dorah	Tablewska	KOBIETA	user2538	user2538@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2539	Hongzhen	Hodge	KOBIETA	user2539	user2539@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2540	Borysław	Kumpa	MEZCZYZNA	user2540	user2540@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2541	Chwalisław	Gocha	MEZCZYZNA	user2541	user2541@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2542	Zinajida	Yakubina	KOBIETA	user2542	user2542@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2543	Syrine	Åhlberg	KOBIETA	user2543	user2543@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2544	Cornélie	Czoske	KOBIETA	user2544	user2544@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2545	Arathy	Zhilina	KOBIETA	user2545	user2545@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2546	Kyla	Reilly sendal	KOBIETA	user2546	user2546@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2547	Yanyna	Rodka	KOBIETA	user2547	user2547@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2548	Lý	Taramina	KOBIETA	user2548	user2548@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2549	Kenaya	Chirica	KOBIETA	user2549	user2549@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2550	Mea	Ausiuk	KOBIETA	user2550	user2550@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2551	Nonglak	Falkoska	KOBIETA	user2551	user2551@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2552	Tęgomir	Kuruś	MEZCZYZNA	user2552	user2552@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2553	Przemysł	Dargiewicz	MEZCZYZNA	user2553	user2553@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2554	Maitrayee	Przibilla	KOBIETA	user2554	user2554@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2555	Husajn	Kołosowski	MEZCZYZNA	user2555	user2555@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2556	Yubin	Golmento	KOBIETA	user2556	user2556@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2557	Apollonie	Pisklewicz-rycaj	KOBIETA	user2557	user2557@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2558	Ziemowit	Malc	MEZCZYZNA	user2558	user2558@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2559	Sun hee	Popielańska	KOBIETA	user2559	user2559@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2560	Edda	Bakuńska	KOBIETA	user2560	user2560@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2561	Kastor	Kocent	MEZCZYZNA	user2561	user2561@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2562	Vanisha	Ustupski	KOBIETA	user2562	user2562@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2563	Anzelm	Brańczyk	MEZCZYZNA	user2563	user2563@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2564	Jarowit	Koźbiał	MEZCZYZNA	user2564	user2564@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2565	Antula	Holoviatynska	KOBIETA	user2565	user2565@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2566	Ailyn	Sołtyk-sołtycka	KOBIETA	user2566	user2566@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2567	Ronghua	Pryluka	KOBIETA	user2567	user2567@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2568	Rajmund	Kobyra	MEZCZYZNA	user2568	user2568@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2569	Modest	Skorzybut	MEZCZYZNA	user2569	user2569@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2570	Tytus	Kułakowski	MEZCZYZNA	user2570	user2570@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2571	Myriam	Droschińska	KOBIETA	user2571	user2571@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2572	Franchesca	Pożakowska	KOBIETA	user2572	user2572@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2573	Polikarp	Rajca	MEZCZYZNA	user2573	user2573@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2574	Lola	Salska	KOBIETA	user2574	user2574@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2575	Esta	Treska	KOBIETA	user2575	user2575@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2576	Lam	Pukan	KOBIETA	user2576	user2576@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2577	Walenty	Walusz	MEZCZYZNA	user2577	user2577@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2578	Witosław	Bertrandt	MEZCZYZNA	user2578	user2578@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2579	Niecisław	Reczkowski	MEZCZYZNA	user2579	user2579@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2580	Fiammetta	Shkorbetska	KOBIETA	user2580	user2580@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2581	Żytomir	Polkowski	MEZCZYZNA	user2581	user2581@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2582	Sharen	Buroszek	KOBIETA	user2582	user2582@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2583	Shanda	Chirsanova	KOBIETA	user2583	user2583@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2584	Beat	Kapałka	MEZCZYZNA	user2584	user2584@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2585	Grzegorz	Fortunka	MEZCZYZNA	user2585	user2585@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2586	Leuza	Sovetova	KOBIETA	user2586	user2586@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2587	Aimeerim	Gładki	KOBIETA	user2587	user2587@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2588	Farid	Pomarański	MEZCZYZNA	user2588	user2588@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2589	Jeanine	Matiiuk	KOBIETA	user2589	user2589@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2590	Rossitza	Osipiak	KOBIETA	user2590	user2590@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2591	Jaromir	Elke	MEZCZYZNA	user2591	user2591@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2592	Thị phong	Kolendo	NIEOKRESLONY	user2592	user2592@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2593	Serwacy	Wisłowski	MEZCZYZNA	user2593	user2593@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2594	Manuel	Anduła	MEZCZYZNA	user2594	user2594@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2595	Otto	Koślicki	MEZCZYZNA	user2595	user2595@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2596	Wolimir	Młotek	MEZCZYZNA	user2596	user2596@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2597	Fumina	Offermann	KOBIETA	user2597	user2597@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2598	Baltazar	Równiak	MEZCZYZNA	user2598	user2598@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2599	Idan	Tomaszewska-krawczyk	KOBIETA	user2599	user2599@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2600	Mściwoj	Gogacz	MEZCZYZNA	user2600	user2600@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2601	Robynne	Żurawska	KOBIETA	user2601	user2601@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2602	Julienne	Zarichniak	KOBIETA	user2602	user2602@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2603	Pemba	Klottka	KOBIETA	user2603	user2603@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2604	Jan	Chyczewski	MEZCZYZNA	user2604	user2604@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2605	Houda	Korwal	NIEOKRESLONY	user2605	user2605@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2606	Paweł	Reptak	MEZCZYZNA	user2606	user2606@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2607	Łucjan	Chodakowski	MEZCZYZNA	user2607	user2607@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2608	Blanca cecilia	Kabluchko	KOBIETA	user2608	user2608@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2609	Dobiesław	Książek	MEZCZYZNA	user2609	user2609@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2610	Zhanel	Posadzki	KOBIETA	user2610	user2610@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2611	Nawojka	Zejer	KOBIETA	user2611	user2611@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2612	Małgorzata	Hoang van	KOBIETA	user2612	user2612@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2613	Hyeji	Khovanska	KOBIETA	user2613	user2613@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2614	Rajmund	Suproniuk	MEZCZYZNA	user2614	user2614@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2615	Marijona	Sarbinovska	KOBIETA	user2615	user2615@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2616	Tatsiana	Besarabiw	KOBIETA	user2616	user2616@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2617	Sameeksha	Chabiuk	KOBIETA	user2617	user2617@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2618	Nikhan	Alkhazashvili	KOBIETA	user2618	user2618@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2619	Siyu	Owczarczak	KOBIETA	user2619	user2619@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2620	Dayanis	Pozhyvotenko	KOBIETA	user2620	user2620@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2621	Kumushbibi	Hrebennik	NIEOKRESLONY	user2621	user2621@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2622	Roxanna	Paniewska	KOBIETA	user2622	user2622@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2623	Deepika	Puentespina	KOBIETA	user2623	user2623@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2624	Lubogost	Wardyński	MEZCZYZNA	user2624	user2624@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2625	Herbert	Listwan	MEZCZYZNA	user2625	user2625@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2626	Huyền trang	Abou saleh	KOBIETA	user2626	user2626@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2627	Damian	Chłopik	MEZCZYZNA	user2627	user2627@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2628	Rajzla	Zalcman-ziora	KOBIETA	user2628	user2628@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2629	Efrem	Hajduk	MEZCZYZNA	user2629	user2629@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2630	Abdon	Cibart	MEZCZYZNA	user2630	user2630@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2631	Wiktor	Brzuszek	MEZCZYZNA	user2631	user2631@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2632	Ingetraut	Kowik	KOBIETA	user2632	user2632@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2633	Arpitaben	Levkivska	KOBIETA	user2633	user2633@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2634	Adrianne	Nemchyk	KOBIETA	user2634	user2634@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2635	Kilian	Kuls	MEZCZYZNA	user2635	user2635@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2636	Seethalakshmi	Streiss	KOBIETA	user2636	user2636@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2637	Iyar	Dzondza	KOBIETA	user2637	user2637@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2638	Xiaoyun	Chorowiec	KOBIETA	user2638	user2638@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2639	Zoryna	Fijołek-brudko	KOBIETA	user2639	user2639@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2640	Jolitta	Shybalova	KOBIETA	user2640	user2640@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2641	Dobrogost	Skrobić	MEZCZYZNA	user2641	user2641@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2642	August	Iwat	MEZCZYZNA	user2642	user2642@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2643	Jiaqi	Skulisz	KOBIETA	user2643	user2643@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2644	Bolebor	Klata	MEZCZYZNA	user2644	user2644@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2645	Fryderyk	Szecel	MEZCZYZNA	user2645	user2645@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2646	Sookyoung	Motuz	KOBIETA	user2646	user2646@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2647	Dżan	Słaboń	MEZCZYZNA	user2647	user2647@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2648	Annasz	Białołęcki-dąbrowski	MEZCZYZNA	user2648	user2648@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2649	Tobiasz	Rennik	MEZCZYZNA	user2649	user2649@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2650	Miłorad	Stohnij	MEZCZYZNA	user2650	user2650@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2651	Efrem	Efemberg	MEZCZYZNA	user2651	user2651@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2652	Świętopełk	Starke	MEZCZYZNA	user2652	user2652@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2653	Farhana	Aubertin	KOBIETA	user2653	user2653@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2654	Marek	Tunyan	MEZCZYZNA	user2654	user2654@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2655	Atena	Vovk-yufe	KOBIETA	user2655	user2655@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2656	Ryszard	Łuba	MEZCZYZNA	user2656	user2656@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2657	Łukasz	Bałdyga	MEZCZYZNA	user2657	user2657@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2658	Meggy	Beneturska	KOBIETA	user2658	user2658@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2659	Saruul	Margania	KOBIETA	user2659	user2659@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2660	Thi kim thoa	Trójca	KOBIETA	user2660	user2660@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2661	Tuţa	Lekveishvili	KOBIETA	user2661	user2661@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2662	Idalia	Kabowska	KOBIETA	user2662	user2662@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2663	Birtukan	Zitek	KOBIETA	user2663	user2663@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2664	Boguchwał	Karcz	MEZCZYZNA	user2664	user2664@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2665	Seweryn	Starostecki	MEZCZYZNA	user2665	user2665@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2666	Marine	Nwoko	KOBIETA	user2666	user2666@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2667	Jette	Turitsa	KOBIETA	user2667	user2667@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2668	Phidan	Słomianko	KOBIETA	user2668	user2668@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2669	Idzi	Feigel	MEZCZYZNA	user2669	user2669@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2670	Kamil	Zwierzyński	MEZCZYZNA	user2670	user2670@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2671	Maham	Vogels	KOBIETA	user2671	user2671@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2672	Adrian	Dziaduszewski	MEZCZYZNA	user2672	user2672@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2673	Miłorad	Skiendzielewski	MEZCZYZNA	user2673	user2673@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2674	Kalbubu	Kopitzke	KOBIETA	user2674	user2674@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2675	Vitta	Renou	KOBIETA	user2675	user2675@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2676	Bratumiła	Frączak	KOBIETA	user2676	user2676@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2677	Joachim	Syrek	MEZCZYZNA	user2677	user2677@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2678	Jihyo	Kebas	KOBIETA	user2678	user2678@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2679	Yeter	Ramnani	KOBIETA	user2679	user2679@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2680	Mélaine	Stendera	KOBIETA	user2680	user2680@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2681	Aitach	Sharman	KOBIETA	user2681	user2681@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2682	Budzisław	Lolas	MEZCZYZNA	user2682	user2682@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2683	Thị mai thanh	Mokshyna	KOBIETA	user2683	user2683@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2684	Florian	Przybysławski	MEZCZYZNA	user2684	user2684@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2685	Dżemil	Strojwąs	MEZCZYZNA	user2685	user2685@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2686	Angela	Lüthy	KOBIETA	user2686	user2686@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2687	Karolin	Hellmis	KOBIETA	user2687	user2687@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2688	Żarko	Rolewski	MEZCZYZNA	user2688	user2688@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2689	Alfina	Piaszczyk	KOBIETA	user2689	user2689@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2690	Yun-yi	Soyta-leon	KOBIETA	user2690	user2690@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2691	Sif	Grieß	KOBIETA	user2691	user2691@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2692	Malsha	Van deursen	KOBIETA	user2692	user2692@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2693	Miłowan	Skociński	MEZCZYZNA	user2693	user2693@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2694	Hieronim	Smuszkiewicz	MEZCZYZNA	user2694	user2694@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2695	Miłosław	Wolniaczyk	MEZCZYZNA	user2695	user2695@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2696	Xiaoping	Gwiździał	KOBIETA	user2696	user2696@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2697	Tulimierz	Chuchmacz	MEZCZYZNA	user2697	user2697@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2698	Haejin	Filipiak-kaczmarek	KOBIETA	user2698	user2698@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2699	Edwin	Nikoniuk	MEZCZYZNA	user2699	user2699@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2700	Radzimir	Drabikowski	MEZCZYZNA	user2700	user2700@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2701	Żarek	Deputat	MEZCZYZNA	user2701	user2701@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2702	Achilles	Mindryn	MEZCZYZNA	user2702	user2702@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2703	Izajasz	Żdan	MEZCZYZNA	user2703	user2703@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2704	Fabian	Hamulecki	MEZCZYZNA	user2704	user2704@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2705	Andriia	Tomchakovska	KOBIETA	user2705	user2705@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2706	Miray	Węcławiak	KOBIETA	user2706	user2706@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2707	Manuel	Mruczyk	MEZCZYZNA	user2707	user2707@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2708	Amadea	Fizyczak	KOBIETA	user2708	user2708@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2709	Bianna	Rabięcny	KOBIETA	user2709	user2709@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2710	Thi thu huong	Drużbiak	NIEOKRESLONY	user2710	user2710@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2711	Dionne	Wybituła	KOBIETA	user2711	user2711@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2712	Regina	Olesnevych	KOBIETA	user2712	user2712@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2713	Gerwazy	Chwojko	MEZCZYZNA	user2713	user2713@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2714	Anastazy	Małowiecki	MEZCZYZNA	user2714	user2714@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2715	Nadieżda	Khashchii	KOBIETA	user2715	user2715@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2716	Ładysław	Tarabasz	MEZCZYZNA	user2716	user2716@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2717	Donat	Rogóż	MEZCZYZNA	user2717	user2717@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2718	Roselle	Terelis	KOBIETA	user2718	user2718@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2719	Ērika	Bahnitska	KOBIETA	user2719	user2719@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2720	Shokoufeh	Goyska	KOBIETA	user2720	user2720@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2721	Barabasz	Pakulski vel modrzejewski	MEZCZYZNA	user2721	user2721@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2722	Miłobąd	Szwedko	MEZCZYZNA	user2722	user2722@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2723	Sanela	Tesmer	KOBIETA	user2723	user2723@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2724	Bogdan	Ordijewicz	MEZCZYZNA	user2724	user2724@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2725	Tomisław	Chawa	MEZCZYZNA	user2725	user2725@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2726	Rostislava	Szelmanowska	KOBIETA	user2726	user2726@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2727	Jaroslava	Latacz	KOBIETA	user2727	user2727@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2728	Kajfasz	Ntuli	MEZCZYZNA	user2728	user2728@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2729	Barnim	Kuśmierek	MEZCZYZNA	user2729	user2729@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2730	Ameera	Skłucka	KOBIETA	user2730	user2730@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2731	Sławek	Paś	MEZCZYZNA	user2731	user2731@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2732	Margarida	Mnisz	KOBIETA	user2732	user2732@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2733	Irene	Zakoretska	KOBIETA	user2733	user2733@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2734	Bruno	Stasak	MEZCZYZNA	user2734	user2734@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2735	Faris	Sońko	MEZCZYZNA	user2735	user2735@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2736	Ambroży	Wieciński	MEZCZYZNA	user2736	user2736@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2737	Dagma	Chinakal	KOBIETA	user2737	user2737@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2738	Makary	Będa	MEZCZYZNA	user2738	user2738@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2739	Robert	Owerski	MEZCZYZNA	user2739	user2739@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2740	Bazyli	Dacyszyn	MEZCZYZNA	user2740	user2740@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2741	Faustyn	Ortel	MEZCZYZNA	user2741	user2741@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2742	Petroniusz	Ścibiorek	MEZCZYZNA	user2742	user2742@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2743	Danelle	Cier	KOBIETA	user2743	user2743@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2744	Emanuel	Poturalski	MEZCZYZNA	user2744	user2744@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2745	Jona	Sigeda	NIEOKRESLONY	user2745	user2745@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2746	Benedykt	Rosłoń	MEZCZYZNA	user2746	user2746@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2747	Klemens	Półtorzycki	MEZCZYZNA	user2747	user2747@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2748	Herakles	Reszkowski	MEZCZYZNA	user2748	user2748@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2749	Subashini	Palach	KOBIETA	user2749	user2749@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2750	Saita	Hollanda	KOBIETA	user2750	user2750@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2751	January	Drzał	MEZCZYZNA	user2751	user2751@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2752	Godfryg	Dybiec	MEZCZYZNA	user2752	user2752@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2753	Dal	Groner	MEZCZYZNA	user2753	user2753@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2754	Güleser	Sturgulewska	KOBIETA	user2754	user2754@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2755	Ana mireya	Szlag	KOBIETA	user2755	user2755@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2756	Eliot	Wanicki	MEZCZYZNA	user2756	user2756@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2757	Danisław	Bok	MEZCZYZNA	user2757	user2757@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2758	Sanelisiwe	Ausdajczer	KOBIETA	user2758	user2758@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2759	January	Juraczko	MEZCZYZNA	user2759	user2759@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2760	Ljubov	Kazulenas	KOBIETA	user2760	user2760@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2761	Radogost	Plewka	MEZCZYZNA	user2761	user2761@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2762	Rosalina	Lahutkina	KOBIETA	user2762	user2762@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2763	Zenobiusz	Kołder-maryniak	MEZCZYZNA	user2763	user2763@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2764	Nikodem	Robel	MEZCZYZNA	user2764	user2764@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2765	Andrea patricia	Pliushchova	KOBIETA	user2765	user2765@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2766	Tymon	Bubik	MEZCZYZNA	user2766	user2766@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2767	Minseo	Naskopulu	KOBIETA	user2767	user2767@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2768	Tulimierz	Siemiatycki	MEZCZYZNA	user2768	user2768@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2769	Modest	Dziubliński	MEZCZYZNA	user2769	user2769@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2770	Kamelia	Flikierska	KOBIETA	user2770	user2770@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2771	Janet	Korlakunta	KOBIETA	user2771	user2771@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2772	Jakub	Mai	MEZCZYZNA	user2772	user2772@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2773	Ada luz	Kulisevich	KOBIETA	user2773	user2773@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2774	Kanchhi	Otłowska	KOBIETA	user2774	user2774@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2775	Sowon	Van hulten	KOBIETA	user2775	user2775@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2776	Ariel	Polańczuk	MEZCZYZNA	user2776	user2776@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2777	Narcyz	Krzeszkiewicz	MEZCZYZNA	user2777	user2777@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2778	Ziemowit	Bronowicz	MEZCZYZNA	user2778	user2778@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2779	Sani	Zbanok	KOBIETA	user2779	user2779@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2780	Batkhishig	Szymutko	NIEOKRESLONY	user2780	user2780@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2781	Melchior	Chałabis	MEZCZYZNA	user2781	user2781@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2782	Radogost	Minasyan	MEZCZYZNA	user2782	user2782@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2783	Jiah	Periv	KOBIETA	user2783	user2783@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2784	Agniia	Kierznikiewicz	KOBIETA	user2784	user2784@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2785	Agłaja	Gliese	KOBIETA	user2785	user2785@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2786	Jacenty	Chlechowicz	MEZCZYZNA	user2786	user2786@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2787	Leonela	Aleksanyan	KOBIETA	user2787	user2787@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2788	Dajmir	Böttcher	MEZCZYZNA	user2788	user2788@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2789	Władysław	Żalski	MEZCZYZNA	user2789	user2789@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2790	Dargomir	Burkhardt	MEZCZYZNA	user2790	user2790@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2791	Alexandria	Melykh	KOBIETA	user2791	user2791@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2792	Sylwester	Olsztyński	MEZCZYZNA	user2792	user2792@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2793	Heni	Wczysła	KOBIETA	user2793	user2793@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2794	Nuna	Malaninets	KOBIETA	user2794	user2794@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2795	Stefan	Kieś-wiśniewski	MEZCZYZNA	user2795	user2795@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2796	Aleks	Chróściel	MEZCZYZNA	user2796	user2796@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2797	Tęgomir	Lyczywek	MEZCZYZNA	user2797	user2797@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2798	Norbert	Szalla	MEZCZYZNA	user2798	user2798@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2799	Teobald	Pejas	MEZCZYZNA	user2799	user2799@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2800	Zemfira	Ulok	KOBIETA	user2800	user2800@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2801	Carmella	Bryntsova	KOBIETA	user2801	user2801@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2802	Mynodora	Van der horst	KOBIETA	user2802	user2802@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2803	Thị lài	Khomutynska	KOBIETA	user2803	user2803@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2804	Iwo	Gill	MEZCZYZNA	user2804	user2804@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2805	Hieronim	Żardecki	MEZCZYZNA	user2805	user2805@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2806	Larisa-maria	Pahlke	KOBIETA	user2806	user2806@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2807	Gerwazy	Sioch	MEZCZYZNA	user2807	user2807@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2808	Nasif	Jelonek	MEZCZYZNA	user2808	user2808@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2809	Effimia	Kosar	KOBIETA	user2809	user2809@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2810	Ksawery	Białecki	MEZCZYZNA	user2810	user2810@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2811	Sławina	Skudławska	KOBIETA	user2811	user2811@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2812	Chaitrali	Bytiuk	KOBIETA	user2812	user2812@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2813	Hvozdika	Grzejdak	KOBIETA	user2813	user2813@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2814	Korneliusz	Bobek	MEZCZYZNA	user2814	user2814@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2815	Kunigunda	Rivett	KOBIETA	user2815	user2815@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2816	Tadeusz	Waliński	MEZCZYZNA	user2816	user2816@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2817	Kasper	Miodoński	MEZCZYZNA	user2817	user2817@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2818	Dominik	Sobesto	MEZCZYZNA	user2818	user2818@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2819	August	Pokłacki	MEZCZYZNA	user2819	user2819@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2820	Jeremiasz	Czugała	MEZCZYZNA	user2820	user2820@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2821	Gülce	Nahaitseva	KOBIETA	user2821	user2821@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2822	Gwido	Frischke	MEZCZYZNA	user2822	user2822@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2823	Gerard	Ciastoń	MEZCZYZNA	user2823	user2823@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2824	Renat	Rezler	MEZCZYZNA	user2824	user2824@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2825	Alaa	Anzina	KOBIETA	user2825	user2825@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2826	Abelard	Sopyła	MEZCZYZNA	user2826	user2826@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2827	Emil	Janiszczak	MEZCZYZNA	user2827	user2827@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2828	Ludomił	Srokosz	MEZCZYZNA	user2828	user2828@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2829	Illona	Dzhalilova	KOBIETA	user2829	user2829@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2830	Janine	Tecklenburg	KOBIETA	user2830	user2830@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2831	Nabina	Giermasz	KOBIETA	user2831	user2831@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2832	Wendelin	Azjan	MEZCZYZNA	user2832	user2832@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2833	Thị thanh mai	Suzynowicz	KOBIETA	user2833	user2833@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2834	Seynur	Jańdziak	KOBIETA	user2834	user2834@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2835	Şükriye	Skibińska-rusinek	KOBIETA	user2835	user2835@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2836	Dechen	Bliakhivska	KOBIETA	user2836	user2836@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2837	Khavra	Polaszyk	KOBIETA	user2837	user2837@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2838	Imena	Knypińska	KOBIETA	user2838	user2838@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2839	Aicholpon	Zargarova	KOBIETA	user2839	user2839@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2840	Nazik	Szemelowska	KOBIETA	user2840	user2840@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2841	Naima	Stempowicz	KOBIETA	user2841	user2841@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2842	Josphine	Cremona	KOBIETA	user2842	user2842@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2843	Magnus	Jeszke	MEZCZYZNA	user2843	user2843@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2844	Lydmyla	Chornoloz	KOBIETA	user2844	user2844@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2845	Katelynn	Kuchyt	KOBIETA	user2845	user2845@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2846	Natan	Macinkiewicz	MEZCZYZNA	user2846	user2846@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2847	Waraporn	Biegiert	KOBIETA	user2847	user2847@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2848	Kumushai	Franciszków	KOBIETA	user2848	user2848@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2849	Shengying	Maroun	KOBIETA	user2849	user2849@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2850	Adell	Łogusz	KOBIETA	user2850	user2850@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2851	Zwinisław	Mandelka	MEZCZYZNA	user2851	user2851@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2852	Zefiryn	Zagrodnik	MEZCZYZNA	user2852	user2852@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2853	Farid	Paukszt	MEZCZYZNA	user2853	user2853@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2854	Durley	Chuzhynova	KOBIETA	user2854	user2854@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2855	Meagan	Kosmala-nowak	KOBIETA	user2855	user2855@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2856	Cezar	Kubiak-chwast	MEZCZYZNA	user2856	user2856@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2857	Antonin	Dobrochowski	MEZCZYZNA	user2857	user2857@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2858	Polikarp	Purczyński	MEZCZYZNA	user2858	user2858@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2859	Guldana	Koniushkina	KOBIETA	user2859	user2859@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2860	Arlene	Okrutnik	KOBIETA	user2860	user2860@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2861	Maciej	Urman	MEZCZYZNA	user2861	user2861@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2862	Astrida	Wengrower	KOBIETA	user2862	user2862@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2863	Artur	Wyrambik	MEZCZYZNA	user2863	user2863@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2864	Leszek	Żukowski-konopka	MEZCZYZNA	user2864	user2864@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2865	Herma	Petcu	KOBIETA	user2865	user2865@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2866	Elana	Seegerer	KOBIETA	user2866	user2866@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2867	Zdena	Tymoshko	KOBIETA	user2867	user2867@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2868	Mateusz	Rosynek	MEZCZYZNA	user2868	user2868@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2869	Leydi	Trautner	KOBIETA	user2869	user2869@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2870	Ludomir	Ryczko	MEZCZYZNA	user2870	user2870@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2871	Śnieżka	Naiarovska	KOBIETA	user2871	user2871@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2872	Anana	Trandu	KOBIETA	user2872	user2872@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2873	Dżan	Gużeński	MEZCZYZNA	user2873	user2873@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2874	Jarosław	Chalił	MEZCZYZNA	user2874	user2874@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2875	Pelaheia	Wyrwa-wójcik	KOBIETA	user2875	user2875@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2876	Bilha	Repyakh	KOBIETA	user2876	user2876@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2877	Wojsław	Falęcik	MEZCZYZNA	user2877	user2877@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2878	Lambert	Czaprowski	MEZCZYZNA	user2878	user2878@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2879	Oleg	Jajus	MEZCZYZNA	user2879	user2879@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2880	Shargiyya	Petryszyn	KOBIETA	user2880	user2880@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2881	Kumral	Garchu	KOBIETA	user2881	user2881@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2882	Bożydar	Wontorowski	MEZCZYZNA	user2882	user2882@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2883	Boguchwał	Skórnicki	MEZCZYZNA	user2883	user2883@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2884	Bartosz	Nadbrzuchowski	MEZCZYZNA	user2884	user2884@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2885	Bogusław	Łompieś	MEZCZYZNA	user2885	user2885@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2886	Cecilie	Waguca	KOBIETA	user2886	user2886@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2887	Filka	Ivtushok	KOBIETA	user2887	user2887@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2888	Melodi	Bohonko	KOBIETA	user2888	user2888@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2889	Adelfina	Smytiukh	KOBIETA	user2889	user2889@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2890	Miku	Skopovska	KOBIETA	user2890	user2890@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2891	Hermes	Brązert	MEZCZYZNA	user2891	user2891@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2892	Bożan	Blinstrub	MEZCZYZNA	user2892	user2892@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2893	Hòa	Ćwiekowska	KOBIETA	user2893	user2893@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2894	Florise	Korczak-mleczko	KOBIETA	user2894	user2894@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2895	Beat	Nadrzycki	MEZCZYZNA	user2895	user2895@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2896	Anh ðào	Duhinova	KOBIETA	user2896	user2896@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2897	Zenon	Hodyma	MEZCZYZNA	user2897	user2897@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2898	Igor	Targoński	MEZCZYZNA	user2898	user2898@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2899	Lubisław	Fitkovskyy	MEZCZYZNA	user2899	user2899@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2900	Benedykt	Cytacki	MEZCZYZNA	user2900	user2900@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2901	Li-wen	Romanyk	KOBIETA	user2901	user2901@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2902	Tasha	Harajon	KOBIETA	user2902	user2902@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2903	Fatoş	Atsu	KOBIETA	user2903	user2903@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2904	Mihal	Martusciello	KOBIETA	user2904	user2904@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2905	Nikodem	Oś	MEZCZYZNA	user2905	user2905@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2906	Aiko	Ardiiants	NIEOKRESLONY	user2906	user2906@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2907	Irem	Oryga	KOBIETA	user2907	user2907@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2908	Anastasiia-solomiia	Barakhoieva	KOBIETA	user2908	user2908@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2909	Paweł	Zdański	MEZCZYZNA	user2909	user2909@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2910	Paméla	Kotuc	KOBIETA	user2910	user2910@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2911	Omar	Piecewicz	MEZCZYZNA	user2911	user2911@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2912	Jarowit	Pustelniak	MEZCZYZNA	user2912	user2912@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2913	Kwietosław	Stempiński	MEZCZYZNA	user2913	user2913@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2914	Cátia	Erfani	KOBIETA	user2914	user2914@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2915	Veleslava	Tokovylo	KOBIETA	user2915	user2915@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2916	Mary grace	Kazhanouskaya	KOBIETA	user2916	user2916@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2917	Omar	Kukulski	MEZCZYZNA	user2917	user2917@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2918	Soyul	Ruczakowska	KOBIETA	user2918	user2918@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2919	Tsetseg	Wypadło	KOBIETA	user2919	user2919@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2920	Mariana	Skronik	KOBIETA	user2920	user2920@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2921	Kyria	Avdi	KOBIETA	user2921	user2921@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2922	Havanna	Mysera	NIEOKRESLONY	user2922	user2922@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2923	Wenli	Larssen	KOBIETA	user2923	user2923@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2924	Hadidja	Bzhytska	KOBIETA	user2924	user2924@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2925	Santijana	Wiśniewska-nowak	KOBIETA	user2925	user2925@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2926	Yanli	Luchting	KOBIETA	user2926	user2926@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2927	Sobiesław	Ryszewski	MEZCZYZNA	user2927	user2927@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2928	Bernard	Kożdoń	MEZCZYZNA	user2928	user2928@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2929	Renat	Bortnowski	MEZCZYZNA	user2929	user2929@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2930	Micheline	Bosiacki	KOBIETA	user2930	user2930@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2931	Yoval	Bodurka-krzyżak	KOBIETA	user2931	user2931@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2932	Sędzisław	Hrycak	MEZCZYZNA	user2932	user2932@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2933	Cecylian	Rogaliński	MEZCZYZNA	user2933	user2933@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2934	Zefir	Kopycki	MEZCZYZNA	user2934	user2934@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2935	Mojżesz	Szkuat	MEZCZYZNA	user2935	user2935@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2936	Dzierżysława	Mościdło	KOBIETA	user2936	user2936@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2937	Leszek	Araszkiewicz	MEZCZYZNA	user2937	user2937@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2938	Bożimir	Robotycki	MEZCZYZNA	user2938	user2938@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2939	Thị thục	Szenawa	KOBIETA	user2939	user2939@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2940	Zişan	Kehrel	KOBIETA	user2940	user2940@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2941	Donald	Bekier	MEZCZYZNA	user2941	user2941@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2942	Anri	Onopczuk	KOBIETA	user2942	user2942@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2943	Seweryn	Biórka	MEZCZYZNA	user2943	user2943@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2944	Kasjusz	Anysz	MEZCZYZNA	user2944	user2944@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2945	Faustyn	Aboufakher	MEZCZYZNA	user2945	user2945@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2946	Teofil	Baryła	MEZCZYZNA	user2946	user2946@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2947	Duszan	Koptaś	MEZCZYZNA	user2947	user2947@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2948	Romanenko	Gołówka	KOBIETA	user2948	user2948@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2949	Mojmierz	Kuroś	MEZCZYZNA	user2949	user2949@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2950	Shelter	Kameniuka	KOBIETA	user2950	user2950@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2951	Józef	Demianiuk	MEZCZYZNA	user2951	user2951@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2952	Thi hau	Porczyńska-walczak	KOBIETA	user2952	user2952@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2953	Vĕra	Hołtra	KOBIETA	user2953	user2953@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2954	Walery	Pankiewicz	MEZCZYZNA	user2954	user2954@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2955	Wenancjusz	Gnatowski	MEZCZYZNA	user2955	user2955@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2956	Godfryg	Śleszycki	MEZCZYZNA	user2956	user2956@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2957	Gisselle	Chebotariova	KOBIETA	user2957	user2957@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2958	Viryneya	Hova	KOBIETA	user2958	user2958@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2959	Silje	Kalivoda	KOBIETA	user2959	user2959@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2960	Hristina	Kadac	KOBIETA	user2960	user2960@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2961	Rumiya	Tosheva	KOBIETA	user2961	user2961@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2962	Herakles	Koryń	MEZCZYZNA	user2962	user2962@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2963	Dima	Zagierska	KOBIETA	user2963	user2963@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2964	Paraskiewi	Pocztarski	KOBIETA	user2964	user2964@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2965	Beniamin	Smyrak	MEZCZYZNA	user2965	user2965@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2966	Brak imienia	Poklikay	KOBIETA	user2966	user2966@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2967	Annora	Boznańska	KOBIETA	user2967	user2967@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2968	Dobrosław	Cempa	MEZCZYZNA	user2968	user2968@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2969	Hyeji	Michieletti	KOBIETA	user2969	user2969@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2970	Dobrogost	Prawda	MEZCZYZNA	user2970	user2970@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2971	Samhita	Bulla	KOBIETA	user2971	user2971@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2972	Walentyn	Lutek	MEZCZYZNA	user2972	user2972@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2973	Dawid	Skowyra	MEZCZYZNA	user2973	user2973@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2974	Wided	Pizar	KOBIETA	user2974	user2974@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2975	Cezary	Wunschik	MEZCZYZNA	user2975	user2975@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2976	Kryspin	Grabizna	MEZCZYZNA	user2976	user2976@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2977	Yadviga	Kirvalidze	KOBIETA	user2977	user2977@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2978	Doudou	Jadach	KOBIETA	user2978	user2978@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2979	Shayda	Liapota	KOBIETA	user2979	user2979@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2980	Marian	Szykierski	MEZCZYZNA	user2980	user2980@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2981	Lieniie	Szwamber	KOBIETA	user2981	user2981@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2982	Dzwonimierz	Paleczek	MEZCZYZNA	user2982	user2982@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2983	Chunyu	Byamba	KOBIETA	user2983	user2983@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2984	Zygmunta	Szulfer	MEZCZYZNA	user2984	user2984@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2985	Sujatha	Zuzula	KOBIETA	user2985	user2985@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2986	Laureline	Zujko	KOBIETA	user2986	user2986@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2987	Hubert	Małańczak	MEZCZYZNA	user2987	user2987@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2988	Sajeda	Dybus	KOBIETA	user2988	user2988@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2989	Maitê	Tobowska	KOBIETA	user2989	user2989@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2990	Evana	Kurzyna-findel	KOBIETA	user2990	user2990@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2991	Vieronika	Izańczak	KOBIETA	user2991	user2991@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2992	Apoloniusz	Magnuszewski	MEZCZYZNA	user2992	user2992@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2993	Beat	Ściak	MEZCZYZNA	user2993	user2993@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2994	Błażej	Domurat	MEZCZYZNA	user2994	user2994@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2995	Bolebor	Luraniec	MEZCZYZNA	user2995	user2995@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2996	Zaure	Markowa	KOBIETA	user2996	user2996@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2997	Iordana	Koczek	KOBIETA	user2997	user2997@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2998	Aimei	Hladkochub	KOBIETA	user2998	user2998@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
2999	Ciechosław	Grymulski	MEZCZYZNA	user2999	user2999@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3000	Jonatan	Małaszuk	MEZCZYZNA	user3000	user3000@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3001	Arnold	Bortnik	MEZCZYZNA	user3001	user3001@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3002	Tsatsral	Zaichykova	KOBIETA	user3002	user3002@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3003	Hermes	Łyczek	MEZCZYZNA	user3003	user3003@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3004	Hubert	Kadłubek	MEZCZYZNA	user3004	user3004@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3005	Yesenia	Ustich	KOBIETA	user3005	user3005@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3006	Aneta	Pantiukhova	KOBIETA	user3006	user3006@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3007	Yiyu	Młynarowicz	KOBIETA	user3007	user3007@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3008	Tinsae	Szyrwińska	KOBIETA	user3008	user3008@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3009	Jelly	Villarosa	KOBIETA	user3009	user3009@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3010	Bolesław	Rut	MEZCZYZNA	user3010	user3010@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3011	Marekhi	Winkelmann	KOBIETA	user3011	user3011@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3012	Vitaliana	Uwaifo	KOBIETA	user3012	user3012@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3013	Dajmir	Szuplak	MEZCZYZNA	user3013	user3013@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3014	Mahnaz	Januś	KOBIETA	user3014	user3014@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3015	Sylwester	Beń	MEZCZYZNA	user3015	user3015@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3016	Medard	Demkowski	MEZCZYZNA	user3016	user3016@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3017	Myślimir	Lewańczuk	MEZCZYZNA	user3017	user3017@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3018	Dobiesław	Osiowy	MEZCZYZNA	user3018	user3018@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3019	Świętibor	Klewer	MEZCZYZNA	user3019	user3019@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3020	Maryn	Farmas	MEZCZYZNA	user3020	user3020@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3021	India	Nesvietailova	KOBIETA	user3021	user3021@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3022	Amadeusz	Szemberski	MEZCZYZNA	user3022	user3022@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3023	Dobrinka	Szewka	KOBIETA	user3023	user3023@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3024	Derwit	Opala	MEZCZYZNA	user3024	user3024@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3025	Świętopełk	Budziszewski	MEZCZYZNA	user3025	user3025@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3026	Zenobiusz	Alechno	MEZCZYZNA	user3026	user3026@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3027	Melchior	Sępkowski	MEZCZYZNA	user3027	user3027@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3028	Jasneet	Dalkilic	KOBIETA	user3028	user3028@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3029	Kanimir	Proszowski	MEZCZYZNA	user3029	user3029@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3030	Krystyn	Olek	MEZCZYZNA	user3030	user3030@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3031	Ayzan	Gruchowska	KOBIETA	user3031	user3031@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3032	Agaton	Blachani	MEZCZYZNA	user3032	user3032@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3033	Jacenty	Grabarek	MEZCZYZNA	user3033	user3033@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3034	Rahila	Boczula	KOBIETA	user3034	user3034@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3035	Sergiusz	Odwald	MEZCZYZNA	user3035	user3035@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3036	Klarysa	Bel	KOBIETA	user3036	user3036@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3037	Przybysław	Kaplita	MEZCZYZNA	user3037	user3037@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3038	Władysław	Haraziński	MEZCZYZNA	user3038	user3038@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3039	Sylwiusz	Rejkowicz	MEZCZYZNA	user3039	user3039@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3040	Beat	Mrowca-ciułacz	MEZCZYZNA	user3040	user3040@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3041	Cichosław	Papazjan	MEZCZYZNA	user3041	user3041@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3042	Jensen	Gakos	KOBIETA	user3042	user3042@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3043	Paskal	Szymusiak	MEZCZYZNA	user3043	user3043@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3044	Rosalina	Strilchuk	KOBIETA	user3044	user3044@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3045	Suvdaa	Zyromski	KOBIETA	user3045	user3045@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3046	Hubert	Zero	MEZCZYZNA	user3046	user3046@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3047	Pragnya	Żerdzińska	KOBIETA	user3047	user3047@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3048	Tulimierz	Ordutowski	MEZCZYZNA	user3048	user3048@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3049	Dajmir	Janoch	MEZCZYZNA	user3049	user3049@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3050	Paloma	Oganezovi	KOBIETA	user3050	user3050@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3051	Sarya	Biga	KOBIETA	user3051	user3051@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3052	Manjari	Pardiak	KOBIETA	user3052	user3052@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3053	Saeideh	Dzileńska	KOBIETA	user3053	user3053@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3054	Maria-alexandra	Wróblewska-woźniak	KOBIETA	user3054	user3054@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3055	Maria eugenia	Synoweć	KOBIETA	user3055	user3055@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3056	Koral	Plaża	KOBIETA	user3056	user3056@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3057	Megija	Szaleńców	KOBIETA	user3057	user3057@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3058	Konradyn	Jewczuk	MEZCZYZNA	user3058	user3058@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3059	Vladliena	Jesiotr	KOBIETA	user3059	user3059@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3060	Daksha	Cekić	KOBIETA	user3060	user3060@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3061	Walentyn	Sendacki	MEZCZYZNA	user3061	user3061@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3062	Roland	Tamari	MEZCZYZNA	user3062	user3062@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3063	Hermes	Kamela	MEZCZYZNA	user3063	user3063@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3064	Ananiasz	Nadolny	MEZCZYZNA	user3064	user3064@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3065	Ryszard	Frost	MEZCZYZNA	user3065	user3065@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3066	Radomir	Bukowiecki	MEZCZYZNA	user3066	user3066@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3067	Natalia	Łapska	KOBIETA	user3067	user3067@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3068	Kordian	Hazior	MEZCZYZNA	user3068	user3068@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3069	Mārīte	Mendel	KOBIETA	user3069	user3069@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3070	Yukiyo	Goljan	KOBIETA	user3070	user3070@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3071	Samson	Stasiewicz	MEZCZYZNA	user3071	user3071@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3072	Warwara	Borovetcaia	KOBIETA	user3072	user3072@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3073	Oskar	Bokun	MEZCZYZNA	user3073	user3073@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3074	Nikodem	Kocerka	MEZCZYZNA	user3074	user3074@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3075	Danisław	Marconi	MEZCZYZNA	user3075	user3075@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3076	Bożętyna	Grohnert	KOBIETA	user3076	user3076@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3077	Mojmir	Kondeusz	MEZCZYZNA	user3077	user3077@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3078	Benon	Markitan	MEZCZYZNA	user3078	user3078@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3079	Thi thuy trang	Aranzi	KOBIETA	user3079	user3079@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3080	Nataniel	Sztejkowski	MEZCZYZNA	user3080	user3080@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3081	Dobiesław	Lubas	MEZCZYZNA	user3081	user3081@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3082	Mi hyang	Wędłowska	KOBIETA	user3082	user3082@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3083	Jonata	Nerezenko	KOBIETA	user3083	user3083@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3084	Ji seon	Onoshchenko	KOBIETA	user3084	user3084@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3085	Ziemowit	Fiedor	MEZCZYZNA	user3085	user3085@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3086	Witold	Maroń	MEZCZYZNA	user3086	user3086@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3087	Rozy	Franiok	KOBIETA	user3087	user3087@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3088	Prokop	Pskowski	MEZCZYZNA	user3088	user3088@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3089	Aideen	Formoli	KOBIETA	user3089	user3089@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3090	Wisenna	Brucki	KOBIETA	user3090	user3090@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3091	Firangiz	Kanadska	KOBIETA	user3091	user3091@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3092	Ying	Muraszko-kuźma	KOBIETA	user3092	user3092@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3093	Chrystian	Dworczyński	MEZCZYZNA	user3093	user3093@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3094	Ok	Mykietyńska	KOBIETA	user3094	user3094@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3095	Bonifacy	Kubit	MEZCZYZNA	user3095	user3095@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3096	Medard	Gurbała	MEZCZYZNA	user3096	user3096@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3097	Pakosław	Dorniak	MEZCZYZNA	user3097	user3097@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3098	Rufus	Galan	MEZCZYZNA	user3098	user3098@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3099	Rajna	Okuszko	KOBIETA	user3099	user3099@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3100	Sykstus	Rzymski	MEZCZYZNA	user3100	user3100@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3101	Leo	Pajerowski	MEZCZYZNA	user3101	user3101@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3102	Julianna	Koeppe	KOBIETA	user3102	user3102@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3103	Mirit	Kulabukhova	KOBIETA	user3103	user3103@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3104	Ladyslava	Galaz	KOBIETA	user3104	user3104@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3105	Thanh ha	Shliakhytniuk	KOBIETA	user3105	user3105@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3106	Wendelin	Truty	MEZCZYZNA	user3106	user3106@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3107	Sędzisław	Dzwinczyk	MEZCZYZNA	user3107	user3107@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3108	Lubisław	Grynfelder	MEZCZYZNA	user3108	user3108@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3109	Mirosz	Chyłek	MEZCZYZNA	user3109	user3109@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3110	Leo	Pajda	MEZCZYZNA	user3110	user3110@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3111	Leonia	Lilyanova	KOBIETA	user3111	user3111@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3112	Sławomir	Rydzeński	MEZCZYZNA	user3112	user3112@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3113	Justynian	Szkuta	MEZCZYZNA	user3113	user3113@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3114	Sambor	Pielach	MEZCZYZNA	user3114	user3114@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3115	Walid	Ochendowski	MEZCZYZNA	user3115	user3115@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3116	Tytus	Karamański	MEZCZYZNA	user3116	user3116@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3117	Ellen grace	Wawrzynkiewicz-raźna	KOBIETA	user3117	user3117@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3118	Hasumi	Notaras	KOBIETA	user3118	user3118@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3119	Vadym	Kruth	KOBIETA	user3119	user3119@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3120	Josephin	Tuchina	KOBIETA	user3120	user3120@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3121	Arian	Panchvidze	KOBIETA	user3121	user3121@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3122	Yiqi	Oczyński	KOBIETA	user3122	user3122@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3123	Violet	Hjortung	KOBIETA	user3123	user3123@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3124	Otto	Bauc	MEZCZYZNA	user3124	user3124@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3125	Nishi	Trzyńska	KOBIETA	user3125	user3125@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3126	Gaweł	Kuegler	MEZCZYZNA	user3126	user3126@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3127	Bodosław	Kasperczyk	MEZCZYZNA	user3127	user3127@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3128	Maurycjusz	Kołtan	MEZCZYZNA	user3128	user3128@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3129	Coca	Kibilska	KOBIETA	user3129	user3129@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3130	Khrystyna-sofiia	Drobinko	KOBIETA	user3130	user3130@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3131	Darateya	Ixner	KOBIETA	user3131	user3131@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3132	Idzi	Sury	MEZCZYZNA	user3132	user3132@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3133	Rajner	Malankowski	MEZCZYZNA	user3133	user3133@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3134	Kastor	Janczak	MEZCZYZNA	user3134	user3134@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3135	Aniko	Waśniewska	KOBIETA	user3135	user3135@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3184	Faustyn	Szulant	MEZCZYZNA	user3184	user3184@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3136	Melahat	Andrejczuk	KOBIETA	user3136	user3136@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3137	Kain	Delmaczyński	MEZCZYZNA	user3137	user3137@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3138	Farhinbanu	Vytvitska	KOBIETA	user3138	user3138@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3139	Shantal	Zilm	KOBIETA	user3139	user3139@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3140	Hadia	Malej	KOBIETA	user3140	user3140@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3141	Ugne	Murashka	KOBIETA	user3141	user3141@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3142	Avy	Hrubets	KOBIETA	user3142	user3142@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3143	Serafin	Kopycki	MEZCZYZNA	user3143	user3143@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3144	Grzegorz	Dzedzej	MEZCZYZNA	user3144	user3144@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3145	Kornelja	Lorenz	KOBIETA	user3145	user3145@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3146	Stojan	Osmani	MEZCZYZNA	user3146	user3146@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3147	Fera	Yahodzynska	KOBIETA	user3147	user3147@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3148	Barnim	Aleks	MEZCZYZNA	user3148	user3148@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3149	Mirosław	Machenia	MEZCZYZNA	user3149	user3149@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3150	Ernest	Czerepak	MEZCZYZNA	user3150	user3150@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3151	Nazire	Morgenthaler	KOBIETA	user3151	user3151@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3152	Milan	Pilachowski	MEZCZYZNA	user3152	user3152@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3153	Saniyat	Domino	KOBIETA	user3153	user3153@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3154	Paraskeviya	Petrochenko	KOBIETA	user3154	user3154@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3155	Zefir	Ciża	MEZCZYZNA	user3155	user3155@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3156	Modest	Peszyński	MEZCZYZNA	user3156	user3156@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3157	Augustyn	Maczassek	MEZCZYZNA	user3157	user3157@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3158	Nini johana	Chodorow	KOBIETA	user3158	user3158@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3159	Barabasz	Dziechciarz	MEZCZYZNA	user3159	user3159@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3160	Tanya	Błaszka	KOBIETA	user3160	user3160@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3161	Kornel-korni	Mandyna	MEZCZYZNA	user3161	user3161@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3162	Funda	Bariba	KOBIETA	user3162	user3162@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3163	Jan	Hatka	MEZCZYZNA	user3163	user3163@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3164	Radomił	Muniak-adamski	MEZCZYZNA	user3164	user3164@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3165	Xiaoshi	Winska	KOBIETA	user3165	user3165@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3166	Türkan	Aleknevičius	KOBIETA	user3166	user3166@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3167	Habi̇be	Młocka	KOBIETA	user3167	user3167@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3168	Iram	Czertak	KOBIETA	user3168	user3168@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3169	Yevhena	Dlouchy	KOBIETA	user3169	user3169@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3170	Lilijana	Kamyczura	KOBIETA	user3170	user3170@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3171	Shea	Bahach	KOBIETA	user3171	user3171@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3172	Jewgenia	Abdukhalilova	KOBIETA	user3172	user3172@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3173	Narges	Hryniewska-metelska	KOBIETA	user3173	user3173@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3174	Yelanta	Bujorean	KOBIETA	user3174	user3174@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3175	Felicjan	Sterecki	MEZCZYZNA	user3175	user3175@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3176	Inetta	Garbolino	KOBIETA	user3176	user3176@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3177	Freia	Iłejko	KOBIETA	user3177	user3177@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3178	Apoloniusz	Trempała	MEZCZYZNA	user3178	user3178@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3179	Ruslana	Dryukova	KOBIETA	user3179	user3179@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3180	Deeksha	Irhizova	KOBIETA	user3180	user3180@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3181	Bożan	Isko	MEZCZYZNA	user3181	user3181@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3182	Emanuel	Sternal	MEZCZYZNA	user3182	user3182@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3183	Donald	Bierski	MEZCZYZNA	user3183	user3183@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3185	Wit	Szwajkowski	MEZCZYZNA	user3185	user3185@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3186	Antonius	Hulbój	MEZCZYZNA	user3186	user3186@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3187	Wendelin	Dzieciaszek	MEZCZYZNA	user3187	user3187@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3188	Hassna	İlçi̇n	KOBIETA	user3188	user3188@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3189	Ainaz	Grósy	KOBIETA	user3189	user3189@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3190	Tien	Ostrovyk	KOBIETA	user3190	user3190@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3191	Chwalimir	Chajneta	MEZCZYZNA	user3191	user3191@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3192	Jędrzej	Pyrzanowski	MEZCZYZNA	user3192	user3192@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3193	Yon	Usarewicz	KOBIETA	user3193	user3193@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3194	Dragomira	Rodriguez sierra	KOBIETA	user3194	user3194@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3195	Włodzisław	Czurłowski	MEZCZYZNA	user3195	user3195@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3196	Mayuree	Mikhalionak	KOBIETA	user3196	user3196@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3197	Rabiga	Schepaniak	KOBIETA	user3197	user3197@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3198	Chwalisław	Śniadek	MEZCZYZNA	user3198	user3198@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3199	Amadeusz	Szweinberger	MEZCZYZNA	user3199	user3199@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3200	Jacquelynn	Khimenko	KOBIETA	user3200	user3200@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3201	Anioł	Brach	MEZCZYZNA	user3201	user3201@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3202	Kanna	Rotkvić	KOBIETA	user3202	user3202@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3203	Lotem	Butyłkin	KOBIETA	user3203	user3203@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3204	Hetvi	Roiako	KOBIETA	user3204	user3204@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3205	Run	Szpajzer	KOBIETA	user3205	user3205@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3206	Prokop	Winsławski	MEZCZYZNA	user3206	user3206@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3207	Huz	Pomykała	KOBIETA	user3207	user3207@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3208	Rosabella	Stangorra	KOBIETA	user3208	user3208@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3209	Sofroniusz	Supłat	MEZCZYZNA	user3209	user3209@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3210	Marianthi	Nchinjayi	KOBIETA	user3210	user3210@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3211	Anastazy	Stefański	MEZCZYZNA	user3211	user3211@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3212	Jasuf	Zadolny	MEZCZYZNA	user3212	user3212@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3213	Param	Taraśkowska	KOBIETA	user3213	user3213@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3214	Melchior	Mistarz	MEZCZYZNA	user3214	user3214@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3215	Reia	Golkina	KOBIETA	user3215	user3215@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3216	Oktawiusz	Traliński	MEZCZYZNA	user3216	user3216@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3217	Wendelin	Nadgórski	MEZCZYZNA	user3217	user3217@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3218	Izydor	Bichajło	MEZCZYZNA	user3218	user3218@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3219	Vanika	Ziółek	KOBIETA	user3219	user3219@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3220	Betia	Szwalka	KOBIETA	user3220	user3220@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3221	Vanisha	Jędrzejowska-paluch	KOBIETA	user3221	user3221@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3222	Khatin	Kreminets	KOBIETA	user3222	user3222@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3223	Wincenty	Koprucha	MEZCZYZNA	user3223	user3223@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3224	Babette	Skale	KOBIETA	user3224	user3224@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3225	Netsai	Czernyj	KOBIETA	user3225	user3225@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3226	Alina-ivanna	Kromann	KOBIETA	user3226	user3226@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3227	Ludomir	Strzechmiński	MEZCZYZNA	user3227	user3227@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3228	Mylene	Breckenridge	KOBIETA	user3228	user3228@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3229	Eskada	Thomsett	KOBIETA	user3229	user3229@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3230	Teofila	Diakonesku	KOBIETA	user3230	user3230@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3231	Strzeżymir	Bałchanowski	MEZCZYZNA	user3231	user3231@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3232	Mirosz	Kachnowicz	MEZCZYZNA	user3232	user3232@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3233	Thị thắm	Frajzinger	KOBIETA	user3233	user3233@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3234	Bolebor	Grembka	MEZCZYZNA	user3234	user3234@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3235	Charo	Wojciechowska-kozłowska	KOBIETA	user3235	user3235@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3236	Otylia	Loboiko	KOBIETA	user3236	user3236@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3237	Shuman	Cavarretta	NIEOKRESLONY	user3237	user3237@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3238	Korneli	Gwizdek	MEZCZYZNA	user3238	user3238@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3239	Wayne	Draśpa	KOBIETA	user3239	user3239@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3240	Faustyn	Hańczka	MEZCZYZNA	user3240	user3240@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3241	Kordian	Parka	MEZCZYZNA	user3241	user3241@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3242	Dajmir	Gaładyn	MEZCZYZNA	user3242	user3242@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3243	Bolelut	Mirocha	MEZCZYZNA	user3243	user3243@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3244	Lienara	Reisener	KOBIETA	user3244	user3244@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3245	Lucjan	Piadek	MEZCZYZNA	user3245	user3245@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3246	Jan	Radywoniuk	MEZCZYZNA	user3246	user3246@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3247	Surayya	Bola	KOBIETA	user3247	user3247@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3248	Milan	Padamczyk	MEZCZYZNA	user3248	user3248@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3249	Thi anh tuyet	Stonebrook	KOBIETA	user3249	user3249@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3250	Wanessa	Paźgier	KOBIETA	user3250	user3250@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3251	Artur	Bosak	MEZCZYZNA	user3251	user3251@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3252	Daisy-may	Mazurek-nowicka	KOBIETA	user3252	user3252@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3253	Irena	Bortnichenko	KOBIETA	user3253	user3253@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3254	Damazy	Pilip	MEZCZYZNA	user3254	user3254@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3255	Amadeusz	Suszka	MEZCZYZNA	user3255	user3255@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3256	Ariel	Gąsienica-szostak	MEZCZYZNA	user3256	user3256@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3257	Liljanna	Rostafińska	KOBIETA	user3257	user3257@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3258	Siemowit	Zazakowny	MEZCZYZNA	user3258	user3258@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3259	Daliia	Komonicka	KOBIETA	user3259	user3259@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3260	Stoisław	Rywczyński	MEZCZYZNA	user3260	user3260@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3261	Karla	Strehlau	KOBIETA	user3261	user3261@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3262	Tsvietana	Behus	KOBIETA	user3262	user3262@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3263	Milan	Dekiert	MEZCZYZNA	user3263	user3263@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3264	Ferdynand	Masarz	MEZCZYZNA	user3264	user3264@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3265	Przemysław	Kis	MEZCZYZNA	user3265	user3265@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3266	Kumari	Kralich	KOBIETA	user3266	user3266@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3267	Giselly	Tsybulieva	KOBIETA	user3267	user3267@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3268	Żelisław	Tota	MEZCZYZNA	user3268	user3268@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3269	Bogusław	Sieśkiewicz	MEZCZYZNA	user3269	user3269@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3270	Placyd	Serowik	MEZCZYZNA	user3270	user3270@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3271	Gulsina	Echtermeyer	KOBIETA	user3271	user3271@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3272	Kashish	Garipova	KOBIETA	user3272	user3272@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3273	Aliona	Roubinek	KOBIETA	user3273	user3273@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3274	Kajusz	Prus	MEZCZYZNA	user3274	user3274@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3275	Miłosz	Adamkowski	MEZCZYZNA	user3275	user3275@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3276	Şilan	Obzor	KOBIETA	user3276	user3276@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3277	Liis	Krystynchuk	KOBIETA	user3277	user3277@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3278	Etel	Radułowicz	KOBIETA	user3278	user3278@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3279	Herbert	Redziak	MEZCZYZNA	user3279	user3279@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3280	Dynara	Niedbała-gwóźdź	KOBIETA	user3280	user3280@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3281	Marcin	Pusztuk	MEZCZYZNA	user3281	user3281@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3282	Kloudia	Vylymets	KOBIETA	user3282	user3282@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3283	Konstanty	Ettinger	MEZCZYZNA	user3283	user3283@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3284	Marceli	Augustynowicz	MEZCZYZNA	user3284	user3284@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3285	Wielisław	Rabie	MEZCZYZNA	user3285	user3285@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3286	Barnim	Ołtuszyk	MEZCZYZNA	user3286	user3286@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3287	Nabiha	Schopny	KOBIETA	user3287	user3287@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3288	Lena	Węzowska	KOBIETA	user3288	user3288@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3289	Aminia	Brzeza	KOBIETA	user3289	user3289@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3290	Thaneesha	Prość	KOBIETA	user3290	user3290@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3291	Ashwini	Przysucha	KOBIETA	user3291	user3291@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3292	Zygfryd	Borss	MEZCZYZNA	user3292	user3292@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3293	Gineta	Gramulińska	KOBIETA	user3293	user3293@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3294	Starwit	Jasiuk	MEZCZYZNA	user3294	user3294@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3295	Romeo	Placek	MEZCZYZNA	user3295	user3295@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3296	Samea	Jurczyszyn	KOBIETA	user3296	user3296@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3297	Cholponai	Szymik-caputa	KOBIETA	user3297	user3297@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3298	Clio	Zrazhevska	KOBIETA	user3298	user3298@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3299	Kochan	Szropa	MEZCZYZNA	user3299	user3299@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3300	Godzisław	Bogusiewicz	MEZCZYZNA	user3300	user3300@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3301	Adam	Anwar	MEZCZYZNA	user3301	user3301@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3302	Wenancjusz	Guzior	MEZCZYZNA	user3302	user3302@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3303	Justyn	Ścibek	MEZCZYZNA	user3303	user3303@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3304	Rachida	Gatty-kostyal	KOBIETA	user3304	user3304@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3305	Dżem	Macchione	MEZCZYZNA	user3305	user3305@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3306	Hanusz	Gerej	MEZCZYZNA	user3306	user3306@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3307	Alojzy	Trembacz	MEZCZYZNA	user3307	user3307@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3308	Tulimir	Ziętarski	MEZCZYZNA	user3308	user3308@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3309	Zwinisław	Klimko	MEZCZYZNA	user3309	user3309@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3310	Veroniki	Hehediush	KOBIETA	user3310	user3310@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3311	Quỳnh trang	Dworkowska	KOBIETA	user3311	user3311@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3312	Modest	Klimański	MEZCZYZNA	user3312	user3312@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3313	Armella	Konelska	KOBIETA	user3313	user3313@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3314	Collen	Grendziak	KOBIETA	user3314	user3314@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3315	Eline	Shypuk	KOBIETA	user3315	user3315@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3316	Prokop	Czytrzyński	MEZCZYZNA	user3316	user3316@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3317	Bakhar	Borowska-kieczyk	KOBIETA	user3317	user3317@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3318	Radomił	Hummel	MEZCZYZNA	user3318	user3318@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3319	Oswald	Frontczak	MEZCZYZNA	user3319	user3319@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3320	Omar	Kuczaj	MEZCZYZNA	user3320	user3320@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3321	Otokar	Alker	MEZCZYZNA	user3321	user3321@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3322	Leopold	Haor	MEZCZYZNA	user3322	user3322@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3323	Bożyna	Dzyrun	KOBIETA	user3323	user3323@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3324	Iwon	Gapinski	MEZCZYZNA	user3324	user3324@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3325	Mykhaylina	Kefala	KOBIETA	user3325	user3325@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3326	Solena	Chernomor	KOBIETA	user3326	user3326@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3327	Żarek	Teskowski	MEZCZYZNA	user3327	user3327@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3328	Thị sen	Matyiashkoits	KOBIETA	user3328	user3328@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3329	Yulka	Thuwan	KOBIETA	user3329	user3329@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3330	Wendelin	Sobiński	MEZCZYZNA	user3330	user3330@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3331	Migle	Chaux cervantes	KOBIETA	user3331	user3331@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3332	Wielisław	Bistron	MEZCZYZNA	user3332	user3332@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3333	Eryk	Krojcig	MEZCZYZNA	user3333	user3333@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3334	Hermes	Nastiuk	MEZCZYZNA	user3334	user3334@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3335	Arevat	Szopieńska	KOBIETA	user3335	user3335@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3336	Diệu	Ostemchuk	KOBIETA	user3336	user3336@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3337	Romeo	Wojtacha	MEZCZYZNA	user3337	user3337@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3338	Tristan	Ciucias	MEZCZYZNA	user3338	user3338@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3339	Mirha	Abramashvili	KOBIETA	user3339	user3339@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3340	Donald	Perz	MEZCZYZNA	user3340	user3340@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3341	Nicolly	Malyavkina	KOBIETA	user3341	user3341@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3342	Kirana	Kleszowska	KOBIETA	user3342	user3342@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3343	Zanura	Putyla	KOBIETA	user3343	user3343@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3344	Leo	Obałka	MEZCZYZNA	user3344	user3344@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3345	Samir	Tołoczko	MEZCZYZNA	user3345	user3345@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3346	Gloriose	Lukaschowitz	KOBIETA	user3346	user3346@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3347	Jarowit	Grzenia	MEZCZYZNA	user3347	user3347@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3348	Şule	Azaryan	KOBIETA	user3348	user3348@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3349	Fabian	Szkiela	MEZCZYZNA	user3349	user3349@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3350	Pafnucy	Zuber	MEZCZYZNA	user3350	user3350@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3351	Chrystian	Sochocki	MEZCZYZNA	user3351	user3351@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3352	Roya	Pykhtia	KOBIETA	user3352	user3352@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3353	Dionizy	Wilkołaski	MEZCZYZNA	user3353	user3353@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3354	Hong trang	Denizhenko	KOBIETA	user3354	user3354@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3355	Oliana	Zdrazil	KOBIETA	user3355	user3355@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3356	Thuraya	Pszczełowska	KOBIETA	user3356	user3356@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3357	Teréz	Monczyńska	KOBIETA	user3357	user3357@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3358	Sabīne	Klajn-broszkiewicz	KOBIETA	user3358	user3358@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3359	Sujitha	Khamrovska	KOBIETA	user3359	user3359@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3360	Świętopełk	Szczesio	MEZCZYZNA	user3360	user3360@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3361	Miron	Reppel	MEZCZYZNA	user3361	user3361@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3362	Agga	Cianowska	KOBIETA	user3362	user3362@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3363	Adelheit	Ranta	KOBIETA	user3363	user3363@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3364	Przybysław	Funcz	MEZCZYZNA	user3364	user3364@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3365	Inesa	Zabkowska	KOBIETA	user3365	user3365@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3366	Nadica	Zahariuk	KOBIETA	user3366	user3366@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3367	Khánh chi	Waintraub	KOBIETA	user3367	user3367@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3368	Donat	Łabuz	MEZCZYZNA	user3368	user3368@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3369	Dzwonimierz	Uzdrowski	MEZCZYZNA	user3369	user3369@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3370	Bartosz	Pawłów	MEZCZYZNA	user3370	user3370@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3371	Protazy	Rębiasz	MEZCZYZNA	user3371	user3371@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3372	Mazarine	Rozumek	KOBIETA	user3372	user3372@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3373	Józefat	Lubera	MEZCZYZNA	user3373	user3373@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3374	Kim ngọc	Zippel	KOBIETA	user3374	user3374@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3375	Zipi	Oldyńska	KOBIETA	user3375	user3375@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3376	Alfred	Kądzielawa	MEZCZYZNA	user3376	user3376@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3377	Wacław	Huńkiewicz	MEZCZYZNA	user3377	user3377@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3378	Abel	Deszcz	MEZCZYZNA	user3378	user3378@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3379	Wandelin	Fedyk	MEZCZYZNA	user3379	user3379@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3380	Deri̇n	Rodzynek	KOBIETA	user3380	user3380@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3381	Ellen	Dyshlevych	KOBIETA	user3381	user3381@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3382	Clothilde	Omelchak	KOBIETA	user3382	user3382@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3383	Marianita	Skrypunova	KOBIETA	user3383	user3383@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3384	Tamaki	Spasova	KOBIETA	user3384	user3384@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3385	Ariel	Kurant	MEZCZYZNA	user3385	user3385@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3386	Zenobiusz	Demianicz	MEZCZYZNA	user3386	user3386@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3387	Yesica alejandra	Slobodniuk	KOBIETA	user3387	user3387@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3388	Janita	Tarlouskaya	KOBIETA	user3388	user3388@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3389	Solanyi	Raduc	KOBIETA	user3389	user3389@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3390	Jamuna	Kyrey	KOBIETA	user3390	user3390@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3391	Zaman	Prokopowicz	KOBIETA	user3391	user3391@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3392	Zygmunt	Petasz	MEZCZYZNA	user3392	user3392@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3393	Cibele	Prosvirova	KOBIETA	user3393	user3393@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3394	Anna-iryna	Noshkaliuk	KOBIETA	user3394	user3394@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3395	Hayane	Ishyna	KOBIETA	user3395	user3395@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3396	Sławomir	Lobermajer	MEZCZYZNA	user3396	user3396@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3397	Lieta	Zagaietska	KOBIETA	user3397	user3397@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3398	Yadviha-vanda	Giczew	KOBIETA	user3398	user3398@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3399	Rokayah	Karpachova	KOBIETA	user3399	user3399@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3400	Eryk	Rebejko	MEZCZYZNA	user3400	user3400@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3401	Anioł	Kliński-chmur	MEZCZYZNA	user3401	user3401@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3402	Gerwazy	Gryciuk	MEZCZYZNA	user3402	user3402@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3403	Waldtraud	Szill	KOBIETA	user3403	user3403@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3404	Gniewosz	Ciurski	MEZCZYZNA	user3404	user3404@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3405	Khánh chi	Karabyn	KOBIETA	user3405	user3405@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3406	Konsuela	Strateichuk	KOBIETA	user3406	user3406@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3407	Evrim	Chodupska	KOBIETA	user3407	user3407@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3408	Walery	Miłkowski	MEZCZYZNA	user3408	user3408@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3409	Laisa	Myhaliuk	KOBIETA	user3409	user3409@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3410	Meia	Chasheika	KOBIETA	user3410	user3410@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3411	Reika	Rumkowska	KOBIETA	user3411	user3411@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3412	Marcjan	Lubianiec	MEZCZYZNA	user3412	user3412@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3413	Radomił	Wudarowicz	MEZCZYZNA	user3413	user3413@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3414	Ananiasz	Delestowicz	MEZCZYZNA	user3414	user3414@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3415	Antoni	Plater-zyberk	MEZCZYZNA	user3415	user3415@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3416	Zinajda	Fonał	KOBIETA	user3416	user3416@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3417	Wilhelm	Łagun-cleworth	MEZCZYZNA	user3417	user3417@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3418	Lorina	Sliepushko	KOBIETA	user3418	user3418@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3419	Ananiasz	Roch	MEZCZYZNA	user3419	user3419@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3420	Fryc	Weremij	MEZCZYZNA	user3420	user3420@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3421	Margerita	Gilligan	KOBIETA	user3421	user3421@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3422	Ioana-raluca	Dvorkina	KOBIETA	user3422	user3422@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3423	Thi hong	Margvelani	KOBIETA	user3423	user3423@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3424	Thị châu	Mbaike	KOBIETA	user3424	user3424@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3425	Ingryda	Szypcio	KOBIETA	user3425	user3425@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3426	Wahid	Neszew	MEZCZYZNA	user3426	user3426@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3427	Konrad	Hombek	MEZCZYZNA	user3427	user3427@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3428	Abelard	Suszkiewicz	MEZCZYZNA	user3428	user3428@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3429	Mehar	Markwardt	KOBIETA	user3429	user3429@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3430	Ludowit	Dyszel	MEZCZYZNA	user3430	user3430@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3431	Rozmaria	Sypiół	KOBIETA	user3431	user3431@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3432	Ludomił	Przystawski	MEZCZYZNA	user3432	user3432@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3433	Tariro	Kolias	KOBIETA	user3433	user3433@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3434	Ludwik	Dobroś	MEZCZYZNA	user3434	user3434@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3435	Dilara	Mazut	KOBIETA	user3435	user3435@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3436	Pafnucy	Bożym	MEZCZYZNA	user3436	user3436@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3437	Manita	Siniarska	NIEOKRESLONY	user3437	user3437@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3438	Azizakhon	Koston	KOBIETA	user3438	user3438@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3439	Silviana	Jankiewicz-alarcon	KOBIETA	user3439	user3439@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3440	Alfred	Poździk	MEZCZYZNA	user3440	user3440@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3441	Ananiasz	Staliś	MEZCZYZNA	user3441	user3441@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3442	Małgorzata	Magadzio	KOBIETA	user3442	user3442@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3443	Olieksandra	Bedouet	KOBIETA	user3443	user3443@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3444	Erazm	Medowski	MEZCZYZNA	user3444	user3444@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3445	Świętomir	Dudkowiak	MEZCZYZNA	user3445	user3445@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3446	Franseska	Żukowska-pawłowska	KOBIETA	user3446	user3446@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3447	Thị thu hiền	Savosko	KOBIETA	user3447	user3447@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3448	Anujin	Ditter	KOBIETA	user3448	user3448@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3449	Herakles	Starowicz	MEZCZYZNA	user3449	user3449@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3450	Thị hiên	Gólnik	KOBIETA	user3450	user3450@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3451	Roch	Bolibok	MEZCZYZNA	user3451	user3451@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3452	Leopold	Gąszcz	MEZCZYZNA	user3452	user3452@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3453	Cornelie	Savchits	KOBIETA	user3453	user3453@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3454	Iaroslawa	Medonchak	KOBIETA	user3454	user3454@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3455	Soukaina	Zonenko	KOBIETA	user3455	user3455@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3456	Leo	Gil gajownik	MEZCZYZNA	user3456	user3456@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3457	Daniel	Alik	MEZCZYZNA	user3457	user3457@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3458	Cecyl	Popielarski	MEZCZYZNA	user3458	user3458@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3459	Rudolf	Karweta	MEZCZYZNA	user3459	user3459@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3460	Charos	Rapczun	KOBIETA	user3460	user3460@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3461	Krzesisław	Pasikowski	MEZCZYZNA	user3461	user3461@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3462	Ailen	Fellberg	KOBIETA	user3462	user3462@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3463	Heloïse	Ezeanieto	KOBIETA	user3463	user3463@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3464	Placyd	Zgorzelski	MEZCZYZNA	user3464	user3464@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3465	Jarad	Świętoniewski	MEZCZYZNA	user3465	user3465@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3466	Ligita	Sheller	KOBIETA	user3466	user3466@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3467	Fabian	Stanios	MEZCZYZNA	user3467	user3467@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3468	Ezechiel	Winkelmann	MEZCZYZNA	user3468	user3468@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3469	Tomasz	Merło	MEZCZYZNA	user3469	user3469@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3470	Kondrat	Warno	MEZCZYZNA	user3470	user3470@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3471	Lubomir	Rabski	MEZCZYZNA	user3471	user3471@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3472	Asmaa	Szendrecka	KOBIETA	user3472	user3472@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3473	Bruno	Całkiewicz	MEZCZYZNA	user3473	user3473@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3474	Myślimir	Stroński	MEZCZYZNA	user3474	user3474@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3475	Hongdi	Ohera	KOBIETA	user3475	user3475@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3476	Maria isabel	Kycej	KOBIETA	user3476	user3476@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3477	Rubina	Rzeźniczuk	KOBIETA	user3477	user3477@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3478	Horacy	Pyrka	MEZCZYZNA	user3478	user3478@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3479	Sykstus	Karasek	MEZCZYZNA	user3479	user3479@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3480	Jasuf	Dobrociński	MEZCZYZNA	user3480	user3480@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3481	Oresa	Mečkovska	KOBIETA	user3481	user3481@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3482	Gracjan	Łucarz	MEZCZYZNA	user3482	user3482@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3483	Godzisław	Anslik	MEZCZYZNA	user3483	user3483@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3484	Lindita	Maseieva	KOBIETA	user3484	user3484@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3485	Tomasz	Zonnabend	MEZCZYZNA	user3485	user3485@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3486	Estefani	Gabaeva	KOBIETA	user3486	user3486@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3487	Tatuana	Dymarets	KOBIETA	user3487	user3487@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3488	Oktawiusz	Kusztubajda	MEZCZYZNA	user3488	user3488@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3489	Klemens	Rygnel	MEZCZYZNA	user3489	user3489@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3490	Penny	Strizhenko	KOBIETA	user3490	user3490@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3491	Toba	Şenyi̇ği̇t	KOBIETA	user3491	user3491@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3492	Chadia	Nozderka	KOBIETA	user3492	user3492@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3493	Hajar	Tsyhanchuk	KOBIETA	user3493	user3493@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3494	Tuong	Musiiets	KOBIETA	user3494	user3494@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3495	Nursena	Khoroshavtseva	KOBIETA	user3495	user3495@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3496	Charanya	Herheleinyk	KOBIETA	user3496	user3496@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3497	Thị tâm	Boiaryna	KOBIETA	user3497	user3497@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3498	Tula	Vislavnykh	KOBIETA	user3498	user3498@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3499	Halimah	Struchalin	KOBIETA	user3499	user3499@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3500	Jinyeong	Matsarina	KOBIETA	user3500	user3500@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3501	Tymoteusz	Kiedrowski	MEZCZYZNA	user3501	user3501@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3502	Soniia	Sotkiewicz	KOBIETA	user3502	user3502@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3503	Sulika	Piędzio	KOBIETA	user3503	user3503@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3504	Ching-yi	Bessas	KOBIETA	user3504	user3504@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3505	Georgios	Kazhibekova	KOBIETA	user3505	user3505@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3506	Sarabjit	Raznomotova	KOBIETA	user3506	user3506@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3507	Łucjan	Specjał	MEZCZYZNA	user3507	user3507@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3508	Wisław	Kała	MEZCZYZNA	user3508	user3508@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3509	Mikeila	Tochynska	KOBIETA	user3509	user3509@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3510	Bogumił	Djokić	MEZCZYZNA	user3510	user3510@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3511	Erla	Ahasiieva	KOBIETA	user3511	user3511@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3512	Mohita	Trzemeska	KOBIETA	user3512	user3512@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3513	Sobiesław	Opuszko	MEZCZYZNA	user3513	user3513@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3514	Dargosław	Rosochacki	MEZCZYZNA	user3514	user3514@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3515	Magdalena	Kostarenko	KOBIETA	user3515	user3515@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3516	Pujitha	Szczekutowska	KOBIETA	user3516	user3516@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3517	Przybysław	Auksztulewicz	MEZCZYZNA	user3517	user3517@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3518	Dajmir	Olewicz	MEZCZYZNA	user3518	user3518@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3519	Leokadiusz	Brzozowiec	MEZCZYZNA	user3519	user3519@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3520	Wolimir	Woch	MEZCZYZNA	user3520	user3520@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3521	Nusaiba	Guion	KOBIETA	user3521	user3521@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3522	Iclal	Jungowska	KOBIETA	user3522	user3522@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3523	Nathali	Chkhaberidze	KOBIETA	user3523	user3523@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3524	Daeun	Dryhel	KOBIETA	user3524	user3524@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3525	Alwin	Metys	MEZCZYZNA	user3525	user3525@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3526	Justynian	Niemiec	MEZCZYZNA	user3526	user3526@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3527	Eren	Kica	KOBIETA	user3527	user3527@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3528	Rashmi	Mioduchowski	KOBIETA	user3528	user3528@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3529	Radzimir	Murgas	MEZCZYZNA	user3529	user3529@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3530	Tulimierz	Maćków	MEZCZYZNA	user3530	user3530@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3531	Le mai	Groeger	KOBIETA	user3531	user3531@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3532	Vivianne	Szwabo	KOBIETA	user3532	user3532@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3533	Rishika	Wełeszczuk	KOBIETA	user3533	user3533@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3534	Napoleon	Czepalla	MEZCZYZNA	user3534	user3534@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3535	Merry	Savyuk	KOBIETA	user3535	user3535@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3536	Mutsa	Azevedo	KOBIETA	user3536	user3536@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3537	Dżamil	Belous	MEZCZYZNA	user3537	user3537@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3538	Rehema	Gnat	KOBIETA	user3538	user3538@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3539	Ellada	Grawińska	KOBIETA	user3539	user3539@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3540	Polikarp	Wawryków	MEZCZYZNA	user3540	user3540@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3541	Diamond	Schamara	KOBIETA	user3541	user3541@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3542	Yeyheniia	Brozzio	KOBIETA	user3542	user3542@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3543	Jurate	Omieljaniuk	KOBIETA	user3543	user3543@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3544	Ana-marija	Trapieznikova	KOBIETA	user3544	user3544@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3545	Hathairat	Danelczyk	KOBIETA	user3545	user3545@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3546	Rosilia	Kozyrievska	KOBIETA	user3546	user3546@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3547	Lubogost	Izdebski	MEZCZYZNA	user3547	user3547@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3548	Nhàn	Chmielniok	KOBIETA	user3548	user3548@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3549	Otokar	Mekin	MEZCZYZNA	user3549	user3549@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3550	Himanshi	Allangba	KOBIETA	user3550	user3550@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3551	Walerian	Rykowski	MEZCZYZNA	user3551	user3551@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3552	Carmina	Grafl	KOBIETA	user3552	user3552@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3553	Letosława	Kolianyk	KOBIETA	user3553	user3553@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3554	Fredelyn	Bytner	KOBIETA	user3554	user3554@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3555	Namika	Gepner	NIEOKRESLONY	user3555	user3555@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3556	Iwan	Maścidło	MEZCZYZNA	user3556	user3556@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3557	Juri	Teliuk	MEZCZYZNA	user3557	user3557@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3558	Hoarik	Guzman romero	KOBIETA	user3558	user3558@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3559	Harlyn	Juryca	KOBIETA	user3559	user3559@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3560	Miłobąd	Paluchowski	MEZCZYZNA	user3560	user3560@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3561	Zhiyi	Monzon	KOBIETA	user3561	user3561@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3562	Nefeli	Godziek-wróbel	KOBIETA	user3562	user3562@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3563	Lilit	Nabukhotna	KOBIETA	user3563	user3563@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3564	Taghreed	Turlova	KOBIETA	user3564	user3564@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3565	Jan	Harasymiak	MEZCZYZNA	user3565	user3565@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3566	Zemzem	Karwowska-sowa	KOBIETA	user3566	user3566@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3567	Andrzej	Kazio	MEZCZYZNA	user3567	user3567@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3568	Kunduz	Sukholotiuk	KOBIETA	user3568	user3568@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3569	Ilgama	Prystup	KOBIETA	user3569	user3569@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3570	Lubisław	Wojskowicz	MEZCZYZNA	user3570	user3570@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3571	Mirela-rebeca	Luiza	KOBIETA	user3571	user3571@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3572	Dariusz	Skuciński	MEZCZYZNA	user3572	user3572@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3573	Dżan	Szulencki	MEZCZYZNA	user3573	user3573@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3574	Czanita	Valenzuela terskikh	KOBIETA	user3574	user3574@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3575	Cichosław	Ochała	MEZCZYZNA	user3575	user3575@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3576	Salomon	Relewicz	MEZCZYZNA	user3576	user3576@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3577	Wrocisław	Kocięcki	MEZCZYZNA	user3577	user3577@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3578	Iwan	Lindenau	MEZCZYZNA	user3578	user3578@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3579	Cimen	Niedzbala	KOBIETA	user3579	user3579@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3580	Lihua	Wakowska	KOBIETA	user3580	user3580@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3581	Godfryg	Tyburowski	MEZCZYZNA	user3581	user3581@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3582	Jarosław	Majder	MEZCZYZNA	user3582	user3582@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3583	Cherry	Söth-kovács	KOBIETA	user3583	user3583@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3584	Amnat	Luebek	KOBIETA	user3584	user3584@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3585	Remigiusz	Powąska	MEZCZYZNA	user3585	user3585@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3586	Foteini	Mihăilă	KOBIETA	user3586	user3586@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3587	Zhanneta	Grabik	KOBIETA	user3587	user3587@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3588	Sibylle	Yushmanova	KOBIETA	user3588	user3588@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3589	Suci	Karkosch	KOBIETA	user3589	user3589@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3590	Xiaoxi	Merek	KOBIETA	user3590	user3590@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3591	Netsai	Seliievska	KOBIETA	user3591	user3591@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3592	Dilupa	Wegs	KOBIETA	user3592	user3592@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3593	Bogumił	Wikierak	MEZCZYZNA	user3593	user3593@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3594	Sulibor	Sewroza	MEZCZYZNA	user3594	user3594@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3595	Teodor	Bronakowski	MEZCZYZNA	user3595	user3595@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3596	Trisha	Tomalia	KOBIETA	user3596	user3596@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3597	Muyassar	Ziołkiewicz	KOBIETA	user3597	user3597@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3598	Tyanna	Wejkszner	KOBIETA	user3598	user3598@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3599	Gyulyumser	Butusina	KOBIETA	user3599	user3599@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3600	Loda	Siverina	KOBIETA	user3600	user3600@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3601	Ewald	Kazaryn	MEZCZYZNA	user3601	user3601@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3602	Zenon	Reichelt	MEZCZYZNA	user3602	user3602@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3603	Ni kadek dwi	Krupp	KOBIETA	user3603	user3603@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3604	Agda	Kozynna	KOBIETA	user3604	user3604@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3605	Firehiwot	Batsyk	KOBIETA	user3605	user3605@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3606	Chaeyoung	Arbaoui	KOBIETA	user3606	user3606@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3607	Diala	Popowicz-wójcik	KOBIETA	user3607	user3607@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3608	Ludmił	Joks	MEZCZYZNA	user3608	user3608@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3609	Ajdin	Bielada	MEZCZYZNA	user3609	user3609@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3610	Ayelet	Drandar	KOBIETA	user3610	user3610@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3611	Tytus	Makles	MEZCZYZNA	user3611	user3611@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3612	Yolanta	Birkouskaya	KOBIETA	user3612	user3612@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3613	Paula daniela	Brace-day	KOBIETA	user3613	user3613@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3614	Marek	Świętoń	MEZCZYZNA	user3614	user3614@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3615	Eligiusz	Poździk	MEZCZYZNA	user3615	user3615@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3616	Zhiqing	Dzhavliuk	KOBIETA	user3616	user3616@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3617	Efrem	Kustosz	MEZCZYZNA	user3617	user3617@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3618	Sędomir	Święcicki	MEZCZYZNA	user3618	user3618@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3619	Tytus	Jaszkowski	MEZCZYZNA	user3619	user3619@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3620	Omar	Błazik	MEZCZYZNA	user3620	user3620@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3621	Gwidon	Pratkowski	MEZCZYZNA	user3621	user3621@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3622	Dymitr	Laryś	MEZCZYZNA	user3622	user3622@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3623	Cyryl	Ligor	MEZCZYZNA	user3623	user3623@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3624	Ireneusz	Hihs	MEZCZYZNA	user3624	user3624@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3625	Srushti	Krogulewska	KOBIETA	user3625	user3625@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3626	Albrecht	Sabastyn	MEZCZYZNA	user3626	user3626@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3627	Marilina	Riedle	KOBIETA	user3627	user3627@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3628	Andrzej	Mamczarek	MEZCZYZNA	user3628	user3628@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3629	Jessica lorena	Miklósová	KOBIETA	user3629	user3629@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3630	Bożan	Wołodźko	MEZCZYZNA	user3630	user3630@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3631	Teobald	Paśnikowski	MEZCZYZNA	user3631	user3631@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3632	Adeltrauta	Poleńska	KOBIETA	user3632	user3632@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3633	Kitija	Jabłońska-paluch	KOBIETA	user3633	user3633@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3634	Hanah	Kalidub	KOBIETA	user3634	user3634@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3635	Diviya	Nowak-stańczyk	KOBIETA	user3635	user3635@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3636	Marceli	Dryniak	MEZCZYZNA	user3636	user3636@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3637	Atiye	Slabyk	KOBIETA	user3637	user3637@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3638	Różanna	Trelina	KOBIETA	user3638	user3638@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3639	Roch	Tokarzewski	MEZCZYZNA	user3639	user3639@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3640	Arkady	Markowicz	MEZCZYZNA	user3640	user3640@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3641	Łazarz	Drachal	MEZCZYZNA	user3641	user3641@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3642	Jonatan	Peljan	MEZCZYZNA	user3642	user3642@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3643	Draupadi	Smaglyuk	KOBIETA	user3643	user3643@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3644	Amirah	Parvin	KOBIETA	user3644	user3644@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3645	Bolelut	Garniewski	MEZCZYZNA	user3645	user3645@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3646	Serafin	Szeja	MEZCZYZNA	user3646	user3646@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3647	Zbigniewa	Choćko	KOBIETA	user3647	user3647@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3648	Marike	Skottki	KOBIETA	user3648	user3648@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3649	Otniel	Zaprzał	MEZCZYZNA	user3649	user3649@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3650	Hektor	Spiż	MEZCZYZNA	user3650	user3650@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3651	Miłowan	Woroszczuk	MEZCZYZNA	user3651	user3651@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3652	Erazm	Ściebura	MEZCZYZNA	user3652	user3652@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3653	Urania	Nowak-sroka	KOBIETA	user3653	user3653@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3654	Wierzchosława	Hale	KOBIETA	user3654	user3654@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3655	Sławomierz	Mamełka	MEZCZYZNA	user3655	user3655@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3656	Maurycy	Smit	MEZCZYZNA	user3656	user3656@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3657	Bolesław	Zejdlewicz	MEZCZYZNA	user3657	user3657@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3658	Kacper	Bartko	MEZCZYZNA	user3658	user3658@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3659	Damian	Wylota	MEZCZYZNA	user3659	user3659@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3660	Maciej	Kosubek	MEZCZYZNA	user3660	user3660@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3661	Bernadia	Karandash	KOBIETA	user3661	user3661@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3662	Jiamiao	Moirinho	KOBIETA	user3662	user3662@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3663	Ranjitha	Dorynek	KOBIETA	user3663	user3663@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3664	Rei	Winiczeńko	KOBIETA	user3664	user3664@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3665	Dobrosław	Kościołowski	MEZCZYZNA	user3665	user3665@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3666	Stanisław	Mojsym	MEZCZYZNA	user3666	user3666@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3667	Bożimir	Stańczy	MEZCZYZNA	user3667	user3667@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3668	Świętosława	Bzoza	KOBIETA	user3668	user3668@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3669	Jaromir	Doniec	MEZCZYZNA	user3669	user3669@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3670	Jaropełk	Mikuta	MEZCZYZNA	user3670	user3670@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3671	Ezaw	Pucel	MEZCZYZNA	user3671	user3671@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3672	Blanca	Drzeżdzon	KOBIETA	user3672	user3672@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3673	Kryspin	Wichman	MEZCZYZNA	user3673	user3673@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3674	Deicy	Kałon	KOBIETA	user3674	user3674@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3675	Kochan	Lesicz	MEZCZYZNA	user3675	user3675@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3676	Jueun	Pakh	KOBIETA	user3676	user3676@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3677	Pompul	Vandiak	KOBIETA	user3677	user3677@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3678	Derwit	Leja	MEZCZYZNA	user3678	user3678@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3679	Kunduz	Mazurava	KOBIETA	user3679	user3679@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3680	Mściwoj	Rikitatt	MEZCZYZNA	user3680	user3680@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3681	Minaya	Wawerla	KOBIETA	user3681	user3681@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3682	Albrecht	Trompeta	MEZCZYZNA	user3682	user3682@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3683	Tolisława	Chorążeczewska	KOBIETA	user3683	user3683@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3684	Rajner	Niedurny	MEZCZYZNA	user3684	user3684@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3685	Zygfryd	Rygielski	MEZCZYZNA	user3685	user3685@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3686	Gemma	Bance	KOBIETA	user3686	user3686@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3687	Godzisław	Miedza	MEZCZYZNA	user3687	user3687@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3688	Buse nur	Bołdowicz	KOBIETA	user3688	user3688@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3689	Donald	Nowoświatłowski	MEZCZYZNA	user3689	user3689@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3690	Ninela	Klimiec	KOBIETA	user3690	user3690@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3691	Achilles	Blama	MEZCZYZNA	user3691	user3691@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3692	Thị anh ðào	Podliuk	KOBIETA	user3692	user3692@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3693	Salatin	Walerska	KOBIETA	user3693	user3693@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3694	Jan	Krążyński	MEZCZYZNA	user3694	user3694@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3695	Rajner	Ołowski	MEZCZYZNA	user3695	user3695@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3696	Walid	Skrucha	MEZCZYZNA	user3696	user3696@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3697	Yuqiao	Wojskonowicz	KOBIETA	user3697	user3697@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3698	Yongqin	Khviadchenia	KOBIETA	user3698	user3698@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3699	Ezel	Śledziona	KOBIETA	user3699	user3699@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3700	Ferdynand	Wraga	MEZCZYZNA	user3700	user3700@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3701	Yuexin	Harbich	KOBIETA	user3701	user3701@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3702	Budzisław	Piorunkiewicz	MEZCZYZNA	user3702	user3702@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3703	Inocenty	Lecjan	MEZCZYZNA	user3703	user3703@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3704	Sakura	Fudalla	KOBIETA	user3704	user3704@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3705	Celestyn	Pokrandt	MEZCZYZNA	user3705	user3705@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3706	Eugeniusz	Gałdyński	MEZCZYZNA	user3706	user3706@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3707	Witold	Haliasz	MEZCZYZNA	user3707	user3707@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3708	Aleksy	Mąkowski	MEZCZYZNA	user3708	user3708@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3709	Munavar	Jeżychowska	KOBIETA	user3709	user3709@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3710	Modest	Serwinowski	MEZCZYZNA	user3710	user3710@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3711	Katrīna	Guidetti	KOBIETA	user3711	user3711@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3712	Sław	Gogulewicz	MEZCZYZNA	user3712	user3712@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3713	Chance	Nasiedkina	KOBIETA	user3713	user3713@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3714	Hugon	Hrywniak	MEZCZYZNA	user3714	user3714@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3715	Radzimir	Budziarek	MEZCZYZNA	user3715	user3715@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3716	Marcin	Kuczerski	MEZCZYZNA	user3716	user3716@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3717	Dongxia	Convery	KOBIETA	user3717	user3717@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3718	Zygmunt	Żukowski	MEZCZYZNA	user3718	user3718@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3719	Mažena	Radominska	KOBIETA	user3719	user3719@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3720	İrem	Miezancew	KOBIETA	user3720	user3720@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3721	Robert	Suchta	MEZCZYZNA	user3721	user3721@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3722	Medna	El hamzaoui	KOBIETA	user3722	user3722@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3723	Odetta	Dranha	KOBIETA	user3723	user3723@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3724	Maryn	Opoczyński	MEZCZYZNA	user3724	user3724@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3725	Mikołaj	Gieczewski	MEZCZYZNA	user3725	user3725@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3726	Żelisława	Możdzyńska	KOBIETA	user3726	user3726@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3727	Natanael	Michnicki	MEZCZYZNA	user3727	user3727@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3728	Weirong	Jarzmus	KOBIETA	user3728	user3728@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3729	Cǎtǎlina	Deringer	KOBIETA	user3729	user3729@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3730	Anastazy	Saik	MEZCZYZNA	user3730	user3730@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3731	Dzhenet	Soryl	KOBIETA	user3731	user3731@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3732	Starwit	Cymiński	MEZCZYZNA	user3732	user3732@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3733	Agapit	Bodzęta	MEZCZYZNA	user3733	user3733@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3734	Ludowit	Liszkowski	MEZCZYZNA	user3734	user3734@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3735	Saide	Maziarz	KOBIETA	user3735	user3735@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3736	Zynoviia	Hejnicka	KOBIETA	user3736	user3736@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3737	Rucha	Busuioc	NIEOKRESLONY	user3737	user3737@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3738	Anastazy	Łuczeńczyk	MEZCZYZNA	user3738	user3738@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3739	Zohal	Tiba	KOBIETA	user3739	user3739@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3740	Juri	Staromiejski	MEZCZYZNA	user3740	user3740@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3741	Huriye	Wełnowska	KOBIETA	user3741	user3741@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3742	Bi̇llur	Sisca	KOBIETA	user3742	user3742@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3743	Świętomir	Lepszonek	MEZCZYZNA	user3743	user3743@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3744	Tsitsidzashe	Lussek	KOBIETA	user3744	user3744@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3745	Asmina	Widkowska	KOBIETA	user3745	user3745@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3746	Pratha	Bukushyan	KOBIETA	user3746	user3746@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3747	Ogulnabat	Faifor	KOBIETA	user3747	user3747@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3748	Ryszard	Porzycki	MEZCZYZNA	user3748	user3748@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3749	Żasmin	Demerji	KOBIETA	user3749	user3749@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3750	Maurycy	Pierzchliński	MEZCZYZNA	user3750	user3750@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3751	Strzeżymir	Pigulak	MEZCZYZNA	user3751	user3751@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3752	Romane	Semeniuta	KOBIETA	user3752	user3752@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3753	Maia-sonia	Mccloskey	KOBIETA	user3753	user3753@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3754	Otton	Puczyński	MEZCZYZNA	user3754	user3754@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3755	Magnus	Falk	MEZCZYZNA	user3755	user3755@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3756	Yarmila	Yemielianova	KOBIETA	user3756	user3756@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3757	Norman	Rebiger	MEZCZYZNA	user3757	user3757@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3758	Annasz	Kurzątkowski	MEZCZYZNA	user3758	user3758@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3759	Stanisław	Misikonis	MEZCZYZNA	user3759	user3759@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3760	Dawid	Szmytke	MEZCZYZNA	user3760	user3760@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3761	Magnus	Król	MEZCZYZNA	user3761	user3761@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3762	Witosław	Żyśko	MEZCZYZNA	user3762	user3762@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3763	Lew	Kałaniuk	MEZCZYZNA	user3763	user3763@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3764	Dobrosław	Dulnik	MEZCZYZNA	user3764	user3764@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3765	Paskal	Bosiakowski	MEZCZYZNA	user3765	user3765@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3766	Miron	Łopiński	MEZCZYZNA	user3766	user3766@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3767	Ryszard	Niegosz	MEZCZYZNA	user3767	user3767@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3768	Alpha	Gryżwald	KOBIETA	user3768	user3768@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3769	Haeeun	Godzic	KOBIETA	user3769	user3769@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3770	Wincenty	Gasek	MEZCZYZNA	user3770	user3770@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3771	Walter	Osesiak	MEZCZYZNA	user3771	user3771@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3772	Henryk	Frahs	MEZCZYZNA	user3772	user3772@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3773	Serwacy	Reiwer	MEZCZYZNA	user3773	user3773@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3774	Agnès	Senczak	KOBIETA	user3774	user3774@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3775	Ruchama	Chetak	KOBIETA	user3775	user3775@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3776	Gülbahar	Mato	KOBIETA	user3776	user3776@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3777	Shuqin	Neil	KOBIETA	user3777	user3777@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3778	Fabian	Joryn	MEZCZYZNA	user3778	user3778@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3779	Sarangerel	Gątaszewska	KOBIETA	user3779	user3779@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3780	Witold	Lotko	MEZCZYZNA	user3780	user3780@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3781	Jełyzaweta	Zykin	KOBIETA	user3781	user3781@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3782	Roch	Szulce	MEZCZYZNA	user3782	user3782@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3783	Christianne	Ksztoń	KOBIETA	user3783	user3783@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3784	Szymon	Samkowicz	MEZCZYZNA	user3784	user3784@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3785	Tharani	Haziri	KOBIETA	user3785	user3785@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3786	Mehrangez	Mieszkało	KOBIETA	user3786	user3786@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3787	Robert	Janczak	MEZCZYZNA	user3787	user3787@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3788	Nasif	Mazurak	MEZCZYZNA	user3788	user3788@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3789	Sławiana	Chrzanowska-kozak	KOBIETA	user3789	user3789@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3790	Bonawentura	Wolnic	MEZCZYZNA	user3790	user3790@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3791	Elida	Antoshynska	KOBIETA	user3791	user3791@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3792	Ksawery	Demboryński	MEZCZYZNA	user3792	user3792@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3793	Gabriel	Redo	MEZCZYZNA	user3793	user3793@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3794	Gościsław	Dziewanowski	MEZCZYZNA	user3794	user3794@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3795	Bogdan	Korzela	MEZCZYZNA	user3795	user3795@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3796	Bartłomiej	Ligus	MEZCZYZNA	user3796	user3796@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3797	Visola	Konikova	KOBIETA	user3797	user3797@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3798	Natthanicha	Ditman	KOBIETA	user3798	user3798@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3799	Malachiasz	Szlapiński	MEZCZYZNA	user3799	user3799@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3800	Dobiesław	Ayariğ	MEZCZYZNA	user3800	user3800@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3801	Modest	Bubółka	MEZCZYZNA	user3801	user3801@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3802	Radosław	Pacheco-śledź	MEZCZYZNA	user3802	user3802@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3803	Eugeniusz	Śmiglewski	MEZCZYZNA	user3803	user3803@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3804	Leokrycja	Czupernaty	KOBIETA	user3804	user3804@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3805	Nadyia	Dottin	KOBIETA	user3805	user3805@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3806	Majola	Podenas	KOBIETA	user3806	user3806@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3807	Yenny andrea	Reilian	KOBIETA	user3807	user3807@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3808	January	Bartkowski	MEZCZYZNA	user3808	user3808@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3809	Justyn	Wojcięga	MEZCZYZNA	user3809	user3809@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3810	Roland	Susek	MEZCZYZNA	user3810	user3810@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3811	Baldwin	Semetkowski	MEZCZYZNA	user3811	user3811@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3812	Franciszek	Krzymański	MEZCZYZNA	user3812	user3812@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3813	Miłowan	Sieńkowski	MEZCZYZNA	user3813	user3813@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3814	Antoni	Szarowski	MEZCZYZNA	user3814	user3814@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3815	Wiesław	Kotfica	MEZCZYZNA	user3815	user3815@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3816	Soyeon	Hartabuz	KOBIETA	user3816	user3816@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3817	Lucile	Rzewiczok	KOBIETA	user3817	user3817@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3818	Carolaine	Kaszkarot	KOBIETA	user3818	user3818@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3819	Fortunat	Smarkusz	MEZCZYZNA	user3819	user3819@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3820	Julian	Zbysiński	MEZCZYZNA	user3820	user3820@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3821	Miłowan	Eberchard	MEZCZYZNA	user3821	user3821@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3822	Władysław	Magusiak	MEZCZYZNA	user3822	user3822@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3823	Symeon	Chybicki	MEZCZYZNA	user3823	user3823@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3824	Jinzhi	Scripcari	KOBIETA	user3824	user3824@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3825	Vinitha	Komisarczyk	KOBIETA	user3825	user3825@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3826	Gretta	Antipkina	KOBIETA	user3826	user3826@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3827	Zarife	Lassotta	KOBIETA	user3827	user3827@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3828	Lechosław	Agha	MEZCZYZNA	user3828	user3828@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3829	Quyên	Satvaldiieva	KOBIETA	user3829	user3829@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3830	Godzisław	Badawika	MEZCZYZNA	user3830	user3830@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3831	Alesia-sara	Heisig	KOBIETA	user3831	user3831@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3832	Łazarz	Bubrzycki	MEZCZYZNA	user3832	user3832@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3833	Ezaw	Ciok	MEZCZYZNA	user3833	user3833@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3834	Dargomir	Arabas	MEZCZYZNA	user3834	user3834@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3835	Bogumir	Cieleń	MEZCZYZNA	user3835	user3835@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3836	Sulaf	Posiej	KOBIETA	user3836	user3836@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3837	Ebenezer	Sztalinger	KOBIETA	user3837	user3837@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3838	Jessielyn	Krypytsia	KOBIETA	user3838	user3838@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3839	Mściwoj	Stawski	MEZCZYZNA	user3839	user3839@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3840	Symeon	Marczewski	MEZCZYZNA	user3840	user3840@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3841	Roch	Sobierski	MEZCZYZNA	user3841	user3841@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3842	Darwit	Sławek	MEZCZYZNA	user3842	user3842@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3843	Chwalimir	Merdalski	MEZCZYZNA	user3843	user3843@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3844	Bara	Tsyro	KOBIETA	user3844	user3844@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3845	Rajmund	Hrycak	MEZCZYZNA	user3845	user3845@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3846	Grazhyna	Sztój	KOBIETA	user3846	user3846@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3847	Mieczysław	Kraska	MEZCZYZNA	user3847	user3847@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3848	Mirosław	Bródka	MEZCZYZNA	user3848	user3848@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3849	Leyan	Paschenko	KOBIETA	user3849	user3849@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3850	Angielina	Bartoniczek	KOBIETA	user3850	user3850@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3851	Zdzisław	Wyszywacz	MEZCZYZNA	user3851	user3851@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3852	Niecisław	Turziak	MEZCZYZNA	user3852	user3852@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3853	Jozafat	Wałuszko	MEZCZYZNA	user3853	user3853@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3854	Lyailigul	Tauschnik	KOBIETA	user3854	user3854@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3855	Włodzimierz	Rycio	MEZCZYZNA	user3855	user3855@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3856	Līva	Chornomaz	KOBIETA	user3856	user3856@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3857	Dorian	Guryniuk	MEZCZYZNA	user3857	user3857@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3858	Walenty	Ilczuk	MEZCZYZNA	user3858	user3858@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3859	Darika	Walaszko	KOBIETA	user3859	user3859@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3860	Mandeep kaur	Zigmanska	KOBIETA	user3860	user3860@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3861	Gniewomir	Pantelemoniuk	MEZCZYZNA	user3861	user3861@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3863	Anishka	Helnik	KOBIETA	user3863	user3863@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3864	Bartosz	Kocyła	MEZCZYZNA	user3864	user3864@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3865	Immaculee	Manoch	NIEOKRESLONY	user3865	user3865@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3866	Miłosz	Rzepnikowski	MEZCZYZNA	user3866	user3866@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3867	Presilla	Yanchurevich	KOBIETA	user3867	user3867@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3868	Anusha	Dukhnovska	KOBIETA	user3868	user3868@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3869	Belinda	Gorgoń-butt	KOBIETA	user3869	user3869@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3870	Maria de los milagros	Korpok	KOBIETA	user3870	user3870@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3871	Thanh loan	Rabkovska	KOBIETA	user3871	user3871@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3872	Assi	Fishman faingezicht	KOBIETA	user3872	user3872@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3873	Muyao	Horpinchenko	KOBIETA	user3873	user3873@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3874	Andrzej	Łopaciński	MEZCZYZNA	user3874	user3874@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3875	Thu	Hörl	KOBIETA	user3875	user3875@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3876	Enkhzaya	Nikolan	KOBIETA	user3876	user3876@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3877	Ghufran	Yarokhava	KOBIETA	user3877	user3877@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3878	Geovanna	Chróściel	KOBIETA	user3878	user3878@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3879	Yelyzavieta	Ormicka	KOBIETA	user3879	user3879@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3880	Ixchel	Maclean	KOBIETA	user3880	user3880@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3881	Ambika	Chernitsyna	KOBIETA	user3881	user3881@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3882	Ewaryst	Bojaronus	MEZCZYZNA	user3882	user3882@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3883	Anastazy	Puzio	MEZCZYZNA	user3883	user3883@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3884	Wielisław	Krawczewski	MEZCZYZNA	user3884	user3884@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3885	Kaili	Ruggi	KOBIETA	user3885	user3885@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3886	Selmeg	Kukiołka	KOBIETA	user3886	user3886@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3887	Myong sun	Kiplagat	KOBIETA	user3887	user3887@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3888	Gracjan	Ogrodniczak	MEZCZYZNA	user3888	user3888@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3889	Thị ngoan	Krempeć	KOBIETA	user3889	user3889@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3890	Leonard	Jędryczko	MEZCZYZNA	user3890	user3890@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3891	Henryk	Węglarczyk	MEZCZYZNA	user3891	user3891@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3892	Marie-héléne	Zachęś	KOBIETA	user3892	user3892@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3893	Teli	Górska-kluk	KOBIETA	user3893	user3893@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3894	Kenda	Chopyk	KOBIETA	user3894	user3894@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3895	Virginia	Pytelkowska	KOBIETA	user3895	user3895@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3896	Aliaa	Yohros	KOBIETA	user3896	user3896@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3897	January	Żaguń	MEZCZYZNA	user3897	user3897@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3898	Alexandra-maria	Sztenderska	KOBIETA	user3898	user3898@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3899	Muna	Miliukina	KOBIETA	user3899	user3899@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3900	Miłomir	Koziarski	MEZCZYZNA	user3900	user3900@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3901	Arkady	Schiwon	MEZCZYZNA	user3901	user3901@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3902	Tobiasz	Barczyński	MEZCZYZNA	user3902	user3902@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3903	Pratima	Biesialska	KOBIETA	user3903	user3903@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3904	Olimpiada	Kwiatkowska-sienkiewicz	KOBIETA	user3904	user3904@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3905	Kasjusz	Wieczosek	MEZCZYZNA	user3905	user3905@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3906	Radomił	Kołodziejek	MEZCZYZNA	user3906	user3906@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3907	Justyn	Kępowicz	MEZCZYZNA	user3907	user3907@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3908	Bogdał	Smoluch	MEZCZYZNA	user3908	user3908@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3909	Nurzat	Knaerkegaard	KOBIETA	user3909	user3909@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3910	Sandomira	Janiszewska	KOBIETA	user3910	user3910@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3911	Ireneusz	Lasiewicz	MEZCZYZNA	user3911	user3911@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3912	Xenia	Skavinska	KOBIETA	user3912	user3912@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3913	Patrycjusz	Lashmann	MEZCZYZNA	user3913	user3913@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3914	Anna-bozhena	Kryvchun	KOBIETA	user3914	user3914@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3915	Metody	Tepner	MEZCZYZNA	user3915	user3915@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3916	Wespazjan	Kałamucki	MEZCZYZNA	user3916	user3916@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3917	Maresa	Kirsztejn	KOBIETA	user3917	user3917@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3918	Syriusz	Szafirowski	MEZCZYZNA	user3918	user3918@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3919	Kochan	Oczkowski	MEZCZYZNA	user3919	user3919@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3920	Mimma	Obalewska	KOBIETA	user3920	user3920@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3921	Jacek	Popielewicz	MEZCZYZNA	user3921	user3921@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3922	Tohar	Podorozhnya	KOBIETA	user3922	user3922@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3923	Iwan	Wykrzykowski	MEZCZYZNA	user3923	user3923@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3924	Undarmaa	Ikumla	KOBIETA	user3924	user3924@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3925	Serhieieva	Shulman	KOBIETA	user3925	user3925@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3926	Jonasz	Polaków	MEZCZYZNA	user3926	user3926@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3927	Savina	Orzeszko	NIEOKRESLONY	user3927	user3927@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3928	Roch	Frączek	MEZCZYZNA	user3928	user3928@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3929	Eliot	Bordonos	MEZCZYZNA	user3929	user3929@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3930	Śnieżana	Capowicz	KOBIETA	user3930	user3930@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3931	Agapit	Gómułka	MEZCZYZNA	user3931	user3931@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3932	Suchana	Radkova	KOBIETA	user3932	user3932@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3933	Gökçen	Hadziura	KOBIETA	user3933	user3933@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3934	Giulu	Krejner	KOBIETA	user3934	user3934@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3935	Dolly	Czeżniewska	KOBIETA	user3935	user3935@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3936	Więcesław	Żaczyk	MEZCZYZNA	user3936	user3936@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3937	Nara	Kucmin	KOBIETA	user3937	user3937@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3938	Roman	Cymanow	MEZCZYZNA	user3938	user3938@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3939	Hagar	Revak	KOBIETA	user3939	user3939@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3940	Milan	Sakłaski	MEZCZYZNA	user3940	user3940@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3941	Oktawian	Deon	MEZCZYZNA	user3941	user3941@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3942	Karol	Węgrzyn	MEZCZYZNA	user3942	user3942@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3943	Ioulietta	Kujk	KOBIETA	user3943	user3943@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3944	Samila	Bregu	KOBIETA	user3944	user3944@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3945	Jeanetta	Kreshtel	KOBIETA	user3945	user3945@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3946	Napoleon	Musialski	MEZCZYZNA	user3946	user3946@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3947	Zsuzsánna	Radlowski	KOBIETA	user3947	user3947@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3948	Romuald	Nestorowicz	MEZCZYZNA	user3948	user3948@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3949	Serafin	Skrago	MEZCZYZNA	user3949	user3949@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3950	Eun ji	Peltek	KOBIETA	user3950	user3950@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3951	Jaia	Moog	KOBIETA	user3951	user3951@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3952	Elmaz	Sodorska	KOBIETA	user3952	user3952@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3953	Thu hà	Chemij	KOBIETA	user3953	user3953@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3954	Soni	Razzhyvina	KOBIETA	user3954	user3954@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3955	Roman	Olekszyk	MEZCZYZNA	user3955	user3955@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3956	Graziela	Tsalai	KOBIETA	user3956	user3956@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3957	Letisja	Szur	KOBIETA	user3957	user3957@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3958	Dymitr	Jurenczyk	MEZCZYZNA	user3958	user3958@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3959	Belkys	Sodo	KOBIETA	user3959	user3959@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3960	Thoa	Waclawczyk	KOBIETA	user3960	user3960@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3961	Hermes	Chłopowiec	MEZCZYZNA	user3961	user3961@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3962	Leo	Nieboj-dunne	MEZCZYZNA	user3962	user3962@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3963	Sofiia-nikol	Selmeczi	KOBIETA	user3963	user3963@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3964	Vladylina	Nezhura	KOBIETA	user3964	user3964@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3965	Herbert	Szafratowicz	MEZCZYZNA	user3965	user3965@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3966	Indra maya	Suchanek-kowalska	KOBIETA	user3966	user3966@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3967	Lyazzat	Oliunina	KOBIETA	user3967	user3967@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3968	Ivy	Kovalchik	KOBIETA	user3968	user3968@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3969	Sebahat	Szpolorowska	KOBIETA	user3969	user3969@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3970	Anzelm	Jurzysta	MEZCZYZNA	user3970	user3970@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3971	Mattie	Hajziuk	KOBIETA	user3971	user3971@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3972	Jasuf	Dubiecki	MEZCZYZNA	user3972	user3972@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3973	Antonius	Łojewski	MEZCZYZNA	user3973	user3973@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3974	Więcesław	Strasz	MEZCZYZNA	user3974	user3974@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3975	Miłobąd	Pałysiński	MEZCZYZNA	user3975	user3975@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3976	Roch	Gutowski	MEZCZYZNA	user3976	user3976@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3977	Eira	Zherebak	KOBIETA	user3977	user3977@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3978	Rosłan	Strychała	MEZCZYZNA	user3978	user3978@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3979	Aniela	Maziieva	KOBIETA	user3979	user3979@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3980	Miaofen	Połom-rucka	NIEOKRESLONY	user3980	user3980@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3981	Szymon	Ogint	MEZCZYZNA	user3981	user3981@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3982	Milahres	Dincklage	KOBIETA	user3982	user3982@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3983	Edward	Krzesłowski	MEZCZYZNA	user3983	user3983@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3984	Pemika	Siekalska	KOBIETA	user3984	user3984@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3985	Yordanos	Sobott	KOBIETA	user3985	user3985@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3986	Teena	Prasoł	KOBIETA	user3986	user3986@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3987	Sław	Dziamałek	MEZCZYZNA	user3987	user3987@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3988	Kumsal	Antończak	KOBIETA	user3988	user3988@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3989	Damazy	Bielonko	MEZCZYZNA	user3989	user3989@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3990	Zacharula	Chuprii	KOBIETA	user3990	user3990@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3991	Betania	Plesiniak	KOBIETA	user3991	user3991@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3992	Davida	Męderowicz	KOBIETA	user3992	user3992@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3993	Belisima	Bołtacz	KOBIETA	user3993	user3993@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3994	Zygmunt	Rakszawa	MEZCZYZNA	user3994	user3994@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3995	Norita	Kupraszewicz	KOBIETA	user3995	user3995@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3996	Eliot	Szyndler	MEZCZYZNA	user3996	user3996@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3997	Lizelota	Sayfullina	KOBIETA	user3997	user3997@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3998	Roswitha	Szyliniec	KOBIETA	user3998	user3998@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
3999	Blossom	Sendyka	KOBIETA	user3999	user3999@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4000	Świętibor	Yildiz	MEZCZYZNA	user4000	user4000@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4001	Gwido	Sieczka	MEZCZYZNA	user4001	user4001@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4002	Leon	Cwietkow	MEZCZYZNA	user4002	user4002@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4003	Aleksander	Kijewski	MEZCZYZNA	user4003	user4003@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4004	Katerine	Florczak-synuś	KOBIETA	user4004	user4004@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4005	Oleksandriia	Nechaj	KOBIETA	user4005	user4005@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4006	Vaselyna	Vasilina	KOBIETA	user4006	user4006@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4007	Shaymaa	Sawatzka	KOBIETA	user4007	user4007@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4008	Budzisław	Gorczyński	MEZCZYZNA	user4008	user4008@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4009	Emil	Dubiński	MEZCZYZNA	user4009	user4009@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4010	Harshitha	Kemme	KOBIETA	user4010	user4010@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4011	Analine	Sakundiak	KOBIETA	user4011	user4011@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4012	Jazmin	Kusmider	KOBIETA	user4012	user4012@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4013	Jo	Bulatnik	KOBIETA	user4013	user4013@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4014	Miłosław	Dziergowski	MEZCZYZNA	user4014	user4014@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4015	Sedanur	Kałpowicz	KOBIETA	user4015	user4015@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4016	Joachim	Retmańczyk	MEZCZYZNA	user4016	user4016@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4017	Shokhsanam	Syżycka	KOBIETA	user4017	user4017@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4018	Florian	Skobliński	MEZCZYZNA	user4018	user4018@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4019	Luzie	Niemczynow	KOBIETA	user4019	user4019@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4020	Liudviha	Pervashova	KOBIETA	user4020	user4020@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4021	Władysław	Jasieniewicz	MEZCZYZNA	user4021	user4021@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4022	Zulpa	Yartsava	KOBIETA	user4022	user4022@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4023	Thao vy	Hrydina	KOBIETA	user4023	user4023@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4024	Jaromir	Dalmata	MEZCZYZNA	user4024	user4024@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4025	Nanu	Kuchmiak	KOBIETA	user4025	user4025@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4026	Ramandeep	Stetsova	KOBIETA	user4026	user4026@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4027	Rashmi	Cipta	KOBIETA	user4027	user4027@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4028	Damian	Meduna	MEZCZYZNA	user4028	user4028@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4029	Milan	Turkiewicz	MEZCZYZNA	user4029	user4029@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4030	Damazy	Żabrowski	MEZCZYZNA	user4030	user4030@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4031	Włodzimierz	Muszak	MEZCZYZNA	user4031	user4031@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4032	Ireneusz	Penski	MEZCZYZNA	user4032	user4032@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4033	Dariusz	Ochoński	MEZCZYZNA	user4033	user4033@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4034	Bakhyt	Jajówka	KOBIETA	user4034	user4034@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4035	Kondrat	Podlisiecki	MEZCZYZNA	user4035	user4035@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4036	Horacy	Holender	MEZCZYZNA	user4036	user4036@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4037	Wincenty	Jazowit	MEZCZYZNA	user4037	user4037@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4038	Clarisa	Tyzbierek	KOBIETA	user4038	user4038@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4039	Zygfryd	Jarząbski	MEZCZYZNA	user4039	user4039@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4040	Oswald	Rupa	MEZCZYZNA	user4040	user4040@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4041	Anitta	Lubicz-sienicka	KOBIETA	user4041	user4041@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4042	Jaybee	Korchanava	KOBIETA	user4042	user4042@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4043	Nasif	Hausner	MEZCZYZNA	user4043	user4043@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4044	Władysław	Graw	MEZCZYZNA	user4044	user4044@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4045	Sibele	Arabulova	KOBIETA	user4045	user4045@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4046	Gitla	Dziadoszek	KOBIETA	user4046	user4046@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4047	Ignacy	Grajda	MEZCZYZNA	user4047	user4047@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4048	Krystian	Hanack	MEZCZYZNA	user4048	user4048@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4049	August	Kopystyński	MEZCZYZNA	user4049	user4049@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4050	Ferdynand	Ochętal	MEZCZYZNA	user4050	user4050@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4051	Rudolf	Skliarenko	MEZCZYZNA	user4051	user4051@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4052	Benon	Marciniuk	MEZCZYZNA	user4052	user4052@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4053	Donat	Krzysztofiński	MEZCZYZNA	user4053	user4053@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4054	Hugon	Moczadło	MEZCZYZNA	user4054	user4054@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4055	Nhật	Dwurska	KOBIETA	user4055	user4055@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4056	Hanim	Neveshkina	KOBIETA	user4056	user4056@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4057	Ildefons	Kundt	MEZCZYZNA	user4057	user4057@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4058	Aeris	Ostrianko	KOBIETA	user4058	user4058@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4059	Tymoteusz	Oleszak	MEZCZYZNA	user4059	user4059@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4060	Marcel	Hulalka	MEZCZYZNA	user4060	user4060@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4061	Miłobąd	Ślebzak	MEZCZYZNA	user4061	user4061@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4062	Antoni	Żertka	MEZCZYZNA	user4062	user4062@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4063	Oleg	Bażan	MEZCZYZNA	user4063	user4063@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4064	Ellinor	Gudojć	NIEOKRESLONY	user4064	user4064@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4065	Świętomir	Topolski	MEZCZYZNA	user4065	user4065@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4066	Leopold	Biel	MEZCZYZNA	user4066	user4066@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4067	Wespazjan	Kwasowski	MEZCZYZNA	user4067	user4067@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4068	Naomi	Pandipati	KOBIETA	user4068	user4068@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4069	Miłosław	Łożewski	MEZCZYZNA	user4069	user4069@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4070	Zargan	Kirsten	KOBIETA	user4070	user4070@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4071	Lebogang	Respicio	KOBIETA	user4071	user4071@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4072	Nadie	Kyforenko	KOBIETA	user4072	user4072@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4073	Mirosław	Dratwiak	MEZCZYZNA	user4073	user4073@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4074	Lamya	Hanichenko	KOBIETA	user4074	user4074@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4075	Patryk	Pawłowiec	MEZCZYZNA	user4075	user4075@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4076	Domasław	Gucejt	MEZCZYZNA	user4076	user4076@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4077	Hubert	Pachnowski	MEZCZYZNA	user4077	user4077@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4078	Davida	Gamza	KOBIETA	user4078	user4078@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4079	Emilía	Fidryna	KOBIETA	user4079	user4079@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4080	Bibian	Malart	KOBIETA	user4080	user4080@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4081	Valentyna-viktoriia	Hromykhina	KOBIETA	user4081	user4081@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4082	Grzymisław	Brągiel	MEZCZYZNA	user4082	user4082@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4083	Narangarav	Masuku	KOBIETA	user4083	user4083@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4084	Jose	Rossynska	KOBIETA	user4084	user4084@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4085	Marcjan	Wielgos	MEZCZYZNA	user4085	user4085@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4086	Fruma	Świerczyńska-mucha	KOBIETA	user4086	user4086@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4087	Jacek	Majtczak	MEZCZYZNA	user4087	user4087@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4088	Licet	Masz	KOBIETA	user4088	user4088@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4089	Cedra	Kutycka	KOBIETA	user4089	user4089@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4090	Erwin	Chełmecki	MEZCZYZNA	user4090	user4090@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4091	Jacenty	Kryszczuk	MEZCZYZNA	user4091	user4091@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4092	Rinoa	Taroń	KOBIETA	user4092	user4092@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4093	Merete	Majchrzak-skibińska	KOBIETA	user4093	user4093@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4094	Stoigniew	Kociszewski	MEZCZYZNA	user4094	user4094@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4095	Idzi	Czerczuk	MEZCZYZNA	user4095	user4095@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4096	Wojciech	Wojtyczka	MEZCZYZNA	user4096	user4096@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4097	Estella	Panajotow	KOBIETA	user4097	user4097@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4098	Bogusław	Średniawski	MEZCZYZNA	user4098	user4098@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4099	Łucjan	Hubkowski	MEZCZYZNA	user4099	user4099@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4100	Wirgiliusz	Platków-gilewski	MEZCZYZNA	user4100	user4100@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4101	Amanat	Dalupiri	KOBIETA	user4101	user4101@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4102	Sorcha	Sarris	KOBIETA	user4102	user4102@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4103	Temi	Golnowska	KOBIETA	user4103	user4103@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4104	Maisa	Tierney	KOBIETA	user4104	user4104@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4105	Szvetlana	Veit	KOBIETA	user4105	user4105@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4106	Eugeniusz	Seidert	MEZCZYZNA	user4106	user4106@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4107	Alfred	Rzadkiewicz	MEZCZYZNA	user4107	user4107@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4108	Yirui	Sputek	KOBIETA	user4108	user4108@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4109	Metody	Chamczyk	MEZCZYZNA	user4109	user4109@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4110	Nily	Pozdniak	KOBIETA	user4110	user4110@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4111	Meiyu	Kukhtyk	KOBIETA	user4111	user4111@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4112	Yichao	Jonasz-obolewicz	KOBIETA	user4112	user4112@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4113	Aleksy	Grzesiński	MEZCZYZNA	user4113	user4113@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4114	Kamelia	Lunievska	KOBIETA	user4114	user4114@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4115	Daria-elena	Pikosz	KOBIETA	user4115	user4115@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4116	Stine	Iakobashvili	KOBIETA	user4116	user4116@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4117	Yeranuhi	Kryvoruchka	KOBIETA	user4117	user4117@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4118	Jędrzej	Daniłowski	MEZCZYZNA	user4118	user4118@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4119	Zenon	Kuśmierczyk	MEZCZYZNA	user4119	user4119@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4120	Przybysław	Tarara	MEZCZYZNA	user4120	user4120@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4121	Andzelina	Podkhaliuzina	KOBIETA	user4121	user4121@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4122	Edgar	Szustakiewicz	MEZCZYZNA	user4122	user4122@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4123	Nataniel	Rojczyk	MEZCZYZNA	user4123	user4123@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4124	Benon	Kłódka	MEZCZYZNA	user4124	user4124@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4125	Amaliya	Shafie	KOBIETA	user4125	user4125@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4126	Cecyl	Władyczka	MEZCZYZNA	user4126	user4126@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4127	Zdzisław	Schlichtholz	MEZCZYZNA	user4127	user4127@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4128	Antonin	Modrzyński	MEZCZYZNA	user4128	user4128@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4129	Oana-alina	Kolushkina	KOBIETA	user4129	user4129@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4130	Auriane	Kryworuka	KOBIETA	user4130	user4130@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4131	Maria angeles	Chaplianka	KOBIETA	user4131	user4131@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4132	Safija	Rialland	KOBIETA	user4132	user4132@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4133	Gereltuya	Byela	KOBIETA	user4133	user4133@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4134	Kasjusz	Rafeld	MEZCZYZNA	user4134	user4134@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4135	Leonard	Jatczuk	MEZCZYZNA	user4135	user4135@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4136	Reia	Adelheim	KOBIETA	user4136	user4136@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4137	Thi nhung	Gulakow	KOBIETA	user4137	user4137@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4138	Rafał	Łatka	MEZCZYZNA	user4138	user4138@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4139	Solomiia-oleksandra	Zrałczyk	KOBIETA	user4139	user4139@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4140	Sebastian	Chopcian	MEZCZYZNA	user4140	user4140@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4141	Yuxiao	Tumbas	KOBIETA	user4141	user4141@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4142	Fabian	Blak	MEZCZYZNA	user4142	user4142@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4143	Aleqsandra	Fiszgala	KOBIETA	user4143	user4143@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4144	Lucjan	Wieczerzyński	MEZCZYZNA	user4144	user4144@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4145	Leo	Sychla	MEZCZYZNA	user4145	user4145@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4146	Xiaoxia	Ciuperny	KOBIETA	user4146	user4146@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4147	Mikołaj	Łysagóra	MEZCZYZNA	user4147	user4147@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4148	Tadeusza	Hensetska	KOBIETA	user4148	user4148@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4149	Vasundhara	Khovanets	KOBIETA	user4149	user4149@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4150	Amadeusz	Płotica	MEZCZYZNA	user4150	user4150@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4151	Dargomir	Rzeszuciński	MEZCZYZNA	user4151	user4151@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4152	Wincenty	Keipash	MEZCZYZNA	user4152	user4152@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4153	Daniiella	Harbarczyk	KOBIETA	user4153	user4153@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4154	Sylwiusz	Trenkler	MEZCZYZNA	user4154	user4154@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4155	Filona	Velichová	KOBIETA	user4155	user4155@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4156	Nadiia-mariia	Emerling	KOBIETA	user4156	user4156@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4157	Thị thu hoài	Hachlica	KOBIETA	user4157	user4157@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4158	Aggy	Pichańska	KOBIETA	user4158	user4158@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4159	Gustaw	Tesarowicz	MEZCZYZNA	user4159	user4159@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4160	Krystian	Flejter	MEZCZYZNA	user4160	user4160@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4161	Otton	Hubal	MEZCZYZNA	user4161	user4161@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4162	Ireneusz	Poszwiński	MEZCZYZNA	user4162	user4162@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4163	Natela	Yechiam	KOBIETA	user4163	user4163@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4164	Zvenyslava	Tramś	KOBIETA	user4164	user4164@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4165	Wincenty	Wrzesinski	MEZCZYZNA	user4165	user4165@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4166	Aukse	Sendo	KOBIETA	user4166	user4166@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4167	Yurina	Przybysz-jasek	KOBIETA	user4167	user4167@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4168	Nivetha	Laubsztejn	KOBIETA	user4168	user4168@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4169	Emerald	Mruczkowski	NIEOKRESLONY	user4169	user4169@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4170	Tanaya	Sugiura	KOBIETA	user4170	user4170@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4171	Zlikha	Kotsiukh	KOBIETA	user4171	user4171@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4172	Krzesimir	Krämer	MEZCZYZNA	user4172	user4172@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4173	Yrsa	Kaczorowski	KOBIETA	user4173	user4173@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4174	Gihan	Grubala	KOBIETA	user4174	user4174@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4175	Meryll	Vaidya	KOBIETA	user4175	user4175@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4176	Thị tuyết mai	Ryżanowska	KOBIETA	user4176	user4176@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4177	Waldemar	Rachfalski	MEZCZYZNA	user4177	user4177@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4178	Nea	Dzigańska	KOBIETA	user4178	user4178@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4179	Arkadiusz	Buczyński	MEZCZYZNA	user4179	user4179@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4180	Olgierda	Shvernenko	KOBIETA	user4180	user4180@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4181	Konstanty	Szałagan	MEZCZYZNA	user4181	user4181@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4182	Shekhla	Mysiala	KOBIETA	user4182	user4182@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4183	Wszebor	Micał	MEZCZYZNA	user4183	user4183@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4184	Bogusz	Powys	MEZCZYZNA	user4184	user4184@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4185	Meryll	Supredko	KOBIETA	user4185	user4185@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4186	Minahil	Spachowska	KOBIETA	user4186	user4186@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4187	Noeme	Dubko	KOBIETA	user4187	user4187@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4188	Mi ran	Chmir	KOBIETA	user4188	user4188@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4189	Polishchuk	Bołżan	KOBIETA	user4189	user4189@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4190	Carolynn	Ryter	KOBIETA	user4190	user4190@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4191	Zaure	Bąchort	KOBIETA	user4191	user4191@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4192	Mǎdǎlina	Basyukova	KOBIETA	user4192	user4192@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4193	Shanvi	Lobchuk	KOBIETA	user4193	user4193@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4194	Herakles	Sielatycki	MEZCZYZNA	user4194	user4194@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4195	Władysław	Sierka	MEZCZYZNA	user4195	user4195@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4196	Emīlija	Atishkin	KOBIETA	user4196	user4196@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4197	Mariana	Chutchenko	KOBIETA	user4197	user4197@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4198	Wandelin	Smoder	MEZCZYZNA	user4198	user4198@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4199	Rejane	Biczul	KOBIETA	user4199	user4199@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4200	Mojmir	Lusiński	MEZCZYZNA	user4200	user4200@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4201	Roman	Demiter	MEZCZYZNA	user4201	user4201@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4202	Korneliusz	Tuchalski	MEZCZYZNA	user4202	user4202@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4203	Xiumei	Kanoniuk	KOBIETA	user4203	user4203@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4204	Justyn	Ławniczuk	MEZCZYZNA	user4204	user4204@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4205	Fryderyk	Toropow	MEZCZYZNA	user4205	user4205@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4206	Mikołaj	Pańczak	MEZCZYZNA	user4206	user4206@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4207	Katelin	Zagawska	KOBIETA	user4207	user4207@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4208	Arna	Krupa-brzozowska	KOBIETA	user4208	user4208@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4209	Prajna	Zapałacz	KOBIETA	user4209	user4209@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4210	Eliot	Malesza	MEZCZYZNA	user4210	user4210@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4211	Marin	Mutwicki	MEZCZYZNA	user4211	user4211@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4212	Józef	Gamalski	MEZCZYZNA	user4212	user4212@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4213	Sindhuri	Kichenko	KOBIETA	user4213	user4213@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4214	Wendy tatiana	Batkalova	KOBIETA	user4214	user4214@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4215	Rajinder kaur	Kondziak	KOBIETA	user4215	user4215@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4216	Stojan	Grzanowicz	MEZCZYZNA	user4216	user4216@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4217	Lubomił	Kmiecik	MEZCZYZNA	user4217	user4217@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4218	Zulai	Zhelondek	KOBIETA	user4218	user4218@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4219	Jona	Chwesiak	MEZCZYZNA	user4219	user4219@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4220	Tulimir	Goździowski	MEZCZYZNA	user4220	user4220@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4221	Inhrida	Lossah	KOBIETA	user4221	user4221@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4222	Paisley	Darpiniants	KOBIETA	user4222	user4222@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4223	Mariusz	Hamer	MEZCZYZNA	user4223	user4223@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4224	Husajn	Górlicki	MEZCZYZNA	user4224	user4224@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4225	Yani	Gierałt	KOBIETA	user4225	user4225@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4226	Gražina	Podilska	KOBIETA	user4226	user4226@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4227	Priyanjali	Braunsejs	KOBIETA	user4227	user4227@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4228	Sylwan	Królak	MEZCZYZNA	user4228	user4228@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4229	Gulniso	Kalogianni	KOBIETA	user4229	user4229@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4230	Ismat	Sklarski	KOBIETA	user4230	user4230@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4231	Thị thuyên	Vypryk	KOBIETA	user4231	user4231@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4232	Abelard	Kobiałko	MEZCZYZNA	user4232	user4232@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4233	Wojciech	Hadjali	MEZCZYZNA	user4233	user4233@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4234	Borys	Gilarski	MEZCZYZNA	user4234	user4234@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4235	Milan	Frydrychowicz	MEZCZYZNA	user4235	user4235@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4236	Janusz	Blondzik	MEZCZYZNA	user4236	user4236@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4237	Lebogang	Saivoiye	KOBIETA	user4237	user4237@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4238	Nomsa	Wewióra	KOBIETA	user4238	user4238@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4239	Mieczysław	Matwieiszyn	MEZCZYZNA	user4239	user4239@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4240	Lanai	Lesonina	KOBIETA	user4240	user4240@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4241	Brunon	Jazdzewski	MEZCZYZNA	user4241	user4241@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4242	Kvetoslava	Burdovska	KOBIETA	user4242	user4242@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4243	Lech	Wietchy	MEZCZYZNA	user4243	user4243@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4244	Rusanda	Lejsal	KOBIETA	user4244	user4244@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4245	Yuri andrea	Matsailo	KOBIETA	user4245	user4245@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4246	Włodzimierz	Zoll	MEZCZYZNA	user4246	user4246@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4247	Makary	Głuchy	MEZCZYZNA	user4247	user4247@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4248	Wenessa	Mirkens	KOBIETA	user4248	user4248@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4249	Izanna	Gołąb-skórzewska	KOBIETA	user4249	user4249@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4250	Zaina	Grawenda	KOBIETA	user4250	user4250@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4251	Herman	Korski	MEZCZYZNA	user4251	user4251@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4252	Elvie	Kopeikina	KOBIETA	user4252	user4252@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4253	Prot	Kowyk	MEZCZYZNA	user4253	user4253@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4254	Chwalimir	Koniakiewicz	MEZCZYZNA	user4254	user4254@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4255	Amadeusz	Brudnoch	MEZCZYZNA	user4255	user4255@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4256	Jan	Chypś	MEZCZYZNA	user4256	user4256@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4257	Maciej	Librant	MEZCZYZNA	user4257	user4257@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4258	Jingyun	Deszcz	KOBIETA	user4258	user4258@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4259	Inina	Plötze	KOBIETA	user4259	user4259@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4260	Kozeta	Koral-górka	KOBIETA	user4260	user4260@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4261	Hanusz	Kietliński	MEZCZYZNA	user4261	user4261@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4262	Yryszhan	Buzhenko	KOBIETA	user4262	user4262@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4263	Sylwiusz	Radzio	MEZCZYZNA	user4263	user4263@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4264	Nedzhmie	Piescioch	NIEOKRESLONY	user4264	user4264@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4265	Haneen	Wrześniok	KOBIETA	user4265	user4265@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4266	Mai	Rodzenko	KOBIETA	user4266	user4266@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4267	Mojmierz	Kościańczuk	MEZCZYZNA	user4267	user4267@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4268	Mihaela-andreea	Naouar	KOBIETA	user4268	user4268@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4269	Ajna	Vrehas	KOBIETA	user4269	user4269@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4270	Zdzisław	Formela	MEZCZYZNA	user4270	user4270@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4271	Zenobiusz	Ginko	MEZCZYZNA	user4271	user4271@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4272	Łukasz	Heinze	MEZCZYZNA	user4272	user4272@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4273	Narcyz	Hadas	MEZCZYZNA	user4273	user4273@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4274	Mateusz	Czabara	MEZCZYZNA	user4274	user4274@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4275	Yeohwa	Musko	KOBIETA	user4275	user4275@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4276	Ildefons	Chołuj	MEZCZYZNA	user4276	user4276@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4277	Samson	Motykowski	MEZCZYZNA	user4277	user4277@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4278	Syuzan	Khrupalova	KOBIETA	user4278	user4278@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4279	Leopold	Janików	MEZCZYZNA	user4279	user4279@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4280	August	Raduszewski	MEZCZYZNA	user4280	user4280@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4281	Marian	Samotyj	MEZCZYZNA	user4281	user4281@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4282	Chloe-ann	Petrynets	KOBIETA	user4282	user4282@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4283	Haydee	Nahler	KOBIETA	user4283	user4283@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4284	Dasom	Kushchak	KOBIETA	user4284	user4284@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4285	Semi̇ha	Mykytchuk	KOBIETA	user4285	user4285@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4286	Damin	Hanyak	KOBIETA	user4286	user4286@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4287	Miron	Kapłaniuk	MEZCZYZNA	user4287	user4287@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4288	Jozafat	Esiava	MEZCZYZNA	user4288	user4288@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4289	Radzimir	Hordys	MEZCZYZNA	user4289	user4289@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4290	Margaret	Gorospe	KOBIETA	user4290	user4290@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4291	Khine	Kazharskaya	KOBIETA	user4291	user4291@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4292	Witołd	Kogut-maliszewski	MEZCZYZNA	user4292	user4292@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4293	Filip	Opuszko	MEZCZYZNA	user4293	user4293@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4294	Baltazar	Pacho	MEZCZYZNA	user4294	user4294@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4295	Hoàng my	Vizirenko	KOBIETA	user4295	user4295@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4296	Sion	Antol	KOBIETA	user4296	user4296@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4297	Hubert	Burmer	MEZCZYZNA	user4297	user4297@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4298	Oleg	Mireński	MEZCZYZNA	user4298	user4298@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4299	Rajmund	Radczyc	MEZCZYZNA	user4299	user4299@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4300	Jianmei	Gess	KOBIETA	user4300	user4300@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4301	Eleonóra	Mqwathi	KOBIETA	user4301	user4301@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4302	Michaell	Durğun	KOBIETA	user4302	user4302@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4303	Hugon	Chylaszek	MEZCZYZNA	user4303	user4303@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4304	Józef	Rudecki	MEZCZYZNA	user4304	user4304@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4305	Leoncja	Kuzmychova	KOBIETA	user4305	user4305@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4306	Pauline	Setti	KOBIETA	user4306	user4306@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4307	Korneliusz	Więsik	MEZCZYZNA	user4307	user4307@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4308	Eleni	Tomašević	KOBIETA	user4308	user4308@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4309	Hadrian	Kwiatyszek	MEZCZYZNA	user4309	user4309@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4310	Borzywoj	Radchenko	MEZCZYZNA	user4310	user4310@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4311	Wilhelm	Pęcherski	MEZCZYZNA	user4311	user4311@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4312	Stefanyda	Makhinova	KOBIETA	user4312	user4312@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4313	Betul	Spauschus	KOBIETA	user4313	user4313@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4314	Yanina-sofiya	Dvihaila	KOBIETA	user4314	user4314@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4315	Rahel	Zwyrzykowska	KOBIETA	user4315	user4315@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4316	Lubisław	Kierod	MEZCZYZNA	user4316	user4316@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4317	Dargomir	Zbojna	MEZCZYZNA	user4317	user4317@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4318	Adam	Sluzhynskyi	MEZCZYZNA	user4318	user4318@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4319	Onufry	Sarama	MEZCZYZNA	user4319	user4319@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4320	Bożimir	Łobanowski	MEZCZYZNA	user4320	user4320@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4321	Hoài an	Mundrzyńska	KOBIETA	user4321	user4321@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4322	Bonawentura	Różewski	MEZCZYZNA	user4322	user4322@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4323	Joachima	Zhytkomlinova	KOBIETA	user4323	user4323@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4324	Shashikala	Stefańska-polak	KOBIETA	user4324	user4324@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4325	Olia	Martynets	KOBIETA	user4325	user4325@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4326	Eufalia	Gładikowska	KOBIETA	user4326	user4326@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4327	Farhinbanu	Chyrkun	KOBIETA	user4327	user4327@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4328	Evguenia	Bosisio	KOBIETA	user4328	user4328@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4329	Lech	Mędrzecki	MEZCZYZNA	user4329	user4329@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4330	Berra	Tychończuk	KOBIETA	user4330	user4330@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4331	Ryszarda	Donaldson	KOBIETA	user4331	user4331@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4332	Krystian	Wischka von borczyskowski	MEZCZYZNA	user4332	user4332@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4333	Jung mi	Tsybulenko	KOBIETA	user4333	user4333@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4334	Yong sun	Iovina	KOBIETA	user4334	user4334@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4335	Dobrogost	Toll	MEZCZYZNA	user4335	user4335@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4336	Zygfryd	Szmulewicz	MEZCZYZNA	user4336	user4336@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4337	Clotilde	Makshun	KOBIETA	user4337	user4337@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4338	Otniel	Wacewicz	MEZCZYZNA	user4338	user4338@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4339	Emir	Watemborski	MEZCZYZNA	user4339	user4339@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4340	Sławomierz	Łasak	MEZCZYZNA	user4340	user4340@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4341	Dżamil	Socha-bystroń	MEZCZYZNA	user4341	user4341@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4342	Ashley	Ramsaha	KOBIETA	user4342	user4342@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4343	Miłosz	Miezio	MEZCZYZNA	user4343	user4343@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4344	Ksantia	Bekeshka	KOBIETA	user4344	user4344@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4345	Bi̇rgül	Divdic	KOBIETA	user4345	user4345@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4346	Shaohua	Badzialik	KOBIETA	user4346	user4346@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4347	Ziyarat	Zubrod	KOBIETA	user4347	user4347@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4348	Amanita	Samulska vel smulska	KOBIETA	user4348	user4348@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4349	Miłowan	Patyna	MEZCZYZNA	user4349	user4349@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4350	Acelya	Niebutkowska	KOBIETA	user4350	user4350@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4351	Sadat	Ramos martinez	KOBIETA	user4351	user4351@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4352	Antonius	Sor	MEZCZYZNA	user4352	user4352@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4353	Oleg	Dobaczewski	MEZCZYZNA	user4353	user4353@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4354	Inocentyna	Brajan	KOBIETA	user4354	user4354@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4355	Ornella	Nie	KOBIETA	user4355	user4355@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4356	Sofroniusz	Laszczyński	MEZCZYZNA	user4356	user4356@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4357	Miłogost	Scech	MEZCZYZNA	user4357	user4357@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4358	Belen	Kaniuth	KOBIETA	user4358	user4358@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4359	Kanina	Gőransson	KOBIETA	user4359	user4359@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4360	Rosemari	Bromińska	KOBIETA	user4360	user4360@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4361	Saisha	Liahushova	KOBIETA	user4361	user4361@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4362	Igor	Przetaczyński	MEZCZYZNA	user4362	user4362@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4363	Arkady	Haładuda	MEZCZYZNA	user4363	user4363@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4364	Arlet	Dunio	KOBIETA	user4364	user4364@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4365	Omar	Gomolla	MEZCZYZNA	user4365	user4365@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4366	Mugadansa	Ohainska	KOBIETA	user4366	user4366@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4367	Chandra	Jankovskaja	KOBIETA	user4367	user4367@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4368	Włodzisław	Zemuła	MEZCZYZNA	user4368	user4368@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4369	Yesica	Mych	KOBIETA	user4369	user4369@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4370	Aizat	Syrowiecki	KOBIETA	user4370	user4370@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4371	Nicci	Tsyril	KOBIETA	user4371	user4371@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4372	Eda	Masling	KOBIETA	user4372	user4372@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4373	Dobiesław	Erlich	MEZCZYZNA	user4373	user4373@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4374	Sławomir	Grzmilas	MEZCZYZNA	user4374	user4374@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4375	Roger	Dwilewicz	MEZCZYZNA	user4375	user4375@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4376	Lubisław	Zdunicz-skośkiewicz	MEZCZYZNA	user4376	user4376@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4377	Hamza	Kociemba	MEZCZYZNA	user4377	user4377@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4378	Shely	Grădinaru	KOBIETA	user4378	user4378@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4379	Symeon	Remlajn	MEZCZYZNA	user4379	user4379@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4380	Krzesimir	Pikus	MEZCZYZNA	user4380	user4380@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4381	Teofiliia	Klakotskaya	KOBIETA	user4381	user4381@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4382	Lexia	Łapucewicz	KOBIETA	user4382	user4382@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4383	Pabian	Paściak	MEZCZYZNA	user4383	user4383@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4384	Dzhennet	Zürcher	KOBIETA	user4384	user4384@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4385	Odon	Bielka	MEZCZYZNA	user4385	user4385@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4386	Cyryl	Kucal	MEZCZYZNA	user4386	user4386@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4387	Tėja	Andriiesi	KOBIETA	user4387	user4387@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4388	Arina	Raczkowska	KOBIETA	user4388	user4388@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4389	Chia-jou	Zhepka	KOBIETA	user4389	user4389@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4390	Stojan	Młodożeniec	MEZCZYZNA	user4390	user4390@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4391	Nikole	Klitzke komorowski	NIEOKRESLONY	user4391	user4391@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4392	Leo	Herman	MEZCZYZNA	user4392	user4392@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4393	Tymon	Lecointe	NIEOKRESLONY	user4393	user4393@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4394	Ezechiel	Politański	MEZCZYZNA	user4394	user4394@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4395	Bogusław	Pujdak	MEZCZYZNA	user4395	user4395@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4396	Zwinisław	Trejta	MEZCZYZNA	user4396	user4396@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4397	Stanisław	Giżyński	MEZCZYZNA	user4397	user4397@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4398	Hasan	Zuchowski	MEZCZYZNA	user4398	user4398@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4399	Conny	Jakubschon	KOBIETA	user4399	user4399@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4400	Meggy	Svetlichna	KOBIETA	user4400	user4400@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4401	Yayan	Rabczak	KOBIETA	user4401	user4401@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4402	Antonius	Sulowski	MEZCZYZNA	user4402	user4402@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4403	Thi bao	Bomerska	KOBIETA	user4403	user4403@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4404	Nikodem	Wanaga	MEZCZYZNA	user4404	user4404@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4405	Agapit	Czarnowusy	MEZCZYZNA	user4405	user4405@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4406	Miroład	Wybiera	MEZCZYZNA	user4406	user4406@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4407	Mihoko	Luiza	KOBIETA	user4407	user4407@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4408	Mey	Sędziwy	KOBIETA	user4408	user4408@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4409	Zachariasz	Chalaba	MEZCZYZNA	user4409	user4409@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4410	Feiyi	Khachatrian	KOBIETA	user4410	user4410@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4411	Yevhenia	Nichifor	KOBIETA	user4411	user4411@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4412	Vaselyna	Wąśniewska	KOBIETA	user4412	user4412@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4413	Filipa	Janjić	KOBIETA	user4413	user4413@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4414	Eloah	Göllner	KOBIETA	user4414	user4414@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4415	Laurencjusz	Szmulkis	MEZCZYZNA	user4415	user4415@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4416	Idzi	Kusznierenko	MEZCZYZNA	user4416	user4416@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4417	Faris	Ławruk	MEZCZYZNA	user4417	user4417@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4418	Nithila	Van gessel	KOBIETA	user4418	user4418@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4419	Apollo	Terrett	MEZCZYZNA	user4419	user4419@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4420	Ładysław	Misiakiewicz	MEZCZYZNA	user4420	user4420@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4421	Mikhaila	Zuchalska	KOBIETA	user4421	user4421@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4422	Bogumił	Łapszański	MEZCZYZNA	user4422	user4422@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4423	Urban	Górajski	MEZCZYZNA	user4423	user4423@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4424	Ramune	Pokhylchenko	KOBIETA	user4424	user4424@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4425	Apollo	Mocarny	MEZCZYZNA	user4425	user4425@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4426	Lidyia	Winiecki	KOBIETA	user4426	user4426@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4427	Jenifer	Pasiut	NIEOKRESLONY	user4427	user4427@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4428	Arathy	Basok	KOBIETA	user4428	user4428@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4429	Przybysław	Solecki	MEZCZYZNA	user4429	user4429@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4430	Florian	Bugalski	MEZCZYZNA	user4430	user4430@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4431	Tanaporn	Cur	NIEOKRESLONY	user4431	user4431@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4432	Caridad	Wilczyńska-czekaj	KOBIETA	user4432	user4432@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4433	Gaweł	Tupiec	MEZCZYZNA	user4433	user4433@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4434	Roch	Kleszczyński	MEZCZYZNA	user4434	user4434@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4435	Phuong hoa	Holzapfel	KOBIETA	user4435	user4435@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4436	Ayshan	Ośmińska	KOBIETA	user4436	user4436@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4437	Marija	Myszkun	KOBIETA	user4437	user4437@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4438	Lustyna	Bailina	KOBIETA	user4438	user4438@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4439	Romisaa	Holnieva	KOBIETA	user4439	user4439@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4440	Żarko	Farganus	MEZCZYZNA	user4440	user4440@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4441	Fryderyk	Buchowicz	MEZCZYZNA	user4441	user4441@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4442	Bolesław	Soszko	MEZCZYZNA	user4442	user4442@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4443	Natan	Koziołkiewicz	MEZCZYZNA	user4443	user4443@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4444	Shreenika	Makles-kotwica	KOBIETA	user4444	user4444@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4445	Enissa	Południewska	KOBIETA	user4445	user4445@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4446	Rica	Krivjanska	KOBIETA	user4446	user4446@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4447	Jaropełk	Grądas	MEZCZYZNA	user4447	user4447@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4448	Olaf	Szajc	MEZCZYZNA	user4448	user4448@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4449	Jarin	Dworak-stępień	KOBIETA	user4449	user4449@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4450	Giertruda	Yendzura	KOBIETA	user4450	user4450@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4451	Ellaina	Pryshchepina	KOBIETA	user4451	user4451@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4452	Erwin	Pacer	MEZCZYZNA	user4452	user4452@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4453	Juliusz	Gębczyk	MEZCZYZNA	user4453	user4453@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4454	Łucjan	Lukas	MEZCZYZNA	user4454	user4454@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4455	Angelena	Gelba	KOBIETA	user4455	user4455@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4456	Galy	Gaiday	KOBIETA	user4456	user4456@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4457	Andrea del pilar	Wątrobicz	KOBIETA	user4457	user4457@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4458	Fazila	Dżaluk	KOBIETA	user4458	user4458@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4459	Marie-helene	Schlussman	KOBIETA	user4459	user4459@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4460	Feliks	Imosa	MEZCZYZNA	user4460	user4460@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4461	Marigold	Dumić	KOBIETA	user4461	user4461@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4462	Wolimir	Rudolf	MEZCZYZNA	user4462	user4462@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4463	Zenon	Skipietrow	MEZCZYZNA	user4463	user4463@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4464	Marilyn	Sędzielowska	KOBIETA	user4464	user4464@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4465	Pei-chen	Golding	KOBIETA	user4465	user4465@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4466	Izajasz	Harasymczuk	MEZCZYZNA	user4466	user4466@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4467	Danobia	Solecká	KOBIETA	user4467	user4467@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4468	Herakles	Kaczyński	MEZCZYZNA	user4468	user4468@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4469	Napoleon	Doleanu	MEZCZYZNA	user4469	user4469@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4470	Cathérine	Santandreu	KOBIETA	user4470	user4470@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4471	Nurangez	Dękierowska	KOBIETA	user4471	user4471@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4472	Gladis	Dahlmanns	KOBIETA	user4472	user4472@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4473	Lujia	Adamczyk-gajewska	KOBIETA	user4473	user4473@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4474	Mojżesz	Drach	MEZCZYZNA	user4474	user4474@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4475	Kwietosław	Gochniak	MEZCZYZNA	user4475	user4475@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4476	Sławomir	Nowialis	MEZCZYZNA	user4476	user4476@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4477	Danielia	Osierda	KOBIETA	user4477	user4477@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4478	Huirong	Pazdrii	KOBIETA	user4478	user4478@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4479	Barnim	Klacza	MEZCZYZNA	user4479	user4479@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4480	Otokar	Dubil	MEZCZYZNA	user4480	user4480@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4481	Ayxa	Chodinow	KOBIETA	user4481	user4481@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4482	Zhyldyz	Tkhorynska	KOBIETA	user4482	user4482@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4483	Thenmozhi	Bommersheim	KOBIETA	user4483	user4483@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4484	Pavlina	Serebrynska	KOBIETA	user4484	user4484@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4485	Jolantha	Mormytko	KOBIETA	user4485	user4485@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4486	Nasif	Maciej	MEZCZYZNA	user4486	user4486@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4487	Fabian	Dekarzewski	MEZCZYZNA	user4487	user4487@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4488	Thị thơm	Szewińska	KOBIETA	user4488	user4488@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4489	Luborad	Ozarowski	MEZCZYZNA	user4489	user4489@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4490	Dymitra	Rafaj	KOBIETA	user4490	user4490@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4491	Khedija	Rafalowicz	KOBIETA	user4491	user4491@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4492	Gyulshen	Staszkiewicz-kapuśniak	KOBIETA	user4492	user4492@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4493	Nese	Dudzic	KOBIETA	user4493	user4493@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4494	Arpenik	Redlich	KOBIETA	user4494	user4494@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4495	Lonia	Wloczka	KOBIETA	user4495	user4495@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4496	Friederike	Burukina	KOBIETA	user4496	user4496@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4497	Lanhua	Fisik	KOBIETA	user4497	user4497@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4498	Kajusz	Gorbacewicz	MEZCZYZNA	user4498	user4498@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4499	Wrocisław	Bulatović	MEZCZYZNA	user4499	user4499@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4500	Jur	Okołów	MEZCZYZNA	user4500	user4500@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4501	Chaitanya	Valivakhina	KOBIETA	user4501	user4501@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4502	Kacper	Wikłacz	MEZCZYZNA	user4502	user4502@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4503	Placyd	Korpas	MEZCZYZNA	user4503	user4503@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4504	Meiqi	Ablameika	KOBIETA	user4504	user4504@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4505	Herschel	Handrabura	KOBIETA	user4505	user4505@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4506	Adelard	Załustowicz	MEZCZYZNA	user4506	user4506@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4507	Song sun	Couch	KOBIETA	user4507	user4507@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4508	Maksuda	Dubisz-świderska	KOBIETA	user4508	user4508@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4509	Otto	Kondek	MEZCZYZNA	user4509	user4509@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4510	Jovana	Chitaukire	KOBIETA	user4510	user4510@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4511	Dobrogost	Piotrowski	MEZCZYZNA	user4511	user4511@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4512	Felicjan	Klonecki	MEZCZYZNA	user4512	user4512@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4513	Mazarine	Martelova	KOBIETA	user4513	user4513@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4514	Emmaculate	Strakovych	KOBIETA	user4514	user4514@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4515	Dzena	Seden	KOBIETA	user4515	user4515@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4516	Janusz	Żołowicz	MEZCZYZNA	user4516	user4516@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4517	Marceli	Herós	MEZCZYZNA	user4517	user4517@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4518	Longin	Cuprych	MEZCZYZNA	user4518	user4518@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4519	Thị thu hiến	Curujew	KOBIETA	user4519	user4519@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4520	Wiesław	Czyrka	MEZCZYZNA	user4520	user4520@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4521	Anatasiia	Pajfer	KOBIETA	user4521	user4521@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4522	Florentyn	Mazia	MEZCZYZNA	user4522	user4522@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4523	Romella	Szybska	KOBIETA	user4523	user4523@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4524	Wawrzyniec	Konsor	MEZCZYZNA	user4524	user4524@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4525	Wojciech	Grabijas	MEZCZYZNA	user4525	user4525@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4526	Siemowit	Fulman	MEZCZYZNA	user4526	user4526@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4527	Qizilgul	Podolska-czajka	KOBIETA	user4527	user4527@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4528	Oran	Palczykowska	KOBIETA	user4528	user4528@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4529	Gulden	Podymsky	KOBIETA	user4529	user4529@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4530	Walentyn	Łomzik	MEZCZYZNA	user4530	user4530@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4531	Viera	Wyłomański	KOBIETA	user4531	user4531@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4532	Lambert	Włudarczyk	MEZCZYZNA	user4532	user4532@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4533	Ignacy	El hlaoui	KOBIETA	user4533	user4533@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4534	Beatrisa	Kuźnicka	KOBIETA	user4534	user4534@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4535	Claudia lorena	Ryeutova	KOBIETA	user4535	user4535@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4536	Antonius	Kryszczuk	MEZCZYZNA	user4536	user4536@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4537	Oktawiusz	Tereszkiewicz	MEZCZYZNA	user4537	user4537@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4538	Miłogost	Szubiński	MEZCZYZNA	user4538	user4538@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4539	Stoigniew	Peliwo	MEZCZYZNA	user4539	user4539@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4540	Sambor	Wiliński	MEZCZYZNA	user4540	user4540@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4541	Sanjita	Madelska	KOBIETA	user4541	user4541@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4542	Oleg	Brylski	MEZCZYZNA	user4542	user4542@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4543	Shelby	Bitenc	KOBIETA	user4543	user4543@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4544	Thi thuy hang	Lukianov	KOBIETA	user4544	user4544@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4545	Renarda	Demczuk-konecka	KOBIETA	user4545	user4545@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4546	Duszan	Kondas	MEZCZYZNA	user4546	user4546@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4547	Aie	Emrykh	KOBIETA	user4547	user4547@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4548	Chwalisław	Naleźnik	MEZCZYZNA	user4548	user4548@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4549	Ankitaben	Ratai	KOBIETA	user4549	user4549@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4550	Kai	Modlewska	KOBIETA	user4550	user4550@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4551	Songkan	Winiarz	KOBIETA	user4551	user4551@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4552	Matrena	Khabibullina	KOBIETA	user4552	user4552@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4553	Nikolietta	Kimszal	KOBIETA	user4553	user4553@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4554	Krystyn	Skwierawski	MEZCZYZNA	user4554	user4554@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4555	Bożydar	Aleksandrow	MEZCZYZNA	user4555	user4555@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4556	Selva	Bilanchuk	KOBIETA	user4556	user4556@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4557	Sędzisław	Ismail	MEZCZYZNA	user4557	user4557@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4558	Erdenetuya	Tsvilodub	KOBIETA	user4558	user4558@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4559	Grzegorz	Zarubiak	MEZCZYZNA	user4559	user4559@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4560	Wisław	Jonietz	MEZCZYZNA	user4560	user4560@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4561	Kwietosław	Pszczółkowski	MEZCZYZNA	user4561	user4561@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4562	Yennefer	Czuraków	KOBIETA	user4562	user4562@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4563	Bartłomiej	Durawa	MEZCZYZNA	user4563	user4563@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4564	Karolena	Ieremii	KOBIETA	user4564	user4564@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4565	Damian	Źródłowski	MEZCZYZNA	user4565	user4565@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4566	Jiye	Savosh	KOBIETA	user4566	user4566@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4567	Heliodor	Barszczowski	MEZCZYZNA	user4567	user4567@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4568	Maryn	Czepaczyński	MEZCZYZNA	user4568	user4568@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4569	Donald	Łado	MEZCZYZNA	user4569	user4569@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4570	Hoor	Kariavka	KOBIETA	user4570	user4570@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4571	Walentyn	Mołczyk	MEZCZYZNA	user4571	user4571@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4572	Lenart	Pszona	MEZCZYZNA	user4572	user4572@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4573	Shijie	Savickas	KOBIETA	user4573	user4573@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4574	Thuan	Niszczy	KOBIETA	user4574	user4574@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4575	Hyeyoung	Rogala-zawadzka	KOBIETA	user4575	user4575@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4576	Yeiris	Medaj	KOBIETA	user4576	user4576@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4577	Tatiyna	Dziechcińska	KOBIETA	user4577	user4577@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4578	Dominik	Wodyczko	MEZCZYZNA	user4578	user4578@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4579	Mściwoj	Sanders	MEZCZYZNA	user4579	user4579@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4580	Prisca	Haynysz	KOBIETA	user4580	user4580@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4581	Alfred	Kupczyński	MEZCZYZNA	user4581	user4581@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4582	Baasansuren	Beulich	KOBIETA	user4582	user4582@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4583	Rasika	Hampshire	KOBIETA	user4583	user4583@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4584	Oswald	Koerber	MEZCZYZNA	user4584	user4584@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4585	Otto	Angerman	MEZCZYZNA	user4585	user4585@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4586	Marcin	Scheibe	MEZCZYZNA	user4586	user4586@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4587	Geetha	Grzegorowski	KOBIETA	user4587	user4587@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4588	Teodozjusz	Wolik	MEZCZYZNA	user4588	user4588@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4589	Reichel	Zahlukha	KOBIETA	user4589	user4589@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4590	Thị hải yến	Patashuri	KOBIETA	user4590	user4590@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4591	Zempira	Elmrych	KOBIETA	user4591	user4591@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4592	Bartosz	Jonczak	MEZCZYZNA	user4592	user4592@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4593	Augustyn	Marchlak	MEZCZYZNA	user4593	user4593@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4594	Pamela	Yuzel	KOBIETA	user4594	user4594@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4595	Marżanna	Nahilenko	KOBIETA	user4595	user4595@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4596	Kryspin	Pisz	MEZCZYZNA	user4596	user4596@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4597	January	Askhabov	MEZCZYZNA	user4597	user4597@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4598	Maurycjusz	Bojaryn	MEZCZYZNA	user4598	user4598@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4599	Józefat	Kurpanik	MEZCZYZNA	user4599	user4599@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4600	Melitta	Ziemlanowska	KOBIETA	user4600	user4600@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4601	Godfryg	Łosik	MEZCZYZNA	user4601	user4601@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4602	Lata	Bakhurinska	KOBIETA	user4602	user4602@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4603	Filip	Prejc	MEZCZYZNA	user4603	user4603@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4604	Prokop	Kęsek	MEZCZYZNA	user4604	user4604@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4605	Rafał	Szajerski	MEZCZYZNA	user4605	user4605@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4606	Voski	Eisenbardt	KOBIETA	user4606	user4606@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4607	Sreenidhi	Kondratsova	KOBIETA	user4607	user4607@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4608	Shiqi	Nycnerska	KOBIETA	user4608	user4608@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4609	Ishani	Vardzelashvili	KOBIETA	user4609	user4609@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4610	Chwalibóg	Cieplucha	MEZCZYZNA	user4610	user4610@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4611	Roderyk	Matjaszczuk	MEZCZYZNA	user4611	user4611@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4612	Naveena	Koublová	KOBIETA	user4612	user4612@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4613	Miharu	Huzenkova	KOBIETA	user4613	user4613@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4614	Telesfor	Piastowicz	MEZCZYZNA	user4614	user4614@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4615	Lucianna	Iodice	KOBIETA	user4615	user4615@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4616	Chethana	Tatsko	KOBIETA	user4616	user4616@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4617	Thi thu huong	Okvuchi	KOBIETA	user4617	user4617@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4618	Baran	Tretsiakova	KOBIETA	user4618	user4618@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4619	Nicefor	Włodarczak	MEZCZYZNA	user4619	user4619@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4620	Juxiang	Kaczmarek-müller	KOBIETA	user4620	user4620@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4621	Ignacy	Mencner	KOBIETA	user4621	user4621@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4622	Mikaella	Milewska-grzyb	KOBIETA	user4622	user4622@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4623	Xiaoran	Nowoświat	KOBIETA	user4623	user4623@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4624	Aaiza	Zajchowska	KOBIETA	user4624	user4624@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4625	Dilşa	Bäckström	KOBIETA	user4625	user4625@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4626	Łucjan	Ganowski	MEZCZYZNA	user4626	user4626@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4627	Thu trang	Locke	KOBIETA	user4627	user4627@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4628	Noélie	Mikalaichyk	KOBIETA	user4628	user4628@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4629	Krzysztof	Igwe	MEZCZYZNA	user4629	user4629@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4630	Lubisław	Falenta	MEZCZYZNA	user4630	user4630@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4631	Yuleisi	Derekh	KOBIETA	user4631	user4631@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4632	Salem	Pitera	KOBIETA	user4632	user4632@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4633	Krystian	Szcześniewicz	MEZCZYZNA	user4633	user4633@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4634	Salama	Shichi	KOBIETA	user4634	user4634@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4635	Stephy	Gutseva	KOBIETA	user4635	user4635@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4636	Franciszek	Nowakowska-domagała	KOBIETA	user4636	user4636@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4637	Jaropełk	Warszyński	MEZCZYZNA	user4637	user4637@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4638	Ma	Bohodytsia	KOBIETA	user4638	user4638@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4639	Mamert	Szymała	MEZCZYZNA	user4639	user4639@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4640	Gamar	Ivanescu	KOBIETA	user4640	user4640@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4641	Debika	Pietruszewicz	KOBIETA	user4641	user4641@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4642	Eun ah	Lopaten	KOBIETA	user4642	user4642@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4643	Kwiatosław	Dzbanuszek	MEZCZYZNA	user4643	user4643@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4644	Annasz	Kazimierczak-boszko	MEZCZYZNA	user4644	user4644@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4645	Belita	Balabaieva	KOBIETA	user4645	user4645@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4646	Andrea patricia	Tulinova	KOBIETA	user4646	user4646@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4647	Elmas	Haładewicz	KOBIETA	user4647	user4647@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4648	Mamert	Przyszlak	MEZCZYZNA	user4648	user4648@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4649	Herman	Pacia	MEZCZYZNA	user4649	user4649@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4650	Gniewosz	Śniosek	MEZCZYZNA	user4650	user4650@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4651	Eliot	Jendrak	MEZCZYZNA	user4651	user4651@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4652	Magnus	Garula	MEZCZYZNA	user4652	user4652@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4653	Olívia	Brodniewicz składanek	KOBIETA	user4653	user4653@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4654	Arenika	Glausiuss	KOBIETA	user4654	user4654@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4655	Eset	Lazaryewa	KOBIETA	user4655	user4655@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4656	Kosma	Reśliński	MEZCZYZNA	user4656	user4656@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4657	Iwan	Suszycki	MEZCZYZNA	user4657	user4657@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4658	Emy	Blazej	KOBIETA	user4658	user4658@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4659	Tsitsidzashe	Krechowiecka	KOBIETA	user4659	user4659@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4660	Toba	Męcikiewicz	KOBIETA	user4660	user4660@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4661	Mitchel	Gołonowicz	KOBIETA	user4661	user4661@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4662	Zefir	Johaniuk	MEZCZYZNA	user4662	user4662@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4663	Miłorad	Grądwald	MEZCZYZNA	user4663	user4663@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4664	Ronald	Rocki	MEZCZYZNA	user4664	user4664@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4665	Diána	Sradomski	NIEOKRESLONY	user4665	user4665@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4666	Xin	Kontseva	KOBIETA	user4666	user4666@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4667	Sergiusz	Andryszczyk	MEZCZYZNA	user4667	user4667@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4668	Nuray	Leontii	KOBIETA	user4668	user4668@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4669	Yebin	Prychyska	KOBIETA	user4669	user4669@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4670	Tarik	Deptuch	MEZCZYZNA	user4670	user4670@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4671	Jahanavi	Knizia	KOBIETA	user4671	user4671@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4672	Yovka	Gärtner	KOBIETA	user4672	user4672@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4673	Medea	Seewald	KOBIETA	user4673	user4673@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4674	Hubert	Ciejka	MEZCZYZNA	user4674	user4674@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4675	Otton	Stabryła	MEZCZYZNA	user4675	user4675@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4676	Laurencjusz	Żydecki	MEZCZYZNA	user4676	user4676@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4677	Mercedez	Fibińska	KOBIETA	user4677	user4677@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4678	Minerwa	Bielecka vel bielińska	KOBIETA	user4678	user4678@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4679	Shu-han	Żydzianowska	KOBIETA	user4679	user4679@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4680	Natassia	Vavrichyna	KOBIETA	user4680	user4680@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4681	Anzhalina	Chulist	KOBIETA	user4681	user4681@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4682	Wojciech	Majdiuk	MEZCZYZNA	user4682	user4682@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4683	Świętopełk	Gąsior	MEZCZYZNA	user4683	user4683@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4684	Maurycjusz	Nestmann	MEZCZYZNA	user4684	user4684@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4685	Anastazy	Werpachowski	MEZCZYZNA	user4685	user4685@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4686	Róża maria	Demucha	KOBIETA	user4686	user4686@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4687	Dianella	Churylovich	KOBIETA	user4687	user4687@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4688	Pelagiusz	Kunkel	MEZCZYZNA	user4688	user4688@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4689	Ajla	Zakutajew	KOBIETA	user4689	user4689@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4690	Muguette	Ričkus	KOBIETA	user4690	user4690@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4691	Tęgomir	Katz	MEZCZYZNA	user4691	user4691@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4692	Charo	Janowski	KOBIETA	user4692	user4692@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4693	Grzegorz	Fara	MEZCZYZNA	user4693	user4693@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4694	Najiba	Parys-matysiak	KOBIETA	user4694	user4694@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4695	Mieszko	Koluch	MEZCZYZNA	user4695	user4695@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4696	Balladyna	Legras	KOBIETA	user4696	user4696@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4697	Mojżesz	Służewicz	MEZCZYZNA	user4697	user4697@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4698	Norie	Bardachenko	KOBIETA	user4698	user4698@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4699	Maryn	Krasulak	MEZCZYZNA	user4699	user4699@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4700	Sędomir	Ziombrowski	MEZCZYZNA	user4700	user4700@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4701	Wendy vanessa	Jungto	KOBIETA	user4701	user4701@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4702	Ali̇ye	Zelenytsia	KOBIETA	user4702	user4702@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4703	Damazy	Lissowski	MEZCZYZNA	user4703	user4703@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4704	Jaromir	Bryling	MEZCZYZNA	user4704	user4704@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4705	Sławomir	Burcek	MEZCZYZNA	user4705	user4705@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4706	Sousan	Shchepitka	KOBIETA	user4706	user4706@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4707	Zwinisław	Kraczyna	MEZCZYZNA	user4707	user4707@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4708	Christel	Papialushka	KOBIETA	user4708	user4708@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4709	Savina	Włodyka	KOBIETA	user4709	user4709@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4710	Sędzisław	Końko	MEZCZYZNA	user4710	user4710@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4711	Mailin	Macdonald	KOBIETA	user4711	user4711@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4712	Fryderyk	Leligdowicz	MEZCZYZNA	user4712	user4712@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4713	Thị tám	Perdomo garcia	KOBIETA	user4713	user4713@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4714	Lesław	Połętek	MEZCZYZNA	user4714	user4714@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4715	Fabian	Posała	MEZCZYZNA	user4715	user4715@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4716	Gustaw	Mielnicki	MEZCZYZNA	user4716	user4716@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4717	Benigna	Krupanek	KOBIETA	user4717	user4717@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4718	Maurycy	Kosela	MEZCZYZNA	user4718	user4718@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4719	Sybilla	Persan	KOBIETA	user4719	user4719@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4720	Manfred	Wydmański	MEZCZYZNA	user4720	user4720@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4721	Raida	Basiel	KOBIETA	user4721	user4721@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4722	Lubomił	Lotz	MEZCZYZNA	user4722	user4722@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4723	Strzeżymir	Chomko	MEZCZYZNA	user4723	user4723@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4724	Iza	Biriukowa	KOBIETA	user4724	user4724@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4725	Walid	Buwaj	MEZCZYZNA	user4725	user4725@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4726	Strzeżymir	Uliasz	MEZCZYZNA	user4726	user4726@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4727	Owidiusz	Dańczyszyn	MEZCZYZNA	user4727	user4727@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4728	Thị ngọc	Bąk-majka	KOBIETA	user4728	user4728@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4729	Aneli	Bolyubash	KOBIETA	user4729	user4729@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4730	Aireen	Tumaieva	KOBIETA	user4730	user4730@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4731	Chana	Şenyurt	KOBIETA	user4731	user4731@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4732	Ludomir	Nakwaski	MEZCZYZNA	user4732	user4732@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4733	Gardomir	Hemlich	MEZCZYZNA	user4733	user4733@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4734	Sędomir	Szyja	MEZCZYZNA	user4734	user4734@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4735	Walenty	Kopala	MEZCZYZNA	user4735	user4735@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4736	Aleks	Bieluszko	MEZCZYZNA	user4736	user4736@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4737	Sunia	Hrazhynskaya	KOBIETA	user4737	user4737@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4738	Liya	Tokaieva	KOBIETA	user4738	user4738@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4739	Malky	Allgaier	KOBIETA	user4739	user4739@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4740	Jarowit	Osiczko	MEZCZYZNA	user4740	user4740@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4741	Michał	Rangełow	MEZCZYZNA	user4741	user4741@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4742	Gabriel	Izergin	MEZCZYZNA	user4742	user4742@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4743	Gniewomir	Dłuski	MEZCZYZNA	user4743	user4743@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4744	Agłaja	Veliseiko	NIEOKRESLONY	user4744	user4744@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4745	Nomathemba	Polihushko	NIEOKRESLONY	user4745	user4745@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4746	Józefat	Dusoge	MEZCZYZNA	user4746	user4746@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4747	Champa	Nikolaeva	KOBIETA	user4747	user4747@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4748	Horacy	Gazdowicz	MEZCZYZNA	user4748	user4748@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4749	Neni	Nozhevnyk	KOBIETA	user4749	user4749@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4750	Sarmīte	Mendec	KOBIETA	user4750	user4750@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4751	Izydor	Kidała	MEZCZYZNA	user4751	user4751@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4752	Kajusz	Żwirkowski	MEZCZYZNA	user4752	user4752@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4753	Hasan	Dymon	MEZCZYZNA	user4753	user4753@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4754	Agapit	Kowaluk	MEZCZYZNA	user4754	user4754@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4755	Ludomir	Szlagura	MEZCZYZNA	user4755	user4755@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4756	Duszan	Mierkiewicz	MEZCZYZNA	user4756	user4756@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4757	Safi̇ye	Żydziak	KOBIETA	user4757	user4757@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4758	Walery	Cent	MEZCZYZNA	user4758	user4758@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4759	Divine	Czerepuszko	KOBIETA	user4759	user4759@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4760	Jonasz	Szwabowski	MEZCZYZNA	user4760	user4760@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4761	Świętibor	Chwalczyk	MEZCZYZNA	user4761	user4761@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4762	Melissza	Kolvakh	KOBIETA	user4762	user4762@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4763	Chayenne	Wawilin	KOBIETA	user4763	user4763@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4764	Rajca	Maibuk	KOBIETA	user4764	user4764@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4765	Tatiyana	Dobrodieieva	KOBIETA	user4765	user4765@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4766	Nurhayat	Pawlikowska-maćkowiak	KOBIETA	user4766	user4766@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4767	Ewald	Cabanek	MEZCZYZNA	user4767	user4767@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4768	Hermes	Milonas	MEZCZYZNA	user4768	user4768@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4769	Atchara	Kalytiuk	KOBIETA	user4769	user4769@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4770	Idzi	Samojlik	MEZCZYZNA	user4770	user4770@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4771	Jędrzej	Nazim	MEZCZYZNA	user4771	user4771@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4772	Sithabisiwe	Głąbczyńska	KOBIETA	user4772	user4772@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4773	Świętosław	Ćwiklik	MEZCZYZNA	user4773	user4773@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4774	Jingfei	Skudina	KOBIETA	user4774	user4774@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4775	Aleksy	Krezman	MEZCZYZNA	user4775	user4775@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4776	Korneliusz	Sałapat	MEZCZYZNA	user4776	user4776@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4777	Bảo châu	Sotirovska	KOBIETA	user4777	user4777@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4778	Hilal	Ortell	KOBIETA	user4778	user4778@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4779	Gardomir	Nagaba	MEZCZYZNA	user4779	user4779@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4780	Ksawery	Bachurek	MEZCZYZNA	user4780	user4780@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4781	Shaohua	Demczyna	KOBIETA	user4781	user4781@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4782	Oswald	Oskulski	MEZCZYZNA	user4782	user4782@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4783	Lizan	Tytenko	KOBIETA	user4783	user4783@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4784	Verda	Chrabołowska	KOBIETA	user4784	user4784@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4785	Yeonsoo	Plein	KOBIETA	user4785	user4785@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4786	Nikodem	Paśniewski	MEZCZYZNA	user4786	user4786@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4787	Chwalimir	Kunsztowicz	MEZCZYZNA	user4787	user4787@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4788	Wirgiliusz	Butrymowski	MEZCZYZNA	user4788	user4788@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4789	Lusjana	Horhola	KOBIETA	user4789	user4789@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4790	Ibeth	Mapuranga	KOBIETA	user4790	user4790@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4791	Gardomir	Subbotko	MEZCZYZNA	user4791	user4791@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4792	Gustaw	Grajper	MEZCZYZNA	user4792	user4792@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4793	Tess	Scott-pomesna	KOBIETA	user4793	user4793@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4794	Suzette	Friszkemut	KOBIETA	user4794	user4794@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4795	Olaf	Bartłomiej	MEZCZYZNA	user4795	user4795@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4796	Diviya	Pepchuk	KOBIETA	user4796	user4796@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4797	Cleopatra	Ban	KOBIETA	user4797	user4797@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4798	Tunia	Piecak	KOBIETA	user4798	user4798@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4799	Godfryg	Opieczyński	MEZCZYZNA	user4799	user4799@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4800	Piotr	Kotyja	MEZCZYZNA	user4800	user4800@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4801	Rukiyat	Bigott	KOBIETA	user4801	user4801@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4802	Althea	Aleksiejenko	KOBIETA	user4802	user4802@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4803	Grzegorz	Trojga	MEZCZYZNA	user4803	user4803@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4804	Narcyz	Sztajglik	MEZCZYZNA	user4804	user4804@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4805	Hyerin	Makucewicz	KOBIETA	user4805	user4805@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4806	Lotem	Mamprejew	KOBIETA	user4806	user4806@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4807	Nannan	Najdenow	KOBIETA	user4807	user4807@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4808	Yesol	Hadzhylova	KOBIETA	user4808	user4808@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4809	Lesław	Zimny	MEZCZYZNA	user4809	user4809@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4810	Sevcan	Sztajnke	KOBIETA	user4810	user4810@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4811	Sofroniusz	Pryszcz	MEZCZYZNA	user4811	user4811@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4812	Radowit	Zylka	MEZCZYZNA	user4812	user4812@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4813	Oktaviia	Bernakiewicz-rek	KOBIETA	user4813	user4813@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4814	Jyothi	Derebchynska	KOBIETA	user4814	user4814@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4815	Jonatan	Słotki	MEZCZYZNA	user4815	user4815@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4816	Charlotta	Pliakun	KOBIETA	user4816	user4816@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4817	Edwin	Dembowski	MEZCZYZNA	user4817	user4817@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4818	Burulkan	Vasylyshyn-zaripova	KOBIETA	user4818	user4818@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4819	Gustaw	Łuniewski	MEZCZYZNA	user4819	user4819@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4820	Ronald	Tołyż	MEZCZYZNA	user4820	user4820@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4821	Hasan	Hołubasz	MEZCZYZNA	user4821	user4821@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4822	Marceli	De jakusz-gostomski	MEZCZYZNA	user4822	user4822@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4823	Cyryl	Tyrpuła	MEZCZYZNA	user4823	user4823@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4824	Kazimierz	Cwalina	MEZCZYZNA	user4824	user4824@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4825	Visalakshi	Krykwa	KOBIETA	user4825	user4825@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4826	Wielisława	Żamojtuk	KOBIETA	user4826	user4826@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4827	Więcesław	Puszkarów	MEZCZYZNA	user4827	user4827@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4828	Maksymilian	Cimiński	MEZCZYZNA	user4828	user4828@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4829	Janka	Kwaśniak	KOBIETA	user4829	user4829@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4830	Mirod	Pipiak	MEZCZYZNA	user4830	user4830@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4831	Liliana	Szafrańska-kowalska	KOBIETA	user4831	user4831@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4832	Edgar	Melerski	MEZCZYZNA	user4832	user4832@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4833	Avi	De klerck	KOBIETA	user4833	user4833@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4834	Bogusz	Szopik	MEZCZYZNA	user4834	user4834@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4835	Lucjan	Aniśkowicz	MEZCZYZNA	user4835	user4835@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4836	Filip	Cichoski	MEZCZYZNA	user4836	user4836@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4837	Fryc	Szymonik	MEZCZYZNA	user4837	user4837@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4838	Więcesław	Piatnytskyi	MEZCZYZNA	user4838	user4838@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4839	Krzesisław	Kulbida	MEZCZYZNA	user4839	user4839@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4840	Jan	Wurst	MEZCZYZNA	user4840	user4840@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4841	Katica	Bakyt	KOBIETA	user4841	user4841@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4842	Kasjusz	Okruciński	MEZCZYZNA	user4842	user4842@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4843	Alijah	Somerska	KOBIETA	user4843	user4843@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4844	Aleksy	Brzęk	MEZCZYZNA	user4844	user4844@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4845	Żelisław	Remdziak	MEZCZYZNA	user4845	user4845@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4846	Hilary	Łastowiecki	MEZCZYZNA	user4846	user4846@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4847	Aiga	Dubalska	KOBIETA	user4847	user4847@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4848	Yefrosyniia	Srebrna	KOBIETA	user4848	user4848@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4849	Abelard	Gaweł	MEZCZYZNA	user4849	user4849@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4850	Ildefons	Zarośliński	MEZCZYZNA	user4850	user4850@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4851	Iordana	Relska	KOBIETA	user4851	user4851@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4852	Emelie	Nadgłowski	NIEOKRESLONY	user4852	user4852@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4853	Dildora	Korovnichenko	KOBIETA	user4853	user4853@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4854	Merlita	Velusamy	KOBIETA	user4854	user4854@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4855	Nayra	Yakovyshyna	KOBIETA	user4855	user4855@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4856	Minzifa	Jaćczak	KOBIETA	user4856	user4856@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4857	Olgierd	Polednia	MEZCZYZNA	user4857	user4857@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4858	Stefaniia	Saichenko	KOBIETA	user4858	user4858@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4859	Cyria	Kolianda	KOBIETA	user4859	user4859@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4860	Saat	Fydria	KOBIETA	user4860	user4860@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4861	Marceli	Parafińczuk	MEZCZYZNA	user4861	user4861@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4862	Prokop	Ciszewski	MEZCZYZNA	user4862	user4862@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4863	Dawid	Dyński	MEZCZYZNA	user4863	user4863@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4864	Liolia	Kamieniorz	KOBIETA	user4864	user4864@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4865	Sofroniusz	Boruciak	MEZCZYZNA	user4865	user4865@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4866	Gabriel	Bieluń	MEZCZYZNA	user4866	user4866@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4867	Adele	Sabov	KOBIETA	user4867	user4867@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4868	Dayana paola	Nescieruk	KOBIETA	user4868	user4868@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4869	Shahaf	Zadrożna	KOBIETA	user4869	user4869@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4870	Lūcija	Gikuma	KOBIETA	user4870	user4870@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4871	Tomasz	Solarz	MEZCZYZNA	user4871	user4871@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4872	Bogumił	Garbat	MEZCZYZNA	user4872	user4872@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4873	Dandan	Myzova	KOBIETA	user4873	user4873@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4874	Grzymisław	Wierski	MEZCZYZNA	user4874	user4874@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4875	Valeryia	Raspopin	KOBIETA	user4875	user4875@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4876	Vivi	Derets	KOBIETA	user4876	user4876@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4877	Kamolakhon	Krivoshlykova	KOBIETA	user4877	user4877@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4878	Zlata-adelina	Szkudłabska	KOBIETA	user4878	user4878@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4879	Thanh loan	Kiparoidze	KOBIETA	user4879	user4879@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4880	Mojmir	Pykało	MEZCZYZNA	user4880	user4880@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4881	Evie	Lianka	KOBIETA	user4881	user4881@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4882	Donald	Sipowski	MEZCZYZNA	user4882	user4882@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4883	Xiaoli	Emrykh	KOBIETA	user4883	user4883@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4884	Jona	Cębrowski	MEZCZYZNA	user4884	user4884@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4885	Irith	Sładek	KOBIETA	user4885	user4885@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4886	Lesław	Doromiejczuk	MEZCZYZNA	user4886	user4886@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4887	Anișoara	Drozella	KOBIETA	user4887	user4887@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4888	Delfina	Kuchcinski	NIEOKRESLONY	user4888	user4888@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4889	Barnim	Płonka	MEZCZYZNA	user4889	user4889@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4890	Dilia	Stanymyr	KOBIETA	user4890	user4890@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4891	Norman	Śmietanowski	MEZCZYZNA	user4891	user4891@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4892	Bozhena	Malańkowska	KOBIETA	user4892	user4892@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4893	Samrawit	Uras	KOBIETA	user4893	user4893@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4894	Astrid	Budasova	KOBIETA	user4894	user4894@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4895	Thi nhuan	Toroshelidze	KOBIETA	user4895	user4895@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4896	Yelyzavieta	Kurczewska	KOBIETA	user4896	user4896@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4897	Bonifacy	Zubko	MEZCZYZNA	user4897	user4897@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4898	Kain	Superczyński	MEZCZYZNA	user4898	user4898@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4899	Justynian	Pyk	MEZCZYZNA	user4899	user4899@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4900	Zachariasz	Wieleba	MEZCZYZNA	user4900	user4900@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4901	Hanusz	Kemski	MEZCZYZNA	user4901	user4901@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4902	Petroniusz	Psiuk	MEZCZYZNA	user4902	user4902@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4903	Iwan	Szczubliński	MEZCZYZNA	user4903	user4903@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4904	Weining	Hejncelman	KOBIETA	user4904	user4904@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4905	Khapta	Niemczenia	KOBIETA	user4905	user4905@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4906	Lech	Majnardi	MEZCZYZNA	user4906	user4906@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4907	Ma. eloisa	Werba	KOBIETA	user4907	user4907@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4908	Michala	Grabowska-jankowska	KOBIETA	user4908	user4908@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4909	Herlen	Delcea	KOBIETA	user4909	user4909@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4910	Mateusz	Woodburn	MEZCZYZNA	user4910	user4910@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4911	Eylem	Van ooteghem	KOBIETA	user4911	user4911@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4912	Symeon	Ruban	MEZCZYZNA	user4912	user4912@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4913	Karakoz	Yendaltseva	KOBIETA	user4913	user4913@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4914	Iwan	Gątnicki	MEZCZYZNA	user4914	user4914@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4915	Tolesława	Probitiuk	KOBIETA	user4915	user4915@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4916	Antonin	Rybarzewski	MEZCZYZNA	user4916	user4916@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4917	Natsuko	Kych	KOBIETA	user4917	user4917@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4918	Dianne	Khikhlova	KOBIETA	user4918	user4918@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4919	Akshatha	Virovska	KOBIETA	user4919	user4919@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4920	Lilianne	Lyb	KOBIETA	user4920	user4920@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4921	Leonard	Kaczyk	MEZCZYZNA	user4921	user4921@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4922	Ni̇lüfer	Bumen	KOBIETA	user4922	user4922@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4923	Apollo	Drejs	MEZCZYZNA	user4923	user4923@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4924	Petroniusz	Sylwanowski	MEZCZYZNA	user4924	user4924@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4925	Bidhya	Lick	KOBIETA	user4925	user4925@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4926	Anzhella	Chystiakova	KOBIETA	user4926	user4926@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4927	Kanwal	Bruż	KOBIETA	user4927	user4927@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4928	Giedrė	Sarnecka-sługocka	KOBIETA	user4928	user4928@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4929	Karol	Stanuch	MEZCZYZNA	user4929	user4929@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4930	Savvina	Novoselsky	KOBIETA	user4930	user4930@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4931	Ilknur	Pichkobii	KOBIETA	user4931	user4931@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4932	So jeong	Schübbe	KOBIETA	user4932	user4932@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4933	Ścibor	Hoerner de roithberg	MEZCZYZNA	user4933	user4933@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4934	Wiesław	Kuleczka	MEZCZYZNA	user4934	user4934@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4935	Dargosław	Piskosz	MEZCZYZNA	user4935	user4935@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4936	Thi sinh	Yeutukhova	KOBIETA	user4936	user4936@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4937	Benan	Raiza	KOBIETA	user4937	user4937@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4938	Damian	Dziurdzia	MEZCZYZNA	user4938	user4938@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4939	Donald	Saletnik	MEZCZYZNA	user4939	user4939@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4940	Marcin	Puszkarek	MEZCZYZNA	user4940	user4940@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4941	Siela	Kulevska	KOBIETA	user4941	user4941@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4942	Jiexi	Szczegielniak	KOBIETA	user4942	user4942@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4943	Saren	Zavoiovska	KOBIETA	user4943	user4943@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4944	Hranush	Golikova	KOBIETA	user4944	user4944@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4945	Klaudiusz	Piaszczyk	MEZCZYZNA	user4945	user4945@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4946	Iwon	Łaksa	MEZCZYZNA	user4946	user4946@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4947	Gali	Reminna	KOBIETA	user4947	user4947@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4948	Gilbert	Drożdżowicz	MEZCZYZNA	user4948	user4948@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4949	Alwin	Gallas	MEZCZYZNA	user4949	user4949@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4950	Bogusz	Berych	MEZCZYZNA	user4950	user4950@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4951	Gena	Młodzianowska	KOBIETA	user4951	user4951@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4952	Adira	Polynovska	KOBIETA	user4952	user4952@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4953	Lena-maria	Czekajło-germer	KOBIETA	user4953	user4953@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4954	Ruma	Azuaje sanchez	KOBIETA	user4954	user4954@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4955	Fira	Jandulska	KOBIETA	user4955	user4955@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4956	Ellin	Etowska	KOBIETA	user4956	user4956@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4957	Donat	Lincner	MEZCZYZNA	user4957	user4957@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4958	Ioana-nicoleta	Chukhaturian	KOBIETA	user4958	user4958@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4959	Stefan	Szelugowski	MEZCZYZNA	user4959	user4959@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4960	Kudzaishe	Dzvelaia	KOBIETA	user4960	user4960@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4961	Lubisław	Mink	MEZCZYZNA	user4961	user4961@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4962	Munisahon	Voits	KOBIETA	user4962	user4962@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4963	Iwon	Pachliński	MEZCZYZNA	user4963	user4963@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4964	Artur	Cylke	MEZCZYZNA	user4964	user4964@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4965	Nikodem	Szaleniec	MEZCZYZNA	user4965	user4965@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4966	Romeo	Nasulewicz	MEZCZYZNA	user4966	user4966@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4967	Fetije	Neza	KOBIETA	user4967	user4967@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4968	Gulchin	Gabrychowicz	KOBIETA	user4968	user4968@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4969	Pabian	Przepłata	MEZCZYZNA	user4969	user4969@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4970	Rynata	Czesynek	KOBIETA	user4970	user4970@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4971	Tiina	Chraniuk	KOBIETA	user4971	user4971@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4972	Lijana	Nehliadova	KOBIETA	user4972	user4972@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4973	Krystyn	Gagjew	MEZCZYZNA	user4973	user4973@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4974	Roland	Czabok	MEZCZYZNA	user4974	user4974@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4975	Liudmyła	Żolinas	KOBIETA	user4975	user4975@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4976	Aden	Ostołowska	KOBIETA	user4976	user4976@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4977	Susi	Pogroszewska	KOBIETA	user4977	user4977@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4978	Asmaia	Niksdorf	KOBIETA	user4978	user4978@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4979	Adnan	Grzeczka	MEZCZYZNA	user4979	user4979@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4980	Fortunat	Wozowczyk	MEZCZYZNA	user4980	user4980@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4981	Jemalyn	Anghelenici	KOBIETA	user4981	user4981@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4982	Riyana	Hryhortsiv	KOBIETA	user4982	user4982@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4983	Sambor	Ankiewicz	MEZCZYZNA	user4983	user4983@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4984	Can	Strefner	KOBIETA	user4984	user4984@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4985	Rechla	Kaldarova	KOBIETA	user4985	user4985@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4986	Otokar	Klóziak	MEZCZYZNA	user4986	user4986@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4987	Ināra	Glabian	KOBIETA	user4987	user4987@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4988	Kamila	Bazaka	KOBIETA	user4988	user4988@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4989	Jamie	Futerhendler	KOBIETA	user4989	user4989@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4990	Huyền anh	El kaylany	KOBIETA	user4990	user4990@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4991	Yijun	Ahmad zai	KOBIETA	user4991	user4991@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4992	Marek	Ganczo	MEZCZYZNA	user4992	user4992@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4993	Marusia	Ciokalska	KOBIETA	user4993	user4993@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4994	Jarzębina	Honerkamp	KOBIETA	user4994	user4994@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4995	Margaretha	Legudzińska	KOBIETA	user4995	user4995@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4996	Gantuya	Tsakhno	KOBIETA	user4996	user4996@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4997	Shevchenko	Folleher	KOBIETA	user4997	user4997@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4998	Konradyn	Trzebunia	MEZCZYZNA	user4998	user4998@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
4999	Nadežda	Wikariusz	KOBIETA	user4999	user4999@biblioteka.local	domyslny_hash_do_zmiany	domyslna_sol_do_zmiany	\N	\N	\N	2025-11-06 14:17:08.75658	t
\.


--
-- Data for Name: wejscia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.wejscia (id_wejscia, id_osoby, id_filii, data_wejscia) FROM stdin;
2	1253	1	2025-02-05 07:16:23.807237
3	1253	1	2025-08-23 12:50:48.046287
4	1253	1	2025-01-24 04:59:46.865267
5	1253	1	2025-10-27 14:02:31.868269
6	1253	1	2025-04-11 03:29:55.178856
7	1253	1	2025-11-20 14:25:07.194869
8	1253	1	2024-12-29 15:16:15.741134
9	1253	1	2025-10-06 09:17:01.21015
10	1253	1	2025-12-02 11:35:17.708997
11	1253	1	2025-08-31 06:07:47.348287
12	1253	1	2025-08-31 06:53:53.690446
13	1253	1	2025-06-18 15:24:19.783144
14	1253	1	2025-02-27 20:57:17.800896
15	1253	1	2025-11-19 23:37:53.251387
16	1253	1	2025-11-21 14:37:24.997583
17	1253	1	2025-09-14 17:31:16.81241
18	1253	1	2025-11-05 16:30:51.215446
19	1253	1	2025-01-03 22:42:57.264874
20	1253	1	2025-11-30 14:50:24.227417
21	1253	1	2025-05-09 22:18:13.554297
22	1253	1	2025-11-14 02:00:02.817395
23	1253	1	2025-11-08 01:02:00.216803
24	1253	1	2025-11-05 09:44:41.057993
25	1253	1	2025-05-20 15:03:14.04697
26	1253	1	2025-12-01 02:29:49.740427
27	1253	1	2025-08-05 08:30:17.236347
28	1253	1	2025-02-17 05:23:29.777201
29	1253	1	2025-06-14 18:13:37.99107
30	1253	1	2025-07-12 21:11:07.593489
31	1253	1	2025-04-16 05:04:22.015257
32	1253	1	2025-01-07 05:25:19.621277
33	1253	1	2025-03-07 02:19:49.091531
34	1253	1	2025-02-16 05:58:07.182424
35	1253	1	2025-05-09 02:01:24.832855
36	1253	1	2025-01-15 02:49:38.003577
37	1253	1	2025-02-11 07:23:43.401114
38	1253	1	2025-12-09 10:09:29.141527
39	1253	1	2025-01-29 11:44:38.959008
40	1253	1	2025-12-08 03:13:32.99301
41	1253	1	2025-11-01 02:28:58.162095
42	1253	1	2025-10-31 17:15:46.211281
43	1253	1	2025-12-09 14:36:12.309511
44	1253	1	2024-12-29 12:31:40.097293
45	1253	1	2025-10-19 15:17:28.401564
46	1253	1	2025-11-21 14:02:19.828353
47	1253	1	2025-06-15 12:12:46.903046
48	1253	1	2025-08-21 19:42:46.876214
49	1253	1	2025-03-22 10:46:46.860966
50	1253	1	2025-02-10 04:56:23.323675
51	1253	1	2025-04-01 06:53:59.954947
52	1253	1	2025-08-13 20:40:02.231932
53	1253	1	2025-10-22 20:07:31.294276
54	1253	1	2025-08-27 03:06:09.243766
55	1253	1	2025-03-13 10:54:19.591553
56	1253	1	2025-09-27 14:36:03.722072
57	1253	1	2025-12-03 18:57:08.119635
58	1253	1	2025-07-06 21:35:34.788991
59	1253	1	2025-03-11 08:00:41.384382
60	1253	1	2025-08-22 23:25:25.683826
61	1253	1	2025-03-03 17:05:44.302816
62	1253	1	2025-10-03 15:48:53.876958
63	1253	1	2025-04-10 08:27:43.861132
64	1253	1	2025-12-05 21:35:57.684238
65	1253	1	2025-08-20 04:06:58.178222
66	1253	1	2025-03-27 05:04:43.579426
67	1253	1	2025-07-01 12:55:49.911363
68	1253	1	2025-06-03 06:18:29.177549
69	1253	1	2025-03-04 22:49:14.526163
70	1253	1	2025-12-04 05:31:14.227797
71	1253	1	2025-07-06 01:51:49.445826
72	1253	1	2025-04-08 01:05:06.525931
73	1253	1	2025-03-31 16:55:29.893945
74	1253	1	2025-05-31 00:12:20.686907
75	1253	1	2025-10-29 22:04:14.403375
76	1253	1	2025-10-02 04:40:09.142958
77	1253	1	2025-11-03 03:15:50.117844
78	1253	1	2025-02-09 12:36:42.770182
79	1253	1	2024-12-21 15:02:11.88781
80	1253	1	2025-07-07 23:23:32.168676
81	1253	1	2025-03-11 18:52:18.304422
82	1253	1	2025-05-27 03:18:26.21072
83	1253	1	2025-06-15 06:04:49.779618
84	1253	1	2025-03-22 02:14:21.711002
85	1253	1	2025-05-26 04:44:05.806153
86	1253	1	2025-07-27 07:54:04.897265
87	1253	1	2025-05-05 23:29:32.279452
88	1253	1	2025-12-01 00:11:24.86516
89	1253	1	2025-08-21 15:03:36.485561
90	1253	1	2025-10-10 05:56:04.321399
91	1253	1	2025-08-13 04:44:47.277011
92	1253	1	2025-01-26 11:36:47.050805
93	1253	1	2025-09-07 20:55:53.112056
94	1253	1	2025-06-30 13:10:44.201162
95	1253	1	2025-01-01 12:09:41.201528
96	1253	1	2025-05-13 17:47:29.095385
97	1253	1	2025-09-21 19:21:31.127006
98	1253	1	2025-06-01 07:01:16.032509
99	1253	1	2024-12-19 22:32:01.211467
100	1253	1	2025-05-31 00:30:04.275053
101	1253	1	2025-02-08 15:37:45.278595
102	1253	1	2025-09-05 11:01:11.416623
103	1253	1	2025-08-10 17:36:58.973104
104	1253	1	2025-12-03 14:58:23.540964
105	1253	1	2025-10-29 21:45:15.171806
106	1253	1	2025-05-01 11:57:56.420416
107	1253	1	2025-12-03 18:45:50.197122
108	1253	1	2025-08-06 16:22:12.685299
109	1253	1	2025-11-13 16:13:34.827896
110	1253	1	2024-12-24 06:19:44.738439
111	1253	1	2025-10-17 00:42:57.747926
112	1253	1	2025-10-23 15:39:21.284582
113	1253	1	2025-01-28 17:25:12.085083
114	1253	1	2025-06-19 07:24:44.696712
115	1253	1	2025-11-20 16:19:44.185209
116	1253	1	2025-05-28 00:33:56.066019
117	1253	1	2025-05-18 13:42:13.686529
118	1253	1	2025-10-20 12:38:37.537785
119	1253	1	2025-10-26 17:26:55.348924
120	1253	1	2025-07-07 09:39:14.142944
121	1253	1	2025-05-23 01:15:50.092692
122	1253	1	2025-07-09 18:53:03.577547
123	1253	1	2025-03-23 23:23:05.883617
124	1253	1	2025-05-29 05:01:08.825461
125	1253	1	2025-09-11 20:20:50.993391
126	1253	1	2025-06-23 02:15:40.420771
127	1253	1	2025-06-14 00:00:38.389992
128	1253	1	2025-11-28 02:32:55.520572
129	1253	1	2025-12-10 20:33:22.643385
130	1253	1	2024-12-19 02:09:56.62391
131	1253	1	2025-06-29 00:01:39.533813
132	1253	1	2025-12-02 23:58:15.756236
133	1253	1	2025-09-02 16:47:03.236533
134	1253	1	2025-04-20 06:55:50.308121
135	1253	1	2025-02-28 16:31:21.870826
136	1253	1	2025-03-25 16:44:45.818894
137	1253	1	2025-08-23 07:28:39.964474
138	1253	1	2025-05-20 11:57:38.909341
139	1253	1	2025-12-15 17:48:32.879037
140	1253	1	2025-08-04 18:06:54.477339
141	1253	1	2025-12-13 08:24:23.308744
142	1253	1	2025-05-02 04:12:32.383953
143	1253	1	2025-05-05 11:25:16.213015
144	1253	1	2025-08-06 01:02:28.882301
145	1253	1	2025-10-25 10:39:56.269641
146	1253	1	2025-08-02 09:06:21.488331
147	1253	1	2025-09-19 22:56:44.17877
148	1253	1	2025-04-10 18:26:30.089818
149	1253	1	2025-09-10 03:52:44.87172
150	1253	1	2025-03-18 15:35:27.874634
151	1253	1	2025-03-16 01:53:32.954988
152	1555	4	2025-04-05 20:12:43.703227
153	1555	4	2025-02-18 03:54:45.302737
154	1555	4	2025-05-19 23:09:25.491257
155	1555	4	2024-12-22 14:29:37.776305
156	1555	4	2025-09-22 16:18:14.272466
157	1555	4	2025-02-02 02:58:55.432576
158	1555	4	2025-09-26 09:48:22.931554
159	1555	4	2025-11-06 16:05:14.705292
160	1555	4	2025-01-27 05:35:02.473363
161	1555	4	2025-01-25 05:28:50.238712
162	1555	4	2025-11-10 11:27:14.220697
163	1555	4	2025-07-31 10:23:51.706928
164	1555	4	2025-02-13 03:49:41.261551
165	1555	4	2025-06-17 05:21:48.701237
166	1555	4	2025-01-14 00:32:22.876311
167	1555	4	2025-01-01 06:24:10.889114
168	1555	4	2025-10-12 23:49:24.070364
169	1555	4	2025-10-06 06:07:39.168764
170	1555	4	2025-03-15 16:49:55.257064
171	1555	4	2025-08-26 08:36:34.610833
172	1555	4	2025-10-21 09:33:18.35979
173	1555	4	2025-10-03 11:34:34.531804
174	1555	4	2025-01-23 14:35:45.717424
175	1555	4	2025-08-05 01:45:25.277701
176	1555	4	2025-03-12 10:10:27.300325
177	1555	4	2025-04-16 18:09:21.483047
178	1555	4	2025-04-17 02:45:46.181998
179	1555	4	2025-07-15 12:53:09.949439
180	1555	4	2025-10-14 14:06:55.741851
181	1555	4	2025-07-07 04:47:22.712403
182	1555	4	2025-09-27 23:39:17.192121
183	1555	4	2025-05-27 07:51:09.784126
184	1555	4	2025-12-04 22:11:19.415013
185	1555	4	2025-09-24 04:25:23.234408
186	1555	4	2025-07-28 16:32:25.704687
187	1555	4	2025-11-15 18:29:09.925631
188	1555	4	2025-08-28 18:24:13.689091
189	1555	4	2025-03-29 04:40:29.579745
190	1555	4	2025-06-25 13:27:18.539031
191	1555	4	2025-01-13 14:55:48.718957
192	1555	4	2025-09-26 11:48:20.266448
193	1555	4	2025-07-30 15:50:38.0016
194	1555	4	2025-03-08 06:36:33.005645
195	1555	4	2025-02-09 06:22:19.89629
196	1555	4	2025-07-31 06:04:34.652003
197	1555	4	2025-08-20 06:11:49.40245
198	1555	4	2025-12-01 06:15:31.663333
199	1555	4	2025-06-07 23:14:46.337971
200	1555	4	2025-10-13 16:56:31.707361
201	1555	4	2025-12-16 13:56:34.469516
202	1555	4	2025-10-19 01:53:39.907869
203	1555	4	2024-12-24 20:16:06.032162
204	1555	4	2025-02-13 21:49:41.634295
205	1555	4	2025-01-23 17:34:26.859286
206	1555	4	2025-11-15 17:29:25.312572
207	1555	4	2025-10-04 03:23:37.088699
208	1555	4	2025-01-27 00:53:01.831287
209	1555	4	2025-05-16 12:12:59.342252
210	1555	4	2025-06-16 10:37:26.81188
211	1555	4	2025-08-08 03:46:51.113593
212	1555	4	2025-12-15 19:53:33.720688
213	1555	4	2025-01-04 17:50:33.576993
214	1555	4	2025-09-12 00:03:20.381641
215	1555	4	2025-07-11 09:41:05.159926
216	1555	4	2025-06-11 16:31:40.433447
217	1555	4	2025-02-07 23:32:32.360993
218	1555	4	2025-10-20 05:27:55.81228
219	1555	4	2025-01-28 11:41:31.866977
220	1555	4	2025-05-10 17:16:07.679153
221	1555	4	2025-12-17 00:07:21.601204
222	1555	4	2025-03-30 17:02:23.954609
223	1555	4	2025-10-08 07:40:24.079329
224	1555	4	2025-03-16 03:36:43.437531
225	1555	4	2025-10-19 19:43:04.99188
226	1555	4	2025-09-22 21:40:27.68891
227	1555	4	2025-05-10 21:13:51.5793
228	1555	4	2025-04-12 04:01:34.231665
229	1555	4	2025-01-29 23:42:32.662711
230	1555	4	2025-08-30 07:20:27.373671
231	1555	4	2025-12-12 21:45:00.785008
232	1555	4	2025-04-13 01:13:41.264413
233	1555	4	2025-04-18 16:27:11.218873
234	1555	4	2025-03-24 09:46:22.098051
235	1555	4	2025-10-21 16:29:28.767436
236	1555	4	2025-07-28 21:21:02.676494
237	1555	4	2025-06-07 01:38:17.457955
238	1555	4	2025-11-09 18:11:54.791334
239	1555	4	2025-11-19 18:45:24.658923
240	1555	4	2025-11-03 18:35:19.611039
241	1555	4	2025-05-13 08:44:59.101327
242	1555	4	2025-05-30 18:50:11.292011
243	1555	4	2025-06-14 10:53:06.209785
244	1555	4	2025-05-13 05:48:58.297351
245	1555	4	2025-06-19 00:47:29.926944
246	1555	4	2025-11-18 13:01:55.96985
247	1555	4	2025-01-29 02:39:57.757528
248	1555	4	2025-07-05 05:36:08.737732
249	1555	4	2025-04-02 19:50:36.370833
250	1555	4	2025-02-21 08:44:34.166213
251	1555	4	2025-09-19 18:48:50.256554
252	1555	4	2025-04-28 12:35:37.867324
253	1555	4	2025-02-04 05:08:10.982998
254	1555	4	2025-10-07 19:47:53.186916
255	1555	4	2025-03-21 09:34:20.668953
256	1555	4	2025-11-08 13:46:09.895389
257	1555	4	2024-12-29 21:11:37.281219
258	1555	4	2025-08-29 22:08:00.492504
259	1555	4	2025-06-11 16:40:45.952132
260	1555	4	2025-06-03 00:56:40.750682
261	1555	4	2025-03-23 13:55:50.350629
262	1555	4	2025-11-10 19:29:53.598336
263	1555	4	2025-10-15 21:35:43.673061
264	1555	4	2025-11-06 08:11:23.731672
265	1555	4	2025-07-29 18:28:42.021209
266	1555	4	2025-10-29 00:52:41.575817
267	1555	4	2025-09-24 21:34:11.181276
268	1555	4	2025-06-04 03:11:29.950208
269	1555	4	2025-08-28 09:05:49.225333
270	1555	4	2025-11-14 07:47:22.64394
271	1555	4	2025-07-15 23:21:22.817778
272	1555	4	2025-07-20 05:22:56.134231
273	1555	4	2025-02-22 16:39:23.9643
274	1555	4	2025-09-14 15:18:23.113297
275	1555	4	2025-05-14 13:36:05.690492
276	1555	4	2025-11-18 03:22:18.318015
277	1555	4	2025-05-26 03:28:30.394565
278	1555	4	2024-12-17 22:19:24.267388
279	1555	4	2025-01-16 00:31:09.345055
280	1555	4	2025-03-26 11:01:13.278759
281	1555	4	2025-04-30 13:41:12.139664
282	1555	4	2025-09-17 21:46:02.476953
283	1555	4	2024-12-25 22:59:00.193952
284	1555	4	2025-05-15 19:55:21.708241
285	1555	4	2025-01-28 18:27:14.69063
286	1555	4	2025-11-15 18:19:03.202774
287	1555	4	2025-08-18 10:00:30.717402
288	1555	4	2025-06-17 20:57:54.344785
289	1555	4	2025-03-11 02:39:06.445247
290	1555	4	2025-10-22 15:53:37.609123
291	1555	4	2025-08-11 06:44:04.352925
292	1555	4	2025-06-18 13:46:57.390035
293	1555	4	2025-06-02 05:51:20.643148
294	1555	4	2025-02-05 16:02:26.372596
295	1555	4	2025-12-06 13:29:35.726121
296	1555	4	2025-07-03 13:40:20.979055
297	1555	4	2025-07-22 22:54:09.24214
298	1555	4	2025-05-27 14:43:07.571405
299	1555	4	2025-08-17 07:10:43.733027
300	1555	4	2025-09-21 14:30:43.369365
301	1555	4	2025-03-03 09:44:29.895415
\.


--
-- Data for Name: wypozyczenia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.wypozyczenia (id_wypozyczenia, id_osoby, id_ksiazki, data_wypozyczenia, planowana_data_zwrotu) FROM stdin;
\.


--
-- Data for Name: zwroty; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zwroty (id_wypozyczenia, data_zwrotu) FROM stdin;
\.


--
-- Name: filie_id_filii_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.filie_id_filii_seq', 10, true);


--
-- Name: kary_id_kary_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kary_id_kary_seq', 110, true);


--
-- Name: kategorie_id_kategorii_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kategorie_id_kategorii_seq', 24, true);


--
-- Name: komentarze_id_komentarza_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.komentarze_id_komentarza_seq', 121, true);


--
-- Name: rezerwacje_id_rezerwacji_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rezerwacje_id_rezerwacji_seq', 131, true);


--
-- Name: rodzaje_kar_id_rodzaju_kary_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rodzaje_kar_id_rodzaju_kary_seq', 6, true);


--
-- Name: wejscia_id_wejscia_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.wejscia_id_wejscia_seq', 301, true);


--
-- Name: filie filie_adres_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.filie
    ADD CONSTRAINT filie_adres_key UNIQUE (adres);


--
-- Name: filie filie_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.filie
    ADD CONSTRAINT filie_pkey PRIMARY KEY (id_filii);


--
-- Name: kary kary_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kary
    ADD CONSTRAINT kary_pkey PRIMARY KEY (id_kary);


--
-- Name: kategorie kategorie_nazwa_kategorii_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kategorie
    ADD CONSTRAINT kategorie_nazwa_kategorii_key UNIQUE (nazwa_kategorii);


--
-- Name: kategorie kategorie_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kategorie
    ADD CONSTRAINT kategorie_pkey PRIMARY KEY (id_kategorii);


--
-- Name: komentarze komentarze_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.komentarze
    ADD CONSTRAINT komentarze_pkey PRIMARY KEY (id_komentarza);


--
-- Name: ksiazki ksiazki_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ksiazki
    ADD CONSTRAINT ksiazki_pkey PRIMARY KEY (id_ksiazki);


--
-- Name: uzytkownicy osoby_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.uzytkownicy
    ADD CONSTRAINT osoby_pkey PRIMARY KEY (id_osoby);


--
-- Name: rezerwacje rezerwacje_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rezerwacje
    ADD CONSTRAINT rezerwacje_pkey PRIMARY KEY (id_rezerwacji);


--
-- Name: rodzaje_kar rodzaje_kar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rodzaje_kar
    ADD CONSTRAINT rodzaje_kar_pkey PRIMARY KEY (id_rodzaju_kary);


--
-- Name: ksiazki unikalny_egzemplarz; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ksiazki
    ADD CONSTRAINT unikalny_egzemplarz UNIQUE (nr_isbn, numer_inwentarzowy);


--
-- Name: uzytkownicy uq_email; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.uzytkownicy
    ADD CONSTRAINT uq_email UNIQUE (email);


--
-- Name: uzytkownicy uq_login; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.uzytkownicy
    ADD CONSTRAINT uq_login UNIQUE (login);


--
-- Name: uzytkownicy uzytkownicy_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.uzytkownicy
    ADD CONSTRAINT uzytkownicy_email_key UNIQUE (email);


--
-- Name: uzytkownicy uzytkownicy_login_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.uzytkownicy
    ADD CONSTRAINT uzytkownicy_login_key UNIQUE (login);


--
-- Name: wejscia wejscia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wejscia
    ADD CONSTRAINT wejscia_pkey PRIMARY KEY (id_wejscia);


--
-- Name: wypozyczenia wypozyczenia_id_ksiazki_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wypozyczenia
    ADD CONSTRAINT wypozyczenia_id_ksiazki_key UNIQUE (id_ksiazki);


--
-- Name: wypozyczenia wypozyczenia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wypozyczenia
    ADD CONSTRAINT wypozyczenia_pkey PRIMARY KEY (id_wypozyczenia);


--
-- Name: zwroty zwroty_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zwroty
    ADD CONSTRAINT zwroty_pkey PRIMARY KEY (id_wypozyczenia);


--
-- Name: zwroty trg_walidacja_daty_zwrotu; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_walidacja_daty_zwrotu BEFORE INSERT OR UPDATE ON public.zwroty FOR EACH ROW EXECUTE FUNCTION public.sprawdz_date_zwrotu();


--
-- Name: ksiazki fk_filia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ksiazki
    ADD CONSTRAINT fk_filia FOREIGN KEY (id_filii) REFERENCES public.filie(id_filii);


--
-- Name: ksiazki fk_kategoria; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ksiazki
    ADD CONSTRAINT fk_kategoria FOREIGN KEY (id_kategorii) REFERENCES public.kategorie(id_kategorii);


--
-- Name: wypozyczenia fk_ksiazka; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wypozyczenia
    ADD CONSTRAINT fk_ksiazka FOREIGN KEY (id_ksiazki) REFERENCES public.ksiazki(id_ksiazki) ON DELETE CASCADE;


--
-- Name: wypozyczenia fk_osoba; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wypozyczenia
    ADD CONSTRAINT fk_osoba FOREIGN KEY (id_osoby) REFERENCES public.uzytkownicy(id_osoby) ON DELETE CASCADE;


--
-- Name: zwroty fk_wypozyczenie; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zwroty
    ADD CONSTRAINT fk_wypozyczenie FOREIGN KEY (id_wypozyczenia) REFERENCES public.wypozyczenia(id_wypozyczenia) ON DELETE CASCADE;


--
-- Name: kary kary_id_osoby_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kary
    ADD CONSTRAINT kary_id_osoby_fkey FOREIGN KEY (id_osoby) REFERENCES public.uzytkownicy(id_osoby);


--
-- Name: kary kary_id_rodzaju_kary_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kary
    ADD CONSTRAINT kary_id_rodzaju_kary_fkey FOREIGN KEY (id_rodzaju_kary) REFERENCES public.rodzaje_kar(id_rodzaju_kary);


--
-- Name: kary kary_id_wypozyczenia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kary
    ADD CONSTRAINT kary_id_wypozyczenia_fkey FOREIGN KEY (id_wypozyczenia) REFERENCES public.wypozyczenia(id_wypozyczenia);


--
-- Name: komentarze komentarze_id_osoby_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.komentarze
    ADD CONSTRAINT komentarze_id_osoby_fkey FOREIGN KEY (id_osoby) REFERENCES public.uzytkownicy(id_osoby);


--
-- Name: rezerwacje rezerwacje_id_filii_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rezerwacje
    ADD CONSTRAINT rezerwacje_id_filii_fkey FOREIGN KEY (id_filii) REFERENCES public.filie(id_filii);


--
-- Name: rezerwacje rezerwacje_id_osoby_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rezerwacje
    ADD CONSTRAINT rezerwacje_id_osoby_fkey FOREIGN KEY (id_osoby) REFERENCES public.uzytkownicy(id_osoby);


--
-- Name: wejscia wejscia_id_filii_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wejscia
    ADD CONSTRAINT wejscia_id_filii_fkey FOREIGN KEY (id_filii) REFERENCES public.filie(id_filii);


--
-- Name: wejscia wejscia_id_osoby_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wejscia
    ADD CONSTRAINT wejscia_id_osoby_fkey FOREIGN KEY (id_osoby) REFERENCES public.uzytkownicy(id_osoby);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--
-- Tworzymy rolę bibliotekarza (jeśli nie istnieje)
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'bibliotekarz') THEN
    CREATE ROLE bibliotekarz WITH LOGIN PASSWORD 'haslo123';
  END IF;
END
$$;

-- Tworzymy rolę gościa (jeśli nie istnieje)
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'gosc_biblioteki') THEN
    CREATE ROLE gosc_biblioteki WITH LOGIN PASSWORD 'gosc123';
  END IF;
END
$$;
GRANT USAGE ON SCHEMA public TO bibliotekarz;
GRANT USAGE ON SCHEMA public TO gosc_biblioteki;


--
-- Name: TABLE filie; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.filie TO bibliotekarz;
GRANT SELECT ON TABLE public.filie TO gosc_biblioteki;


--
-- Name: SEQUENCE filie_id_filii_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.filie_id_filii_seq TO bibliotekarz;


--
-- Name: TABLE kary; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.kary TO bibliotekarz;


--
-- Name: SEQUENCE kary_id_kary_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.kary_id_kary_seq TO bibliotekarz;


--
-- Name: TABLE kategorie; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.kategorie TO bibliotekarz;
GRANT SELECT ON TABLE public.kategorie TO gosc_biblioteki;


--
-- Name: SEQUENCE kategorie_id_kategorii_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.kategorie_id_kategorii_seq TO bibliotekarz;


--
-- Name: TABLE komentarze; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.komentarze TO bibliotekarz;


--
-- Name: SEQUENCE komentarze_id_komentarza_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.komentarze_id_komentarza_seq TO bibliotekarz;


--
-- Name: TABLE ksiazki; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ksiazki TO bibliotekarz;
GRANT SELECT ON TABLE public.ksiazki TO gosc_biblioteki;


--
-- Name: TABLE rezerwacje; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.rezerwacje TO bibliotekarz;


--
-- Name: SEQUENCE rezerwacje_id_rezerwacji_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.rezerwacje_id_rezerwacji_seq TO bibliotekarz;


--
-- Name: TABLE rodzaje_kar; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.rodzaje_kar TO bibliotekarz;


--
-- Name: SEQUENCE rodzaje_kar_id_rodzaju_kary_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.rodzaje_kar_id_rodzaju_kary_seq TO bibliotekarz;


--
-- Name: TABLE uzytkownicy; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.uzytkownicy TO bibliotekarz;


--
-- Name: TABLE wypozyczenia; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.wypozyczenia TO bibliotekarz;


--
-- Name: TABLE zwroty; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.zwroty TO bibliotekarz;


--
-- Name: TABLE view_dluznicy; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.view_dluznicy TO bibliotekarz;


--
-- Name: TABLE view_top_ksiazki; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.view_top_ksiazki TO bibliotekarz;


--
-- Name: TABLE wejscia; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.wejscia TO bibliotekarz;


--
-- Name: SEQUENCE wejscia_id_wejscia_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.wejscia_id_wejscia_seq TO bibliotekarz;


--
-- PostgreSQL database dump complete
--

\unrestrict sHLN4kdDFxmF0kHxkGT8eq8mEEnyyOT1n8DeC5MvBVbLRYdF1PviRLPjj52Jy6v

