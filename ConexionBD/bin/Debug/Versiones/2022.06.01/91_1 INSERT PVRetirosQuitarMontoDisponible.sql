IF NOT EXISTS(
	SELECT 1
	FROM sis_preferencias
	WHERE Preferencia = 'PVRetirosQuitarMontoDisponible'
)
BEGIN
	INSERT INTO sis_preferencias(
		Preferencia,Descripcion,ParaEmpresa,ParaUsuario,CreadoEl
	)
	SELECT 'PVRetirosQuitarMontoDisponible','Si la preferencia est� activa, al intentar realizar un retiro se omitir� mostrar el monto disponible. ',1,0,GETDATE()
END