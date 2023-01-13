----- Her bir ürün Kategorisinde kargo başına ortalama Kg'ı(kargo) bulan fonksiyon -----

IF OBJECT_ID('dbo.fn_ortalama_kargo_kg') IS NOT NULL
	BEGIN
		DROP FUNCTION fn_ortalama_kargo_kg
	END
GO

CREATE FUNCTION fn_ortalama_kargo_kg(@kategori_id INT)
RETURNS FLOAT
AS
BEGIN
    DECLARE @ortalama_kg FLOAT;

    SELECT @ortalama_kg = SUM(TU.Kg) / COUNT(DISTINCT TU.KargoId)
    FROM tblUrun TU
    WHERE TU.UrunKategoriId = @kategori_id;

    RETURN @ortalama_kg;
END;
GO

-- Fonksiyon Test
SELECT *,dbo.fn_ortalama_kargo_kg(TUK.ID) Gonderi_Basi_Ortalama_Kg FROM tblUrunKategorisi TUK