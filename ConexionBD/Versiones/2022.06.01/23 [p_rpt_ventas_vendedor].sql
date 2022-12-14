

-- p_rpt_ventas_vendedor 1,1,7,'20220706','20220707'
ALTER proc [dbo].[p_rpt_ventas_vendedor]
@pSucursalId int,
@pCajaId int,
@pCajeroId int,
@pDel DateTime,
@pAl DateTime
as

		select v.UsuarioCreacionId,
			Efectivo = sum(case when vfp.FormaPagoId = 1 then Cantidad  else 0 end),
			Tarjeta = sum(case when vfp.FormaPagoId in( 2,3) then Cantidad  else 0 end),
			Vales = sum(case when vfp.FormaPagoId not in( 1,2,3 ) then Cantidad  else 0 end),
			Total = sum(case when vfp.FormaPagoId in( 1,2,3,4,5) then Cantidad  else 0 end),
			Fecha = convert(varchar,v.Fecha,112)
		into #tmpFormasPagoV
		from [doc_ventas_formas_pago] vfp
		inner join doc_ventas v on v.VentaId = vfp.VentaId
		where @pCajeroId in (0,v.UsuarioCreacionId) and 
		@pCajaId IN (0,V.CajaId) and
		v.SucursalId = @pSucursalId and
		v.FechaCancelacion is null and
		convert(varchar,v.Fecha,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112)
		group by v.UsuarioCreacionId,convert(varchar,v.Fecha,112)

		union

		select ap.CreadoPor,
			Efectivo = sum(case when vfp.FormaPagoId = 1 then Cantidad  else 0 end),
			Tarjeta = sum(case when vfp.FormaPagoId in( 2,3) then Cantidad  else 0 end),
			Vales = sum(case when vfp.FormaPagoId  not in( 1,2,3 ) then Cantidad  else 0 end),
			Total = sum(case when vfp.FormaPagoId in( 1,2,3,4,5) then Cantidad  else 0 end),
			Fecha = convert(varchar,v.CreadoEl,112)
		
		from doc_apartados_formas_pago vfp
		inner join doc_apartados_pagos ap on ap.ApartadoPagoId = vfp.ApartadoPagoId
		inner join doc_apartados v on v.ApartadoId = ap.ApartadoId
		where @pCajeroId in (0,ap.CreadoPor) and 
		@pCajaId IN (0,V.CajaId) and
		v.SucursalId = @pSucursalId and		
		convert(varchar,v.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112)
		group by ap.CreadoPor,convert(varchar,v.CreadoEl,112)

		--select * from #tmpFormasPagoV


		select UsuarioCreacionId,
			Efectivo =sum(Efectivo),
			Tarjeta =sum(Tarjeta),
			Vales =sum(Vales),
			Total =sum(Total),
			Fecha
		into  #tmpFormasPagoV2
		from #tmpFormasPagoV
		group by UsuarioCreacionId,Fecha

		select 
		Del = @pDel,
		Al = @pAl,
		u.IdUsuario,
		Fecha = convert(varchar,v.Fecha,103),
		Vendedora = u.NombreUsuario,
		Efectivo = fp.Efectivo,
		Tpv = fp.Tarjeta,
		Vales = fp.Vales,
		Total = fp.Total,
		Gastos = (
			select isnull(sum(Monto),0)
			from doc_gastos g
			where @pCajaId in (0,g.cajaId) and
			g.SucursalId = @pSucursalId and
			v.UsuarioCreacionId = g.CreadoPor and
			convert(varchar,g.CreadoEl,103) = convert(varchar,v.Fecha,103)
		),
		Cancelaciones = (
			select isnull(sum(sv.TotalVenta),0)
			from doc_ventas sv
			where @pCajaId in(sv.CajaId,0)  and
			v.UsuarioCreacionId = sv.UsuarioCancelacionId and
			sv.FechaCancelacion is not null and
			convert(varchar,sv.FechaCancelacion,103) = convert(varchar,v.Fecha,103)
		),
		Retiros =(
			select isnull(sum(sv.MontoRetiro),0)
			from doc_retiros sv
			where @pCajaId in(sv.CajaId,0)  and
			v.UsuarioCreacionId = sv.CreadoPor and			
			convert(varchar,sv.FechaRetiro,103) = convert(varchar,v.Fecha,103)
		),-- isnull(sum(ret.MontoRetiro),0),
		Devoluciones = (
			select isnull(sum(sdev.Total),0)
			from doc_devoluciones sdev
			inner join doc_ventas sv on sv.VentaId = sdev.VentaId
			where convert(varchar,sv.Fecha,103) = convert(varchar,v.Fecha,103) and
			@pCajaId in (0,sv.CajaId) and
			v.UsuarioCreacionId = sdev.CreadoPor and
			sv.SucursalId = @pSucursalId		
			
		),
		TotalCorte = fp.Total 
				-
					(
					select isnull(sum(Monto),0)
					from doc_gastos g
					where @pCajaId in (0,g.cajaId) and
					g.SucursalId = @pSucursalId and
					v.UsuarioCreacionId = g.CreadoPor and
					convert(varchar,g.CreadoEl,103) = convert(varchar,v.Fecha,103) 
				)
				---
				--(
				--	select isnull(sum(sv.TotalVenta),0)
				--	from doc_ventas sv
				--	where @pCajaId in(sv.CajaId,0)  and
				--	v.UsuarioCreacionId = sv.UsuarioCancelacionId and
				--	sv.FechaCancelacion is not null and
				--	convert(varchar,sv.FechaCancelacion,103) = convert(varchar,v.Fecha,103) 
				--)
				-
				(
					select isnull(sum(sdev.Total),0)
					from doc_devoluciones sdev
					inner join doc_ventas sv on sv.VentaId = sdev.VentaId
					where convert(varchar,sv.Fecha,103) = convert(varchar,v.Fecha,103) and
					@pCajaId in (0,sv.CajaId) and
					v.UsuarioCreacionId = sdev.CreadoPor and
					sv.SucursalId = @pSucursalId		
			
				)
				-
				(
					select isnull(sum(sv.MontoRetiro),0)
					from doc_retiros sv
					where @pCajaId in(sv.CajaId,0)  and
					v.UsuarioCreacionId = sv.CreadoPor and			
					convert(varchar,sv.FechaRetiro,103) = convert(varchar,v.Fecha,103) 
				)			,
			Empresa = emp.NombreComercial,
			Sucursal = suc.NombreSucursal
		from doc_ventas v
		inner join #tmpFormasPagoV2 fp on 	convert(varchar,fp.Fecha,112) = convert(varchar,v.Fecha,112)
		inner join cat_usuarios u on u.IdUsuario = v.UsuarioCreacionId and
									fp.UsuarioCreacionId = u.IdUsuario
		--inner join cat_formas_pago cfp on cfp.FormaPagoId = fp.FormaPagoId
		inner join cat_sucursales suc on suc.Clave = v.SucursalId
		inner join cat_empresas emp on emp.Clave = suc.Empresa
		
		where v.SucursalId =@pSucursalId and
		@pCajaId in (0,v.CajaId) and
		@pCajeroId in (v.UsuarioCreacionId ,0) and
		convert(varchar,v.Fecha,112) 
			between convert(varchar,@pDel,112) and convert(varchar,@pAl,112)

			group by  convert(varchar,v.Fecha,103),
			u.NombreUsuario,
			IdUsuario,
			 emp.NombreComercial,
			suc.NombreSucursal,
			v.UsuarioCreacionId,
			fp.Efectivo,
			fp.Tarjeta,
			fp.Vales,
			fp.Total


