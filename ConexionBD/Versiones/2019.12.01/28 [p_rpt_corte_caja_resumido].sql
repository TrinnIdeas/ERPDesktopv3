-- p_rpt_corte_caja_resumido 1,1,'20180723','20180724'
ALTER Proc [dbo].[p_rpt_corte_caja_resumido]
@pSucursal int,
@pCajaId int,
@pDel DateTime,
@pAl DateTime
as

	declare @gastos money,
		@retiros money
	
	select cc.CorteCajaId,total1 = isnull(sum(g.Monto),0)
	into #tmpGastos
	from doc_corte_caja cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join doc_gastos g on g.CajaId = cc.cajaId and
							g.CreadoEl between FechaApertura and FechaCorte
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId


	select cc.CorteCajaId,total1 = isnull(sum(g.MontoRetiro),0)
	into #tmpRetiros
	from doc_corte_caja cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join doc_retiros g on g.CajaId = cc.cajaId and
							g.FechaRetiro between FechaApertura and FechaCorte
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId



	select Efectivo = sum(case when fp.FormaPagoId = 1 then fp.Total else 0 end),
	Tarjeta=sum(case when fp.FormaPagoId in( 2,3) then fp.Total else 0 end),
	Vales = sum(case when fp.FormaPagoId in( 5) then fp.Total else 0 end),
	Total = sum(case when fp.FormaPagoId = 1 then fp.Total else 0 end) +
			sum(case when fp.FormaPagoId in( 2,3) then fp.Total else 0 end) +
			sum(case when fp.FormaPagoId in( 5) then fp.Total else 0 end),
	cc.CorteCajaId
	into #tmpApartadosFP
	from [doc_corte_caja_fp_apartado] fp
	inner join doc_corte_caja cc on cc.CorteCajaId = fp.CorteCajaId
	inner join cat_cajas  c on c.clave = cc.CajaId
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId,fp.FormaPagoId


	select 
		Del = @pDel,
		Al = @pAl,
		Caja = caja.Descripcion,
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		Folio = cc.CorteCajaId,
		Fecha = cast(FechaApertura as date),
		FechaApertura = FechaApertura,
		FechaCierre = cc.FechaCorte,
		Efectivo = sum(case when ccfp.FormaPagoId = 1 then ccfp.Total else 0 end) +
					isnull(afp.Efectivo,0),
		Tarjeta = sum(case when ccfp.FormaPagoId in( 2,3) then ccfp.Total else 0 end)+
				isnull(afp.Tarjeta,0),
		Vales = sum(case when ccfp.FormaPagoId in( 5) then ccfp.Total else 0 end) +
				isnull(afp.Vales,0),
		Total =sum(case when ccfp.FormaPagoId in (1,2,3,5) then ccfp.Total else 0 end)+
			isnull(afp.Total,0) ,
		Gastos = isnull(g.total1,0),--isnull(sum(g.Monto),0),
		Cancelaciones = (
			select isnull(sum(sv.TotalVenta),0)
			from doc_ventas sv
			where sv.CajaId = cc.CajaId and
			sv.FechaCancelacion is not null and
			sv.FechaCancelacion between cc.FechaApertura and cc.FechaCorte
		),
		Retiros = isnull(r.total1,0),--isnull(sum(ret.MontoRetiro),0),
		Devoluciones = (
			select isnull(sum(sdev.Total),0)
			from doc_devoluciones sdev
			inner join doc_ventas sv on sv.VentaId = sdev.VentaId
			where sv.CajaId = cc.CajaId and
			sv.Fecha between cc.FechaApertura and cc.FechaCorte
			
		),
		TotalCorte = sum(case when ccfp.FormaPagoId in (1,2,3,5) then ccfp.Total else 0 end)+
			 isnull(afp.Total,0)
			-
			isnull(g.total1,0)-
			--(
			--	select isnull(sum(sv.TotalVenta),0)
			--	from doc_ventas sv
			--	where sv.CajaId = cc.CajaId and
			--	sv.FechaCancelacion is not null and
			--	sv.FechaCancelacion between cc.FechaApertura and cc.FechaCorte
			--) -
			isnull(r.total1,0)-
			(
			select isnull(sum(sdev.Total),0)
			from doc_devoluciones sdev
			inner join doc_ventas sv on sv.VentaId = sdev.VentaId
			where sv.CajaId = cc.CajaId and
			sv.Fecha between cc.FechaApertura and cc.FechaCorte
			
		),
		Vendedor = u.NombreUsuario
	from doc_corte_caja cc
	inner join doc_corte_caja_fp ccfp on ccfp.CorteCajaId = cc.CorteCajaId
	inner join cat_cajas caja on caja.Clave = cc.CajaId
	inner join cat_sucursales suc on suc.Clave = caja.Sucursal
	inner join cat_empresas emp on emp.Clave = suc.Empresa
	inner join cat_usuarios u on u.IdUsuario = cc.CreadoPor
	left join #tmpRetiros r on r.CorteCajaId = cc.CorteCajaId
	left join #tmpGastos g on g.CorteCajaId = cc.CorteCajaId
	left join #tmpApartadosFP afp on afp.CorteCajaId = cc.CorteCajaId
	

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
		afp.Efectivo,
		afp.Tarjeta,
		afp.Vales,
		afp.Total
	


