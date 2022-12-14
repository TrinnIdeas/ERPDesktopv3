if exists (	
	select 1
	from sysobjects
	where name = 'p_rpt_corte_caja_descuentos_previo'
)
drop proc p_rpt_corte_caja_descuentos_previo
go

-- p_rpt_corte_caja_descuentos 1
create proc [dbo].[p_rpt_corte_caja_descuentos_previo]
@pCorteCaja int
as

	select v.Folio,
			Descuento = v.DescuentoEnPartidas
	from doc_corte_caja_previo cc
	inner join doc_ventas v on v.VentaId between cc.VentaIniId and cc.VentaFinId and
				v.Activo = 1 and
				isnull(v.DescuentoEnPartidas,0) > 0 AND
				v.UsuarioCreacionId = cc.CreadoPor
	where cc.CorteCajaId = @pCorteCaja
	order by v.Folio

	





