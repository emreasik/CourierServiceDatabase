USE KargoDb 
GO

DROP INDEX IF EXISTS mahalleAdIndex
ON tblMahalle
GO

CREATE NONCLUSTERED INDEX mahalleAdIndex ON tblMahalle
(
Mahalle ASC
)
GO

SET STATISTICS IO ON
SET STATISTICS TIME OFF
SELECT * FROM tblMahalle WHERE Mahalle = 'NARLI'
GO