IF NOT EXISTS(
	SELECT 1
	FROM sis_preferencias
	WHERE Preferencia = 'PVBotonRegistroBasculaPedidosApp'
)
BEGIN
	INSERT INTO sis_preferencias(
		Preferencia,Descripcion,ParaEmpresa,ParaUsuario,CreadoEl
	)
	SELECT 'PVBotonRegistroBasculaPedidosApp','Si la preferencia est� activa, se mostrar� un bot�n en el punto de venta en dode se podr� registrar la b�scula de pedidos registrados desde la app. NO NECESITA VALOR',1,0,GETDATE()
END