IF NOT EXISTS(
	SELECT 1
	FROM sis_preferencias
	WHERE Preferencia = 'PVCorteCajaOcultarDetalleCajero'
)
BEGIN
	INSERT INTO sis_preferencias(
		Preferencia,Descripcion,ParaEmpresa,ParaUsuario,CreadoEl
	)
	SELECT 'PVCorteCajaOcultarDetalleCajero','Si la preferencia est� activa, se ocultar� la informaci�n de totales y no se imprimir� el corte. Solo se imprimir� con clave de supervisor',1,0,GETDATE()
END