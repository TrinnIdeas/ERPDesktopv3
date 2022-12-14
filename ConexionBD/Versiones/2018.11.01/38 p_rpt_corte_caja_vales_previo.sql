if exists (	
	select 1
	from sysobjects
	where name = 'p_rpt_corte_caja_vales_previo'
)
drop proc p_rpt_corte_caja_vales_previo
go

create proc [dbo].[p_rpt_corte_caja_vales_previo]
@pCorteCaja int
as

	select Folio = isnull(v.Serie,'') + cast(v.VentaId as varchar),
		   MontoTicket = v.TotalVenta,
		   FolioVale = vale.DevolucionId,
		   MontoVale = dev.Total
	from doc_ventas v
	inner join doc_corte_caja_previo cc on cc.CorteCajaId = @pCorteCaja and
							v.Fecha between cc.FechaApertura and cc.FechaCorte
	inner join [dbo].[doc_ventas_formas_pago_vale] vale on vale.VentaId = v.VentaId 
	inner join doc_devoluciones  dev on dev.DevolucionId = vale.DevolucionId
						

