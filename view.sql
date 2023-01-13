--- Kargolarin urunleriyle birlikte kategori tiplerine gore, o kategorideki ortalama kg agirligiyla birlikte detayli gosterimi ----

IF OBJECT_ID('dbo.vKargodaki_Urunlerin_Ortalama_Kg_Ile_Raporu') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vKargodaki_Urunlerin_Ortalama_Kg_Ile_Raporu
	END
GO

CREATE VIEW vKargodaki_Urunlerin_Ortalama_Kg_Ile_Raporu AS
	SELECT
		TK.Barkod_Numarası,
		TUK.Kategori_Tipi,
		SUM(TU.KG) AS URUN_BAZLI_KATEGORIYE_GORE_KG,
		TK.Toplam_Ucret AS KARGO_TOPLAM_UCRETI,
		dbo.fn_ortalama_kargo_kg(TUK.ID) AS KATEGORIYE_GORE_KG_ORTALAMA,
		CASE 
			WHEN SUM(TU.Kg) < DBO.fn_ortalama_kargo_kg(TUK.ID) THEN 'Ortalamadan Düşük'
			WHEN SUM(TU.Kg) > DBO.fn_ortalama_kargo_kg(TUK.ID) THEN 'Ortalamadan Büyük'
			WHEN SUM(TU.Kg) = DBO.fn_ortalama_kargo_kg(TUK.ID) THEN 'Ortalamaya Eşit'
		END AS 'KG/ORTALAMA',
		FORMAT(TK.Teslim_Alım_Tarihi, 'dddd, MMMM, yyyy', 'tr-tr') AS TESLIM_ALIM_TARIHI,
		FORMAT(TK.Teslim_Edilme_Tarihi, 'dddd, MMMM, yyyy', 'tr-tr') AS TESLIM_EDILME_TARIHI
	FROM tblUrun TU
	INNER JOIN tblUrunKategorisi TUK ON TU.UrunKategoriId = TUK.ID
		INNER JOIN tblKargo TK	ON TK.ID = TU.KargoId
			INNER JOIN tblOdemeTipi TOT	ON TOT.ID = TK.OdemeTipiId
				GROUP BY TK.Barkod_Numarası,TUK.Kategori_Tipi,TK.Toplam_Ucret,TUK.ID, TK.Teslim_Alım_Tarihi, Tk.Teslim_Edilme_Tarihi
GO

---- View Test ------
SELECT  
	vK.*,
	TOT.Tip AS ODEME_TIPI,
	TC.Telno AS KARGODAN_SORUMLU_CALISAN_TEL_NO,
	TMG.Ad + ' ' + TMG.Soyad  AS GONDEREN_MUSTERI,
	TMG.Telno AS GONDEREN_MUSTERI_TEL_NO,
	TMA.Ad + ' ' + TMA.Soyad  AS TESLIM_ALAN_MUSTERI,
	TMA.Telno AS TESLIM_ALAN_MUSTERI_TEL_NO,
	ISNULL(TGD.Icerik,'Yorum yok') MUSTERI_YORUMU
	
	FROM vKargodaki_Urunlerin_Ortalama_Kg_Ile_Raporu vK
		INNER JOIN tblKargo TK	ON TK.Barkod_Numarası = vK.Barkod_Numarası
			INNER JOIN tblOdemeTipi TOT	ON TOT.ID = TK.OdemeTipiId
				LEFT JOIN tblGeridonut TGD ON  TGD.ID = TK.GeriDonutId
					INNER JOIN tblCalisan TC ON TC.ID = TK.ID
						INNER JOIN tblMusteri TMG ON TMG.ID = TK.GönderenMusteriId
							INNER JOIN tblMusteri TMA ON TMA.ID = TK.TeslimAlanMusteriId