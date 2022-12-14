if exists (
	select 1
	from sysobjects
	where name = 'p_rpt_corte_caja_denom_previo'
)
drop proc p_rpt_corte_caja_denom_previo
go
-- p_rpt_corte_caja_denom 1
create proc [dbo].[p_rpt_corte_caja_denom_previo]
@pCorteCajaId int
as

	select Denominacion=d.Descripcion,
		Cantidad = cd.Cantidad,
		Total = cd.Total
	from doc_corte_caja_denominaciones_previo cd
	inner join doc_corte_caja_previo cc on cc.CorteCajaId = cd.CorteCajaId
	INNER JOIN cat_denominaciones d on d.Clave = cd.DenominacionId
	where cc.CorteCajaId = @pCorteCajaId





