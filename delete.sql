--KAPATILACAK 2112310201 SUBE KODLU SUBENIN CALISANLARI
DELETE FROM tblCalisan
	WHERE TC IN 
	(
	SELECT TC.TC FROM tblCalisan TC
		INNER JOIN tblSube TS
			ON TC.SubeId = TS.ID
				WHERE TS.Sube_Kodu = '2112310201'
	)

-- KAPATILAN 2112310201 SUBE KODLU, SUBE
DELETE FROM tblSube
	WHERE Sube_Kodu = '2112310201'


-- HIC KULLANILMAYAN 34SEO03 VE 34SEO05 PLAKALI ARACLAR FILODAN CIKARILDI
DELETE FROM tblArac
	WHERE Plaka IN (SELECT TA.Plaka FROM tblArac TA
	WHERE NOT TA.ID IN(SELECT DISTINCT TKH.AracId  FROM tblKargoHareketleri TKH 
	WHERE TKH.AracId IS NOT NULL))

--Amerika Birlesik Devletleri,Birlesik Arap Emirlikleri,Çin Halk Cumhuriyeti,Gabon,Doğu Timor ÜLKELERİNE YURTDIŞI HİZMET PLANINDAN ÇIKARILDI
DELETE FROM tblUlke
	WHERE Ulke IN ('Amerika Birleşik Devletleri','Birleşik Arap Emirlikleri','Çin Halk Cumhuriyeti','Gabon','Doğu Timor')


-- KRİPTO ÖDEMELER YASAKLANDI
DELETE FROM tblOdemeTipi
	WHERE Tip = 'Kripto'

	
		