if exists (
	select 1
	from sysobjects
	where name = 'p_rpt_corte_caja_apartados_det_previo'
)
drop proc p_rpt_corte_caja_apartados_det_previo
go
-- p_rpt_corte_caja_apartados_det 7
create PROC [dbo].[p_rpt_corte_caja_apartados_det_previo]
@pCorteCajaId int
as

	--Anticipos
	select Pagos = count(distinct a.ApartadoPagoId),
			TipoPago = 'Anticipo',
			Total = isnull(sum(a.Importe),0)
	from doc_apartados_pagos a
	inner join doc_corte_caja_previo cc on cc.CorteCajaId = @pCorteCajaId 
	where a.FechaPago between cc.FechaApertura and cc.FechaCorte and
	cc.CreadoPor = a.CreadoPor and
	a.anticipo = 1
	having count(distinct a.ApartadoPagoId) > 0

	union

	select Pagos = count(distinct a.ApartadoPagoId),
			TipoPago = 'Abono',
			Total = sum(a.Importe)
	from doc_apartados_pagos a
	inner join doc_corte_caja_previo cc on cc.CorteCajaId = @pCorteCajaId 
	where a.FechaPago between cc.FechaApertura and cc.FechaCorte and
	cc.CreadoPor = a.CreadoPor and
	a.anticipo = 0
	having count(distinct a.ApartadoPagoId) > 0




