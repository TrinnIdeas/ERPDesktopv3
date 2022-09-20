
ALTER proc [dbo].[p_doc_pedidos_orden_insupd]
@pPedidoId	int OUT,
@pSucursalId	int,
@pComandaId	int,
@pPorcDescuento	decimal(5,2),
@pSubtotal	money,
@pDescuento	money,
@pImpuestos	money,
@pTotal	money,
@pClienteId	int,
@pMotivoCancelacion	varchar(150),
@pActivo	bit,
@pCreadoPor	int,
@pPersonas tinyint,
@pFechaApertura Datetime,
@pFechaCierre Datetime,
@pUberEats bit
as


	set @pClienteId = case when @pClienteId =0 then null else @pClienteId end

	if not exists (
		select 1
		from [doc_pedidos_orden]
		where PedidoId = @pPedidoId
	)
	begin

		select @pPedidoId = isnull(max(PedidoId),0) + 1
		from [doc_pedidos_orden]
		
		insert into [dbo].[doc_pedidos_orden](
			PedidoId,SucursalId,ComandaId,PorcDescuento,Subtotal,Descuento,Impuestos,Total,ClienteId,MotivoCancelacion,
			Activo,CreadoEl,CreadoPor,Personas,FechaApertura,FechaCierre,UberEats
		)
		select @pPedidoId,@pSucursalId,@pComandaId,@pPorcDescuento,@pSubtotal,@pDescuento,@pImpuestos,@pTotal,@pClienteId,@pMotivoCancelacion,
			1,getdate(),@pCreadoPor,@pPersonas,@pFechaApertura,@pFechaCierre,@pUberEats
	end
	Else
	Begin
		update [doc_pedidos_orden]
		set ComandaId = @pComandaId,
			PorcDescuento = @pPorcDescuento,
			Subtotal = @pSubtotal,
			Descuento = @pDescuento,
			Impuestos = @pImpuestos,
			Total = @pTotal,
			ClienteId = @pClienteId,
			MotivoCancelacion = @pMotivoCancelacion,
			Activo = @pActivo,
			FechaCierre = @pFechaCierre,
			Personas = @pPersonas,
			UberEats = @pUberEats
		where PedidoId = @pPedidoId
			
	End

	

	exec p_doc_pedidos_cargos_calculo @pPedidoId,@pCreadoPor


	update doc_pedidos_orden
	set Descuento = (select isnull(sum(Descuento),0) from doc_pedidos_orden_detalle where PedidoId = @pPedidoId and isnull(Cancelado,0) = 0)
	where PedidoId = @pPedidoId

	update doc_pedidos_orden
	set Total = (select isnull(sum(Total),0) from doc_pedidos_orden_detalle where PedidoId = @pPedidoId and isnull(Cancelado,0) = 0) - isnull(Descuento,0),
		Impuestos = (select isnull(sum(Impuestos),0) from doc_pedidos_orden_detalle where PedidoId = @pPedidoId and isnull(Cancelado,0) = 0)
	where PedidoId = @pPedidoId

	update doc_pedidos_orden
	set Subtotal = Total-isnull(Impuestos,0)
	where PedidoId = @pPedidoId