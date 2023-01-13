
IF OBJECT_ID('dbo.sp_calisan_duzenleme') IS NOT NULL
	BEGIN
		DROP PROCEDURE sp_calisan_duzenleme
	END
GO

/* Calisan bilgileri güncelleme procedure'ü. Eğer var olan bir calisan varsa update yapilmasi, yoksa yeni calisanin insert edilmesi */

CREATE or ALTER PROCEDURE sp_calisan_duzenleme(
@calisanAd VARCHAR(50),
@calisanSoyad VARCHAR(50),
@calisanMail VARCHAR(100),
@calisanDogumTarihi DATE,
@calisanCinsiyet VARCHAR(15),
@calisanTelNo VARCHAR(16),
@calisanTc VARCHAR(11),
@calisanSubeId INT
)
AS
	DECLARE @TranCounter INT=@@TRANCOUNT;
	IF @TranCounter > 0
		SAVE TRANSACTION sp_save

	SET NOCOUNT ON; 
	BEGIN TRANSACTION
	BEGIN TRY       
			  -- Duzenleme yapilacak olan calisanin var olup olmadigi kontrolu ---- 
					IF @calisanTc IN (SELECT C.TC FROM tblCalisan C WHERE C.TC = @calisanTc)
					BEGIN
						UPDATE tblCalisan ---- Tc haric, bu calisanin verilen bilgilerin update'i ----
						SET Ad = @calisanAd, Soyad = @calisanSoyad, Mail = @calisanMail, Dogum_Tarihi = @calisanDogumTarihi,
								Cinsiyet = @calisanCinsiyet, Telno = @calisanTelNo, SubeId = @calisanSubeId
						WHERE TC = @calisanTc		
					END

					-- Calisan db'de kayitli degilse else bloguna girecek
					ELSE BEGIN
					
					-- Verilen parametrelere gore yeni calisanin tabloya kaydedilmesi.
						INSERT INTO tblCalisan(Ad, Soyad, Mail, Dogum_Tarihi, Cinsiyet, Telno, TC, SubeId)
						VALUES(@calisanAd, @calisanSoyad, @calisanMail, @calisanDogumTarihi, @calisanCinsiyet, @calisanTelNo, @calisanTc, @calisanSubeId)
					END
               
			   --Hata olmadigi takdirde bu islemler commit edilir.
              COMMIT TRANSACTION
       END TRY

       BEGIN CATCH
			--Hata yakalandigi takdirde rollback ile islemler geri alinir.
            IF @TranCounter = 0 OR XACT_STATE() = -1
				ROLLBACK TRANSACTION
			ELSE
			BEGIN
				ROLLBACK TRANSACTION sp_save
				COMMIT
			END
			  DECLARE @ErrorMessage NVARCHAR(4000)
			  SET @ErrorMessage = ERROR_MESSAGE()
			  DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
			  DECLARE @ErrorState INT = ERROR_STATE()
			  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)
       END CATCH

GO

SELECT * FROM tblCalisan

---- Var olan bir calisanin bilgilerinin guncellenmesi
EXEC sp_calisan_duzenleme 'Emre', 'Asik', 'emre_asik@outlook.com', '2000-03-21', 'Erkek', '5455781111', '46483312342', '1'
GO

---- Var olmayan bir calisanin insert edilmesi
EXEC sp_calisan_duzenleme 'Melek', 'Berrak', 'melekberrak@icloud.com', '1988-05-24', 'Kad�n', '5456451231', '2354759442', '2'

GO