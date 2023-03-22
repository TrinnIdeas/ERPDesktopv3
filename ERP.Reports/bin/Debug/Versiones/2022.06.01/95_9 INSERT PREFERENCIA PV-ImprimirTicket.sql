IF NOT EXISTS(
	SELECT 1
	FROM sis_preferencias
	WHERE Preferencia = 'PV-ImprimirTicket'
)
BEGIN
	INSERT INTO sis_preferencias(
		Preferencia,Descripcion,ParaEmpresa,ParaUsuario,CreadoEl
	)
	SELECT 'PV-ImprimirTicket','Si la preferencia est� activa, se habilitar� la impresi�n de Tickets y como valor se ingresar� el monto minimo de venta para realizar la impresi�n',1,0,GETDATE()
END
GO