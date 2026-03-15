
-- Utfört av Alexander Johansson YH25

CREATE DATABASE inlamning1; -- skapar databasen som motsvarar en liten bokhandel
USE inlamning1; -- använder databasen för att kunna ändra/läsa av innehållet i databasen.



 -- Skapa Kunder-tabellen med fem attributer som innehåller kundinformation
CREATE TABLE Kunder (   
    KundID INT AUTO_INCREMENT PRIMARY KEY, 
    Namn VARCHAR(100) NOT NULL, 
    Epost VARCHAR(255) UNIQUE NOT NULL, 
    Telefon VARCHAR(30) NOT NULL,
    Adress VARCHAR(100) NOT NULL
);

-- Skapa Kundloggs-tabellen med information som är relevant för loggning
CREATE TABLE Kundlogg (
    LoggID INT AUTO_INCREMENT PRIMARY KEY,
    KundID INT, 
    Handelse VARCHAR(255),
    Loggdatum TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (KundID) REFERENCES Kunder(KundID) ON DELETE SET NULL
);

 -- Skapa Bocker-tabellen med sex attributer som innehåller information om böcker
CREATE TABLE Bocker (  
    ISBN BIGINT PRIMARY KEY, -- Böckernas ID nummer i form av ISBN (ISBN är unikt för boken)
    Forfattare VARCHAR(100) NOT NULL,
    Genre VARCHAR(50) NOT NULL,
    Titel VARCHAR(100) NOT NULL,
    Pris DECIMAL(10,2) NOT NULL CHECK (Pris > 0),  -- CHECK gör så att värdet måste vara större än 0 (Punkt 2 i 5.)
    Lagerstatus INT NOT NULL
);

-- Skapa Bestallningar-tabellen med fyra attributer som innehåller information om beställning
CREATE TABLE Bestallningar ( 
	Ordernummer INT AUTO_INCREMENT PRIMARY KEY,
    KundID INT NOT NULL,
    Totalbelopp DECIMAL(10,2) NOT NULL CHECK (Totalbelopp > 0), -- CHECK gör så att värdet måste vara större än 0.
    Datum TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (KundID) REFERENCES Kunder(KundID) -- Lånar primärnyckel från KundID i Kunder-tabellen
);

-- Skapa Orderrader-tabellen med fyra attributer som innehåller orderinformation
CREATE TABLE Orderrader (   
    OrderradID INT AUTO_INCREMENT PRIMARY KEY, 
    ISBN BIGINT NOT NULL,
    Ordernummer INT NOT NULL,
    Antal INT NOT NULL CHECK (Antal > 0), 
    FOREIGN KEY (Ordernummer) REFERENCES Bestallningar(Ordernummer), -- Lånar primärnyckel från ordernummer i Bestallningar-tabellen 
    FOREIGN KEY (ISBN) REFERENCES Bocker(ISBN) -- Lånar primärnyckel från ISBN i Böcker-tabellen 
);




-- Skapa en trigger som uppdaterar lagerstatus efter en beställnings gjorts (punkt 3 & 4 i 5.)
DELIMITER $$

-- Första triggern
CREATE TRIGGER logga_ny_kund
AFTER INSERT ON Kunder
FOR EACH ROW
BEGIN
   INSERT INTO Kundlogg (KundID)
   VALUES (NEW.KundID);
END $$

-- Andra triggern
CREATE TRIGGER uppdatera_lagersaldo
AFTER INSERT ON Orderrader
FOR EACH ROW 
BEGIN
    UPDATE Bocker
    SET Lagerstatus = Lagerstatus - NEW.Antal
    WHERE ISBN = NEW.ISBN;
END $$

DELIMITER ;





-- Infogar data i Kunder-tabellen
INSERT INTO Kunder (Namn, Epost, Telefon, Adress) VALUES 
    ('Paul Atreides', 'paul.atreides@dune.com', '123', 'Arrakis'),
    ('Duncan Idaho', 'duncan.idaho@dune.com', '456', 'Arrakis'),
    ('Glossu Rabban', 'glossu.rabban@dune.com', '789', 'Arrakis'),
    ('Test Deletion', 'testdeletion@dune.com', '101112', 'Arrakis');

-- infogar data i Böcker-tabellen
INSERT INTO Bocker (ISBN, Forfattare, Genre, Titel, Pris, Lagerstatus) VALUES 
    ('9834032234', 'Frank Herbert', 'Sci-fi', 'Dune', 79.99, 10), 
    ('9634982340', 'Ravrek al-Dahim', 'Sci-fi', 'Chronicles of the Spice Horizon', 99.99, 3),
    ('9324234311', 'Brian Herbet', 'Sci-fi', 'Dune: House Atreides', 119.99, 5);

-- infogar data i Beställningar-tabellen
INSERT INTO Bestallningar (KundID, Totalbelopp) VALUES
    (1, 79.99),
	(1, 239.98),
    (1, 99.99),
    (2, 99.99),
    (3, 199.98);   

-- infogar data i Orderrader-tabellen
INSERT INTO Orderrader (ISBN, Ordernummer, Antal) VALUES
    (9834032234, 1, 1),  
    (9634982340, 2, 1),   
    (9324234311, 3, 2),
    (9324234311, 4, 2),
    (9634982340, 5, 1);
    
    

