/*
    Calisan tablosundaki sp icerisinde Insert ve update edilirken kurallara uygunlugunu daha sonra ise 
    Calisanin son duzenlenmis bilgilerinin tutuldugu tabloya bunun eklenmesi veya guncellenmesi yapilir.
*/

IF OBJECT_ID('dbo.trg_Calisan_Duzenleme') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.trg_Calisan_Duzenleme
	END
GO

CREATE TRIGGER trg_Calisan_Duzenleme ON tblCalisan AFTER INSERT, UPDATE AS 

	DECLARE @calisanAd VARCHAR(50)
	DECLARE @calisanSoyad VARCHAR(50)
	DECLARE @calisanMail VARCHAR(100)
	DECLARE @calisanDogumTarihi DATE
	DECLARE @calisanCinsiyet VARCHAR(15)
	DECLARE @calisanTelNo VARCHAR(16)
	DECLARE @calisanTc VARCHAR(11)
	DECLARE @calisanSubeId INT

	DECLARE @calisanEskiMail VARCHAR(100)
	DECLARE @calisanEskiTelNo VARCHAR(16)

	-- Inserted tablosundan gerekli bilgilerin cekilmesi
	SELECT @calisanAd = Ad, @calisanSoyad = Soyad, @calisanMail = Mail, @calisanDogumTarihi = Dogum_Tarihi,
			@calisanCinsiyet = Cinsiyet, @calisanTelNo = Telno, @calisanTc = TC, @calisanSubeId = SubeId
	FROM inserted

	-- Calisanin insert veya update'den onceki son mail ve telefon numara bilgileri tblCalisan tablosundan cekiliyor
	SELECT @calisanEskiMail = Mail, @calisanEskiTelNo = Telno
	FROM deleted WHERE TC= @calisanTc

	IF (@calisanMail NOT LIKE '_%@__%.__%')
		BEGIN
			RAISERROR('Gecersiz mail formatı girildi.',16,1)
			ROLLBACK
		END

	ELSE IF (@calisanDogumTarihi > GETDATE())
		BEGIN	 
			RAISERROR('Doğum tarihi günümüz tarihinden sonra olamaz.',16,1)
			ROLLBACK
		END

	ELSE IF @calisanCinsiyet != 'Erkek' AND @calisanCinsiyet != 'Kadın'
		BEGIN
			RAISERROR('Geçersiz cinsiyet türü girildi.',16,1)
			ROLLBACK
		END

	ELSE IF @calisanTelNo NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
		BEGIN
			RAISERROR('Geçersiz telefon formatı veya uzunluğu girildi.',16,1)
			ROLLBACK
		END

	ELSE IF @calisanSubeId NOT IN ( SELECT S.ID FROM tblSube S WHERE S.ID = @calisanSubeId )
		BEGIN
			RAISERROR('Var olmayan şube girildi.',16,1)
			ROLLBACK
		END

	IF @calisanTc IN (SELECT DC.TC FROM tblDuzenlenmisCalisan DC WHERE DC.TC = @calisanTc)
			BEGIN
				UPDATE tblDuzenlenmisCalisan SET Ad = @calisanAd, Soyad = @calisanSoyad,
					EskiMail = @calisanEskiMail, EskiTelno = @calisanEskiTelNo
					WHERE TC = @calisanTc
			END

	IF @calisanTc NOT IN (SELECT DC.TC FROM tblDuzenlenmisCalisan DC WHERE DC.TC = @calisanTc)
			BEGIN
				INSERT INTO tblDuzenlenmisCalisan (Ad,Soyad,EskiMail,EskiTelno,TC)
				VALUES
				(@calisanAd, @calisanSoyad, @calisanEskiMail, @calisanEskiTelNo, @calisanTc)
			END
GO

SELECT * FROM tblCalisan
SELECT * FROM tblDuzenlenmisCalisan

----- Önceden oluşturduğumuz create table'larda CONSTRAINT check olduğu için Telno, Tc, Email'de trigger'dan gelecek RAISERROR hatayi goremiyoruz.
----- Tablonun kendisi bunu engelliyor ve hata gosteriyor. Ama fazla kosul olmasi icin Telno, Email icin trigger icerisinde kontrol kodlarini biraktim.

---- Var olan bir calisanin bilgilerinin guncellenmesi, daha sonrasinda tblDuzenlenmisCalisan tablosunda bu bilgileri gorebiliriz
EXEC sp_calisan_duzenleme 'Batuhan', 'Demir', 'batudemir@hotmail.com', '1999-03-21', 'Erkek', '5345711447', '24587412472', '1'
GO

---- Hatali Insert; Dogum tarihi ve Cinsiyet
EXEC sp_calisan_duzenleme 'Mustafa', 'Aktas', 'mustafaaktas@icloud.com', '2023-03-21', 'Erkek', '5345717841', '34585422472', '1'
EXEC sp_calisan_duzenleme 'Mustafa', 'Aktas', 'mustafaaktas@icloud.com', '2000-03-21', 'Erkekk', '5345717841', '34585422472', '1'
GO

----- Yeni Insert yapilan ornek
EXEC sp_calisan_duzenleme 'Tarık', 'Eski', 'tar@keski@hotmail.com', '2001-02-18', 'Erkek', '5453267475', '3245216459', '1'
GO
