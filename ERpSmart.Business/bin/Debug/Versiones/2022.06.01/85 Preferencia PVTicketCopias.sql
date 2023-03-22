IF NOT EXISTS(
	SELECT 1
	FROM sis_preferencias
	WHERE Preferencia = 'PVTicketCopias'
)
BEGIN
	INSERT INTO sis_preferencias(
		Preferencia,Descripcion,ParaEmpresa,ParaUsuario,CreadoEl
	)
	SELECT 'PVTicketCopias','Si la preferencia est� activa, Se imprimir�n las copias que se haya especificado como valor de preferencia. Requiere Valor [Valor= Numero de copias]',1,0,GETDATE()
END