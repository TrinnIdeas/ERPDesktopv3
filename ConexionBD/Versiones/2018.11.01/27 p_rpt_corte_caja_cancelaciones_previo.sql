if exists (
	select 1
	from sysobjects
	where name = 'p_rpt_corte_caja_cancelaciones_previo'
)
drop proc p_rpt_corte_caja_cancelaciones_previo
go
-- p_rpt_corte_caja_cancelaciones 8
create Proc [dbo].[p_rpt_corte_caja_cancelaciones_previo]
@pCorteCajaId int
as

	select Folio = v.VentaId,
		FechaCancelacion = v.FechaCancelacion,
		v.TotalVenta
	from doc_ventas v
	inner join doc_corte_caja_previo cc on cc.CorteCajaId = @pCorteCajaId and
							v.FechaCancelacion
							between cc.FechaApertura and cc.FechaCorte and
							cc.CreadoPor = v.UsuarioCreacionId
	where v.Activo = 0  and
	v.CajaId = cc.CajaId



	
	





