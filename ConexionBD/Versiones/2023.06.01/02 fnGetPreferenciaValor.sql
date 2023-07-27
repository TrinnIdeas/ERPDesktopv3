IF EXISTS (
	SELECT 1
	FROM SYSOBJECTS
	WHERE NAME = 'fnGetPreferenciaValor'
)
DROP FUNCTION fnGetPreferenciaValor
GO
-- select dbo.fnPreferenciaAplicaSiNo('SOB-SoloProdBascula',6)
CREATE  FUNCTION [dbo].[fnGetPreferenciaValor] 
( 
    @Preferencia VARCHAR(50),
	@SucursalId INT
) 
RETURNS VARCHAR(250)
BEGIN 

	DECLARE @Result VARCHAR(250)
   
   IF EXISTS (
	SELECT  PS.Valor
	FROM sis_preferencias_sucursales PS
	INNER JOIN sis_preferencias P ON P.Id = PS.PreferenciaId
	WHERE P.Preferencia IN( @Preferencia) AND
	PS.SucursalId = @SucursalId)
	BEGIN

	 

			SELECT @Result= ISNULL(PS.Valor,'')
			FROM sis_preferencias_sucursales PS
			INNER JOIN sis_preferencias P ON P.Id = PS.PreferenciaId
			WHERE P.Preferencia IN( @Preferencia) AND
			PS.SucursalId = @SucursalId
	END


	IF @Result = 0
	BEGIN

		IF EXISTS (
			SELECT  PS.Valor
			FROM sis_preferencias_empresa PS
			INNER JOIN sis_preferencias P ON P.Id = PS.PreferenciaId
			WHERE P.Preferencia IN( @Preferencia) 
		)
		BEGIN
			SELECT  @Result= ISNULL(PS.Valor,'')
			FROM sis_preferencias_empresa PS
			INNER JOIN sis_preferencias P ON P.Id = PS.PreferenciaId
			WHERE P.Preferencia IN( @Preferencia)
		END
	END


	
   
    RETURN @Result
END 


