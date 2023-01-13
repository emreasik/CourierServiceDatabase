
--KULLANICILARIN CİNSİYET VE YAŞLARINA GÖRE TOPLAM ŞİRKETE VERDİKLERİ ÜCRETLER VE BUNLARIN CİNSİYET VE YIL BAZLI OLARAK TOPLAM ÜCRETLERİ
SELECT COALESCE(CONVERT(varchar,DATEDIFF(year,TM.Dogum_Tarihi,GETDATE())),'GENEL_YAŞ') YAŞ,
	COALESCE(TM.Cinsiyet,'GENEL_CİNSİYET') CİNSİYET,
		SUM(TK.Toplam_Ucret) TOPLAM_UCRET from tblMusteri TM
			INNER JOIN tblKargo TK ON TM.ID = TK.GönderenMusteriId
				GROUP BY CUBE(DATEDIFF(year,TM.Dogum_Tarihi,GETDATE()),TM.Cinsiyet)


--HER BİR ÜRÜN KATEGORİSİNE GÖRE ÇIKIŞ ŞEHİR BAZLI TOPLAM ALINAN ÜCRET VE SİPARİŞ SAYILARI
SELECT TS.Sehir,TUK.Kategori_Tipi,SUM(TU.Fiyat) TOPLAM ,COUNT(TU.ID) M�KTAR FROM tblUrun TU
	INNER JOIN tblUrunKategorisi TUK ON TUK.ID = TU.UrunKategoriId 
		INNER JOIN tblKargo TK ON TK.ID = TU.KargoId
			INNER JOIN tblAdres TA ON TA.ID = TK.CikisAdresId
				INNER JOIN tblSehir TS ON TS.ID = TA.SehirId
					GROUP BY TS.Sehir,TUK.Kategori_Tipi
						ORDER BY TS.Sehir

-- İSMİ A İLE BAŞLAYAN ÇALIŞANLARIN BULUNDUĞU ŞUBELERDEN GEÇEN KARGOLIN TESLİM EDİLDİĞİ MÜŞTERİLERİN ADI SOYADI  VE ADRES BİLGİLERİ 

SELECT DISTINCT TMUS.Ad,TMUS.Soyad,TS.Sehir,TI.Ilce,TM.Mahalle, TA.Acik_adres FROM tblKargo TK
	INNER JOIN (SELECT *  FROM tblKargoHareketleri TKH
		WHERE TKH.VarisSubeId IN (SELECT TC.SubeId FROM tblCalisan TC WHERE TC.Ad LIKE 'A%')
			OR TKH.CikisSubeId IN (SELECT TC.SubeId FROM tblCalisan TC WHERE TC.Ad LIKE 'A%')) T
		ON T.KargoId = TK.ID
			INNER JOIN tblMusteri TMUS ON TMUS.ID = TK.TeslimAlanMusteriId
				INNER JOIN tblAdres TA ON TK.TeslimAlanMusteriId = TA.MusteriId
					INNER JOIN tblUlke TU ON TU.ID = TA.UlkeId
						INNER JOIN tblSehir TS ON TS.ID = TA.SehirId
							INNER JOIN tblIlce TI ON TI.ID = TA.IlceId
								INNER JOIN tblMahalle TM ON TM.ID = TA.MahalleId


-- BİRDEN FAZLA KARGO GÖNDEREN MÜŞTERİLER VE KARGO SAYILARI
SELECT TM.Ad,TM.Soyad,COUNT(TK.ID) SIPARIS_ADEDI FROM tblMusteri TM
	INNER JOIN tblKargo TK ON TK.GönderenMusteriId = TM.ID
		GROUP BY TM.Ad,TM.Soyad
			HAVING COUNT(TK.ID) > 1

--Kategoriye göre kargolanan ürün sayisi.
Select UK.Kategori_Tipi,Count(UK.ID) ToplamUrunSayisi
    From tblUrun U
        Inner Join tblUrunKategorisi UK On UK.ID=U.UrunKategoriId
            Group By UK.Kategori_Tipi
--3 Gunden az surede teslim edilen kargolarin barkod numarasi ve tarihleri.
Select K.Barkod_Numarası,K.Teslim_Alım_Tarihi,K.Teslim_Edilme_Tarihi
    From tblKargo K
        Where DATEDIFF(DD,K.Teslim_Alım_Tarihi,K.Teslim_Edilme_Tarihi)<3


--Hangi Durumda kac kargo oldugunu gosteren tablo.
Select KH.KargoDurumId,KD.Durum, COUNT(KH.KargoId) DurumdakiKargoSayisi
    From tblKargoHareketleri KH
        Inner Join tblKargoDurumu KD On KH.KargoDurumId=KD.ID
            Group By KH.KargoDurumId,KD.Durum
--Toplam ucreti ortalama toplam ucretinden dusuk olan kargolarin listesi.
Select*
    From tblKargo K
        Where K.Toplam_Ucret<(Select Sum(K.Toplam_Ucret)/Count(K.ID) ORTALAMA
                                From tblKargo K)










			 