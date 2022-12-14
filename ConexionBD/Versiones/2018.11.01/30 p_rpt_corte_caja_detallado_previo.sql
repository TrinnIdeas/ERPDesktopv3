if exists (	
	select 1
	from sysobjects
	where name = 'p_rpt_corte_caja_detallado_previo'
)
drop proc p_rpt_corte_caja_detallado_previo
go


-- [p_rpt_corte_caja_detallado] 1,1,'20180723','20180724'
create Proc [dbo].[p_rpt_corte_caja_detallado_previo]
@pSucursal int,
@pCajaId int,
@pDel DateTime,
@pAl DateTime
as

	declare @gastos money,
		@retiros money,
		@efectivoApartado money,
		@tarjetaApartado money

    --gastos
	select cc.CorteCajaId,total1 = isnull(sum(g.Monto),0)
	into #tmpGastos
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join doc_gastos g on g.CajaId = cc.cajaId and
							g.CreadoEl between FechaApertura and FechaCorte
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId

	

	--retiros
	select cc.CorteCajaId,total1 = isnull(sum(g.MontoRetiro),0)
	into #tmpRetiros
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join doc_retiros g on g.CajaId = cc.cajaId and
							g.FechaRetiro between FechaApertura and FechaCorte
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId

	--Efectivo Apartado
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpEfectivoApartado
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp_apartado] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid = 1 --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId

	--Tarjeta Apartado
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpTarjetasApartado
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp_apartado] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid in (2,3) --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId


	--Efectivo Venta
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpEfectivoVenta
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid = 1 --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId


	--Tarjeta Apartado
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpTarjetasVenta
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid in (2,3) --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId

	---vales
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpValesVenta
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid in (5) --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId




	select 
		Dia = convert(varchar,FechaApertura,112) ,
		Del = @pDel,
		Al = @pAl,
		Caja = caja.Descripcion,
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		Folio = cc.CorteCajaId,
		FechaApertura = FechaApertura,
		FechaCierre = cc.FechaCorte,
		--Ventas
		EfectivoVenta = isnull(ev.Total1,0),
		TarjetaVenta = isnull(tv.Total1,0),		
		TotalVenta =isnull(ev.Total1,0)+isnull(tv.Total1,0) ,
		--Apartados
		EfectivoApartado = isnull(ea.Total1,0),
		TarjetaApartado = isnull(ta.Total1,0),		
		TotalApartado =isnull(ea.Total1,0)+isnull(ta.Total1,0) ,
		--
		Gastos = isnull(g.total1,0),
		Vales = isnull(vv.total1,0),
		Cancelaciones = (
			select isnull(sum(sv.TotalVenta),0)
			from doc_ventas sv
			where sv.CajaId = cc.CajaId and
			sv.FechaCancelacion is not null and
			sv.FechaCancelacion between cc.FechaApertura and cc.FechaCorte
		),
		Retiros = isnull(r.total1,0),
		Devoluciones = (
			select isnull(sum(sdev.Total),0)
			from doc_devoluciones sdev
			inner join doc_ventas sv on sv.VentaId = sdev.VentaId
			where sv.CajaId = cc.CajaId and
			sv.Fecha between cc.FechaApertura and cc.FechaCorte
			
		),
		TotalIngreso = isnull(ev.Total1,0)+isnull(tv.Total1,0)+
						isnull(ea.Total1,0)+isnull(ta.Total1,0),
		TotalGral = isnull(ev.Total1,0)+isnull(tv.Total1,0)+
						isnull(ea.Total1,0)+isnull(ta.Total1,0)-
						 isnull(g.total1,0),
		TotalCorte = isnull(ev.Total1,0) +
					 isnull(tv.Total1,0) +
					 isnull(ea.Total1,0) +
					 isnull(ta.Total1,0) +
					 isnull(vv.total1,0) -
					 isnull(g.total1,0) -
					(
						select isnull(sum(sv.TotalVenta),0)
						from doc_ventas sv
						where sv.CajaId = cc.CajaId and
						sv.FechaCancelacion is not null and
						sv.FechaCancelacion between cc.FechaApertura and cc.FechaCorte
					) -
					isnull(r.total1,0) -
					(
						select isnull(sum(sdev.Total),0)
						from doc_devoluciones sdev
						inner join doc_ventas sv on sv.VentaId = sdev.VentaId
						where sv.CajaId = cc.CajaId and
						sv.Fecha between cc.FechaApertura and cc.FechaCorte
			
					),
		Vendedor = u.NombreUsuario
	from doc_corte_caja_previo cc
	--inner join doc_corte_caja_fp ccfp on ccfp.CorteCajaId = cc.CorteCajaId
	inner join cat_cajas caja on caja.Clave = cc.CajaId
	inner join cat_sucursales suc on suc.Clave = caja.Sucursal
	inner join cat_empresas emp on emp.Clave = suc.Empresa
	inner join cat_usuarios u 
				on u.IdUsuario = (
					select isnull(min(sv.UsuarioCreacionId),cc.CreadoPor)
					from doc_ventas sv
					where sv.VentaId between cc.VentaIniId and cc.VentaFinId
					)
	left join #tmpRetiros r on r.CorteCajaId = cc.CorteCajaId
	left join #tmpGastos g on g.CorteCajaId = cc.CorteCajaId
	left join doc_corte_caja_fp_apartado_previo ccapartado on ccapartado.CorteCajaId  = cc.CorteCajaId
	left join #tmpEfectivoApartado ea on ea.CorteCajaId = cc.CorteCajaId
	left join #tmpTarjetasApartado ta on ta.CorteCajaId = cc.CorteCajaId
	left join #tmpEfectivoVenta ev on ev.CorteCajaId = cc.CorteCajaId
	left join #tmpTarjetasVenta tv on tv.CorteCajaId = cc.CorteCajaId
	left join #tmpValesVenta vv on vv.CorteCajaId = cc.CorteCajaId

	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	@pCajaId in (cc.CajaId ,0)
	group by  cc.CorteCajaId,
		 FechaApertura,
		 cc.FechaCorte,
		 cc.CajaId,
		 cc.TotalCorte,
		 emp.NombreComercial,
		suc.NombreSucursal,
		caja.Descripcion,
		u.NombreUsuario,
		r.total1,
		g.total1,
		ea.total1,
		ta.total1,
		ev.total1,
		tv.total1,
		vv.total1
	