-- För att få fram resultat visuellt från tabellerna.

SELECT * FROM Kunder; -- Hämtar data från Kunder-tabellen.
SELECT * FROM Bocker; -- Hämtar data från Böcker-tabellen.
SELECT * FROM Orderrader; -- Hämtar data från Orderrader-tabellen.
SELECT * FROM Bestallningar; -- Hämtar data från Bestallningar-tabellen.


SELECT * FROM Kunder WHERE Namn = 'Paul Atreides';  -- Hämtar endast specifik namndata från Kunder-tabellen .
SELECT * FROM Bocker WHERE Pris > 100; -- Hämtar endast böcker som kostar över 100kr från Böcker-tabellen .
SELECT * FROM Bocker ORDER BY Pris DESC; -- Hämtar data med sorterat pris från Böcker-tabellen
SELECT Ordernummer FROM Orderrader WHERE Antal > 1; -- Hämtar alla ordernummer där det beställts fler än 1 exemplar av en bok
SELECT * FROM Bestallningar WHERE Totalbelopp > 100;  -- Hämtar alla bestallningar där totalbeloppet är mer än 100kr


-- Ta reda på hur tabellerna är uppbyggda.
DESCRIBE Kunder;
DESCRIBE Bocker;
DESCRIBE Bestallningar;
DESCRIBE Orderrader;



/*
Där det står NOT NULL måste det stå något. 
Där det står CHECK så måste värdet vara större än 0
Primary key samt UNIQUE NOT NULL är unika värden som MÅSTE vara unika.
ISBN är som böckernas "personnummer" är unikt och ändras inte. 


När man exekverar raderna 4-69 så skapas databasen, tabellerna + attributerna samt lite data infogas även i tabellerna.
Jag har adderat några SELECT FROM så att man kan visa resultat av tabellerna rent visuellt.

*/




-- Inlämning2, påbyggnad av första inlämningen --





-- 2. Hämta, filtrera och sortera data
-- Hämtar all data från Kunder och Beställningar-tabellen (punkt 1)
SELECT * FROM Kunder 
INNER JOIN Bestallningar ON Kunder.KundID = Bestallningar.KundID;



-- Hämta kunden som har X namn och X epost (punkt 2)
SELECT * FROM Kunder 
WHERE Namn = 'Paul Atreides' AND Epost = 'paul.atreides@dune.com';


-- Hämtar data med fallande pris från Böcker-tabellen (punkt 3)
SELECT * FROM Bocker ORDER BY Pris DESC;







-- Modifiera DATA (UPDATE, DELETE, TRANSAKATIONER)
-- Uppdatera kund med ID 1's epost-adress (punkt 1)
UPDATE Kunder
SET Epost = 'paul.atreides2@dune.com'
WHERE KundID = 1;


 -- Kolla så att kunden fanns, blev borttagen samt rollbackad (punkt 2)
SELECT * FROM Kunder; 

-- Påbörja möjligheten att kunna ångra framtida ändringar
START TRANSACTION; 

-- Ta bort Test Deletion som kund.
DELETE FROM Kunder
WHERE KundID = 1; 

-- Rollbacka senaste ändringen
ROLLBACK;










-- Arbeta med JOINS & GROUP BY
-- Se vilka kunder som har lagt beställningar (punkt 1)
SELECT Kunder.Namn, Bestallningar.Ordernummer 
FROM Kunder 
INNER JOIN Bestallningar ON
Kunder.KundID = Bestallningar.KundID
ORDER BY Bestallningar.Ordernummer ASC;


-- Se alla kunder även de som inte har lagt beställningar (punkt 2)
SELECT Kunder.Namn, Bestallningar.Ordernummer
FROM Kunder LEFT JOIN
Bestallningar ON
Kunder.KundID = Bestallningar.KundID
ORDER BY Bestallningar.Ordernummer ASC;



-- Hämta hur många beställningar varje kund har lagt. (punkt 3)
SELECT KundID, COUNT(KundID) 
AS 'Antal Beställningar' 
FROM Bestallningar
GROUP BY KundID;

-- Visa endast de kunder lagt fler än 2 beställningar (punkt 4)
SELECT KundID, COUNT(Ordernummer)
AS 'Antal Beställningar'
FROM Bestallningar
GROUP BY KundID 
HAVING COUNT(Ordernummer) > 2;


-- Index, Constraints & Triggers
-- Skapa index på e-post i Kunder (punkt 1)
CREATE INDEX idx_epost
ON Kunder (Epost);




/*
Där det står NOT NULL måste det stå något. 
Där det står CHECK så måste värdet vara större än 0
Primary key samt UNIQUE NOT NULL är unika värden som MÅSTE vara unika.
ISBN är som böckernas "personnummer" är unikt och ändras inte. 


När man exekverar raderna 4-69 så skapas databasen, tabellerna + attributerna samt lite data infogas även i tabellerna.
Jag har adderat några SELECT FROM så att man kan visa resultat av tabellerna rent visuellt.
Utöver SELECT FROM så har jag även adderat INNER JOIN, LEFT JOIN och RIGHT JOIN för att hämta antingen matchande i två tabeller eller höger/vänster tabell + matchingar.
Dessutom så har jag indexerat Epost i Kunder-tabellen.


*/


