if  exists (
	select 1
	from sysobjects
	where name = 'p_doc_pedidos_orden_detalle_insupd'
)
drop proc p_doc_pedidos_orden_detalle_insupd
go

create proc [dbo].[p_doc_pedidos_orden_detalle_insupd]
@pPedidoDetalleId	int out,
@pPedidoId	int,
@pProductoId	int,
@pCantidad	decimal(14,3),
@pPrecioUnitario	money,
@pPorcDescuento	decimal(5,2),
@pDescuento	money,
@pImpuestos	money,
@pNotas	varchar(200),
@pTotal	money,
@pCreadoPor	int,
@pTasaIVA	decimal(5,2),
@pParallevar bit,
@pComandaId int OUT
as

	declare @porcIVA decimal(5,2)

	select @porcIVA = (Porcentaje / 100)
	from cat_productos_impuestos pi
	inner join cat_impuestos i on i.Clave = pi.ImpuestoId 
	where pi.ProductoId = @pProductoId and
	pi.ImpuestoId = 1--IVA	

	select @pPrecioUnitario = Precio
	from  cat_productos_precios 
	where IdProducto = @pProductoId and
	IdPrecio = 1

	set @pTotal = @pPrecioUnitario * @pCantidad

	set @pImpuestos = case when @porcIVA > 0 then  @pTotal / (1 + @porcIVA) else 0 end

	if not exists (
		select 1
		from [doc_pedidos_orden_detalle]
		where PedidoDetalleId = @pPedidoDetalleId
	)
	begin


		--Comanda
		if(isnull(@pComandaId,0)=0)
		begin
			select @pComandaId = min(c.ComandaId)
			from cat_rest_comandas c
			inner join doc_pedidos_orden p on p.PedidoId = @pPedidoId
			left join doc_pedidos_orden_detalle pd on pd.ComandaId = c.ComandaId
			where Disponible = 1 and
			p.SucursalId = P.SucursalId  and
			pd.ComandaId is null


			if(isnull(@pComandaId,0) = 0)
			begin
				

				select @pComandaId = isnull(max(ComandaId),0) + 1
				from cat_rest_comandas 

				insert into cat_rest_comandas(
					ComandaId,SucursalId,Folio,Disponible,CreadoPor,CreadoEl
				)
				select @pComandaId,p.SucursalId,cast(@pComandaId as varchar),0,@pCreadoPor,getdate()
				from  doc_pedidos_orden p where p.PedidoId = @pPedidoId

				 
			end
		end

		update cat_rest_comandas
		set Disponible = 0
		where ComandaId = @pComandaId

		select @pPedidoDetalleId = isnull(max(PedidoDetalleId),0) + 1
		from [doc_pedidos_orden_detalle]

		insert into  [dbo].[doc_pedidos_orden_detalle](
			PedidoDetalleId,	PedidoId,	ProductoId,	Cantidad,	PrecioUnitario,	PorcDescuento,
			Descuento,			Impuestos,	Notas,		Total,		CreadoPor,		CreadoEl,
			TasaIVA,			Impreso,	Parallevar,	ComandaId
		)
		select @pPedidoDetalleId,	@pPedidoId,		@pProductoId,	@pCantidad,		@pPrecioUnitario,	@pPorcDescuento,
			@pDescuento,			@pImpuestos,	@pNotas,		@pTotal  ,		@pCreadoPor,		getdate(),
			@pTasaIVA,			0,			@pParallevar, @pComandaId
	end
	Else
	Begin
		update [doc_pedidos_orden_detalle]
		set ProductoId=@pProductoId,
			Cantidad = @pCantidad,
			PrecioUnitario = @pPrecioUnitario,
			PorcDescuento = @pPorcDescuento,
			Descuento = @pDescuento,
			Impuestos = @pImpuestos,
			Notas = @pNotas,
			Total = @pTotal,
			TasaIVA = @pTasaIVA
		WHERE PedidoDetalleId = PedidoDetalleId

	End

	update doc_pedidos_orden
	set Total = (select isnull(sum(Total),0) from doc_pedidos_orden_detalle where PedidoId = @pPedidoId),
		Impuestos = (select isnull(sum(Impuestos),0) from doc_pedidos_orden_detalle where PedidoId = @pPedidoId)
	where PedidoId = @pPedidoId

	update doc_pedidos_orden
	set Subtotal = Total-isnull(Impuestos,0)
	where PedidoId = @pPedidoId