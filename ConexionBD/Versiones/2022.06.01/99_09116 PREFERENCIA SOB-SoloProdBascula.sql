IF EXISTS (
	SELECT 1
	FROM SYSOBJECTS
	WHERE name = 'fnPreferenciaAplicaSiNo'
)
DROP FUNCTION fnPreferenciaAplicaSiNo
GO
-- select dbo.fnPreferenciaAplicaSiNo('SOB-SoloProdBascula',6)
CREATE  FUNCTION [dbo].[fnPreferenciaAplicaSiNo] 
( 
    @Preferencia VARCHAR(50),
	@SucursalId INT
) 
RETURNS BIT
BEGIN 

	DECLARE @Result BIT=0
   
   IF EXISTS (
	SELECT  PS.Valor
	FROM sis_preferencias_sucursales PS
	INNER JOIN sis_preferencias P ON P.Id = PS.PreferenciaId
	WHERE P.Preferencia IN( 'MAIZ-SACO-CLAVE', 'MASECA-SACO-CLAVE') AND
	PS.SucursalId = @SucursalId)
	BEGIN

	  SET @Result = 1
	END


	IF @Result = 0
	BEGIN

		IF EXISTS (
			SELECT  PS.Valor
			FROM sis_preferencias_empresa PS
			INNER JOIN sis_preferencias P ON P.Id = PS.PreferenciaId
			WHERE P.Preferencia IN( 'MAIZ-SACO-CLAVE', 'MASECA-SACO-CLAVE') 
		)
		BEGIN
			SET @Result = 1
		END
	END


	
   
    RETURN @Result
END 


