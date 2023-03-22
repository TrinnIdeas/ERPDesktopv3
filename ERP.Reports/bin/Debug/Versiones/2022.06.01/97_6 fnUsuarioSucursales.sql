if  EXISTS (
	SELECT 1
	FROM SYSOBJECTS
	WHERE NAME = 'fnUsuarioSucursales'
)
DROP FUNCTION fnUsuarioSucursales
GO

-- select * from dbo.[fnUsuarioSucursales](1)
CREATE  FUNCTION [dbo].[fnUsuarioSucursales] 
( 
    @pUsuarioId INT
) 
RETURNS @output TABLE(sucursalId int)
 
--declare @tabla  table(splitdata int)
--declare @string varchar(50) = '1580',
--	   @delimiter char(1) = ','

BEGIN 
	INSERT INTO @output (sucursalId)  
	SELECT Clave
	FROM cat_sucursales s
	INNER JOIN cat_usuarios_sucursales US ON US.UsuarioId = @pUsuarioId AND
								US.SucursalId = s.Clave

    RETURN 
END 


