IF NOT EXISTS(
	SELECT 1
	FROM sis_preferencias
	WHERE Preferencia = 'PVExcluirBasculaPedidos'
)
BEGIN
	INSERT INTO sis_preferencias(
		Preferencia,Descripcion,ParaEmpresa,ParaUsuario,CreadoEl
	)
	SELECT 'PVExcluirBasculaPedidos','Si la preferencia est� activa, el sistema no se conectar� a la b�scula al querere registrar un producto a granel, el peso se ingresar� manualmente',1,0,GETDATE()
END