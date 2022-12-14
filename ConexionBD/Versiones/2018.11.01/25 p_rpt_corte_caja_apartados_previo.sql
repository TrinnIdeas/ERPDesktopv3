
if exists (
	select 1
	from sysobjects
	where name ='p_rpt_corte_caja_apartados_previo'
)
drop proc p_rpt_corte_caja_apartados_previo
go
create proc [dbo].[p_rpt_corte_caja_apartados_previo]
@pCorteCajaId int
as

	select Folio = a.ApartadoId,
		a.TotalApartado 
	from doc_apartados a
	inner join doc_corte_caja_previo cc on cc.CorteCajaId = @pCorteCajaId 
	where a.CreadoEl between cc.FechaApertura and cc.FechaCorte and
	cc.CreadoPor = a.CreadoPor



