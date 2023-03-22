IF NOT EXISTS(
	SELECT 1
	FROM sis_preferencias
	WHERE Preferencia = 'PV-QuitarCalculoInventarioEnVenta'
)
BEGIN
	INSERT INTO sis_preferencias(
		Preferencia,Descripcion,ParaEmpresa,ParaUsuario,CreadoEl
	)
	SELECT 'PV-QuitarCalculoInventarioEnVenta','Si la preferencia est� activa, se deshabilitar� el calculo del inventario al registrar una venta [NO NECESITA VALOR] ',1,0,GETDATE()
END
GO