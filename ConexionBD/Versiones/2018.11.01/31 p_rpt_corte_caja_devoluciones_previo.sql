if exists (	
	select 1
	from sysobjects
	where name = 'p_rpt_corte_caja_devoluciones_previo'
)
drop proc p_rpt_corte_caja_devoluciones_previo
go

create proc [dbo].[p_rpt_corte_caja_devoluciones_previo]
@pCorteCajaId int
as
	select FolioDevolucion=	dev.DevolucionId,
			FolioVenta = v.Folio,
			MontoDevolucion = dev.Total
	from doc_corte_caja_previo cc
	INNER JOIN doc_devoluciones DEV ON 
				DEV.CreadoEl 
				between cc.FechaApertura and cc.FechaCorte 
	inner join doc_ventas v on v.VentaId = dev.VentaId
	where cc.CorteCajaId = @pCorteCajaId AND
	cc.CreadoPor = dev.CreadoPor





