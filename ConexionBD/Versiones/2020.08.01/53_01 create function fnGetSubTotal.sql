
if exists (
	select 1
	from sysobjects
	where name = 'fnGetSubTotal'
)
drop function fnGetSubTotal
go
-- select dbo.fnGetSubTotal(100)
create  FUNCTION [dbo].[fnGetSubTotal] 
( 
    @total money
) 
RETURNS money
BEGIN 
    DECLARE @impuestos money,
			@resultado money

			select @impuestos = Porcentaje
			from cat_impuestos
			where clave = 1

			set @resultado = @total / (1+ (@impuestos/100))
   
    RETURN isnull(@resultado,0)
END 


