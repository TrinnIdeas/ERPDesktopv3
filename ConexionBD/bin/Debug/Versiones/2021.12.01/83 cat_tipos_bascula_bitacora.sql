
IF NOT EXISTS (
	SELECT 1
	FROM cat_tipos_bascula_bitacora
	WHERE TipoBasculaBitacoraId = 12
)
BEGIN
	INSERT INTO cat_tipos_bascula_bitacora
	SELECT 12,'Cancelaci�n Producto PV',GETDATE()
END
GO


IF NOT EXISTS (
	SELECT 1
	FROM cat_tipos_bascula_bitacora
	WHERE TipoBasculaBitacoraId = 13
)
BEGIN
	INSERT INTO cat_tipos_bascula_bitacora
	SELECT 13,'Cancelaci�n Venta PV',GETDATE()
END
GO