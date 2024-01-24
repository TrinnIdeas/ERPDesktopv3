USE [erplocaldb]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_DECODE_FROM_BASE64]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- select dbo.fn_str_FROM_BASE64('MTAw')
CREATE FUNCTION [dbo].[fn_DECODE_FROM_BASE64]
(
    @BASE64_STRING VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    RETURN (
        SELECT 
            CAST(
                CAST(N'' AS XML).value('xs:base64Binary(sql:variable("@BASE64_STRING"))', 'VARBINARY(MAX)') 
            AS VARCHAR(MAX)
            )   UTF8Encoding
    )
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_ENCODE_TO_BASE64]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_ENCODE_TO_BASE64]
(
    @STRING VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    RETURN (
        SELECT
            CAST(N'' AS XML).value(
                  'xs:base64Binary(xs:hexBinary(sql:column("bin")))'
                , 'VARCHAR(MAX)'
            )   Base64Encoding
        FROM (
            SELECT CAST(@STRING AS VARBINARY(MAX)) AS bin
        ) AS bin_sql_server_temp
    )
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetDateTimeServer]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[fn_GetDateTimeServer]()
RETURNS DateTime
AS
BEGIN
	
	return DATEADD(HOUR,1,getdate())

END


GO
/****** Object:  UserDefinedFunction [dbo].[fnGetComandaAdicionales]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnGetComandaAdicionales]
(
	@pPedidoDetalleId int
)
RETURNS varchar(500)
AS
BEGIN
	
	DECLARE @Result varchar(500),
			@ingredientes varchar(500)='',
			@adicionales varchar(500)='',
			@notas varchar(500) = ''

	select @ingredientes= @ingredientes + ' '+
						case when i.Con = 1 then 'C/'
							 when i.Sin = 1 then 'S/'
						end+
						isnull(p.DescripcionCorta,'')
	from doc_pedidos_orden_ingre i	
	inner join cat_productos p on p.ProductoId = i.ProductoId
	where PedidoDetalleId = @pPedidoDetalleId

	select @adicionales = @adicionales +
						' /'+
						isnull(a.Descripcion,'')
	from doc_pedidos_orden_adicional pa
	inner join cat_rest_platillo_adicionales a on a.Id = pa.AdicionalId
	where pa.PedidoDetalleId = @pPedidoDetalleId


	select @notas = Notas
	from doc_pedidos_orden_detalle
	where PedidoDetalleId = @pPedidoDetalleId

	set @Result = isnull(@ingredientes,'') + ' '+
					isnull(@adicionales,'') +' '+ isnull(@notas,'')


	

	-- Return the result of the function
	RETURN @Result

END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetComandaMesas]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnGetComandaMesas]
(
	@pPedidoId int
)
RETURNS varchar(500)
AS
BEGIN
	
	DECLARE @Result varchar(500)=''


	select @Result = @Result +  m.Nombre + ','
	from doc_pedidos_orden_mesa pm
	inner join cat_rest_mesas m on m.MesaId = pm.MesaId
	where PedidoOrdenId = @pPedidoId


	

	-- Return the result of the function
	RETURN @Result

END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetPreferenciaValor]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select dbo.fnPreferenciaAplicaSiNo('SOB-SoloProdBascula',6)
CREATE  FUNCTION [dbo].[fnGetPreferenciaValor] 
( 
    @Preferencia VARCHAR(50),
	@SucursalId INT
) 
RETURNS VARCHAR(250)
BEGIN 

	DECLARE @Result VARCHAR(250)
   
   IF EXISTS (
	SELECT  PS.Valor
	FROM sis_preferencias_sucursales PS
	INNER JOIN sis_preferencias P ON P.Id = PS.PreferenciaId
	WHERE P.Preferencia IN( @Preferencia) AND
	PS.SucursalId = @SucursalId)
	BEGIN

	 

			SELECT @Result= ISNULL(PS.Valor,'')
			FROM sis_preferencias_sucursales PS
			INNER JOIN sis_preferencias P ON P.Id = PS.PreferenciaId
			WHERE P.Preferencia IN( @Preferencia) AND
			PS.SucursalId = @SucursalId
	END


	IF @Result = 0
	BEGIN

		IF EXISTS (
			SELECT  PS.Valor
			FROM sis_preferencias_empresa PS
			INNER JOIN sis_preferencias P ON P.Id = PS.PreferenciaId
			WHERE P.Preferencia IN( @Preferencia) 
		)
		BEGIN
			SELECT  @Result= ISNULL(PS.Valor,'')
			FROM sis_preferencias_empresa PS
			INNER JOIN sis_preferencias P ON P.Id = PS.PreferenciaId
			WHERE P.Preferencia IN( @Preferencia)
		END
	END


	
   
    RETURN @Result
END 


GO
/****** Object:  UserDefinedFunction [dbo].[fnGetSubTotal]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select dbo.fnGetSubTotal(100)
create  FUNCTION [dbo].[fnGetSubTotal] 
( 
    @total money
) 
RETURNS money
BEGIN 
    DECLARE @impuestos money,
			@resultado money

			select @impuestos = Porcentaje
			from cat_impuestos
			where clave = 1

			set @resultado = @total / (1+ (@impuestos/100))
   
    RETURN isnull(@resultado,0)
END 


GO
/****** Object:  UserDefinedFunction [dbo].[fnPreferenciaAplicaSiNo]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- select dbo.fnPreferenciaAplicaSiNo('SOB-SoloProdBascula',6)
CREATE  FUNCTION [dbo].[fnPreferenciaAplicaSiNo] 
( 
    @Preferencia VARCHAR(50),
	@SucursalId INT
) 
RETURNS BIT
BEGIN 

	DECLARE @Result BIT=0
   
   IF EXISTS (
	SELECT  PS.Valor
	FROM sis_preferencias_sucursales PS
	INNER JOIN sis_preferencias P ON P.Id = PS.PreferenciaId
	WHERE P.Preferencia IN( @Preferencia) AND
	PS.SucursalId = @SucursalId)
	BEGIN

	  SET @Result = 1
	END


	IF @Result = 0
	BEGIN

		IF EXISTS (
			SELECT  PS.Valor
			FROM sis_preferencias_empresa PS
			INNER JOIN sis_preferencias P ON P.Id = PS.PreferenciaId
			WHERE P.Preferencia IN( @Preferencia) 
		)
		BEGIN
			SET @Result = 1
		END
	END


	
   
    RETURN @Result
END 


GO
/****** Object:  UserDefinedFunction [dbo].[fnSplitString]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  FUNCTION [dbo].[fnSplitString] 
( 
    @string NVARCHAR(MAX), 
    @delimiter CHAR(1) 
) 
RETURNS @output TABLE(splitdata varchar(max))
 
--declare @tabla  table(splitdata int)
--declare @string varchar(50) = '1580',
--	   @delimiter char(1) = ','

BEGIN 
    DECLARE @start INT, @end bigINT 
    SELECT @start = 1, @end = CHARINDEX(@delimiter, @string) 
    WHILE @start < LEN(@string) + 1 
    BEGIN 
        IF @end = 0  
            SET @end = LEN(@string) + 1
       
        INSERT INTO @output (splitdata)  
        Select Cast((SUBSTRING(@string, @start, @end - @start)) as varchar(max)) 
        SET @start = @end + 1 
        SET @end = CHARINDEX(@delimiter, @string, @start)	   
    END 
    RETURN 
END 


GO
/****** Object:  UserDefinedFunction [dbo].[fnUsuarioSucursales]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- select * from dbo.[fnUsuarioSucursales](1)
CREATE  FUNCTION [dbo].[fnUsuarioSucursales] 
( 
    @pUsuarioId INT
) 
RETURNS @output TABLE(sucursalId int)
 
--declare @tabla  table(splitdata int)
--declare @string varchar(50) = '1580',
--	   @delimiter char(1) = ','

BEGIN 
	INSERT INTO @output (sucursalId)  
	SELECT Clave
	FROM cat_sucursales s
	INNER JOIN cat_usuarios_sucursales US ON US.UsuarioId = @pUsuarioId AND
								US.SucursalId = s.Clave

    RETURN 
END 


GO
/****** Object:  Table [dbo].[cat_abreviaturas_SAT]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_abreviaturas_SAT](
	[Clave] [int] NOT NULL,
	[AbreviaturaSAT] [varchar](50) NOT NULL,
	[CodigoSAT] [varchar](20) NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_cat_abreviaturas_SAT] PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_almacenes]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_almacenes](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[Ubicacion] [varchar](60) NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_anaqueles]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_anaqueles](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_andenes]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_andenes](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_antecedentes]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_antecedentes](
	[AntecedenteId] [int] NOT NULL,
	[Descripcion] [varchar](250) NOT NULL,
 CONSTRAINT [PK_cat_antecedentes] PRIMARY KEY CLUSTERED 
(
	[AntecedenteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_basculas]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_basculas](
	[BasculaId] [int] NOT NULL,
	[EmpresaId] [int] NOT NULL,
	[Alias] [varchar](50) NOT NULL,
	[Marca] [varchar](50) NOT NULL,
	[Modelo] [varchar](50) NOT NULL,
	[Serie] [varchar](50) NOT NULL,
	[SucursalAsignadaId] [int] NULL,
	[Activo] [bit] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[ModificadoEl] [datetime] NULL,
	[ModificadoPor] [int] NULL,
 CONSTRAINT [PK_cat_basculas] PRIMARY KEY CLUSTERED 
(
	[BasculaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_basculas_configuracion]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_basculas_configuracion](
	[EquipoComputoId] [int] NOT NULL,
	[BasculaId] [int] NOT NULL,
	[PortName] [varchar](100) NOT NULL,
	[BaudRate] [int] NOT NULL,
	[ReadBufferSize] [int] NOT NULL,
	[WriteBufferSize] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[PesoDefault] [decimal](10, 4) NULL,
	[SucursalId] [int] NULL,
 CONSTRAINT [PK_cat_basculas_configuracion] PRIMARY KEY CLUSTERED 
(
	[EquipoComputoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_cajas]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_cajas](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NULL,
	[Ubicacion] [varchar](50) NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
	[TipoCajaId] [smallint] NULL,
 CONSTRAINT [PK_cat_cajas] PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_cajas_impresora]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_cajas_impresora](
	[CajaImpresoraId] [int] NOT NULL,
	[CajaId] [int] NOT NULL,
	[ImpresoraId] [smallint] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_cajas_impresora] PRIMARY KEY CLUSTERED 
(
	[CajaImpresoraId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_cargos_adicionales]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_cargos_adicionales](
	[CargoAdicionalId] [smallint] NOT NULL,
	[Descripcion] [varchar](150) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CargoTipoId] [tinyint] NULL,
 CONSTRAINT [PK_cat_cargos_adicionales] PRIMARY KEY CLUSTERED 
(
	[CargoAdicionalId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_cargos_tipos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_cargos_tipos](
	[CargoTipoId] [tinyint] NOT NULL,
	[Tipo] [varchar](50) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_cargos_tipos] PRIMARY KEY CLUSTERED 
(
	[CargoTipoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_centro_costos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_centro_costos](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_clases_sat]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_clases_sat](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](150) NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
	[CodigoSAT] [varchar](2) NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_clasificacion_impuestos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_clasificacion_impuestos](
	[Clave] [int] NOT NULL,
	[NombreSAT] [varchar](150) NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_cat_clasificacion_impuestos] PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_clientes]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_clientes](
	[ClienteId] [int] NOT NULL,
	[Nombre] [varchar](500) NOT NULL,
	[RFC] [varchar](15) NULL,
	[Calle] [varchar](100) NULL,
	[NumeroExt] [varchar](10) NULL,
	[NumeroInt] [varchar](10) NULL,
	[Colonia] [varchar](50) NULL,
	[CodigoPostal] [varchar](5) NULL,
	[EstadoId] [int] NULL,
	[MunicipioId] [int] NULL,
	[PaisId] [smallint] NULL,
	[Telefono] [varchar](15) NULL,
	[Telefono2] [varchar](15) NULL,
	[TipoClienteId] [tinyint] NULL,
	[DiasCredito] [smallint] NULL,
	[LimiteCredito] [money] NULL,
	[AntecedenteId] [int] NULL,
	[CreditoDisponible] [money] NULL,
	[SaldoGlobal] [money] NULL,
	[Activo] [bit] NULL,
	[ClienteEspecial] [bit] NULL,
	[ClienteGral] [bit] NULL,
	[PrecioId] [tinyint] NULL,
	[GiroId] [int] NULL,
	[GiroNegocioId] [int] NULL,
	[ApellidoPaterno] [varchar](50) NULL,
	[ApellidoMaterno] [varchar](50) NULL,
	[UUID] [uniqueidentifier] NULL,
	[KeyClient] [varchar](150) NULL,
	[EmpleadoId] [int] NULL,
	[Clave] [varchar](20) NULL,
	[SucursalBaseId] [int] NULL,
	[pass] [varchar](50) NULL,
 CONSTRAINT [PK_cat_clientes] PRIMARY KEY CLUSTERED 
(
	[ClienteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_clientes_automovil]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_clientes_automovil](
	[ClienteAutoId] [int] NOT NULL,
	[ClienteId] [int] NOT NULL,
	[Modelo] [varchar](150) NOT NULL,
	[Color] [varchar](50) NOT NULL,
	[Placas] [varchar](20) NULL,
	[Observaciones] [varchar](300) NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_clientes_automovil] PRIMARY KEY CLUSTERED 
(
	[ClienteAutoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_clientes_contacto]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_clientes_contacto](
	[ClienteId] [int] NOT NULL,
	[Email] [varchar](100) NULL,
	[Email2] [varchar](100) NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_clientes_contacto] PRIMARY KEY CLUSTERED 
(
	[ClienteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_clientes_direcciones]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_clientes_direcciones](
	[ClienteDireccionId] [int] NOT NULL,
	[ClienteId] [int] NOT NULL,
	[TipoDireccionId] [tinyint] NOT NULL,
	[Calle] [varchar](50) NULL,
	[NumeroInterior] [varchar](10) NULL,
	[NumeroExterior] [varchar](10) NULL,
	[Colonia] [varchar](50) NULL,
	[Ciudad] [varchar](100) NULL,
	[EstadoId] [int] NULL,
	[PaisId] [int] NULL,
	[CodigoPostal] [varchar](5) NULL,
	[CreadoEl] [datetime] NULL,
 CONSTRAINT [PK_cat_clientes_direcciones] PRIMARY KEY CLUSTERED 
(
	[ClienteDireccionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_clientes_openpay]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_clientes_openpay](
	[ClienteId] [int] NOT NULL,
	[OpenPayId] [varchar](35) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_clientes_openpay_1] PRIMARY KEY CLUSTERED 
(
	[ClienteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_clientes_web]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_clientes_web](
	[ClienteId] [int] NOT NULL,
	[Email] [varchar](150) NOT NULL,
	[Password] [varchar](100) NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_clientes_web] PRIMARY KEY CLUSTERED 
(
	[ClienteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_conceptos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_conceptos](
	[ConceptoId] [int] NOT NULL,
	[Descripcion] [varchar](250) NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_cat_conceptos] PRIMARY KEY CLUSTERED 
(
	[ConceptoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_configuracion]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_configuracion](
	[ConfiguradorId] [int] NOT NULL,
	[UnaFormaPago] [bit] NULL,
	[MasUnaFormaPago] [bit] NULL,
	[CosteoUEPS] [bit] NULL,
	[CosteoPEPS] [bit] NULL,
	[CosteoPromedio] [bit] NULL,
	[AfectarInventarioLinea] [bit] NULL,
	[AfectarInventarioManual] [bit] NULL,
	[AfectarInventarioCorte] [bit] NULL,
	[EnlazarPuntoVentaInventario] [bit] NULL,
	[CajeroIncluirDetalleVenta] [bit] NULL,
	[CajeroReqClaveSupervisor] [bit] NULL,
	[SuperIncluirDetalleVenta] [bit] NULL,
	[SuperIncluirVentaTel] [bit] NULL,
	[SuperIncluirDetGastos] [bit] NULL,
	[SuperEmail1] [varchar](100) NULL,
	[SuperEmail2] [varchar](100) NULL,
	[SuperEmail3] [varchar](100) NULL,
	[SuperEmail4] [varchar](100) NULL,
	[RetiroMontoEfec] [money] NULL,
	[RetiroLectura] [bit] NULL,
	[RetiroEscritura] [bit] NULL,
	[NombreImpresora] [varchar](200) NULL,
	[HardwareCaracterCajon] [varchar](50) NULL,
	[EmpleadoPorcDescuento] [decimal](5, 2) NULL,
	[EmpleadoGlobal] [bit] NULL,
	[EmpleadoIndividual] [bit] NULL,
	[MontoImpresionTicket] [money] NULL,
	[ApartadoAnticipo1] [money] NULL,
	[ApartadoAnticipoHasta1] [money] NULL,
	[ApartadoAnticipo2] [money] NULL,
	[ApatadoAnticipoEnAdelante2] [money] NULL,
	[PorcentajeUtilidadProd] [decimal](5, 2) NULL,
	[DesgloceMontoTicket] [bit] NULL,
	[RetiroReqClaveSup] [bit] NULL,
	[CajDeclaracionFondoCorte] [bit] NULL,
	[SupDeclaracionFondoCorte] [bit] NULL,
	[vistaPreviaImpresion] [bit] NULL,
	[CajeroCorteDetGasto] [bit] NULL,
	[SupCorteDetGasto] [bit] NULL,
	[CajeroCorteCancelaciones] [bit] NULL,
	[SupCorteCancelaciones] [bit] NULL,
	[DevDiasVale] [tinyint] NULL,
	[DevDiasGarantia] [tinyint] NULL,
	[DevHorasGarantia] [tinyint] NULL,
	[ApartadoDiasLiq] [tinyint] NULL,
	[ApartadoDiasProrroga] [tinyint] NULL,
	[ReqClaveSupReimpresionTicketPV] [bit] NULL,
	[ReqClaveSupCancelaTicketPV] [bit] NULL,
	[ReqClaveSupGastosPV] [bit] NULL,
	[ReqClaveSupDevolucionPV] [bit] NULL,
	[ReqClaveSupApartadoPV] [bit] NULL,
	[ReqClaveSupExistenciaPV] [bit] NULL,
	[SerieTicketVenta] [char](3) NULL,
	[SerieTicketApartado] [char](3) NULL,
	[CorteCajaIncluirExistencia] [bit] NULL,
	[ImprimirTicketMediaCarta] [bit] NULL,
	[Giro] [varchar](10) NULL,
	[SolicitarComanda] [bit] NULL,
	[TieneRec] [bit] NULL,
	[PorcRec] [decimal](5, 2) NULL,
	[MontoRecargoDiario] [money] NULL,
	[PedidoAnticipoPorc] [decimal](5, 2) NULL,
	[PedidoPoliticaId] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_configuracion_restaurante]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_configuracion_restaurante](
	[Id] [int] NOT NULL,
	[SolicitarFolioComanda] [bit] NOT NULL,
 CONSTRAINT [PK_cat_configuracion_restaurante] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_configuracion_ticket_apartado]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_configuracion_ticket_apartado](
	[ConfiguracionTicketVentaId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[TextoCabecera1] [varchar](250) NOT NULL,
	[TextoCabecera2] [varchar](250) NOT NULL,
	[TextoPie] [varchar](250) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[Serie] [varchar](5) NULL,
 CONSTRAINT [PK_cat_configuracion_ticket_apartado] PRIMARY KEY CLUSTERED 
(
	[ConfiguracionTicketVentaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_configuracion_ticket_venta]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_configuracion_ticket_venta](
	[ConfiguracionTicketVentaId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[TextoCabecera1] [varchar](250) NOT NULL,
	[TextoCabecera2] [varchar](250) NOT NULL,
	[TextoPie] [varchar](250) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[Serie] [varchar](5) NULL,
 CONSTRAINT [PK_cat_configuracion_ticket_venta] PRIMARY KEY CLUSTERED 
(
	[ConfiguracionTicketVentaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_denominaciones]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_denominaciones](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[Valor] [money] NULL,
	[Orden] [int] NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_departamentos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_departamentos](
	[DepartamentoId] [int] NOT NULL,
	[Nombre] [varchar](500) NOT NULL,
	[Activo] [bit] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_cat_departamentos] PRIMARY KEY CLUSTERED 
(
	[DepartamentoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_divisiones_sat]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_divisiones_sat](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](2) NOT NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
	[codigoSAT] [varchar](2) NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_empresas]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_empresas](
	[Clave] [int] NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
	[NombreComercial] [varchar](100) NULL,
	[RegimenFiscal] [varchar](100) NULL,
	[RFC] [varchar](20) NULL,
	[Calle] [varchar](100) NULL,
	[Colonia] [varchar](100) NULL,
	[NoExt] [varchar](20) NULL,
	[NoInt] [varchar](20) NULL,
	[CP] [varchar](20) NULL,
	[Ciudad] [varchar](50) NULL,
	[Estado] [varchar](50) NULL,
	[Pais] [varchar](50) NULL,
	[Telefono1] [varchar](40) NULL,
	[Telefono2] [varchar](40) NULL,
	[Email] [varchar](60) NULL,
	[FechaAlta] [date] NULL,
	[Estatus] [bit] NULL,
	[Logo] [image] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_empresas_config_inventario]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_empresas_config_inventario](
	[EmpresaId] [int] NOT NULL,
	[EnableTraspasoAutomatico] [bit] NOT NULL,
	[ValidarExistenciaTraspaso] [bit] NULL,
 CONSTRAINT [PK_cat_empresa_config_inventario] PRIMARY KEY CLUSTERED 
(
	[EmpresaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_equipos_computo]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_equipos_computo](
	[EquipoComputoId] [int] NOT NULL,
	[HardwareID] [varchar](250) NOT NULL,
	[IPPublica] [varchar](50) NOT NULL,
	[PCName] [varchar](250) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[ModificadoEl] [datetime] NULL,
	[SucursalId] [int] NULL,
 CONSTRAINT [PK_cat_equipos_computo] PRIMARY KEY CLUSTERED 
(
	[EquipoComputoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_estados]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_estados](
	[EstadoId] [int] NOT NULL,
	[PaisId] [smallint] NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
 CONSTRAINT [PK_cat_estados] PRIMARY KEY CLUSTERED 
(
	[EstadoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_estatus]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_estatus](
	[EstatusId] [int] NOT NULL,
	[Descripcion] [varchar](150) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_estatus] PRIMARY KEY CLUSTERED 
(
	[EstatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_estatus_pedido]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_estatus_pedido](
	[EstatusPedidoId] [smallint] NOT NULL,
	[Descripcion] [varchar](50) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[Clave] [varchar](50) NULL,
 CONSTRAINT [PK_cat_pedido_estatus] PRIMARY KEY CLUSTERED 
(
	[EstatusPedidoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_estatus_produccion]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_estatus_produccion](
	[EstatusProduccionId] [int] NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
 CONSTRAINT [PK_cat_estatus_produccion] PRIMARY KEY CLUSTERED 
(
	[EstatusProduccionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_familias]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_familias](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
	[ProductoPortadaId] [int] NULL,
	[Orden] [smallint] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_formas_pago]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_formas_pago](
	[FormaPagoId] [int] NOT NULL,
	[Descripcion] [varchar](100) NOT NULL,
	[Abreviatura] [varchar](10) NOT NULL,
	[Orden] [smallint] NOT NULL,
	[RequiereDigVerificador] [bit] NOT NULL,
	[Activo] [bit] NOT NULL,
	[Signo] [varchar](1) NOT NULL,
	[NumeroHacienda] [smallint] NOT NULL,
 CONSTRAINT [PK_cat_formas_pago] PRIMARY KEY CLUSTERED 
(
	[FormaPagoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_gastos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_gastos](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NULL,
	[ClaveCentroCosto] [int] NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
	[Monto] [money] NULL,
	[Observaciones] [varchar](300) NULL,
	[ConceptoId] [int] NULL,
	[CreadoPor] [int] NULL,
	[CreadoEl] [datetime] NULL,
	[CajaId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_gastos_deducibles]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_gastos_deducibles](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[GastoConceptoId] [int] NULL,
	[CreadoEl] [datetime] NULL,
 CONSTRAINT [PK_cat_gastos_deducibles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_giros]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_giros](
	[GiroId] [smallint] NOT NULL,
	[Descripcion] [varchar](200) NOT NULL,
 CONSTRAINT [PK_cat_giros] PRIMARY KEY CLUSTERED 
(
	[GiroId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_giros_neg]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_giros_neg](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_grupos_sat]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_grupos_sat](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](150) NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
	[CodigoSAT] [varchar](2) NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_guisos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_guisos](
	[productoId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_productos_guisos] PRIMARY KEY CLUSTERED 
(
	[productoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_impresoras]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_impresoras](
	[ImpresoraId] [smallint] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[NombreRed] [varchar](250) NOT NULL,
	[NombreImpresora] [varchar](150) NOT NULL,
	[Activa] [bit] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_impresoras] PRIMARY KEY CLUSTERED 
(
	[ImpresoraId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_impresoras_comandas]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_impresoras_comandas](
	[ImpresoraId] [smallint] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_impresoras_comandas] PRIMARY KEY CLUSTERED 
(
	[ImpresoraId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_impuestos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_impuestos](
	[Clave] [int] NOT NULL,
	[CodigoSAT] [varchar](15) NOT NULL,
	[Descripcion] [varchar](250) NOT NULL,
	[IdAbreviatura] [int] NOT NULL,
	[OrdenImpresion] [tinyint] NOT NULL,
	[IdClasificacionImpuesto] [int] NOT NULL,
	[IdTipoFactor] [int] NOT NULL,
	[Porcentaje] [decimal](5, 2) NULL,
	[CuotaFija] [money] NULL,
	[DecimalesPorcCuota] [tinyint] NULL,
	[DesglosarImpPrecioVta] [bit] NULL,
	[AgregarImpPrecioVta] [bit] NULL,
 CONSTRAINT [PK_cat_impuestos] PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_lineas]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_lineas](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_lotes]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_lotes](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_marcas]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_marcas](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_monedas]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_monedas](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[Abreviacion] [varchar](20) NULL,
	[TipoCambio] [decimal](18, 0) NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
	[IdMonedaAbreviatura] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_monedas_abreviaturas]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_monedas_abreviaturas](
	[IdMonedaAbreviatura] [int] NOT NULL,
	[NombreMonedaSAT] [varchar](200) NOT NULL,
	[ClaveSAT] [varchar](20) NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_cat_monedas_abreviaturas] PRIMARY KEY CLUSTERED 
(
	[IdMonedaAbreviatura] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_municipios]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_municipios](
	[MunicipioId] [int] NOT NULL,
	[EstadoId] [int] NOT NULL,
	[Nombre] [varchar](100) NULL,
 CONSTRAINT [PK_cat_municipios] PRIMARY KEY CLUSTERED 
(
	[MunicipioId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_paises]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_paises](
	[PaisId] [smallint] NOT NULL,
	[Nombre] [varchar](50) NULL,
 CONSTRAINT [PK_cat_paises] PRIMARY KEY CLUSTERED 
(
	[PaisId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_paqueterias]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_paqueterias](
	[PaqueteriaId] [int] NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_paqueterias] PRIMARY KEY CLUSTERED 
(
	[PaqueteriaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_politicas]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_politicas](
	[PoliticaId] [int] NOT NULL,
	[Politica] [text] NOT NULL,
	[Descripcion] [varchar](50) NOT NULL,
	[Activo] [bit] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_politicas] PRIMARY KEY CLUSTERED 
(
	[PoliticaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_precios]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_precios](
	[IdPrecio] [tinyint] NOT NULL,
	[Descripcion] [varchar](100) NULL,
 CONSTRAINT [PK_cat_precios] PRIMARY KEY CLUSTERED 
(
	[IdPrecio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_produccion_productos_sucursal]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_produccion_productos_sucursal](
	[Id] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_produccion_productos_sucursal] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_productos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_productos](
	[ProductoId] [int] NOT NULL,
	[Clave] [varchar](30) NOT NULL,
	[Descripcion] [varchar](500) NULL,
	[DescripcionCorta] [varchar](250) NULL,
	[FechaAlta] [date] NULL,
	[ClaveMarca] [int] NULL,
	[ClaveFamilia] [int] NULL,
	[ClaveSubFamilia] [int] NULL,
	[ClaveLinea] [int] NULL,
	[ClaveUnidadMedida] [int] NULL,
	[ClaveInventariadoPor] [int] NULL,
	[ClaveVendidaPor] [int] NULL,
	[Estatus] [bit] NULL,
	[ProductoTerminado] [bit] NULL,
	[Inventariable] [bit] NULL,
	[MateriaPrima] [bit] NULL,
	[ProdParaVenta] [bit] NULL,
	[ProdVtaBascula] [bit] NULL,
	[Seriado] [bit] NULL,
	[NumeroDecimales] [tinyint] NULL,
	[PorcDescuentoEmpleado] [numeric](19, 2) NULL,
	[ContenidoCaja] [int] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
	[Foto] [image] NULL,
	[ClaveAlmacen] [int] NULL,
	[ClaveAnden] [int] NULL,
	[ClaveLote] [int] NULL,
	[FechaCaducidad] [datetime] NULL,
	[MinimoInventario] [decimal](14, 2) NULL,
	[MaximoInventario] [decimal](14, 2) NULL,
	[PorcUtilidad] [decimal](5, 2) NULL,
	[Talla] [varchar](5) NULL,
	[ParaSexo] [varchar](1) NULL,
	[Color] [varchar](10) NULL,
	[Color2] [varchar](10) NULL,
	[SobrePedido] [bit] NULL,
	[Especificaciones] [varchar](500) NULL,
	[Liquidacion] [bit] NULL,
	[Version] [varchar](20) NULL,
	[CodigoBarras] [varchar](25) NULL,
	[Orden] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_productos_agrupados]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_productos_agrupados](
	[ProductoAgrupadoId] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[DescripcionCorta] [varchar](30) NULL,
	[CreadoEl] [datetime] NOT NULL,
	[Especificaciones] [varchar](500) NULL,
	[ProductoId] [int] NOT NULL,
	[Rating] [tinyint] NULL,
	[Liquidacion] [bit] NULL,
 CONSTRAINT [PK_cat_productos_agrupados] PRIMARY KEY CLUSTERED 
(
	[ProductoAgrupadoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_productos_agrupados_detalle]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_productos_agrupados_detalle](
	[ProductoAgrupadoId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_productos_agrupados_detalle] PRIMARY KEY CLUSTERED 
(
	[ProductoAgrupadoId] ASC,
	[ProductoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_productos_base]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_productos_base](
	[ProductoMateriaPrimaId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[ProductoBaseId] [int] NOT NULL,
	[Cantidad] [decimal](14, 4) NULL,
	[CreadoEl] [datetime] NULL,
	[ModificadoEl] [datetime] NULL,
	[UnidadCocinaId] [int] NULL,
	[ParaCocina] [bit] NULL,
	[Requerido] [bit] NULL,
	[Orden] [int] NULL,
	[GenerarSalidaVenta] [bit] NULL,
 CONSTRAINT [PK_cat_productos_base] PRIMARY KEY CLUSTERED 
(
	[ProductoMateriaPrimaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_productos_base_conceptos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_productos_base_conceptos](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProductoId] [int] NOT NULL,
	[ConceptoId] [int] NOT NULL,
	[RegistrarTiempo] [bit] NULL,
	[RegistrarVolumen] [bit] NULL,
	[CreadoEl] [nchar](10) NULL,
 CONSTRAINT [PK_cat_productos_base_conceptos] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_productos_cambio_precio]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_productos_cambio_precio](
	[Id] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[PrecioId] [tinyint] NOT NULL,
	[PrecioAnterior] [money] NOT NULL,
	[PrecioNuevo] [money] NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[UsuarioRegistroId] [int] NULL,
 CONSTRAINT [PK_cat_productos_cambio_precio] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_productos_config_sucursal]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_productos_config_sucursal](
	[ProductoId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[CalculaPrecioPorcUtilidad] [bit] NOT NULL,
	[CalculaPrecioIncUtilidad] [bit] NOT NULL,
	[CalculaPrecioManual] [bit] NOT NULL,
	[PorcUtilidadValor] [decimal](6, 2) NOT NULL,
	[IncUtilidadValor] [money] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[ModificadoPor] [int] NULL,
	[ModificadoEl] [datetime] NULL,
 CONSTRAINT [PK_cat_productos_config_sucursal] PRIMARY KEY CLUSTERED 
(
	[ProductoId] ASC,
	[SucursalId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_productos_existencias]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_productos_existencias](
	[ProductoId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[ExistenciaTeorica] [decimal](16, 5) NULL,
	[CostoUltimaCompra] [money] NOT NULL,
	[CostoPromedio] [money] NOT NULL,
	[ValCostoUltimaCompra] [money] NOT NULL,
	[ValCostoPromedio] [money] NOT NULL,
	[ModificadoEl] [datetime] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[Apartado] [decimal](14, 2) NULL,
	[Disponible] [decimal](16, 5) NULL,
	[CostoPromedioInicial] [money] NULL,
	[CostoCapturaUsuario] [decimal](14, 2) NULL,
 CONSTRAINT [PK_cat_productos_existencias] PRIMARY KEY CLUSTERED 
(
	[ProductoId] ASC,
	[SucursalId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_productos_guisos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_productos_guisos](
	[ProductoId] [int] NOT NULL,
	[ProductoGuisoId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_productos_guisos_1] PRIMARY KEY CLUSTERED 
(
	[ProductoId] ASC,
	[ProductoGuisoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_productos_imagenes]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_productos_imagenes](
	[ProductoImageId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[FileName] [varchar](250) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[FileByte] [image] NULL,
	[Principal] [bit] NULL,
	[Miniatura] [bit] NULL,
 CONSTRAINT [PK_cat_productos_imagenes] PRIMARY KEY CLUSTERED 
(
	[ProductoImageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_productos_impuestos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_productos_impuestos](
	[ProductoImpuestoId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[ImpuestoId] [int] NOT NULL,
 CONSTRAINT [PK_cat_productos_impuestos] PRIMARY KEY CLUSTERED 
(
	[ProductoImpuestoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_productos_licencias]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_productos_licencias](
	[ProductoId] [int] NOT NULL,
	[TiempoLicencia] [smallint] NOT NULL,
	[UnidadLicencia] [varchar](1) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_productos_licencias] PRIMARY KEY CLUSTERED 
(
	[ProductoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_productos_precios]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_productos_precios](
	[IdProductoPrecio] [int] NOT NULL,
	[IdProducto] [int] NOT NULL,
	[IdPrecio] [tinyint] NOT NULL,
	[PorcDescuento] [decimal](14, 2) NOT NULL,
	[MontoDescuento] [money] NOT NULL,
	[Precio] [money] NOT NULL,
 CONSTRAINT [PK_cat_productos_precios] PRIMARY KEY CLUSTERED 
(
	[IdProductoPrecio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_productos_principales]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_productos_principales](
	[SucursalId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[CreadoEl] [datetime] NULL,
 CONSTRAINT [PK_cat_productos_principales] PRIMARY KEY CLUSTERED 
(
	[SucursalId] ASC,
	[ProductoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_proveedores]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_proveedores](
	[ProveedorId] [int] NOT NULL,
	[Nombre] [varchar](500) NOT NULL,
	[RFC] [varchar](15) NULL,
	[Calle] [varchar](100) NULL,
	[NumeroExt] [varchar](10) NULL,
	[NumeroInt] [varchar](10) NULL,
	[Colonia] [varchar](50) NULL,
	[CodigoPostal] [varchar](5) NULL,
	[EstadoId] [int] NULL,
	[MunicipioId] [int] NULL,
	[PaisId] [smallint] NULL,
	[Telefono] [varchar](15) NULL,
	[Telefono2] [varchar](15) NULL,
	[TipoProveedorId] [tinyint] NULL,
	[DiasCredito] [smallint] NULL,
	[LimiteCredito] [money] NULL,
	[CreditoDisponible] [money] NULL,
	[SaldoGlobal] [money] NULL,
	[Activo] [bit] NULL,
	[ClienteEspecial] [bit] NULL,
	[ClienteGral] [bit] NULL,
	[PrecioId] [tinyint] NULL,
	[GiroId] [int] NULL,
 CONSTRAINT [PK_cat_proveedores] PRIMARY KEY CLUSTERED 
(
	[ProveedorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_rec_configuracion_rangos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_rec_configuracion_rangos](
	[Id] [smallint] NOT NULL,
	[RangoInicial] [money] NOT NULL,
	[RangoFinal] [money] NOT NULL,
	[PorcDeclarar] [decimal](5, 2) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_rec_configuracion_rangos] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_rest_comandas]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_rest_comandas](
	[ComandaId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[Folio] [int] NOT NULL,
	[Disponible] [bit] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_rest_comandas] PRIMARY KEY CLUSTERED 
(
	[ComandaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_rest_mesas]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_rest_mesas](
	[MesaId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[Nombre] [varchar](20) NOT NULL,
	[Descripcion] [varchar](150) NOT NULL,
	[Activo] [bit] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[ModificadoEl] [datetime] NULL,
	[ModificadoPor] [int] NULL,
 CONSTRAINT [PK_cat_rest_mesas] PRIMARY KEY CLUSTERED 
(
	[MesaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_rest_platillo_adicionales]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_rest_platillo_adicionales](
	[Id] [int] NOT NULL,
	[Descripcion] [varchar](50) NOT NULL,
	[MostrarSiempre] [bit] NOT NULL,
	[Activo] [bit] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_cat_rest_platillo_adicionales] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_rest_platillo_adicionales_sfam]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_rest_platillo_adicionales_sfam](
	[PlatilloAdicionalId] [int] NOT NULL,
	[SubfamiliaId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_rest_platillo_adicionales_sfam] PRIMARY KEY CLUSTERED 
(
	[PlatilloAdicionalId] ASC,
	[SubfamiliaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_rubros]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_rubros](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_sitios_entrega_pedido]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_sitios_entrega_pedido](
	[SitioEntregaPedidoId] [smallint] NOT NULL,
	[Descripcion] [varchar](200) NOT NULL,
	[CiudadId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_sitios_entrega_pedido] PRIMARY KEY CLUSTERED 
(
	[SitioEntregaPedidoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_subclases_sat]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_subclases_sat](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](150) NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
	[CodigoSAT] [varchar](2) NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_subfamilias]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_subfamilias](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[Familia] [int] NOT NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_sucursales]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_sucursales](
	[Clave] [int] NOT NULL,
	[Empresa] [int] NULL,
	[Calle] [varchar](50) NULL,
	[Colonia] [varchar](50) NULL,
	[NoExt] [nchar](20) NULL,
	[NoInt] [nchar](20) NULL,
	[Ciudad] [varchar](60) NULL,
	[Estado] [varchar](60) NULL,
	[Pais] [varchar](60) NULL,
	[Telefono1] [varchar](40) NULL,
	[Telefono2] [varchar](40) NULL,
	[Email] [varchar](60) NULL,
	[Estatus] [bit] NULL,
	[NombreSucursal] [varchar](60) NULL,
	[CP] [varchar](5) NULL,
	[ServidorMailSMTP] [varchar](50) NULL,
	[ServidorMailFrom] [varchar](70) NULL,
	[ServidorMailPort] [smallint] NULL,
	[ServidorMailPassword] [varchar](50) NULL,
 CONSTRAINT [PK_cat_sucursales] PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_sucursales_departamentos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_sucursales_departamentos](
	[SucursalId] [int] NOT NULL,
	[DepartamentoId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_cat_sucursales_departamentos] PRIMARY KEY CLUSTERED 
(
	[SucursalId] ASC,
	[DepartamentoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_sucursales_productos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_sucursales_productos](
	[SucursalId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[CreadoEl] [datetime] NULL,
 CONSTRAINT [PK_cat_sucursales_productos] PRIMARY KEY CLUSTERED 
(
	[SucursalId] ASC,
	[ProductoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_tipo_factor_SAT]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_tipo_factor_SAT](
	[Clave] [int] NOT NULL,
	[NombreFactorSAT] [varchar](150) NOT NULL,
	[Activo] [bit] NULL,
 CONSTRAINT [PK_cat_tipo_factor_SAT] PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_tipos_bascula_bitacora]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_tipos_bascula_bitacora](
	[TipoBasculaBitacoraId] [int] NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_tipos_bascula_bitacora] PRIMARY KEY CLUSTERED 
(
	[TipoBasculaBitacoraId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_tipos_cajas]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_tipos_cajas](
	[TipoCajaId] [smallint] NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_cat_tipos_cajas] PRIMARY KEY CLUSTERED 
(
	[TipoCajaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_tipos_cliente]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_tipos_cliente](
	[TipoClienteId] [tinyint] NOT NULL,
	[Descripcion] [varchar](100) NOT NULL,
 CONSTRAINT [PK_cat_tipos_cliente] PRIMARY KEY CLUSTERED 
(
	[TipoClienteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_tipos_descuento]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_tipos_descuento](
	[TipoDescuentoId] [tinyint] NOT NULL,
	[Descripcion] [varchar](50) NOT NULL,
 CONSTRAINT [PK_cat_tipos_cortesia] PRIMARY KEY CLUSTERED 
(
	[TipoDescuentoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_tipos_devolucion]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_tipos_devolucion](
	[TipoDevolucionId] [int] NOT NULL,
	[Descripcion] [varchar](250) NOT NULL,
 CONSTRAINT [PK_cat_tipos_devolucion] PRIMARY KEY CLUSTERED 
(
	[TipoDevolucionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_tipos_direcciones]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_tipos_direcciones](
	[TipoDireccionId] [tinyint] NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_tipos_direcciones] PRIMARY KEY CLUSTERED 
(
	[TipoDireccionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_tipos_documento]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_tipos_documento](
	[TipoDocumentoId] [tinyint] NOT NULL,
	[Descripcion] [varchar](250) NOT NULL,
	[Abreviatura] [varchar](3) NOT NULL,
	[FolioInicial] [int] NOT NULL,
	[RequiereClaveSuper] [bit] NOT NULL,
	[IntegrarCorteCaja] [bit] NOT NULL,
 CONSTRAINT [PK_cat_tipos_documento] PRIMARY KEY CLUSTERED 
(
	[TipoDocumentoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_tipos_mermas]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_tipos_mermas](
	[TipoMermaId] [smallint] NOT NULL,
	[Tipo] [varchar](500) NOT NULL,
	[CreadoEl] [datetime] NULL,
 CONSTRAINT [PK_cat_tipos_mermas] PRIMARY KEY CLUSTERED 
(
	[TipoMermaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_tipos_movimiento_inventario]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_tipos_movimiento_inventario](
	[TipoMovimientoInventarioId] [int] NOT NULL,
	[Descripcion] [varchar](250) NOT NULL,
	[Activo] [bit] NOT NULL,
	[EsEntrada] [bit] NULL,
	[TipoMovimientoCancelacionId] [int] NULL,
 CONSTRAINT [PK_cat_tipo_movimiento_inventario] PRIMARY KEY CLUSTERED 
(
	[TipoMovimientoInventarioId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_tipos_pedido]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_tipos_pedido](
	[TipoPedidoId] [int] NOT NULL,
	[Nombre] [varchar](500) NOT NULL,
	[Folio] [varchar](50) NULL,
 CONSTRAINT [PK_cat_tipos_pedido] PRIMARY KEY CLUSTERED 
(
	[TipoPedidoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_tipos_proveedor]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_tipos_proveedor](
	[TipoProveedorId] [tinyint] NOT NULL,
	[Descripcion] [varchar](100) NULL,
 CONSTRAINT [PK_cat_tipos_proveedor] PRIMARY KEY CLUSTERED 
(
	[TipoProveedorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_tipos_requisiciones]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_tipos_requisiciones](
	[TipoRequisicionId] [smallint] NOT NULL,
	[Descripcion] [varchar](150) NOT NULL,
	[CreadoEl] [datetime] NULL,
 CONSTRAINT [PK_cat_tipos_requisiciones] PRIMARY KEY CLUSTERED 
(
	[TipoRequisicionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_tipos_vale]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_tipos_vale](
	[TipoValeId] [int] NOT NULL,
	[Descripcion] [varchar](55) NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_cat_tipos_vale] PRIMARY KEY CLUSTERED 
(
	[TipoValeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_unidades_medida_SAT]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_unidades_medida_SAT](
	[IdUnidadMedidaSAT] [int] NOT NULL,
	[ClaveSAT] [varchar](20) NOT NULL,
	[NombreSAT] [varchar](100) NOT NULL,
	[DescripcionSAT] [varchar](500) NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_cat_unidades_medida_SAT] PRIMARY KEY CLUSTERED 
(
	[IdUnidadMedidaSAT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_unidadesmed]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_unidadesmed](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[DescripcionCorta] [varchar](20) NULL,
	[Decimales] [int] NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
	[IdCodigoSAT] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_usuarios]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_usuarios](
	[IdUsuario] [int] NOT NULL,
	[IdEmpleado] [int] NOT NULL,
	[NombreUsuario] [varchar](50) NOT NULL,
	[Password] [varchar](20) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[Activo] [bit] NULL,
	[EsSupervisor] [bit] NULL,
	[PasswordSupervisor] [varchar](20) NULL,
	[IdSucursal] [int] NULL,
	[EsSupervisorCajero] [bit] NULL,
	[PasswordSupervisorCajero] [varchar](20) NULL,
	[Email] [varchar](100) NULL,
	[CajaDefaultId] [int] NULL,
 CONSTRAINT [PK_cat_usuarios] PRIMARY KEY CLUSTERED 
(
	[IdUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_usuarios_sucursales]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_usuarios_sucursales](
	[UsuarioId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_usuarios_sucursales] PRIMARY KEY CLUSTERED 
(
	[UsuarioId] ASC,
	[SucursalId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_web_configuracion]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_web_configuracion](
	[SucursalId] [int] NOT NULL,
	[Dominio] [varchar](100) NOT NULL,
	[ServidorFTP] [varchar](50) NOT NULL,
	[UsuarioFTP] [varchar](50) NOT NULL,
	[PasswordFTP] [varchar](20) NOT NULL,
	[FolderProductos] [varchar](150) NOT NULL,
	[DiasEntregaAdicSPedido] [tinyint] NULL,
	[DiasEntregaPedido] [tinyint] NULL,
 CONSTRAINT [PK_cat_web_configuracion] PRIMARY KEY CLUSTERED 
(
	[SucursalId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_aceptaciones_sucursal]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_aceptaciones_sucursal](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SucursalId] [int] NOT NULL,
	[MovimientoId] [int] NULL,
	[Fecha] [datetime] NOT NULL,
	[AceptadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_aceptaciones_sucursal] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_aceptaciones_sucursal_detalle]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_aceptaciones_sucursal_detalle](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[AceptacionSucursalId] [int] NOT NULL,
	[MovimientoDetalleId] [int] NULL,
	[CantidadReal] [decimal](14, 4) NULL,
	[MovimientoDetalleAjusteId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_aceptaciones_sucursal_detalle] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_apartados]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_apartados](
	[ApartadoId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[ClienteId] [int] NOT NULL,
	[TotalApartado] [money] NOT NULL,
	[Saldo] [money] NOT NULL,
	[Activo] [bit] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[FechaLimite] [datetime] NULL,
	[FechaProrroga] [datetime] NULL,
	[VentaId] [bigint] NULL,
	[CajaId] [int] NULL,
 CONSTRAINT [PK_doc_apartados] PRIMARY KEY CLUSTERED 
(
	[ApartadoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_apartados_formas_pago]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_apartados_formas_pago](
	[ApartadoPagoId] [int] NOT NULL,
	[FormaPagoId] [int] NOT NULL,
	[Cantidad] [money] NOT NULL,
	[DigitoVerificador] [varchar](20) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_apartados_formas_pago] PRIMARY KEY CLUSTERED 
(
	[ApartadoPagoId] ASC,
	[FormaPagoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_apartados_pagos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_apartados_pagos](
	[ApartadoPagoId] [int] NOT NULL,
	[ApartadoId] [int] NOT NULL,
	[Importe] [money] NOT NULL,
	[FechaPago] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[Anticipo] [bit] NOT NULL,
	[CajaId] [int] NULL,
 CONSTRAINT [PK_doc_apartados_pagos] PRIMARY KEY CLUSTERED 
(
	[ApartadoPagoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_apartados_productos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_apartados_productos](
	[ApartadoProductoId] [int] NOT NULL,
	[ApartadoId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Cantidad] [decimal](7, 2) NOT NULL,
	[Precio] [money] NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[ModificadoEl] [datetime] NULL,
	[ModificadoPor] [int] NULL,
	[SubTotal] [money] NULL,
	[Impuestos] [money] NULL,
	[Descuentos] [money] NULL,
	[POrcentajeDescuento] [decimal](5, 2) NULL,
 CONSTRAINT [PK_cat_apartados_productos] PRIMARY KEY CLUSTERED 
(
	[ApartadoProductoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_basculas_bitacora]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_basculas_bitacora](
	[Id] [int] NOT NULL,
	[BasculaId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[Cantidad] [decimal](10, 4) NOT NULL,
	[Fecha] [datetime] NOT NULL,
	[TipoBasculaBitacoraId] [int] NULL,
	[ProductoId] [int] NULL,
	[PedidoDetalleId] [int] NULL,
	[Detalle] [varchar](500) NULL,
	[Credito] [bit] NULL,
	[VentaId] [bigint] NULL,
 CONSTRAINT [PK_doc_basculas_bitacora] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_cargo_adicional_config]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_cargo_adicional_config](
	[CargoAdicionalId] [smallint] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[PorcentajeVenta] [decimal](5, 2) NULL,
	[MontoFijo] [money] NULL,
	[Activo] [bit] NOT NULL,
	[CreadoEl] [nchar](10) NULL,
 CONSTRAINT [PK_doc_cargo_adicional_config] PRIMARY KEY CLUSTERED 
(
	[CargoAdicionalId] ASC,
	[SucursalId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_cargos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_cargos](
	[CargoId] [int] NOT NULL,
	[ClienteId] [int] NOT NULL,
	[ProductoId] [int] NULL,
	[Total] [money] NOT NULL,
	[CredoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[Saldo] [money] NULL,
	[Activo] [bit] NULL,
	[Descuento] [money] NULL,
	[Descripcion] [varchar](250) NULL,
	[SucursalId] [int] NULL,
 CONSTRAINT [PK_doc_cargos] PRIMARY KEY CLUSTERED 
(
	[CargoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_cargos_detalle]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_cargos_detalle](
	[CargoDetalleId] [int] NOT NULL,
	[CargoId] [int] NOT NULL,
	[FechaCargo] [datetime] NOT NULL,
	[FechaPago] [datetime] NULL,
	[Subtotal] [money] NOT NULL,
	[Impuestos] [money] NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[Saldo] [money] NULL,
	[Descuento] [money] NULL,
 CONSTRAINT [PK_doc_cargos_detalle] PRIMARY KEY CLUSTERED 
(
	[CargoDetalleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_clientes_licencias]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_clientes_licencias](
	[ClienteLicenciaId] [int] NOT NULL,
	[ClienteId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[FechaVigencia] [datetime] NOT NULL,
	[Vigente] [bit] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[ModificadoEl] [datetime] NULL,
 CONSTRAINT [PK_doc_clientes_licencias] PRIMARY KEY CLUSTERED 
(
	[ClienteLicenciaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_clientes_productos_precios]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_clientes_productos_precios](
	[ClienteProductoPrecioId] [int] NOT NULL,
	[ClienteId] [int] NULL,
	[ProductoId] [int] NULL,
	[Precio] [decimal](18, 2) NULL,
	[CreadoEl] [datetime] NULL,
 CONSTRAINT [PK_doc_clientes_productos_precios] PRIMARY KEY CLUSTERED 
(
	[ClienteProductoPrecioId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_cocimientos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_cocimientos](
	[CocimientoId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[ProduccionId] [int] NOT NULL,
	[FechaCocimiento] [datetime] NOT NULL,
	[FechaHabilitado] [datetime] NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[FechaHoraIni] [datetime] NULL,
	[FechaHoraFin] [datetime] NULL,
 CONSTRAINT [PK_doc_cocimientos] PRIMARY KEY CLUSTERED 
(
	[CocimientoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_cocimientos_grupos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_cocimientos_grupos](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SucursalId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_cocimientos_grupos] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_cocimientos_grupos_detalle]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_cocimientos_grupos_detalle](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CocimientoGrupoId] [int] NOT NULL,
	[CocimientoId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_cocimientos_grupos_detalle] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_cocimientos_grupos_movs_inventario]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_cocimientos_grupos_movs_inventario](
	[CocimientoGrupoId] [int] NOT NULL,
	[MovimientoInventarioId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_cocimientos_grupos_movs_inventario] PRIMARY KEY CLUSTERED 
(
	[CocimientoGrupoId] ASC,
	[MovimientoInventarioId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja](
	[CorteCajaId] [int] NOT NULL,
	[CajaId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[VentaIniId] [bigint] NULL,
	[VentaFinId] [bigint] NULL,
	[FechaApertura] [datetime] NOT NULL,
	[FechaCorte] [datetime] NOT NULL,
	[TotalCorte] [money] NOT NULL,
	[TotalIngresos] [money] NOT NULL,
	[TotalEgresos] [money] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_apartados_pagos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_apartados_pagos](
	[CorteCajaId] [int] NOT NULL,
	[ApartadoPagoId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_apartados_pagos] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC,
	[ApartadoPagoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_apartados_pagos_previo]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_apartados_pagos_previo](
	[CorteCajaId] [int] NOT NULL,
	[ApartadoPagoId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_apartados_pagos_previo] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC,
	[ApartadoPagoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_datos_entrada]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_datos_entrada](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SucursalId] [int] NOT NULL,
	[TiradaTortilla] [decimal](14, 3) NOT NULL,
	[MasaKg] [decimal](14, 3) NOT NULL,
	[TiradaTortillaKg] [decimal](14, 3) NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[MaizKg] [decimal](14, 3) NULL,
	[ModificadoEl] [datetime] NULL,
	[ModificadoPor] [int] NULL,
 CONSTRAINT [PK_doc_corte_caja_datos_entrada] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_denominaciones]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_denominaciones](
	[CorteCajaId] [int] NOT NULL,
	[DenominacionId] [int] NOT NULL,
	[Cantidad] [int] NOT NULL,
	[Valor] [money] NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_denominaciones] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC,
	[DenominacionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_denominaciones_previo]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_denominaciones_previo](
	[CorteCajaId] [int] NOT NULL,
	[DenominacionId] [int] NOT NULL,
	[Cantidad] [int] NOT NULL,
	[Valor] [money] NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_denominaciones_previo] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC,
	[DenominacionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_egresos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_egresos](
	[CorteCajaId] [int] NOT NULL,
	[Gastos] [money] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_egresos] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_egresos_previo]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_egresos_previo](
	[CorteCajaId] [int] NOT NULL,
	[Gastos] [money] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_egresos_previo] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_fp]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_fp](
	[CorteCajaId] [int] NOT NULL,
	[FormaPagoId] [int] NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_fp] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC,
	[FormaPagoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_fp_apartado]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_fp_apartado](
	[CorteCajaId] [int] NOT NULL,
	[FormaPagoId] [int] NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_fp_apartado] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC,
	[FormaPagoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_fp_apartado_previo]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_fp_apartado_previo](
	[CorteCajaId] [int] NOT NULL,
	[FormaPagoId] [int] NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_fp_apartado_previo] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC,
	[FormaPagoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_fp_previo]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_fp_previo](
	[CorteCajaId] [int] NOT NULL,
	[FormaPagoId] [int] NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_fp_previo] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC,
	[FormaPagoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_pedidos_sin_cerrar]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_pedidos_sin_cerrar](
	[CorteCajaId] [int] NOT NULL,
	[PedidoId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_pedidos_sin_cerrar] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC,
	[PedidoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_previo]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_previo](
	[CorteCajaId] [int] NOT NULL,
	[CajaId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[VentaIniId] [bigint] NULL,
	[VentaFinId] [bigint] NULL,
	[FechaApertura] [datetime] NOT NULL,
	[FechaCorte] [datetime] NOT NULL,
	[TotalCorte] [money] NOT NULL,
	[TotalIngresos] [money] NOT NULL,
	[TotalEgresos] [money] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_previo] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_ventas]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_ventas](
	[CorteId] [int] NOT NULL,
	[VentaId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_ventas] PRIMARY KEY CLUSTERED 
(
	[CorteId] ASC,
	[VentaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_ventas_previo]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_ventas_previo](
	[CorteId] [int] NOT NULL,
	[VentaId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_ventas_previo] PRIMARY KEY CLUSTERED 
(
	[CorteId] ASC,
	[VentaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_declaracion_fondo_inicial]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_declaracion_fondo_inicial](
	[DeclaracionFondoId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[CajaId] [int] NULL,
	[CorteCajaId] [int] NULL,
	[Total] [money] NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_declaraciones_fondo] PRIMARY KEY CLUSTERED 
(
	[DeclaracionFondoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_declaracion_fondo_inicial_detalle]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_declaracion_fondo_inicial_detalle](
	[DeclaracionFondoDetalleId] [int] NOT NULL,
	[DeclaracionFondoId] [int] NOT NULL,
	[DenominacionId] [int] NOT NULL,
	[Cantidad] [int] NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NULL,
 CONSTRAINT [PK_doc_declaracion_fondo_inicial_detalle] PRIMARY KEY CLUSTERED 
(
	[DeclaracionFondoDetalleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_devoluciones]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_devoluciones](
	[DevolucionId] [int] NOT NULL,
	[VentaId] [bigint] NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[TipoDevolucionId] [int] NULL,
	[FechaVencimiento] [datetime] NULL,
 CONSTRAINT [PK_doc_devoluciones_1] PRIMARY KEY CLUSTERED 
(
	[DevolucionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_devoluciones_detalle]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_devoluciones_detalle](
	[DevolucionDetId] [int] NOT NULL,
	[DevolucionId] [int] NOT NULL,
	[VentaId] [bigint] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Cantidad] [decimal](14, 2) NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_devoluciones_detalle] PRIMARY KEY CLUSTERED 
(
	[DevolucionDetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_empleados_productos_descuentos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_empleados_productos_descuentos](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[EmpleadoId] [int] NULL,
	[ProductoId] [int] NOT NULL,
	[MontoDescuento] [decimal](14, 2) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[ModificadoPor] [int] NOT NULL,
	[ModificadoEl] [datetime] NULL,
 CONSTRAINT [PK_doc_empleados_productos_descuentos] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_entrada_directa_adicional]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_entrada_directa_adicional](
	[MovimientoDetalleId] [int] NOT NULL,
	[PrecioCompra] [money] NOT NULL,
 CONSTRAINT [PK_doc_entrada_directa_adicional] PRIMARY KEY CLUSTERED 
(
	[MovimientoDetalleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_equipo_computo_bascula_registro]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_equipo_computo_bascula_registro](
	[Id] [bigint] NOT NULL,
	[EquipoConputoId] [int] NOT NULL,
	[Peso] [float] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[OcupadaPorApp] [bit] NULL,
	[SucursalId] [int] NULL,
 CONSTRAINT [PK_doc_equipo_computo_bascula_registro] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_gastos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_gastos](
	[GastoId] [int] NOT NULL,
	[CentroCostoId] [int] NOT NULL,
	[GastoConceptoId] [int] NOT NULL,
	[Obervaciones] [varchar](300) NOT NULL,
	[Monto] [money] NOT NULL,
	[CajaId] [int] NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_doc_gastos] PRIMARY KEY CLUSTERED 
(
	[GastoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_inv_carga_inicial]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_inv_carga_inicial](
	[CargaInventarioId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Cantidad] [decimal](15, 2) NOT NULL,
	[CostoPromedio] [money] NOT NULL,
	[UltimoCosto] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_inv_carga_inicial] PRIMARY KEY CLUSTERED 
(
	[CargaInventarioId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_inv_movimiento]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_inv_movimiento](
	[MovimientoId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[FolioMovimiento] [varchar](10) NOT NULL,
	[TipoMovimientoId] [int] NOT NULL,
	[FechaMovimiento] [datetime] NOT NULL,
	[HoraMovimiento] [time](7) NOT NULL,
	[Comentarios] [varchar](250) NOT NULL,
	[ImporteTotal] [money] NOT NULL,
	[Activo] [bit] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[Autorizado] [bit] NULL,
	[FechaAutoriza] [datetime] NULL,
	[SucursalDestinoId] [int] NULL,
	[AutorizadoPor] [int] NULL,
	[FechaCancelacion] [datetime] NULL,
	[ProductoCompraId] [int] NULL,
	[Consecutivo] [int] NULL,
	[SucursalOrigenId] [int] NULL,
	[VentaId] [bigint] NULL,
	[MovimientoRefId] [int] NULL,
	[Cancelado] [bit] NULL,
	[TipoMermaId] [smallint] NULL,
	[FechaCorteExistencia] [datetime] NULL,
 CONSTRAINT [PK_doc_inv_movimiento] PRIMARY KEY CLUSTERED 
(
	[MovimientoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_inv_movimiento_detalle]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_inv_movimiento_detalle](
	[MovimientoDetalleId] [int] NOT NULL,
	[MovimientoId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Consecutivo] [int] NULL,
	[Cantidad] [decimal](16, 5) NULL,
	[PrecioUnitario] [money] NOT NULL,
	[Importe] [money] NOT NULL,
	[Disponible] [decimal](16, 5) NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CostoUltimaCompra] [money] NULL,
	[CostoPromedio] [money] NULL,
	[ValCostoUltimaCompra] [money] NULL,
	[ValCostoPromedio] [money] NULL,
	[ValorMovimiento] [money] NULL,
	[Flete] [float] NULL,
	[Comisiones] [float] NULL,
	[SubTotal] [money] NULL,
	[PrecioNeto] [money] NULL,
 CONSTRAINT [PK_doc_inv_movimiento_detalle] PRIMARY KEY CLUSTERED 
(
	[MovimientoDetalleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_inventario_captura]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_inventario_captura](
	[Id] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Cantidad] [decimal](18, 5) NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[Cerrado] [bit] NOT NULL,
 CONSTRAINT [PK_doc_inventario_captura] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_inventario_registro]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_inventario_registro](
	[RegistroInventarioId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[CantidadReal] [decimal](14, 4) NOT NULL,
	[CantidadTeorica] [decimal](14, 4) NOT NULL,
	[Diferencia] [decimal](14, 4) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_inventario_registro] PRIMARY KEY CLUSTERED 
(
	[RegistroInventarioId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_maiz_maseca_entrada]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_maiz_maseca_entrada](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SucursalId] [int] NOT NULL,
	[Fecha] [datetime] NOT NULL,
	[MaizSacos] [decimal](14, 3) NOT NULL,
	[MasecaSacos] [decimal](14, 3) NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[ModificadoPor] [int] NULL,
	[ModificadoEl] [datetime] NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_doc_maiz_maseca_entrada] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_maiz_maseca_rendimiento]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_maiz_maseca_rendimiento](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SucursalId] [int] NOT NULL,
	[Fecha] [datetime] NOT NULL,
	[MaizSacos] [float] NOT NULL,
	[MasecaSacos] [float] NOT NULL,
	[TortillaMaizRendimiento] [float] NOT NULL,
	[TortillaMasecaRendimiento] [float] NOT NULL,
	[TortillaTotalRendimiento] [float] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[ModificadoEl] [datetime] NULL,
	[ModificadoPor] [int] NULL,
 CONSTRAINT [PK_doc_maiz_maseca_rendimiento] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pagos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pagos](
	[PagoId] [int] NOT NULL,
	[ClienteId] [int] NULL,
	[CargoId] [int] NULL,
	[FechaPago] [datetime] NOT NULL,
	[FormaPagoId] [int] NOT NULL,
	[Monto] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[Activo] [bit] NULL,
 CONSTRAINT [PK_doc_pagos] PRIMARY KEY CLUSTERED 
(
	[PagoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pagos_cancelaciones]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pagos_cancelaciones](
	[PagoId] [int] NOT NULL,
	[Fecha] [datetime] NOT NULL,
	[CanceladoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_pagos_cancelaciones] PRIMARY KEY CLUSTERED 
(
	[PagoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos](
	[PedidoId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[PedidoConfiguracionId] [int] NULL,
	[ClienteId] [int] NOT NULL,
	[CiudadId] [int] NOT NULL,
	[LugarEntrega] [varchar](300) NULL,
	[FechaEntrega] [date] NOT NULL,
	[HoraEntrega] [timestamp] NOT NULL,
	[EstatusId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_pedidos] PRIMARY KEY CLUSTERED 
(
	[PedidoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_cargos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_cargos](
	[PedidoCargoId] [int] IDENTITY(1,1) NOT NULL,
	[PedidoId] [int] NOT NULL,
	[CargoId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NULL,
 CONSTRAINT [PK_doc_pedidos_cargos] PRIMARY KEY CLUSTERED 
(
	[PedidoCargoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_clientes]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_clientes](
	[PedidoClienteId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[ClienteId] [int] NOT NULL,
	[EstatusId] [smallint] NOT NULL,
	[FechaEntregaProgramada] [datetime] NOT NULL,
	[HoraEntrega] [time](7) NULL,
	[FechaEntregaReal] [datetime] NULL,
	[SitioEntregaId] [smallint] NULL,
	[ClienteDireccionId] [int] NULL,
	[CreadoEl] [datetime] NOT NULL,
	[PedidoConfiguracionId] [int] NULL,
	[CostoEnvio] [money] NULL,
 CONSTRAINT [PK_doc_pedidos_clientes] PRIMARY KEY CLUSTERED 
(
	[PedidoClienteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_clientes_det]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_clientes_det](
	[PedidoClienteDetId] [int] NOT NULL,
	[PedidoClienteId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Cantidad] [decimal](8, 2) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[Precio] [money] NULL,
 CONSTRAINT [PK_doc_pedidos_clientes_det] PRIMARY KEY CLUSTERED 
(
	[PedidoClienteDetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_configuracion]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_configuracion](
	[PedidoConfiguracionId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[Descripcion] [varchar](50) NOT NULL,
	[Inicio] [date] NOT NULL,
	[Cierre] [date] NOT NULL,
	[FechaLlegada] [date] NULL,
	[FechaInicioEntrega] [date] NULL,
	[FechaFinEntrega] [date] NULL,
	[Activo] [bit] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[ModificadoEl] [datetime] NULL,
	[ModificadoPor] [int] NULL,
 CONSTRAINT [PK_doc_pedidos_configuracion] PRIMARY KEY CLUSTERED 
(
	[PedidoConfiguracionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_configuracion_det]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_configuracion_det](
	[PedidoConfiguracionDetId] [int] NOT NULL,
	[PedidoConfiguracionId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[Precio] [money] NULL,
 CONSTRAINT [PK_doc_pedidos_configuracion_det_1] PRIMARY KEY CLUSTERED 
(
	[PedidoConfiguracionDetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_orden]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_orden](
	[PedidoId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[ComandaId] [int] NULL,
	[PorcDescuento] [decimal](5, 2) NOT NULL,
	[Subtotal] [money] NOT NULL,
	[Descuento] [money] NOT NULL,
	[Impuestos] [money] NOT NULL,
	[Total] [money] NOT NULL,
	[ClienteId] [int] NULL,
	[MotivoCancelacion] [varchar](150) NULL,
	[Activo] [bit] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[Personas] [tinyint] NOT NULL,
	[FechaApertura] [datetime] NOT NULL,
	[FechaCierre] [datetime] NOT NULL,
	[VentaId] [bigint] NULL,
	[Cancelada] [bit] NULL,
	[FechaCancelacion] [datetime] NULL,
	[CanceladoPor] [int] NULL,
	[UberEats] [bit] NULL,
	[Para] [varchar](30) NULL,
	[Notas] [varchar](250) NULL,
	[CargoId] [int] NULL,
	[CajaId] [int] NULL,
	[TipoPedidoId] [int] NULL,
	[Folio] [varchar](20) NULL,
	[Facturar] [bit] NULL,
	[SucursalCobroId] [int] NULL,
	[Credito] [bit] NULL,
 CONSTRAINT [PK_cat_rest_comandas_orden] PRIMARY KEY CLUSTERED 
(
	[PedidoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_orden_adicional]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_orden_adicional](
	[PedidoDetalleId] [int] NOT NULL,
	[AdicionalId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_pedidos_orden_adicional] PRIMARY KEY CLUSTERED 
(
	[PedidoDetalleId] ASC,
	[AdicionalId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_orden_cargos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_orden_cargos](
	[PedidoId] [int] NOT NULL,
	[CargoAdicionalId] [smallint] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_pedidos_orden_cargos] PRIMARY KEY CLUSTERED 
(
	[PedidoId] ASC,
	[CargoAdicionalId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_orden_detalle]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_orden_detalle](
	[PedidoDetalleId] [int] NOT NULL,
	[PedidoId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Cantidad] [decimal](14, 3) NOT NULL,
	[PrecioUnitario] [money] NOT NULL,
	[PorcDescuento] [decimal](5, 2) NOT NULL,
	[Descuento] [money] NOT NULL,
	[Impuestos] [money] NOT NULL,
	[Notas] [varchar](200) NULL,
	[Total] [money] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[TasaIVA] [decimal](5, 2) NOT NULL,
	[Impreso] [bit] NULL,
	[ComandaId] [int] NULL,
	[Parallevar] [bit] NULL,
	[Cancelado] [bit] NULL,
	[TipoDescuentoId] [tinyint] NULL,
	[PromocionCMId] [int] NULL,
	[CargoAdicionalId] [smallint] NULL,
	[Descripcion] [varchar](500) NULL,
	[CargoAdicionalMonto] [money] NULL,
	[CantidadOriginal] [decimal](14, 3) NULL,
	[CantidadDevolucion] [decimal](14, 3) NULL,
 CONSTRAINT [PK_doc_pedidos_orden_detalle] PRIMARY KEY CLUSTERED 
(
	[PedidoDetalleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_orden_detalle_impresion]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_orden_detalle_impresion](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PedidoDetalleId] [int] NOT NULL,
	[Impreso] [bit] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_pedidos_orden_detalle_impresion] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_orden_ingre]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_orden_ingre](
	[PedidoDetalleId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Con] [bit] NOT NULL,
	[Sin] [bit] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_pedidos_orden_ingre] PRIMARY KEY CLUSTERED 
(
	[PedidoDetalleId] ASC,
	[ProductoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_orden_mesa]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_orden_mesa](
	[PedidoOrdenId] [int] NOT NULL,
	[MesaId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_pedidos_orden_mesa] PRIMARY KEY CLUSTERED 
(
	[PedidoOrdenId] ASC,
	[MesaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_orden_mesero]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_orden_mesero](
	[PedidoOrdenId] [int] NOT NULL,
	[EmpleadoId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_pedidos_orden_mesero] PRIMARY KEY CLUSTERED 
(
	[PedidoOrdenId] ASC,
	[EmpleadoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_orden_programacion]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_orden_programacion](
	[PedidoProgramacionId] [int] NOT NULL,
	[PedidoId] [int] NOT NULL,
	[ClienteId] [int] NOT NULL,
	[FechaProgramada] [datetime] NOT NULL,
	[HoraProgramada] [time](7) NOT NULL,
	[CreadoEl] [int] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_pedidos_orden_programacion] PRIMARY KEY CLUSTERED 
(
	[PedidoProgramacionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_proveedor]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_proveedor](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SucursalId] [int] NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[FechaPedido] [datetime] NOT NULL,
	[SucursalProveedorId] [int] NOT NULL,
	[Comentarios] [varchar](250) NULL,
	[Terminado] [bit] NOT NULL,
	[CreadoPor] [int] NULL,
	[FechaTerminado] [datetime] NULL,
	[EstatusPedidoId] [smallint] NULL,
 CONSTRAINT [PK_doc_pedidos_proveedor] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_proveedor_detalle]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_proveedor_detalle](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PedidoProveedorId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Cantidad] [decimal](14, 2) NOT NULL,
	[CreadoEl] [datetime] NULL,
	[CreadoPor] [int] NULL,
	[CantidadDevolucion] [decimal](14, 2) NULL,
 CONSTRAINT [PK_doc_pedidos_proveedor_detalle] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_precios_especiales]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_precios_especiales](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](200) NOT NULL,
	[FechaVigencia] [datetime] NOT NULL,
	[HoraVigencia] [datetime] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[SucursalId] [int] NULL,
 CONSTRAINT [PK_doc_precios_especiales] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_precios_especiales_detalle]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_precios_especiales_detalle](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PrecioEspeciaId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[PrecioEspecial] [decimal](14, 2) NOT NULL,
	[MontoAdicional] [decimal](14, 2) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[ModificadoEl] [datetime] NULL,
	[ModificadoPor] [int] NULL,
 CONSTRAINT [PK_doc_precios_especiales_detalle] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_produccion]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_produccion](
	[ProduccionId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[FechaHoraInicio] [datetime] NOT NULL,
	[FechaHoraFin] [datetime] NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[Completado] [bit] NOT NULL,
	[Activo] [bit] NOT NULL,
	[EstatusProduccionId] [int] NOT NULL,
	[ProductoId] [int] NULL,
	[ProduccionSolicitudId] [int] NULL,
 CONSTRAINT [PK_doc_produccion] PRIMARY KEY CLUSTERED 
(
	[ProduccionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_produccion_bitacora]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_produccion_bitacora](
	[ProduccionId] [int] NOT NULL,
	[BitacoraId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_produccion_bitacora] PRIMARY KEY CLUSTERED 
(
	[ProduccionId] ASC,
	[BitacoraId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_produccion_conceptos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_produccion_conceptos](
	[ProduccionConceptoId] [int] NOT NULL,
	[ProduccionId] [int] NOT NULL,
	[ConceptoId] [int] NOT NULL,
	[Inicio] [datetime] NULL,
	[Fin] [datetime] NULL,
	[Cantidad] [decimal](18, 4) NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[ModificadoEl] [datetime] NULL,
	[ModificadoPor] [int] NULL,
	[ValorRango1_1] [float] NULL,
	[ValorRango1_2] [float] NULL,
 CONSTRAINT [PK_doc_produccion_conceptos] PRIMARY KEY CLUSTERED 
(
	[ProduccionConceptoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_produccion_entrada]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_produccion_entrada](
	[ProduccionId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Cantidad] [decimal](10, 4) NOT NULL,
	[UnidadId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[Id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_doc_produccion_entrada_2] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_produccion_finalizada]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_produccion_finalizada](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SucursalId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_produccion_finalizada] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_produccion_movs_inventario]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_produccion_movs_inventario](
	[ProduccionId] [int] NOT NULL,
	[MovimientoInventarioId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_produccion_movs_inventario] PRIMARY KEY CLUSTERED 
(
	[ProduccionId] ASC,
	[MovimientoInventarioId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_produccion_salida]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_produccion_salida](
	[ProduccionId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Cantidad] [decimal](10, 4) NULL,
	[UnidadId] [int] NULL,
	[CreadoEl] [datetime] NOT NULL,
	[Id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_doc_produccion_salida_2] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_produccion_solicitud]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_produccion_solicitud](
	[ProduccionSolicitudId] [int] IDENTITY(1,1) NOT NULL,
	[DeSucursalId] [int] NOT NULL,
	[ParaSucursalId] [int] NOT NULL,
	[Completada] [bit] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[Activa] [bit] NOT NULL,
	[FechaProgramada] [datetime] NULL,
	[Enviada] [bit] NULL,
	[Iniciada] [bit] NULL,
	[FechaInicioEjecucion] [datetime] NULL,
	[FechaFinEjecucion] [datetime] NULL,
	[Terminada] [bit] NULL,
	[Aceptada] [bit] NULL,
	[DepartamentoId] [int] NULL,
	[ProduccionId] [int] NULL,
 CONSTRAINT [PK_doc_produccion_solicitud] PRIMARY KEY CLUSTERED 
(
	[ProduccionSolicitudId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_produccion_solicitud_aceptacion]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_produccion_solicitud_aceptacion](
	[ProduccionSolicitudAceptacionId] [int] IDENTITY(1,1) NOT NULL,
	[ProduccionSolicitudDetalleId] [int] NOT NULL,
	[UnidadId] [int] NOT NULL,
	[Cantidad] [float] NOT NULL,
	[AceptadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[Comentarios] [varchar](1500) NULL,
 CONSTRAINT [PK_doc_produccion_solicitud_aceptacion] PRIMARY KEY CLUSTERED 
(
	[ProduccionSolicitudAceptacionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_produccion_solicitud_ajuste_unidad]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_produccion_solicitud_ajuste_unidad](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProduccionSolicitudDetalleId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[UnidadId] [int] NOT NULL,
	[Cantidad] [float] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_produccion_solicitud_ajuste_unidad] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_produccion_solicitud_detalle]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_produccion_solicitud_detalle](
	[Id] [int] NOT NULL,
	[ProduccionSolicitudId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[UnidadId] [int] NOT NULL,
	[Cantidad] [float] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_produccion_solicitud_detalle] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_produccion_solicitud_requerido]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_produccion_solicitud_requerido](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProduccionSolicitudDetalleId] [int] NOT NULL,
	[ProductoRequeridoId] [int] NOT NULL,
	[UnidadRequeridaId] [int] NOT NULL,
	[Cantidad] [float] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_produccion_solicitud_requerido] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_productos_compra]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_productos_compra](
	[ProductoCompraId] [int] NOT NULL,
	[ProveedorId] [int] NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[NumeroRemision] [varchar](50) NOT NULL,
	[Descuento] [money] NOT NULL,
	[Subtotal] [money] NOT NULL,
	[Impuestos] [money] NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[ModificadoPor] [int] NULL,
	[ModificadoEl] [datetime] NULL,
	[Activo] [bit] NOT NULL,
	[FechaCancelacion] [datetime] NULL,
	[CanceladoPor] [int] NULL,
	[FechaRemision] [datetime] NULL,
	[PrecioAfectado] [bit] NULL,
	[PrecioConImpuestos] [bit] NULL,
	[SucursalId] [int] NULL,
 CONSTRAINT [PK_doc_productos_compra] PRIMARY KEY CLUSTERED 
(
	[ProductoCompraId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_productos_compra_cargos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_productos_compra_cargos](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProductoCompraId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Remision] [varchar](20) NOT NULL,
	[Fecha] [datetime] NOT NULL,
	[ProveedorId] [int] NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_productos_compra_cargos] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_productos_compra_detalle]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_productos_compra_detalle](
	[ProductoCompraDetId] [int] NOT NULL,
	[ProductoCompraId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Cantidad] [decimal](14, 2) NOT NULL,
	[PrecioUnitario] [money] NOT NULL,
	[PorcImpuestos] [decimal](5, 2) NOT NULL,
	[Impuestos] [money] NOT NULL,
	[PorcDescuentos] [decimal](5, 2) NOT NULL,
	[Descuentos] [money] NOT NULL,
	[Subtotal] [money] NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[PrecioNeto] [money] NULL,
	[PrecioCompra] [money] NULL,
	[Flete] [float] NULL,
	[Comisiones] [float] NULL,
 CONSTRAINT [PK_doc_productos_compra_detalle] PRIMARY KEY CLUSTERED 
(
	[ProductoCompraDetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_productos_existencias_diario]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_productos_existencias_diario](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SucursalId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[FechaCorteExistencia] [datetime] NOT NULL,
	[Existencia] [float] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_productos_existencias_diario] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_productos_importacion_bitacora]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_productos_importacion_bitacora](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UUID] [uniqueidentifier] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[TipoMovimientoInventarioId] [int] NOT NULL,
	[Cantidad] [decimal](14, 2) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_productos_importacion_bitacora] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_productos_max_min]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_productos_max_min](
	[SucursalId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Maximo] [decimal](14, 4) NOT NULL,
	[Minimo] [decimal](14, 4) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_productos_max_min] PRIMARY KEY CLUSTERED 
(
	[SucursalId] ASC,
	[ProductoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_productos_minimo]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_productos_minimo](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[SucursalId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Fecha] [date] NOT NULL,
	[Notificacion] [bit] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_productos_minimo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_productos_sobrantes_config]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_productos_sobrantes_config](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[EmpresaId] [int] NOT NULL,
	[ProductoSobranteId] [int] NOT NULL,
	[ProductoConvertirId] [int] NOT NULL,
	[Convertir] [bit] NULL,
	[CreadoEl] [datetime] NULL,
	[CreadoPor] [int] NULL,
	[DejarEnCero] [bit] NULL,
 CONSTRAINT [PK_doc_productos_sobrantes_config] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_productos_sobrantes_registro]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_productos_sobrantes_registro](
	[Id] [int] NOT NULL,
	[SucursalId] [int] NULL,
	[ProductoId] [int] NULL,
	[CantidadSobrante] [float] NULL,
	[CreadoEl] [datetime] NULL,
	[CreadoPor] [int] NULL,
	[Cerrado] [bit] NULL,
	[CerradoEl] [datetime] NULL,
	[CerradoPor] [int] NULL,
	[CantidadInventario] [decimal](14, 3) NULL,
 CONSTRAINT [PK_doc_productos_sobrantes_registro] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_productos_sobrantes_regitro_inventario]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_productos_sobrantes_regitro_inventario](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SobranteRegsitroId] [int] NULL,
	[MovimientoDetalleId] [int] NULL,
	[CreadoEl] [datetime] NULL,
 CONSTRAINT [PK_doc_productos_sobrantes_regitro_inventario] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_promociones]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_promociones](
	[PromocionId] [int] NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[PorcentajeDescuento] [decimal](5, 2) NOT NULL,
	[FechaInicioVigencia] [datetime] NOT NULL,
	[FechaFinVigencia] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[EmpresaId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
	[NombrePromocion] [varchar](100) NULL,
	[Lunes] [bit] NULL,
	[Martes] [bit] NULL,
	[Miercoles] [bit] NULL,
	[Jueves] [bit] NULL,
	[Viernes] [bit] NULL,
	[Sabado] [bit] NULL,
	[Domingo] [bit] NULL,
	[Permanente] [bit] NULL,
 CONSTRAINT [PK_doc_promociones] PRIMARY KEY CLUSTERED 
(
	[PromocionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_promociones_cm]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_promociones_cm](
	[PromocionCMId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[NombrePromocion] [varchar](150) NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[FechaVigencia] [datetime] NOT NULL,
	[HoraVigencia] [time](7) NOT NULL,
	[Lunes] [bit] NULL,
	[Martes] [bit] NULL,
	[Miercoles] [bit] NULL,
	[Jueves] [bit] NULL,
	[Viernes] [bit] NULL,
	[Sabado] [bit] NULL,
	[Domingo] [bit] NULL,
	[CreadoPor] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_doc_promociones_cm] PRIMARY KEY CLUSTERED 
(
	[PromocionCMId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_promociones_cm_detalle]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_promociones_cm_detalle](
	[PromocionCMDetId] [int] NOT NULL,
	[PromocionCMId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[CantidadCompraMinima] [decimal](10, 2) NOT NULL,
	[CantidadCobro] [decimal](10, 2) NOT NULL,
	[CreadoEL] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_promociones_cm_detalle] PRIMARY KEY CLUSTERED 
(
	[PromocionCMDetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_promociones_detalle]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_promociones_detalle](
	[PromocionDetalleId] [int] NOT NULL,
	[PromocionId] [int] NOT NULL,
	[LineaId] [int] NULL,
	[FamiliaId] [int] NULL,
	[Subfamilia] [int] NULL,
	[ProductoId] [int] NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_promociones_detalle] PRIMARY KEY CLUSTERED 
(
	[PromocionDetalleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_promociones_excepcion]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_promociones_excepcion](
	[PromocionExcepcionId] [int] NOT NULL,
	[PromocionId] [int] NOT NULL,
	[LineaId] [int] NULL,
	[FamiliaId] [int] NULL,
	[Subfamilia] [int] NULL,
	[ProductoId] [int] NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_promociones_excepcion] PRIMARY KEY CLUSTERED 
(
	[PromocionExcepcionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_rango_gramos_venta]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_rango_gramos_venta](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RangoIniVenta] [decimal](14, 3) NOT NULL,
	[RangoFinVenta] [decimal](14, 3) NOT NULL,
	[EstablecerValor] [decimal](14, 3) NOT NULL,
 CONSTRAINT [PK_doc_rango_gramos_venta] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_reimpresion_ticket]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_reimpresion_ticket](
	[ReimpresionTicketId] [int] NOT NULL,
	[FechaReimpresion] [datetime] NOT NULL,
	[VentaId] [bigint] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CajaId] [int] NOT NULL,
 CONSTRAINT [PK_doc_reimpresion_ticket] PRIMARY KEY CLUSTERED 
(
	[ReimpresionTicketId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_requisiciones]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_requisiciones](
	[RequisicionId] [int] NOT NULL,
	[Folio] [varchar](50) NOT NULL,
	[Version] [smallint] NOT NULL,
	[ProveedorId] [int] NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[FechaRequerida] [datetime] NOT NULL,
	[RequisicionPadreId] [int] NOT NULL,
	[TipoRequisicionId] [smallint] NOT NULL,
	[EstatusId] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_requisiciones] PRIMARY KEY CLUSTERED 
(
	[RequisicionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_requisiciones_detalle]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_requisiciones_detalle](
	[RequisicionDetalleId] [int] NOT NULL,
	[RequisicionId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Cantidad] [decimal](18, 4) NOT NULL,
	[Precio] [decimal](14, 2) NOT NULL,
	[Total] [decimal](14, 2) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_requisiciones_detalle] PRIMARY KEY CLUSTERED 
(
	[RequisicionDetalleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_retiros]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_retiros](
	[RetiroId] [int] NOT NULL,
	[FechaRetiro] [datetime] NOT NULL,
	[MontoRetiro] [money] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CajaId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[Observaciones] [varchar](300) NOT NULL,
 CONSTRAINT [PK_doc_retiros] PRIMARY KEY CLUSTERED 
(
	[RetiroId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_retiros_denominaciones]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_retiros_denominaciones](
	[RetiroId] [int] NOT NULL,
	[DenominacionId] [int] NOT NULL,
	[Cantidad] [int] NOT NULL,
	[ValorDenominacion] [money] NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_retiros_denominaciones] PRIMARY KEY CLUSTERED 
(
	[RetiroId] ASC,
	[DenominacionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_sesiones_punto_venta]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_sesiones_punto_venta](
	[SesionId] [int] NOT NULL,
	[UsuarioId] [int] NOT NULL,
	[CajaId] [int] NULL,
	[FechaInicio] [datetime] NOT NULL,
	[FechaUltimaConexion] [datetime] NULL,
	[CorteAplicado] [bit] NULL,
	[FechaCorte] [datetime] NULL,
	[Finalizada] [bit] NULL,
	[CorteCajaId] [int] NULL,
 CONSTRAINT [PK_doc_sesiones_punto_venta] PRIMARY KEY CLUSTERED 
(
	[SesionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_sucursales_productos_recepcion]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_sucursales_productos_recepcion](
	[SucursalId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_sucursales_productos_recepcion] PRIMARY KEY CLUSTERED 
(
	[SucursalId] ASC,
	[ProductoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_ventas]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_ventas](
	[VentaId] [bigint] NOT NULL,
	[Folio] [varchar](20) NOT NULL,
	[Fecha] [datetime] NOT NULL,
	[ClienteId] [int] NULL,
	[DescuentoVentaSiNo] [bit] NULL,
	[PorcDescuentoVenta] [decimal](5, 2) NULL,
	[MontoDescuentoVenta] [money] NULL,
	[DescuentoEnPartidas] [money] NULL,
	[TotalDescuento] [money] NULL,
	[Impuestos] [money] NOT NULL,
	[SubTotal] [money] NOT NULL,
	[TotalVenta] [money] NOT NULL,
	[TotalRecibido] [money] NOT NULL,
	[Cambio] [money] NOT NULL,
	[Activo] [bit] NOT NULL,
	[UsuarioCreacionId] [int] NOT NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[UsuarioCancelacionId] [int] NULL,
	[FechaCancelacion] [datetime] NULL,
	[SucursalId] [int] NULL,
	[CajaId] [int] NULL,
	[Serie] [varchar](5) NULL,
	[MotivoCancelacion] [varchar](150) NULL,
	[Rec] [bit] NULL,
	[Facturar] [bit] NULL,
	[EmpleadoId] [int] NULL,
 CONSTRAINT [PK_doc_ventas] PRIMARY KEY CLUSTERED 
(
	[VentaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_ventas_detalle]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_ventas_detalle](
	[VentaDetalleId] [bigint] NOT NULL,
	[VentaId] [bigint] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Cantidad] [decimal](16, 5) NULL,
	[PrecioUnitario] [money] NOT NULL,
	[PorcDescuneto] [decimal](5, 2) NOT NULL,
	[Descuento] [money] NOT NULL,
	[Impuestos] [money] NOT NULL,
	[Total] [money] NOT NULL,
	[UsuarioCreacionId] [int] NOT NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[TasaIVA] [decimal](5, 2) NULL,
	[TipoDescuentoId] [tinyint] NULL,
	[PromocionCMId] [int] NULL,
	[CargoAdicionalId] [smallint] NULL,
	[CargoDetalleId] [int] NULL,
	[Descripcion] [varchar](500) NULL,
	[ParaLlevar] [bit] NULL,
	[ParaMesa] [bit] NULL,
 CONSTRAINT [PK_doc_ventas_detalle] PRIMARY KEY CLUSTERED 
(
	[VentaDetalleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_ventas_formas_pago]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_ventas_formas_pago](
	[FormaPagoId] [int] NOT NULL,
	[VentaId] [bigint] NOT NULL,
	[Cantidad] [money] NOT NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[UsuarioCreacionId] [int] NOT NULL,
	[digitoVerificador] [varchar](20) NULL,
 CONSTRAINT [PK_doc_ventas_formas_pago] PRIMARY KEY CLUSTERED 
(
	[FormaPagoId] ASC,
	[VentaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_ventas_formas_pago_vale]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_ventas_formas_pago_vale](
	[Id] [int] NOT NULL,
	[VentaId] [int] NOT NULL,
	[TipoValeId] [int] NOT NULL,
	[Monto] [money] NOT NULL,
	[DevolucionId] [int] NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_ventas_formas_pago_vale] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_ventas_pagos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_ventas_pagos](
	[VentaId] [bigint] NOT NULL,
	[PagoId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_ventas_pagos] PRIMARY KEY CLUSTERED 
(
	[VentaId] ASC,
	[PagoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_ventas_temp]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_ventas_temp](
	[VentaId] [int] NOT NULL,
	[VentaTempId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_ventas_temp] PRIMARY KEY CLUSTERED 
(
	[VentaId] ASC,
	[VentaTempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_web_carrito]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_web_carrito](
	[uUID] [varchar](50) NOT NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Email] [varchar](50) NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[EnvioCalle] [varchar](250) NOT NULL,
	[EnvioColonia] [varchar](100) NOT NULL,
	[EnvioCiudad] [varchar](70) NOT NULL,
	[EnvioEstadoId] [int] NOT NULL,
	[EnvioCP] [varchar](5) NOT NULL,
	[EnvioPersonaRecibe] [varchar](250) NOT NULL,
	[EnvioTelefonoContacto] [varchar](20) NOT NULL,
	[ClienteId] [int] NULL,
	[Impuestos] [money] NULL,
	[Subtotal] [money] NULL,
	[Pagado] [bit] NULL,
	[FechaPago] [datetime] NULL,
	[VentaId] [bigint] NULL,
	[MontoPaypal] [varchar](20) NULL,
	[TransactionRef] [varchar](30) NULL,
	[FechaEstimadaEntrega] [datetime] NULL,
	[EntregadoEl] [datetime] NULL,
	[FormaPagoId] [tinyint] NULL,
 CONSTRAINT [PK_doc_web_carrito] PRIMARY KEY CLUSTERED 
(
	[uUID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_web_carrito_detalle]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_web_carrito_detalle](
	[IdDetalle] [int] NOT NULL,
	[uUID] [varchar](50) NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Cantidad] [decimal](10, 2) NOT NULL,
	[Descripcion] [varchar](250) NOT NULL,
	[PrecioUnitario] [money] NOT NULL,
	[Importe] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[Impuestos] [money] NULL,
	[Subtotal] [money] NULL,
	[Id] [int] NULL,
	[CargoDetalleId] [int] NULL,
 CONSTRAINT [PK_doc_web_carrito_detalle] PRIMARY KEY CLUSTERED 
(
	[IdDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[rh_departamentos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rh_departamentos](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[rh_empleado_puestos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rh_empleado_puestos](
	[EmpleadoId] [int] NOT NULL,
	[PuestoId] [int] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_rh_empleado_puestos] PRIMARY KEY CLUSTERED 
(
	[EmpleadoId] ASC,
	[PuestoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[rh_empleados]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rh_empleados](
	[NumEmpleado] [int] NOT NULL,
	[Nombre] [varchar](150) NOT NULL,
	[SueldoNeto] [money] NOT NULL,
	[SueldoDiario] [money] NULL,
	[SueldoHra] [money] NULL,
	[FormaPago] [int] NULL,
	[TipoContrato] [int] NULL,
	[Puesto] [int] NULL,
	[Departamento] [int] NULL,
	[FechaIngreso] [date] NULL,
	[FechaInicioLab] [date] NULL,
	[Estatus] [int] NULL,
	[Foto] [image] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[NumEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[rh_estatus_empleados]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rh_estatus_empleados](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[rh_formaspagonom]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rh_formaspagonom](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NULL,
	[NumDias] [int] NULL,
	[HrasDia] [int] NULL,
	[Estatus] [int] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[rh_puestos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rh_puestos](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
	[PermitirEliminar] [bit] NULL,
	[Mostrar] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[rh_tipos_contrato]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rh_tipos_contrato](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sis_apis]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sis_apis](
	[Id] [int] NOT NULL,
	[Url] [varchar](500) NOT NULL,
	[Tipo] [varchar](50) NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_cat_apis] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sis_bitacora_errores]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sis_bitacora_errores](
	[IdError] [int] IDENTITY(1,1) NOT NULL,
	[Sistema] [varchar](60) NOT NULL,
	[Clase] [varchar](250) NULL,
	[ExStackTrace] [varchar](2000) NULL,
	[ExInnerException] [varchar](2000) NULL,
	[ExMessage] [varchar](500) NULL,
	[CreadoEl] [datetime] NULL,
	[CreadoPor] [int] NULL,
 CONSTRAINT [PK_sis_bitacora_errores] PRIMARY KEY CLUSTERED 
(
	[IdError] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sis_bitacora_general]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sis_bitacora_general](
	[BitacoraId] [int] NOT NULL,
	[SucursalId] [int] NULL,
	[Detalle] [varchar](8000) NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NULL,
 CONSTRAINT [PK_sis_bitacora_general] PRIMARY KEY CLUSTERED 
(
	[BitacoraId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sis_correos_tipos]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sis_correos_tipos](
	[TipoCorreoId] [smallint] NOT NULL,
	[Descripcion] [varchar](100) NOT NULL,
	[Html] [text] NOT NULL,
	[CreadoEl] [varchar](250) NOT NULL,
 CONSTRAINT [PK_sis_correos_tipos] PRIMARY KEY CLUSTERED 
(
	[TipoCorreoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sis_cuenta]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sis_cuenta](
	[EmpresaId] [int] NOT NULL,
	[ClienteKey] [varchar](2000) NOT NULL,
	[Email] [varchar](100) NOT NULL,
	[Password] [varchar](2000) NOT NULL,
	[URLValidacion] [varchar](1000) NULL,
	[ClaveSucursal] [int] NULL,
 CONSTRAINT [PK_sis_config_api] PRIMARY KEY CLUSTERED 
(
	[EmpresaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sis_menu]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sis_menu](
	[MenuId] [smallint] NOT NULL,
	[Titulo] [varchar](50) NOT NULL,
	[Descripcion] [varchar](250) NOT NULL,
	[Tipo] [tinyint] NOT NULL,
	[MenuWinBarNameId] [varchar](100) NULL,
	[MenuPadreId] [smallint] NULL,
	[Activo] [bit] NOT NULL,
	[Clave] [varchar](50) NULL,
	[IconoApp] [varchar](500) NULL,
 CONSTRAINT [PK_sis_menu] PRIMARY KEY CLUSTERED 
(
	[MenuId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sis_notificaciones]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sis_notificaciones](
	[NotificacionId] [int] NOT NULL,
	[Para] [varchar](500) NOT NULL,
	[Asunto] [varchar](250) NOT NULL,
	[Mensaje] [text] NOT NULL,
	[FechaProgramadaEnvio] [datetime] NOT NULL,
	[Enviada] [bit] NOT NULL,
	[FechaEnvio] [datetime] NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[ModificadoPor] [int] NULL,
	[ModificadoEl] [datetime] NULL,
	[De] [varchar](100) NULL,
 CONSTRAINT [PK_sis_notificaciones] PRIMARY KEY CLUSTERED 
(
	[NotificacionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sis_perfiles]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sis_perfiles](
	[PerfilId] [smallint] NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
	[Activo] [bit] NOT NULL,
	[Clave] [varchar](50) NULL,
 CONSTRAINT [PK_sis_perfiles] PRIMARY KEY CLUSTERED 
(
	[PerfilId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sis_perfiles_menu]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sis_perfiles_menu](
	[PerfilId] [smallint] NOT NULL,
	[MenuId] [smallint] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_sis_perfiles_menu] PRIMARY KEY CLUSTERED 
(
	[PerfilId] ASC,
	[MenuId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sis_preferencias]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sis_preferencias](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Preferencia] [varchar](150) NOT NULL,
	[Descripcion] [varchar](500) NOT NULL,
	[ParaEmpresa] [bit] NOT NULL,
	[ParaUsuario] [bit] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_sis_preferencias] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sis_preferencias_empresa]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sis_preferencias_empresa](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PreferenciaId] [int] NOT NULL,
	[EmpresaId] [int] NOT NULL,
	[Valor] [varchar](1000) NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_sis_preferencias_empresa] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sis_preferencias_sucursales]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sis_preferencias_sucursales](
	[Id] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[PreferenciaId] [int] NOT NULL,
	[Valor] [varchar](1000) NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_sis_preferencias_sucursales] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sis_roles]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sis_roles](
	[RolId] [smallint] NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_sis_roles] PRIMARY KEY CLUSTERED 
(
	[RolId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sis_roles_perfiles]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sis_roles_perfiles](
	[RolId] [smallint] NOT NULL,
	[PerfilId] [smallint] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_sis_roles_perfiles] PRIMARY KEY CLUSTERED 
(
	[RolId] ASC,
	[PerfilId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sis_usuarios_perfiles]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sis_usuarios_perfiles](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UsuarioId] [int] NOT NULL,
	[PerfilId] [int] NOT NULL,
 CONSTRAINT [PK_sis_usuarios_perfiles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sis_usuarios_roles]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sis_usuarios_roles](
	[UsuarioId] [int] NOT NULL,
	[RolId] [smallint] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_sis_usuarios_roles] PRIMARY KEY CLUSTERED 
(
	[UsuarioId] ASC,
	[RolId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sis_versiones]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sis_versiones](
	[VersionId] [smallint] NOT NULL,
	[Nombre] [varchar](20) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[Completado] [bit] NOT NULL,
	[Intentos] [tinyint] NOT NULL,
 CONSTRAINT [PK_sis_versiones] PRIMARY KEY CLUSTERED 
(
	[VersionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sis_versiones_detalle]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sis_versiones_detalle](
	[VersionDetalleId] [int] NOT NULL,
	[VersionId] [smallint] NOT NULL,
	[ScriptName] [varchar](250) NOT NULL,
	[Completado] [bit] NOT NULL,
 CONSTRAINT [PK_sis_versiones_detalle] PRIMARY KEY CLUSTERED 
(
	[VersionDetalleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tmpProductos0]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpProductos0](
	[IMAGEN] [image] NULL,
	[LINEA] [nvarchar](255) NULL,
	[PRODUCTO] [nvarchar](255) NULL,
	[CODIGO] [nvarchar](255) NULL,
	[DESCRIPCION CORTA] [nvarchar](255) NULL,
	[DESCRIPCION LARGA] [nvarchar](255) NULL,
	[PRECIO] [money] NULL,
	[EXISTENCIAS] [float] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tmpProductos1]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpProductos1](
	[IMAGEN] [nvarchar](255) NULL,
	[LINEA] [nvarchar](255) NULL,
	[PRODUCTO] [nvarchar](255) NULL,
	[CODIGO] [nvarchar](255) NULL,
	[DESCRIPCION CORTA] [nvarchar](255) NULL,
	[DESCRIPCION LARGA] [nvarchar](255) NULL,
	[PRECIO] [money] NULL,
	[EXISTENCIAS] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tmpProductos2]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpProductos2](
	[IMAGEN] [nvarchar](255) NULL,
	[LINEA] [nvarchar](255) NULL,
	[PRODUCTO] [nvarchar](255) NULL,
	[CODIGO] [nvarchar](255) NULL,
	[DESCRIPCION CORTA] [nvarchar](255) NULL,
	[DESCRIPCION LARGA] [nvarchar](255) NULL,
	[PRECIO] [money] NULL,
	[EXISTENCIAS] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tmpProductos3]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpProductos3](
	[IMAGEN] [nvarchar](255) NULL,
	[LINEA] [nvarchar](255) NULL,
	[PRODUCTO] [nvarchar](255) NULL,
	[CODIGO] [nvarchar](255) NULL,
	[DESCRIPCION CORTA] [nvarchar](255) NULL,
	[DESCRIPCION LARGA] [nvarchar](255) NULL,
	[PRECIO] [money] NULL,
	[EXISTENCIAS] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tmpProductos4]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpProductos4](
	[IMAGEN] [nvarchar](255) NULL,
	[LINEA] [nvarchar](255) NULL,
	[PRODUCTO] [nvarchar](255) NULL,
	[CODIGO] [nvarchar](255) NULL,
	[DESCRIPCION CORTA] [nvarchar](255) NULL,
	[DESCRIPCION LARGA] [nvarchar](255) NULL,
	[PRECIO] [money] NULL,
	[EXISTENCIAS] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tmpProductos5]    Script Date: 24/01/2024 07:12:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpProductos5](
	[IMAGEN] [image] NULL,
	[LINEA] [nvarchar](255) NULL,
	[PRODUCTO] [nvarchar](255) NULL,
	[CODIGO] [nvarchar](255) NULL,
	[DESCRIPCION CORTA] [nvarchar](255) NULL,
	[DESCRIPCION LARGA] [nvarchar](255) NULL,
	[PRECIO] [money] NULL,
	[EXISTENCIAS] [float] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[cat_almacenes]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_almacenes]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_almacenes]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_almacenes]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_anaqueles]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_anaqueles]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_anaqueles]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_anaqueles]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_andenes]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_andenes]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_andenes]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_andenes]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_basculas]  WITH CHECK ADD  CONSTRAINT [FK_cat_basculas_cat_empresas] FOREIGN KEY([EmpresaId])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_basculas] CHECK CONSTRAINT [FK_cat_basculas_cat_empresas]
GO
ALTER TABLE [dbo].[cat_basculas]  WITH CHECK ADD  CONSTRAINT [FK_cat_basculas_cat_sucursales] FOREIGN KEY([SucursalAsignadaId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_basculas] CHECK CONSTRAINT [FK_cat_basculas_cat_sucursales]
GO
ALTER TABLE [dbo].[cat_basculas]  WITH CHECK ADD  CONSTRAINT [FK_cat_basculas_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[cat_basculas] CHECK CONSTRAINT [FK_cat_basculas_cat_usuarios]
GO
ALTER TABLE [dbo].[cat_basculas]  WITH CHECK ADD  CONSTRAINT [FK_cat_basculas_cat_usuarios1] FOREIGN KEY([ModificadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[cat_basculas] CHECK CONSTRAINT [FK_cat_basculas_cat_usuarios1]
GO
ALTER TABLE [dbo].[cat_basculas_configuracion]  WITH CHECK ADD  CONSTRAINT [FK_cat_basculas_configuracion_cat_equipos_computo] FOREIGN KEY([EquipoComputoId])
REFERENCES [dbo].[cat_equipos_computo] ([EquipoComputoId])
GO
ALTER TABLE [dbo].[cat_basculas_configuracion] CHECK CONSTRAINT [FK_cat_basculas_configuracion_cat_equipos_computo]
GO
ALTER TABLE [dbo].[cat_basculas_configuracion]  WITH CHECK ADD  CONSTRAINT [FK_cat_basculas_configuracion_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_basculas_configuracion] CHECK CONSTRAINT [FK_cat_basculas_configuracion_cat_sucursales]
GO
ALTER TABLE [dbo].[cat_basculas_configuracion]  WITH CHECK ADD  CONSTRAINT [FK_cat_cajas_basculas_configuracion_cat_basculas] FOREIGN KEY([BasculaId])
REFERENCES [dbo].[cat_basculas] ([BasculaId])
GO
ALTER TABLE [dbo].[cat_basculas_configuracion] CHECK CONSTRAINT [FK_cat_cajas_basculas_configuracion_cat_basculas]
GO
ALTER TABLE [dbo].[cat_cajas]  WITH CHECK ADD  CONSTRAINT [FK__cat_cajas__Empre__160F4887] FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_cajas] CHECK CONSTRAINT [FK__cat_cajas__Empre__160F4887]
GO
ALTER TABLE [dbo].[cat_cajas]  WITH CHECK ADD  CONSTRAINT [FK_cat_cajas_cat_tipos_cajas] FOREIGN KEY([TipoCajaId])
REFERENCES [dbo].[cat_tipos_cajas] ([TipoCajaId])
GO
ALTER TABLE [dbo].[cat_cajas] CHECK CONSTRAINT [FK_cat_cajas_cat_tipos_cajas]
GO
ALTER TABLE [dbo].[cat_cajas_impresora]  WITH CHECK ADD  CONSTRAINT [FK_cat_cajas_impresora_cat_cajas] FOREIGN KEY([CajaId])
REFERENCES [dbo].[cat_cajas] ([Clave])
GO
ALTER TABLE [dbo].[cat_cajas_impresora] CHECK CONSTRAINT [FK_cat_cajas_impresora_cat_cajas]
GO
ALTER TABLE [dbo].[cat_cajas_impresora]  WITH CHECK ADD  CONSTRAINT [FK_cat_cajas_impresora_cat_impresoras] FOREIGN KEY([ImpresoraId])
REFERENCES [dbo].[cat_impresoras] ([ImpresoraId])
GO
ALTER TABLE [dbo].[cat_cajas_impresora] CHECK CONSTRAINT [FK_cat_cajas_impresora_cat_impresoras]
GO
ALTER TABLE [dbo].[cat_cargos_adicionales]  WITH CHECK ADD  CONSTRAINT [FK_cat_cargo_adicional_cargo_tipo] FOREIGN KEY([CargoTipoId])
REFERENCES [dbo].[cat_cargos_tipos] ([CargoTipoId])
GO
ALTER TABLE [dbo].[cat_cargos_adicionales] CHECK CONSTRAINT [FK_cat_cargo_adicional_cargo_tipo]
GO
ALTER TABLE [dbo].[cat_centro_costos]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_centro_costos]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_centro_costos]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_centro_costos]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_clases_sat]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_clases_sat]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_clases_sat]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_clases_sat]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_clientes]  WITH CHECK ADD FOREIGN KEY([EmpleadoId])
REFERENCES [dbo].[rh_empleados] ([NumEmpleado])
GO
ALTER TABLE [dbo].[cat_clientes]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_cat_antecedentes] FOREIGN KEY([AntecedenteId])
REFERENCES [dbo].[cat_antecedentes] ([AntecedenteId])
GO
ALTER TABLE [dbo].[cat_clientes] CHECK CONSTRAINT [FK_cat_clientes_cat_antecedentes]
GO
ALTER TABLE [dbo].[cat_clientes]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_cat_estados] FOREIGN KEY([EstadoId])
REFERENCES [dbo].[cat_estados] ([EstadoId])
GO
ALTER TABLE [dbo].[cat_clientes] CHECK CONSTRAINT [FK_cat_clientes_cat_estados]
GO
ALTER TABLE [dbo].[cat_clientes]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_cat_giros] FOREIGN KEY([GiroId])
REFERENCES [dbo].[cat_giros_neg] ([Clave])
GO
ALTER TABLE [dbo].[cat_clientes] CHECK CONSTRAINT [FK_cat_clientes_cat_giros]
GO
ALTER TABLE [dbo].[cat_clientes]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_cat_municipios] FOREIGN KEY([MunicipioId])
REFERENCES [dbo].[cat_municipios] ([MunicipioId])
GO
ALTER TABLE [dbo].[cat_clientes] CHECK CONSTRAINT [FK_cat_clientes_cat_municipios]
GO
ALTER TABLE [dbo].[cat_clientes]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_cat_paises] FOREIGN KEY([PaisId])
REFERENCES [dbo].[cat_paises] ([PaisId])
GO
ALTER TABLE [dbo].[cat_clientes] CHECK CONSTRAINT [FK_cat_clientes_cat_paises]
GO
ALTER TABLE [dbo].[cat_clientes]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_cat_precios] FOREIGN KEY([PrecioId])
REFERENCES [dbo].[cat_precios] ([IdPrecio])
GO
ALTER TABLE [dbo].[cat_clientes] CHECK CONSTRAINT [FK_cat_clientes_cat_precios]
GO
ALTER TABLE [dbo].[cat_clientes]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_cat_tipos_cliente] FOREIGN KEY([TipoClienteId])
REFERENCES [dbo].[cat_tipos_cliente] ([TipoClienteId])
GO
ALTER TABLE [dbo].[cat_clientes] CHECK CONSTRAINT [FK_cat_clientes_cat_tipos_cliente]
GO
ALTER TABLE [dbo].[cat_clientes]  WITH CHECK ADD  CONSTRAINT [FK_Clientes_Sucursal] FOREIGN KEY([SucursalBaseId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_clientes] CHECK CONSTRAINT [FK_Clientes_Sucursal]
GO
ALTER TABLE [dbo].[cat_clientes_automovil]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_automovil_cat_clientes] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[cat_clientes_automovil] CHECK CONSTRAINT [FK_cat_clientes_automovil_cat_clientes]
GO
ALTER TABLE [dbo].[cat_clientes_contacto]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_contacto_cat_clientes] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[cat_clientes_contacto] CHECK CONSTRAINT [FK_cat_clientes_contacto_cat_clientes]
GO
ALTER TABLE [dbo].[cat_clientes_direcciones]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_direcciones_cat_clientes] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[cat_clientes_direcciones] CHECK CONSTRAINT [FK_cat_clientes_direcciones_cat_clientes]
GO
ALTER TABLE [dbo].[cat_clientes_direcciones]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_direcciones_cat_tipos_direcciones] FOREIGN KEY([TipoDireccionId])
REFERENCES [dbo].[cat_tipos_direcciones] ([TipoDireccionId])
GO
ALTER TABLE [dbo].[cat_clientes_direcciones] CHECK CONSTRAINT [FK_cat_clientes_direcciones_cat_tipos_direcciones]
GO
ALTER TABLE [dbo].[cat_clientes_direcciones]  WITH CHECK ADD  CONSTRAINT [FK_clientes_direcciones_Estados] FOREIGN KEY([EstadoId])
REFERENCES [dbo].[cat_estados] ([EstadoId])
GO
ALTER TABLE [dbo].[cat_clientes_direcciones] CHECK CONSTRAINT [FK_clientes_direcciones_Estados]
GO
ALTER TABLE [dbo].[cat_clientes_openpay]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_openpay_cat_clientes] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[cat_clientes_openpay] CHECK CONSTRAINT [FK_cat_clientes_openpay_cat_clientes]
GO
ALTER TABLE [dbo].[cat_clientes_web]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_web_cat_clientes] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[cat_clientes_web] CHECK CONSTRAINT [FK_cat_clientes_web_cat_clientes]
GO
ALTER TABLE [dbo].[cat_configuracion]  WITH CHECK ADD FOREIGN KEY([PedidoPoliticaId])
REFERENCES [dbo].[cat_politicas] ([PoliticaId])
GO
ALTER TABLE [dbo].[cat_configuracion_ticket_apartado]  WITH CHECK ADD  CONSTRAINT [FK_cat_configuracion_ticket_apartado_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_configuracion_ticket_apartado] CHECK CONSTRAINT [FK_cat_configuracion_ticket_apartado_cat_sucursales]
GO
ALTER TABLE [dbo].[cat_configuracion_ticket_venta]  WITH CHECK ADD  CONSTRAINT [FK_cat_configuracion_ticket_venta_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_configuracion_ticket_venta] CHECK CONSTRAINT [FK_cat_configuracion_ticket_venta_cat_sucursales]
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_departamentos]  WITH CHECK ADD  CONSTRAINT [FK_cat_departamentos_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[cat_departamentos] CHECK CONSTRAINT [FK_cat_departamentos_cat_usuarios]
GO
ALTER TABLE [dbo].[cat_divisiones_sat]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_divisiones_sat]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_divisiones_sat]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_divisiones_sat]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_empresas_config_inventario]  WITH CHECK ADD  CONSTRAINT [FK_cat_empresas_config_inventario_cat_empresas] FOREIGN KEY([EmpresaId])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_empresas_config_inventario] CHECK CONSTRAINT [FK_cat_empresas_config_inventario_cat_empresas]
GO
ALTER TABLE [dbo].[cat_empresas_config_inventario]  WITH CHECK ADD  CONSTRAINT [FK_cat_empresas_config_inventario_cat_empresas_config_inventario] FOREIGN KEY([EmpresaId])
REFERENCES [dbo].[cat_empresas_config_inventario] ([EmpresaId])
GO
ALTER TABLE [dbo].[cat_empresas_config_inventario] CHECK CONSTRAINT [FK_cat_empresas_config_inventario_cat_empresas_config_inventario]
GO
ALTER TABLE [dbo].[cat_equipos_computo]  WITH CHECK ADD  CONSTRAINT [FK_cat_equipos_computo_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_equipos_computo] CHECK CONSTRAINT [FK_cat_equipos_computo_cat_sucursales]
GO
ALTER TABLE [dbo].[cat_estados]  WITH CHECK ADD  CONSTRAINT [FK_cat_estados_cat_paises] FOREIGN KEY([PaisId])
REFERENCES [dbo].[cat_paises] ([PaisId])
GO
ALTER TABLE [dbo].[cat_estados] CHECK CONSTRAINT [FK_cat_estados_cat_paises]
GO
ALTER TABLE [dbo].[cat_familias]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_familias]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_familias]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_familias]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_familias]  WITH CHECK ADD  CONSTRAINT [FK_familias_productos] FOREIGN KEY([ProductoPortadaId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_familias] CHECK CONSTRAINT [FK_familias_productos]
GO
ALTER TABLE [dbo].[cat_gastos]  WITH CHECK ADD FOREIGN KEY([CajaId])
REFERENCES [dbo].[cat_cajas] ([Clave])
GO
ALTER TABLE [dbo].[cat_gastos]  WITH CHECK ADD FOREIGN KEY([CajaId])
REFERENCES [dbo].[cat_cajas] ([Clave])
GO
ALTER TABLE [dbo].[cat_gastos]  WITH CHECK ADD FOREIGN KEY([ClaveCentroCosto])
REFERENCES [dbo].[cat_centro_costos] ([Clave])
GO
ALTER TABLE [dbo].[cat_gastos]  WITH CHECK ADD FOREIGN KEY([ClaveCentroCosto])
REFERENCES [dbo].[cat_centro_costos] ([Clave])
GO
ALTER TABLE [dbo].[cat_gastos]  WITH CHECK ADD FOREIGN KEY([ConceptoId])
REFERENCES [dbo].[cat_conceptos] ([ConceptoId])
GO
ALTER TABLE [dbo].[cat_gastos]  WITH CHECK ADD FOREIGN KEY([ConceptoId])
REFERENCES [dbo].[cat_conceptos] ([ConceptoId])
GO
ALTER TABLE [dbo].[cat_gastos]  WITH CHECK ADD  CONSTRAINT [FK__cat_gasto__Cread__58671BC9] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[cat_gastos] CHECK CONSTRAINT [FK__cat_gasto__Cread__58671BC9]
GO
ALTER TABLE [dbo].[cat_gastos]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_gastos]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_gastos]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_gastos]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_gastos_deducibles]  WITH CHECK ADD  CONSTRAINT [FK_cat_gastos_deducibles_cat_gastos] FOREIGN KEY([GastoConceptoId])
REFERENCES [dbo].[cat_gastos] ([Clave])
GO
ALTER TABLE [dbo].[cat_gastos_deducibles] CHECK CONSTRAINT [FK_cat_gastos_deducibles_cat_gastos]
GO
ALTER TABLE [dbo].[cat_giros_neg]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_giros_neg]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_giros_neg]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_giros_neg]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_grupos_sat]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_grupos_sat]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_grupos_sat]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_grupos_sat]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_guisos]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_guisos_cat_productos] FOREIGN KEY([productoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_guisos] CHECK CONSTRAINT [FK_cat_productos_guisos_cat_productos]
GO
ALTER TABLE [dbo].[cat_impresoras]  WITH CHECK ADD  CONSTRAINT [FK_cat_impresoras_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_impresoras] CHECK CONSTRAINT [FK_cat_impresoras_cat_sucursales]
GO
ALTER TABLE [dbo].[cat_impresoras_comandas]  WITH CHECK ADD  CONSTRAINT [FK_cat_impresoras_comandas_cat_impresoras] FOREIGN KEY([ImpresoraId])
REFERENCES [dbo].[cat_impresoras] ([ImpresoraId])
GO
ALTER TABLE [dbo].[cat_impresoras_comandas] CHECK CONSTRAINT [FK_cat_impresoras_comandas_cat_impresoras]
GO
ALTER TABLE [dbo].[cat_impuestos]  WITH CHECK ADD  CONSTRAINT [FK_cat_impuestos_cat_abreviaturas_SAT] FOREIGN KEY([IdAbreviatura])
REFERENCES [dbo].[cat_abreviaturas_SAT] ([Clave])
GO
ALTER TABLE [dbo].[cat_impuestos] CHECK CONSTRAINT [FK_cat_impuestos_cat_abreviaturas_SAT]
GO
ALTER TABLE [dbo].[cat_impuestos]  WITH CHECK ADD  CONSTRAINT [FK_cat_impuestos_cat_clasificacion_impuestos] FOREIGN KEY([IdClasificacionImpuesto])
REFERENCES [dbo].[cat_clasificacion_impuestos] ([Clave])
GO
ALTER TABLE [dbo].[cat_impuestos] CHECK CONSTRAINT [FK_cat_impuestos_cat_clasificacion_impuestos]
GO
ALTER TABLE [dbo].[cat_impuestos]  WITH CHECK ADD  CONSTRAINT [FK_cat_impuestos_cat_tipo_factor_SAT] FOREIGN KEY([IdTipoFactor])
REFERENCES [dbo].[cat_tipo_factor_SAT] ([Clave])
GO
ALTER TABLE [dbo].[cat_impuestos] CHECK CONSTRAINT [FK_cat_impuestos_cat_tipo_factor_SAT]
GO
ALTER TABLE [dbo].[cat_lineas]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_lineas]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_lineas]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_lineas]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_lotes]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_lotes]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_lotes]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_lotes]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_marcas]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_marcas]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_marcas]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_marcas]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_monedas]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_monedas]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_monedas]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_monedas]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_monedas]  WITH CHECK ADD  CONSTRAINT [FK_monedas_abreviaturas] FOREIGN KEY([IdMonedaAbreviatura])
REFERENCES [dbo].[cat_monedas_abreviaturas] ([IdMonedaAbreviatura])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[cat_monedas] CHECK CONSTRAINT [FK_monedas_abreviaturas]
GO
ALTER TABLE [dbo].[cat_municipios]  WITH CHECK ADD  CONSTRAINT [FK_cat_municipios_cat_estados] FOREIGN KEY([EstadoId])
REFERENCES [dbo].[cat_estados] ([EstadoId])
GO
ALTER TABLE [dbo].[cat_municipios] CHECK CONSTRAINT [FK_cat_municipios_cat_estados]
GO
ALTER TABLE [dbo].[cat_produccion_productos_sucursal]  WITH CHECK ADD  CONSTRAINT [FK_cat_produccion_productos_sucursal_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_produccion_productos_sucursal] CHECK CONSTRAINT [FK_cat_produccion_productos_sucursal_cat_productos]
GO
ALTER TABLE [dbo].[cat_produccion_productos_sucursal]  WITH CHECK ADD  CONSTRAINT [FK_cat_produccion_productos_sucursal_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_produccion_productos_sucursal] CHECK CONSTRAINT [FK_cat_produccion_productos_sucursal_cat_sucursales]
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveAlmacen])
REFERENCES [dbo].[cat_almacenes] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveAnden])
REFERENCES [dbo].[cat_andenes] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveLote])
REFERENCES [dbo].[cat_lotes] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveMarca])
REFERENCES [dbo].[cat_marcas] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveFamilia])
REFERENCES [dbo].[cat_familias] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveSubFamilia])
REFERENCES [dbo].[cat_subfamilias] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveLinea])
REFERENCES [dbo].[cat_lineas] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveUnidadMedida])
REFERENCES [dbo].[cat_unidadesmed] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveInventariadoPor])
REFERENCES [dbo].[cat_unidadesmed] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveVendidaPor])
REFERENCES [dbo].[cat_unidadesmed] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveAlmacen])
REFERENCES [dbo].[cat_almacenes] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveAnden])
REFERENCES [dbo].[cat_andenes] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveLote])
REFERENCES [dbo].[cat_lotes] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveMarca])
REFERENCES [dbo].[cat_marcas] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveFamilia])
REFERENCES [dbo].[cat_familias] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveSubFamilia])
REFERENCES [dbo].[cat_subfamilias] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveLinea])
REFERENCES [dbo].[cat_lineas] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveUnidadMedida])
REFERENCES [dbo].[cat_unidadesmed] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveInventariadoPor])
REFERENCES [dbo].[cat_unidadesmed] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveVendidaPor])
REFERENCES [dbo].[cat_unidadesmed] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos_agrupados]  WITH CHECK ADD  CONSTRAINT [FK_productos_agrupados_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_productos_agrupados] CHECK CONSTRAINT [FK_productos_agrupados_productos]
GO
ALTER TABLE [dbo].[cat_productos_agrupados_detalle]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_agrupados_detalle_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_productos_agrupados_detalle] CHECK CONSTRAINT [FK_cat_productos_agrupados_detalle_cat_productos]
GO
ALTER TABLE [dbo].[cat_productos_agrupados_detalle]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_agrupados_detalle_cat_productos_agrupados] FOREIGN KEY([ProductoAgrupadoId])
REFERENCES [dbo].[cat_productos_agrupados] ([ProductoAgrupadoId])
GO
ALTER TABLE [dbo].[cat_productos_agrupados_detalle] CHECK CONSTRAINT [FK_cat_productos_agrupados_detalle_cat_productos_agrupados]
GO
ALTER TABLE [dbo].[cat_productos_base]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_base_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_productos_base] CHECK CONSTRAINT [FK_cat_productos_base_cat_productos]
GO
ALTER TABLE [dbo].[cat_productos_base]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_base_cat_productos1] FOREIGN KEY([ProductoBaseId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_productos_base] CHECK CONSTRAINT [FK_cat_productos_base_cat_productos1]
GO
ALTER TABLE [dbo].[cat_productos_base]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_base_cat_unidadesmed] FOREIGN KEY([UnidadCocinaId])
REFERENCES [dbo].[cat_unidadesmed] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos_base] CHECK CONSTRAINT [FK_cat_productos_base_cat_unidadesmed]
GO
ALTER TABLE [dbo].[cat_productos_base_conceptos]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_base_conceptos_cat_conceptos] FOREIGN KEY([ConceptoId])
REFERENCES [dbo].[cat_conceptos] ([ConceptoId])
GO
ALTER TABLE [dbo].[cat_productos_base_conceptos] CHECK CONSTRAINT [FK_cat_productos_base_conceptos_cat_conceptos]
GO
ALTER TABLE [dbo].[cat_productos_base_conceptos]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_base_conceptos_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_productos_base_conceptos] CHECK CONSTRAINT [FK_cat_productos_base_conceptos_cat_productos]
GO
ALTER TABLE [dbo].[cat_productos_cambio_precio]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_cambio_precio_cat_precios] FOREIGN KEY([UsuarioRegistroId])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[cat_productos_cambio_precio] CHECK CONSTRAINT [FK_cat_productos_cambio_precio_cat_precios]
GO
ALTER TABLE [dbo].[cat_productos_cambio_precio]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_cambio_precio_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_productos_cambio_precio] CHECK CONSTRAINT [FK_cat_productos_cambio_precio_cat_productos]
GO
ALTER TABLE [dbo].[cat_productos_config_sucursal]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_config_sucursal_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_productos_config_sucursal] CHECK CONSTRAINT [FK_cat_productos_config_sucursal_cat_productos]
GO
ALTER TABLE [dbo].[cat_productos_config_sucursal]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_config_sucursal_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos_config_sucursal] CHECK CONSTRAINT [FK_cat_productos_config_sucursal_cat_sucursales]
GO
ALTER TABLE [dbo].[cat_productos_config_sucursal]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_config_sucursal_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[cat_productos_config_sucursal] CHECK CONSTRAINT [FK_cat_productos_config_sucursal_cat_usuarios]
GO
ALTER TABLE [dbo].[cat_productos_config_sucursal]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_config_sucursal_cat_usuarios1] FOREIGN KEY([ModificadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[cat_productos_config_sucursal] CHECK CONSTRAINT [FK_cat_productos_config_sucursal_cat_usuarios1]
GO
ALTER TABLE [dbo].[cat_productos_existencias]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_existencias_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_productos_existencias] CHECK CONSTRAINT [FK_cat_productos_existencias_cat_productos]
GO
ALTER TABLE [dbo].[cat_productos_existencias]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_existencias_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos_existencias] CHECK CONSTRAINT [FK_cat_productos_existencias_cat_sucursales]
GO
ALTER TABLE [dbo].[cat_productos_guisos]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_guisos_cat_guisos] FOREIGN KEY([ProductoGuisoId])
REFERENCES [dbo].[cat_guisos] ([productoId])
GO
ALTER TABLE [dbo].[cat_productos_guisos] CHECK CONSTRAINT [FK_cat_productos_guisos_cat_guisos]
GO
ALTER TABLE [dbo].[cat_productos_guisos]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_guisos_cat_productos1] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_productos_guisos] CHECK CONSTRAINT [FK_cat_productos_guisos_cat_productos1]
GO
ALTER TABLE [dbo].[cat_productos_imagenes]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_imagenes_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_productos_imagenes] CHECK CONSTRAINT [FK_cat_productos_imagenes_cat_productos]
GO
ALTER TABLE [dbo].[cat_productos_impuestos]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_impuestos_cat_impuestos] FOREIGN KEY([ImpuestoId])
REFERENCES [dbo].[cat_impuestos] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos_impuestos] CHECK CONSTRAINT [FK_cat_productos_impuestos_cat_impuestos]
GO
ALTER TABLE [dbo].[cat_productos_impuestos]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_impuestos_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_productos_impuestos] CHECK CONSTRAINT [FK_cat_productos_impuestos_cat_productos]
GO
ALTER TABLE [dbo].[cat_productos_licencias]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_licencias_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_productos_licencias] CHECK CONSTRAINT [FK_cat_productos_licencias_cat_productos]
GO
ALTER TABLE [dbo].[cat_productos_precios]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_precios_cat_productos] FOREIGN KEY([IdProducto])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_productos_precios] CHECK CONSTRAINT [FK_cat_productos_precios_cat_productos]
GO
ALTER TABLE [dbo].[cat_productos_precios]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_precios_cat_productos_precios] FOREIGN KEY([IdPrecio])
REFERENCES [dbo].[cat_precios] ([IdPrecio])
GO
ALTER TABLE [dbo].[cat_productos_precios] CHECK CONSTRAINT [FK_cat_productos_precios_cat_productos_precios]
GO
ALTER TABLE [dbo].[cat_productos_principales]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_principales_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_productos_principales] CHECK CONSTRAINT [FK_cat_productos_principales_cat_productos]
GO
ALTER TABLE [dbo].[cat_productos_principales]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_principales_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos_principales] CHECK CONSTRAINT [FK_cat_productos_principales_cat_sucursales]
GO
ALTER TABLE [dbo].[cat_proveedores]  WITH CHECK ADD  CONSTRAINT [FK_cat_proveedores_cat_estados] FOREIGN KEY([EstadoId])
REFERENCES [dbo].[cat_estados] ([EstadoId])
GO
ALTER TABLE [dbo].[cat_proveedores] CHECK CONSTRAINT [FK_cat_proveedores_cat_estados]
GO
ALTER TABLE [dbo].[cat_proveedores]  WITH CHECK ADD  CONSTRAINT [FK_cat_proveedores_cat_giros] FOREIGN KEY([GiroId])
REFERENCES [dbo].[cat_giros_neg] ([Clave])
GO
ALTER TABLE [dbo].[cat_proveedores] CHECK CONSTRAINT [FK_cat_proveedores_cat_giros]
GO
ALTER TABLE [dbo].[cat_proveedores]  WITH CHECK ADD  CONSTRAINT [FK_cat_proveedores_cat_municipios] FOREIGN KEY([MunicipioId])
REFERENCES [dbo].[cat_municipios] ([MunicipioId])
GO
ALTER TABLE [dbo].[cat_proveedores] CHECK CONSTRAINT [FK_cat_proveedores_cat_municipios]
GO
ALTER TABLE [dbo].[cat_proveedores]  WITH CHECK ADD  CONSTRAINT [FK_cat_proveedores_cat_paises] FOREIGN KEY([PaisId])
REFERENCES [dbo].[cat_paises] ([PaisId])
GO
ALTER TABLE [dbo].[cat_proveedores] CHECK CONSTRAINT [FK_cat_proveedores_cat_paises]
GO
ALTER TABLE [dbo].[cat_proveedores]  WITH CHECK ADD  CONSTRAINT [FK_cat_proveedores_cat_precios] FOREIGN KEY([PrecioId])
REFERENCES [dbo].[cat_precios] ([IdPrecio])
GO
ALTER TABLE [dbo].[cat_proveedores] CHECK CONSTRAINT [FK_cat_proveedores_cat_precios]
GO
ALTER TABLE [dbo].[cat_proveedores]  WITH CHECK ADD  CONSTRAINT [FK_cat_proveedores_cat_tipos_proveedor] FOREIGN KEY([TipoProveedorId])
REFERENCES [dbo].[cat_tipos_proveedor] ([TipoProveedorId])
GO
ALTER TABLE [dbo].[cat_proveedores] CHECK CONSTRAINT [FK_cat_proveedores_cat_tipos_proveedor]
GO
ALTER TABLE [dbo].[cat_rest_comandas]  WITH CHECK ADD  CONSTRAINT [FK_cat_rest_comandas_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_rest_comandas] CHECK CONSTRAINT [FK_cat_rest_comandas_cat_sucursales]
GO
ALTER TABLE [dbo].[cat_rest_comandas]  WITH CHECK ADD  CONSTRAINT [FK_cat_rest_comandas_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[cat_rest_comandas] CHECK CONSTRAINT [FK_cat_rest_comandas_cat_usuarios]
GO
ALTER TABLE [dbo].[cat_rest_mesas]  WITH CHECK ADD  CONSTRAINT [FK_cat_rest_mesas_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_rest_mesas] CHECK CONSTRAINT [FK_cat_rest_mesas_cat_sucursales]
GO
ALTER TABLE [dbo].[cat_rest_mesas]  WITH CHECK ADD  CONSTRAINT [FK_cat_rest_mesas_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[cat_rest_mesas] CHECK CONSTRAINT [FK_cat_rest_mesas_cat_usuarios]
GO
ALTER TABLE [dbo].[cat_rest_mesas]  WITH CHECK ADD  CONSTRAINT [FK_cat_rest_mesas_cat_usuarios1] FOREIGN KEY([ModificadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[cat_rest_mesas] CHECK CONSTRAINT [FK_cat_rest_mesas_cat_usuarios1]
GO
ALTER TABLE [dbo].[cat_rest_platillo_adicionales]  WITH CHECK ADD  CONSTRAINT [FK_cat_rest_platillo_adicionales_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[cat_rest_platillo_adicionales] CHECK CONSTRAINT [FK_cat_rest_platillo_adicionales_cat_usuarios]
GO
ALTER TABLE [dbo].[cat_rest_platillo_adicionales_sfam]  WITH CHECK ADD  CONSTRAINT [FK_cat_rest_platillo_adicionales_sfam_cat_rest_platillo_adicionales] FOREIGN KEY([PlatilloAdicionalId])
REFERENCES [dbo].[cat_rest_platillo_adicionales] ([Id])
GO
ALTER TABLE [dbo].[cat_rest_platillo_adicionales_sfam] CHECK CONSTRAINT [FK_cat_rest_platillo_adicionales_sfam_cat_rest_platillo_adicionales]
GO
ALTER TABLE [dbo].[cat_rest_platillo_adicionales_sfam]  WITH CHECK ADD  CONSTRAINT [FK_cat_rest_platillo_adicionales_sfam_cat_subfamilias] FOREIGN KEY([SubfamiliaId])
REFERENCES [dbo].[cat_subfamilias] ([Clave])
GO
ALTER TABLE [dbo].[cat_rest_platillo_adicionales_sfam] CHECK CONSTRAINT [FK_cat_rest_platillo_adicionales_sfam_cat_subfamilias]
GO
ALTER TABLE [dbo].[cat_rubros]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_rubros]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_rubros]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_rubros]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_sitios_entrega_pedido]  WITH CHECK ADD  CONSTRAINT [FK_cat_sitios_entrega_pedido_cat_municipios] FOREIGN KEY([CiudadId])
REFERENCES [dbo].[cat_municipios] ([MunicipioId])
GO
ALTER TABLE [dbo].[cat_sitios_entrega_pedido] CHECK CONSTRAINT [FK_cat_sitios_entrega_pedido_cat_municipios]
GO
ALTER TABLE [dbo].[cat_subclases_sat]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_subclases_sat]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_subclases_sat]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_subclases_sat]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_subfamilias]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_subfamilias]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_subfamilias]  WITH CHECK ADD FOREIGN KEY([Familia])
REFERENCES [dbo].[cat_familias] ([Clave])
GO
ALTER TABLE [dbo].[cat_subfamilias]  WITH CHECK ADD FOREIGN KEY([Familia])
REFERENCES [dbo].[cat_familias] ([Clave])
GO
ALTER TABLE [dbo].[cat_subfamilias]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_subfamilias]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_sucursales_departamentos]  WITH CHECK ADD  CONSTRAINT [FK_cat_sucursales_departamentos_cat_departamentos] FOREIGN KEY([DepartamentoId])
REFERENCES [dbo].[cat_departamentos] ([DepartamentoId])
GO
ALTER TABLE [dbo].[cat_sucursales_departamentos] CHECK CONSTRAINT [FK_cat_sucursales_departamentos_cat_departamentos]
GO
ALTER TABLE [dbo].[cat_sucursales_departamentos]  WITH CHECK ADD  CONSTRAINT [FK_cat_sucursales_departamentos_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_sucursales_departamentos] CHECK CONSTRAINT [FK_cat_sucursales_departamentos_cat_sucursales]
GO
ALTER TABLE [dbo].[cat_sucursales_productos]  WITH CHECK ADD  CONSTRAINT [FK_cat_sucursales_productos_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_sucursales_productos] CHECK CONSTRAINT [FK_cat_sucursales_productos_cat_productos]
GO
ALTER TABLE [dbo].[cat_sucursales_productos]  WITH CHECK ADD  CONSTRAINT [FK_cat_sucursales_productos_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_sucursales_productos] CHECK CONSTRAINT [FK_cat_sucursales_productos_cat_sucursales]
GO
ALTER TABLE [dbo].[cat_tipos_movimiento_inventario]  WITH CHECK ADD FOREIGN KEY([TipoMovimientoCancelacionId])
REFERENCES [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId])
GO
ALTER TABLE [dbo].[cat_tipos_movimiento_inventario]  WITH CHECK ADD FOREIGN KEY([TipoMovimientoCancelacionId])
REFERENCES [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId])
GO
ALTER TABLE [dbo].[cat_unidadesmed]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_unidadesmed]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_unidadesmed]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_unidadesmed]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_usuarios]  WITH CHECK ADD  CONSTRAINT [FK_cat_usuarios_cat_cajas] FOREIGN KEY([CajaDefaultId])
REFERENCES [dbo].[cat_cajas] ([Clave])
GO
ALTER TABLE [dbo].[cat_usuarios] CHECK CONSTRAINT [FK_cat_usuarios_cat_cajas]
GO
ALTER TABLE [dbo].[cat_usuarios]  WITH CHECK ADD  CONSTRAINT [FK_cat_usuarios_cat_sucursales] FOREIGN KEY([IdSucursal])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_usuarios] CHECK CONSTRAINT [FK_cat_usuarios_cat_sucursales]
GO
ALTER TABLE [dbo].[cat_usuarios]  WITH CHECK ADD  CONSTRAINT [FK_cat_usuarios_rh_empleados] FOREIGN KEY([IdEmpleado])
REFERENCES [dbo].[rh_empleados] ([NumEmpleado])
GO
ALTER TABLE [dbo].[cat_usuarios] CHECK CONSTRAINT [FK_cat_usuarios_rh_empleados]
GO
ALTER TABLE [dbo].[cat_usuarios_sucursales]  WITH CHECK ADD  CONSTRAINT [FK_cat_usuarios_sucursales_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_usuarios_sucursales] CHECK CONSTRAINT [FK_cat_usuarios_sucursales_cat_sucursales]
GO
ALTER TABLE [dbo].[cat_usuarios_sucursales]  WITH CHECK ADD  CONSTRAINT [FK_cat_usuarios_sucursales_cat_usuarios] FOREIGN KEY([UsuarioId])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[cat_usuarios_sucursales] CHECK CONSTRAINT [FK_cat_usuarios_sucursales_cat_usuarios]
GO
ALTER TABLE [dbo].[cat_web_configuracion]  WITH CHECK ADD  CONSTRAINT [FK_cat_web_configuracion_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_web_configuracion] CHECK CONSTRAINT [FK_cat_web_configuracion_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_aceptaciones_sucursal]  WITH CHECK ADD  CONSTRAINT [FK_doc_aceptaciones_sucursal_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_aceptaciones_sucursal] CHECK CONSTRAINT [FK_doc_aceptaciones_sucursal_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_aceptaciones_sucursal]  WITH CHECK ADD  CONSTRAINT [FK_doc_aceptaciones_sucursal_cat_usuarios] FOREIGN KEY([AceptadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_aceptaciones_sucursal] CHECK CONSTRAINT [FK_doc_aceptaciones_sucursal_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_aceptaciones_sucursal]  WITH CHECK ADD  CONSTRAINT [FK_doc_aceptaciones_sucursal_doc_inv_movimiento] FOREIGN KEY([MovimientoId])
REFERENCES [dbo].[doc_inv_movimiento] ([MovimientoId])
GO
ALTER TABLE [dbo].[doc_aceptaciones_sucursal] CHECK CONSTRAINT [FK_doc_aceptaciones_sucursal_doc_inv_movimiento]
GO
ALTER TABLE [dbo].[doc_aceptaciones_sucursal_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_aceptaciones_sucursal_detalle_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_aceptaciones_sucursal_detalle] CHECK CONSTRAINT [FK_doc_aceptaciones_sucursal_detalle_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_aceptaciones_sucursal_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_aceptaciones_sucursal_detalle_doc_aceptaciones_sucursal] FOREIGN KEY([AceptacionSucursalId])
REFERENCES [dbo].[doc_aceptaciones_sucursal] ([Id])
GO
ALTER TABLE [dbo].[doc_aceptaciones_sucursal_detalle] CHECK CONSTRAINT [FK_doc_aceptaciones_sucursal_detalle_doc_aceptaciones_sucursal]
GO
ALTER TABLE [dbo].[doc_aceptaciones_sucursal_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_aceptaciones_sucursal_detalle_doc_inv_movimiento_detalle] FOREIGN KEY([MovimientoDetalleId])
REFERENCES [dbo].[doc_inv_movimiento_detalle] ([MovimientoDetalleId])
GO
ALTER TABLE [dbo].[doc_aceptaciones_sucursal_detalle] CHECK CONSTRAINT [FK_doc_aceptaciones_sucursal_detalle_doc_inv_movimiento_detalle]
GO
ALTER TABLE [dbo].[doc_aceptaciones_sucursal_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_aceptaciones_sucursal_detalle_doc_inv_movimiento_detalle1] FOREIGN KEY([MovimientoDetalleAjusteId])
REFERENCES [dbo].[doc_inv_movimiento_detalle] ([MovimientoDetalleId])
GO
ALTER TABLE [dbo].[doc_aceptaciones_sucursal_detalle] CHECK CONSTRAINT [FK_doc_aceptaciones_sucursal_detalle_doc_inv_movimiento_detalle1]
GO
ALTER TABLE [dbo].[doc_apartados]  WITH CHECK ADD  CONSTRAINT [FK_apartados_ventas] FOREIGN KEY([VentaId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_apartados] CHECK CONSTRAINT [FK_apartados_ventas]
GO
ALTER TABLE [dbo].[doc_apartados]  WITH CHECK ADD  CONSTRAINT [FK_doc_apartados_cat_clientes] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[doc_apartados] CHECK CONSTRAINT [FK_doc_apartados_cat_clientes]
GO
ALTER TABLE [dbo].[doc_apartados]  WITH CHECK ADD  CONSTRAINT [FK_doc_apartados_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_apartados] CHECK CONSTRAINT [FK_doc_apartados_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_apartados]  WITH CHECK ADD  CONSTRAINT [FK_doc_apartados_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_apartados] CHECK CONSTRAINT [FK_doc_apartados_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_apartados_formas_pago]  WITH CHECK ADD  CONSTRAINT [FK_doc_apartados_formas_pago_cat_formas_pago] FOREIGN KEY([FormaPagoId])
REFERENCES [dbo].[cat_formas_pago] ([FormaPagoId])
GO
ALTER TABLE [dbo].[doc_apartados_formas_pago] CHECK CONSTRAINT [FK_doc_apartados_formas_pago_cat_formas_pago]
GO
ALTER TABLE [dbo].[doc_apartados_formas_pago]  WITH CHECK ADD  CONSTRAINT [FK_doc_apartados_formas_pago_doc_apartados_pagos] FOREIGN KEY([ApartadoPagoId])
REFERENCES [dbo].[doc_apartados_pagos] ([ApartadoPagoId])
GO
ALTER TABLE [dbo].[doc_apartados_formas_pago] CHECK CONSTRAINT [FK_doc_apartados_formas_pago_doc_apartados_pagos]
GO
ALTER TABLE [dbo].[doc_apartados_pagos]  WITH CHECK ADD  CONSTRAINT [FK_doc_apartados_pagos_caja] FOREIGN KEY([CajaId])
REFERENCES [dbo].[cat_cajas] ([Clave])
GO
ALTER TABLE [dbo].[doc_apartados_pagos] CHECK CONSTRAINT [FK_doc_apartados_pagos_caja]
GO
ALTER TABLE [dbo].[doc_apartados_pagos]  WITH CHECK ADD  CONSTRAINT [FK_doc_apartados_pagos_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_apartados_pagos] CHECK CONSTRAINT [FK_doc_apartados_pagos_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_apartados_pagos]  WITH CHECK ADD  CONSTRAINT [FK_doc_apartados_pagos_doc_apartados] FOREIGN KEY([ApartadoId])
REFERENCES [dbo].[doc_apartados] ([ApartadoId])
GO
ALTER TABLE [dbo].[doc_apartados_pagos] CHECK CONSTRAINT [FK_doc_apartados_pagos_doc_apartados]
GO
ALTER TABLE [dbo].[doc_apartados_productos]  WITH CHECK ADD  CONSTRAINT [FK_doc_apartados_productos_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_apartados_productos] CHECK CONSTRAINT [FK_doc_apartados_productos_cat_productos]
GO
ALTER TABLE [dbo].[doc_apartados_productos]  WITH CHECK ADD  CONSTRAINT [FK_doc_apartados_productos_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_apartados_productos] CHECK CONSTRAINT [FK_doc_apartados_productos_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_apartados_productos]  WITH CHECK ADD  CONSTRAINT [FK_doc_apartados_productos_cat_usuarios1] FOREIGN KEY([ModificadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_apartados_productos] CHECK CONSTRAINT [FK_doc_apartados_productos_cat_usuarios1]
GO
ALTER TABLE [dbo].[doc_apartados_productos]  WITH CHECK ADD  CONSTRAINT [FK_doc_apartados_productos_doc_apartados] FOREIGN KEY([ApartadoId])
REFERENCES [dbo].[doc_apartados] ([ApartadoId])
GO
ALTER TABLE [dbo].[doc_apartados_productos] CHECK CONSTRAINT [FK_doc_apartados_productos_doc_apartados]
GO
ALTER TABLE [dbo].[doc_basculas_bitacora]  WITH CHECK ADD  CONSTRAINT [FK_doc_basculas_bitacora_cat_basculas] FOREIGN KEY([BasculaId])
REFERENCES [dbo].[cat_basculas] ([BasculaId])
GO
ALTER TABLE [dbo].[doc_basculas_bitacora] CHECK CONSTRAINT [FK_doc_basculas_bitacora_cat_basculas]
GO
ALTER TABLE [dbo].[doc_basculas_bitacora]  WITH CHECK ADD  CONSTRAINT [FK_doc_basculas_bitacora_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_basculas_bitacora] CHECK CONSTRAINT [FK_doc_basculas_bitacora_cat_productos]
GO
ALTER TABLE [dbo].[doc_basculas_bitacora]  WITH CHECK ADD  CONSTRAINT [FK_doc_basculas_bitacora_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_basculas_bitacora] CHECK CONSTRAINT [FK_doc_basculas_bitacora_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_basculas_bitacora]  WITH CHECK ADD  CONSTRAINT [FK_doc_basculas_bitacora_cat_tipos_bascula_bitacora] FOREIGN KEY([TipoBasculaBitacoraId])
REFERENCES [dbo].[cat_tipos_bascula_bitacora] ([TipoBasculaBitacoraId])
GO
ALTER TABLE [dbo].[doc_basculas_bitacora] CHECK CONSTRAINT [FK_doc_basculas_bitacora_cat_tipos_bascula_bitacora]
GO
ALTER TABLE [dbo].[doc_basculas_bitacora]  WITH CHECK ADD  CONSTRAINT [FK_doc_basculas_bitacora_doc_pedidos_orden_detalle] FOREIGN KEY([PedidoDetalleId])
REFERENCES [dbo].[doc_pedidos_orden_detalle] ([PedidoDetalleId])
GO
ALTER TABLE [dbo].[doc_basculas_bitacora] CHECK CONSTRAINT [FK_doc_basculas_bitacora_doc_pedidos_orden_detalle]
GO
ALTER TABLE [dbo].[doc_basculas_bitacora]  WITH CHECK ADD  CONSTRAINT [FK_doc_basculas_bitacora_doc_ventas] FOREIGN KEY([VentaId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_basculas_bitacora] CHECK CONSTRAINT [FK_doc_basculas_bitacora_doc_ventas]
GO
ALTER TABLE [dbo].[doc_cargo_adicional_config]  WITH CHECK ADD  CONSTRAINT [FK_doc_cargo_adicional_config_cat_cargos_adicionales] FOREIGN KEY([CargoAdicionalId])
REFERENCES [dbo].[cat_cargos_adicionales] ([CargoAdicionalId])
GO
ALTER TABLE [dbo].[doc_cargo_adicional_config] CHECK CONSTRAINT [FK_doc_cargo_adicional_config_cat_cargos_adicionales]
GO
ALTER TABLE [dbo].[doc_cargo_adicional_config]  WITH CHECK ADD  CONSTRAINT [FK_doc_cargo_adicional_config_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_cargo_adicional_config] CHECK CONSTRAINT [FK_doc_cargo_adicional_config_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_cargos]  WITH CHECK ADD  CONSTRAINT [FK_doc_cargos_cat_clientes] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[doc_cargos] CHECK CONSTRAINT [FK_doc_cargos_cat_clientes]
GO
ALTER TABLE [dbo].[doc_cargos]  WITH CHECK ADD  CONSTRAINT [FK_doc_cargos_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_cargos] CHECK CONSTRAINT [FK_doc_cargos_cat_productos]
GO
ALTER TABLE [dbo].[doc_cargos]  WITH CHECK ADD  CONSTRAINT [FK_doc_Cargos_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_cargos] CHECK CONSTRAINT [FK_doc_Cargos_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_cargos_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_cargos_detalle_doc_cargos] FOREIGN KEY([CargoId])
REFERENCES [dbo].[doc_cargos] ([CargoId])
GO
ALTER TABLE [dbo].[doc_cargos_detalle] CHECK CONSTRAINT [FK_doc_cargos_detalle_doc_cargos]
GO
ALTER TABLE [dbo].[doc_clientes_licencias]  WITH CHECK ADD  CONSTRAINT [FK_doc_clientes_licencias_cat_clientes] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[doc_clientes_licencias] CHECK CONSTRAINT [FK_doc_clientes_licencias_cat_clientes]
GO
ALTER TABLE [dbo].[doc_clientes_licencias]  WITH CHECK ADD  CONSTRAINT [FK_doc_clientes_licencias_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_clientes_licencias] CHECK CONSTRAINT [FK_doc_clientes_licencias_cat_productos]
GO
ALTER TABLE [dbo].[doc_clientes_productos_precios]  WITH CHECK ADD  CONSTRAINT [FK_doc_clientes_productos_precios_cat_clientes] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[doc_clientes_productos_precios] CHECK CONSTRAINT [FK_doc_clientes_productos_precios_cat_clientes]
GO
ALTER TABLE [dbo].[doc_clientes_productos_precios]  WITH CHECK ADD  CONSTRAINT [FK_doc_clientes_productos_precios_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_clientes_productos_precios] CHECK CONSTRAINT [FK_doc_clientes_productos_precios_cat_productos]
GO
ALTER TABLE [dbo].[doc_cocimientos]  WITH CHECK ADD  CONSTRAINT [FK_doc_cocimientos_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_cocimientos] CHECK CONSTRAINT [FK_doc_cocimientos_cat_productos]
GO
ALTER TABLE [dbo].[doc_cocimientos]  WITH CHECK ADD  CONSTRAINT [FK_doc_cocimientos_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_cocimientos] CHECK CONSTRAINT [FK_doc_cocimientos_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_cocimientos]  WITH CHECK ADD  CONSTRAINT [FK_doc_cocimientos_doc_produccion] FOREIGN KEY([ProduccionId])
REFERENCES [dbo].[doc_produccion] ([ProduccionId])
GO
ALTER TABLE [dbo].[doc_cocimientos] CHECK CONSTRAINT [FK_doc_cocimientos_doc_produccion]
GO
ALTER TABLE [dbo].[doc_cocimientos_grupos]  WITH CHECK ADD  CONSTRAINT [FK_doc_cocimientos_grupos_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_cocimientos_grupos] CHECK CONSTRAINT [FK_doc_cocimientos_grupos_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_cocimientos_grupos]  WITH CHECK ADD  CONSTRAINT [FK_doc_cocimientos_grupos_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_cocimientos_grupos] CHECK CONSTRAINT [FK_doc_cocimientos_grupos_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_cocimientos_grupos_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_cocimientos_grupos_detalle_doc_cocimientos] FOREIGN KEY([CocimientoId])
REFERENCES [dbo].[doc_cocimientos] ([CocimientoId])
GO
ALTER TABLE [dbo].[doc_cocimientos_grupos_detalle] CHECK CONSTRAINT [FK_doc_cocimientos_grupos_detalle_doc_cocimientos]
GO
ALTER TABLE [dbo].[doc_cocimientos_grupos_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_cocimientos_grupos_detalle_doc_cocimientos_grupos] FOREIGN KEY([CocimientoGrupoId])
REFERENCES [dbo].[doc_cocimientos_grupos] ([Id])
GO
ALTER TABLE [dbo].[doc_cocimientos_grupos_detalle] CHECK CONSTRAINT [FK_doc_cocimientos_grupos_detalle_doc_cocimientos_grupos]
GO
ALTER TABLE [dbo].[doc_cocimientos_grupos_movs_inventario]  WITH CHECK ADD  CONSTRAINT [FK_doc_cocimientos_grupos_movs_inventario_doc_cocimientos_grupos] FOREIGN KEY([CocimientoGrupoId])
REFERENCES [dbo].[doc_cocimientos_grupos] ([Id])
GO
ALTER TABLE [dbo].[doc_cocimientos_grupos_movs_inventario] CHECK CONSTRAINT [FK_doc_cocimientos_grupos_movs_inventario_doc_cocimientos_grupos]
GO
ALTER TABLE [dbo].[doc_cocimientos_grupos_movs_inventario]  WITH CHECK ADD  CONSTRAINT [FK_doc_cocimientos_grupos_movs_inventario_doc_inv_movimiento] FOREIGN KEY([MovimientoInventarioId])
REFERENCES [dbo].[doc_inv_movimiento] ([MovimientoId])
GO
ALTER TABLE [dbo].[doc_cocimientos_grupos_movs_inventario] CHECK CONSTRAINT [FK_doc_cocimientos_grupos_movs_inventario_doc_inv_movimiento]
GO
ALTER TABLE [dbo].[doc_corte_caja]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_cat_cajas] FOREIGN KEY([CajaId])
REFERENCES [dbo].[cat_cajas] ([Clave])
GO
ALTER TABLE [dbo].[doc_corte_caja] CHECK CONSTRAINT [FK_doc_corte_caja_cat_cajas]
GO
ALTER TABLE [dbo].[doc_corte_caja]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_corte_caja] CHECK CONSTRAINT [FK_doc_corte_caja_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_corte_caja]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_doc_ventas] FOREIGN KEY([VentaIniId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_corte_caja] CHECK CONSTRAINT [FK_doc_corte_caja_doc_ventas]
GO
ALTER TABLE [dbo].[doc_corte_caja]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_doc_ventas1] FOREIGN KEY([VentaFinId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_corte_caja] CHECK CONSTRAINT [FK_doc_corte_caja_doc_ventas1]
GO
ALTER TABLE [dbo].[doc_corte_caja_apartados_pagos]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_apartados_pagos_doc_apartados_pagos] FOREIGN KEY([ApartadoPagoId])
REFERENCES [dbo].[doc_apartados_pagos] ([ApartadoPagoId])
GO
ALTER TABLE [dbo].[doc_corte_caja_apartados_pagos] CHECK CONSTRAINT [FK_doc_corte_caja_apartados_pagos_doc_apartados_pagos]
GO
ALTER TABLE [dbo].[doc_corte_caja_apartados_pagos]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_apartados_pagos_doc_corte_caja] FOREIGN KEY([CorteCajaId])
REFERENCES [dbo].[doc_corte_caja] ([CorteCajaId])
GO
ALTER TABLE [dbo].[doc_corte_caja_apartados_pagos] CHECK CONSTRAINT [FK_doc_corte_caja_apartados_pagos_doc_corte_caja]
GO
ALTER TABLE [dbo].[doc_corte_caja_datos_entrada]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_datos_entrada_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_corte_caja_datos_entrada] CHECK CONSTRAINT [FK_doc_corte_caja_datos_entrada_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_corte_caja_datos_entrada]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_datos_entrada_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_corte_caja_datos_entrada] CHECK CONSTRAINT [FK_doc_corte_caja_datos_entrada_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_corte_caja_denominaciones]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_denominaciones_cat_denominaciones] FOREIGN KEY([DenominacionId])
REFERENCES [dbo].[cat_denominaciones] ([Clave])
GO
ALTER TABLE [dbo].[doc_corte_caja_denominaciones] CHECK CONSTRAINT [FK_doc_corte_caja_denominaciones_cat_denominaciones]
GO
ALTER TABLE [dbo].[doc_corte_caja_denominaciones]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_denominaciones_doc_corte_caja] FOREIGN KEY([CorteCajaId])
REFERENCES [dbo].[doc_corte_caja] ([CorteCajaId])
GO
ALTER TABLE [dbo].[doc_corte_caja_denominaciones] CHECK CONSTRAINT [FK_doc_corte_caja_denominaciones_doc_corte_caja]
GO
ALTER TABLE [dbo].[doc_corte_caja_egresos]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_egresos_doc_corte_caja] FOREIGN KEY([CorteCajaId])
REFERENCES [dbo].[doc_corte_caja] ([CorteCajaId])
GO
ALTER TABLE [dbo].[doc_corte_caja_egresos] CHECK CONSTRAINT [FK_doc_corte_caja_egresos_doc_corte_caja]
GO
ALTER TABLE [dbo].[doc_corte_caja_fp]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_fp_doc_corte_caja] FOREIGN KEY([CorteCajaId])
REFERENCES [dbo].[doc_corte_caja] ([CorteCajaId])
GO
ALTER TABLE [dbo].[doc_corte_caja_fp] CHECK CONSTRAINT [FK_doc_corte_caja_fp_doc_corte_caja]
GO
ALTER TABLE [dbo].[doc_corte_caja_fp_apartado]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_fp_apartado_doc_corte_caja] FOREIGN KEY([CorteCajaId])
REFERENCES [dbo].[doc_corte_caja] ([CorteCajaId])
GO
ALTER TABLE [dbo].[doc_corte_caja_fp_apartado] CHECK CONSTRAINT [FK_doc_corte_caja_fp_apartado_doc_corte_caja]
GO
ALTER TABLE [dbo].[doc_corte_caja_pedidos_sin_cerrar]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_pedidos_sin_cerrar_doc_corte_caja] FOREIGN KEY([CorteCajaId])
REFERENCES [dbo].[doc_corte_caja] ([CorteCajaId])
GO
ALTER TABLE [dbo].[doc_corte_caja_pedidos_sin_cerrar] CHECK CONSTRAINT [FK_doc_corte_caja_pedidos_sin_cerrar_doc_corte_caja]
GO
ALTER TABLE [dbo].[doc_corte_caja_pedidos_sin_cerrar]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_pedidos_sin_cerrar_doc_pedidos_orden] FOREIGN KEY([PedidoId])
REFERENCES [dbo].[doc_pedidos_orden] ([PedidoId])
GO
ALTER TABLE [dbo].[doc_corte_caja_pedidos_sin_cerrar] CHECK CONSTRAINT [FK_doc_corte_caja_pedidos_sin_cerrar_doc_pedidos_orden]
GO
ALTER TABLE [dbo].[doc_declaracion_fondo_inicial]  WITH CHECK ADD  CONSTRAINT [FK_doc_declaracion_fondo_inicial_cat_cajas] FOREIGN KEY([CajaId])
REFERENCES [dbo].[cat_cajas] ([Clave])
GO
ALTER TABLE [dbo].[doc_declaracion_fondo_inicial] CHECK CONSTRAINT [FK_doc_declaracion_fondo_inicial_cat_cajas]
GO
ALTER TABLE [dbo].[doc_declaracion_fondo_inicial]  WITH CHECK ADD  CONSTRAINT [FK_doc_declaraciones_fondo_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_declaracion_fondo_inicial] CHECK CONSTRAINT [FK_doc_declaraciones_fondo_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_declaracion_fondo_inicial]  WITH CHECK ADD  CONSTRAINT [FK_doc_declaraciones_fondo_doc_corte_caja] FOREIGN KEY([CorteCajaId])
REFERENCES [dbo].[doc_corte_caja] ([CorteCajaId])
GO
ALTER TABLE [dbo].[doc_declaracion_fondo_inicial] CHECK CONSTRAINT [FK_doc_declaraciones_fondo_doc_corte_caja]
GO
ALTER TABLE [dbo].[doc_declaracion_fondo_inicial_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_declaracion_fondo_inicial_detalle_cat_denominaciones] FOREIGN KEY([DenominacionId])
REFERENCES [dbo].[cat_denominaciones] ([Clave])
GO
ALTER TABLE [dbo].[doc_declaracion_fondo_inicial_detalle] CHECK CONSTRAINT [FK_doc_declaracion_fondo_inicial_detalle_cat_denominaciones]
GO
ALTER TABLE [dbo].[doc_declaracion_fondo_inicial_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_declaracion_fondo_inicial_detalle_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_declaracion_fondo_inicial_detalle] CHECK CONSTRAINT [FK_doc_declaracion_fondo_inicial_detalle_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_declaracion_fondo_inicial_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_declaracion_fondo_inicial_detalle_doc_declaracion_fondo_inicial] FOREIGN KEY([DeclaracionFondoId])
REFERENCES [dbo].[doc_declaracion_fondo_inicial] ([DeclaracionFondoId])
GO
ALTER TABLE [dbo].[doc_declaracion_fondo_inicial_detalle] CHECK CONSTRAINT [FK_doc_declaracion_fondo_inicial_detalle_doc_declaracion_fondo_inicial]
GO
ALTER TABLE [dbo].[doc_devoluciones]  WITH CHECK ADD FOREIGN KEY([TipoDevolucionId])
REFERENCES [dbo].[cat_tipos_devolucion] ([TipoDevolucionId])
GO
ALTER TABLE [dbo].[doc_devoluciones]  WITH CHECK ADD FOREIGN KEY([TipoDevolucionId])
REFERENCES [dbo].[cat_tipos_devolucion] ([TipoDevolucionId])
GO
ALTER TABLE [dbo].[doc_devoluciones]  WITH CHECK ADD  CONSTRAINT [FK_doc_devoluciones_cat_usuarios1] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_devoluciones] CHECK CONSTRAINT [FK_doc_devoluciones_cat_usuarios1]
GO
ALTER TABLE [dbo].[doc_devoluciones]  WITH CHECK ADD  CONSTRAINT [FK_doc_devoluciones_doc_ventas1] FOREIGN KEY([VentaId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_devoluciones] CHECK CONSTRAINT [FK_doc_devoluciones_doc_ventas1]
GO
ALTER TABLE [dbo].[doc_devoluciones_detalle]  WITH CHECK ADD FOREIGN KEY([DevolucionId])
REFERENCES [dbo].[doc_devoluciones] ([DevolucionId])
GO
ALTER TABLE [dbo].[doc_devoluciones_detalle]  WITH CHECK ADD FOREIGN KEY([DevolucionId])
REFERENCES [dbo].[doc_devoluciones] ([DevolucionId])
GO
ALTER TABLE [dbo].[doc_devoluciones_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_devoluciones_cat_productos] FOREIGN KEY([VentaId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_devoluciones_detalle] CHECK CONSTRAINT [FK_doc_devoluciones_cat_productos]
GO
ALTER TABLE [dbo].[doc_devoluciones_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_devoluciones_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_devoluciones_detalle] CHECK CONSTRAINT [FK_doc_devoluciones_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_devoluciones_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_devoluciones_doc_ventas] FOREIGN KEY([VentaId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_devoluciones_detalle] CHECK CONSTRAINT [FK_doc_devoluciones_doc_ventas]
GO
ALTER TABLE [dbo].[doc_empleados_productos_descuentos]  WITH CHECK ADD  CONSTRAINT [FK_doc_empleados_productos_descuentos_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_empleados_productos_descuentos] CHECK CONSTRAINT [FK_doc_empleados_productos_descuentos_cat_productos]
GO
ALTER TABLE [dbo].[doc_empleados_productos_descuentos]  WITH CHECK ADD  CONSTRAINT [FK_doc_empleados_productos_descuentos_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_empleados_productos_descuentos] CHECK CONSTRAINT [FK_doc_empleados_productos_descuentos_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_empleados_productos_descuentos]  WITH CHECK ADD  CONSTRAINT [FK_doc_empleados_productos_descuentos_cat_usuarios1] FOREIGN KEY([ModificadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_empleados_productos_descuentos] CHECK CONSTRAINT [FK_doc_empleados_productos_descuentos_cat_usuarios1]
GO
ALTER TABLE [dbo].[doc_empleados_productos_descuentos]  WITH CHECK ADD  CONSTRAINT [FK_doc_empleados_productos_descuentos_rh_empleados] FOREIGN KEY([EmpleadoId])
REFERENCES [dbo].[rh_empleados] ([NumEmpleado])
GO
ALTER TABLE [dbo].[doc_empleados_productos_descuentos] CHECK CONSTRAINT [FK_doc_empleados_productos_descuentos_rh_empleados]
GO
ALTER TABLE [dbo].[doc_entrada_directa_adicional]  WITH CHECK ADD  CONSTRAINT [FK_doc_entrada_directa_adicional_doc_inv_movimiento_detalle] FOREIGN KEY([MovimientoDetalleId])
REFERENCES [dbo].[doc_inv_movimiento_detalle] ([MovimientoDetalleId])
GO
ALTER TABLE [dbo].[doc_entrada_directa_adicional] CHECK CONSTRAINT [FK_doc_entrada_directa_adicional_doc_inv_movimiento_detalle]
GO
ALTER TABLE [dbo].[doc_equipo_computo_bascula_registro]  WITH CHECK ADD  CONSTRAINT [FK_doc_equipo_computo_bascula_registro_cat_equipos_computo] FOREIGN KEY([EquipoConputoId])
REFERENCES [dbo].[cat_equipos_computo] ([EquipoComputoId])
GO
ALTER TABLE [dbo].[doc_equipo_computo_bascula_registro] CHECK CONSTRAINT [FK_doc_equipo_computo_bascula_registro_cat_equipos_computo]
GO
ALTER TABLE [dbo].[doc_equipo_computo_bascula_registro]  WITH CHECK ADD  CONSTRAINT [FK_doc_equipo_computo_bascula_registro_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_equipo_computo_bascula_registro] CHECK CONSTRAINT [FK_doc_equipo_computo_bascula_registro_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_gastos]  WITH CHECK ADD  CONSTRAINT [FK_doc_gastos_cat_cajas] FOREIGN KEY([CajaId])
REFERENCES [dbo].[cat_cajas] ([Clave])
GO
ALTER TABLE [dbo].[doc_gastos] CHECK CONSTRAINT [FK_doc_gastos_cat_cajas]
GO
ALTER TABLE [dbo].[doc_gastos]  WITH CHECK ADD  CONSTRAINT [FK_doc_gastos_cat_centro_costos] FOREIGN KEY([CentroCostoId])
REFERENCES [dbo].[cat_centro_costos] ([Clave])
GO
ALTER TABLE [dbo].[doc_gastos] CHECK CONSTRAINT [FK_doc_gastos_cat_centro_costos]
GO
ALTER TABLE [dbo].[doc_gastos]  WITH CHECK ADD  CONSTRAINT [FK_doc_gastos_cat_gastos] FOREIGN KEY([GastoConceptoId])
REFERENCES [dbo].[cat_gastos] ([Clave])
GO
ALTER TABLE [dbo].[doc_gastos] CHECK CONSTRAINT [FK_doc_gastos_cat_gastos]
GO
ALTER TABLE [dbo].[doc_gastos]  WITH CHECK ADD  CONSTRAINT [FK_doc_gastos_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_gastos] CHECK CONSTRAINT [FK_doc_gastos_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_gastos]  WITH CHECK ADD  CONSTRAINT [FK_doc_gastos_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_gastos] CHECK CONSTRAINT [FK_doc_gastos_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_inv_carga_inicial]  WITH CHECK ADD  CONSTRAINT [FK_doc_inv_carga_inicial_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_inv_carga_inicial] CHECK CONSTRAINT [FK_doc_inv_carga_inicial_cat_productos]
GO
ALTER TABLE [dbo].[doc_inv_carga_inicial]  WITH CHECK ADD  CONSTRAINT [FK_doc_inv_carga_inicial_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_inv_carga_inicial] CHECK CONSTRAINT [FK_doc_inv_carga_inicial_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_inv_carga_inicial]  WITH CHECK ADD  CONSTRAINT [FK_doc_inv_carga_inicial_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_inv_carga_inicial] CHECK CONSTRAINT [FK_doc_inv_carga_inicial_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD FOREIGN KEY([AutorizadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD FOREIGN KEY([AutorizadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD FOREIGN KEY([ProductoCompraId])
REFERENCES [dbo].[doc_productos_compra] ([ProductoCompraId])
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD FOREIGN KEY([ProductoCompraId])
REFERENCES [dbo].[doc_productos_compra] ([ProductoCompraId])
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD FOREIGN KEY([SucursalOrigenId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD FOREIGN KEY([SucursalDestinoId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD FOREIGN KEY([SucursalOrigenId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD FOREIGN KEY([SucursalDestinoId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD FOREIGN KEY([VentaId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD FOREIGN KEY([VentaId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD  CONSTRAINT [FK_doc_inv_movimiento_cancelacion] FOREIGN KEY([MovimientoRefId])
REFERENCES [dbo].[doc_inv_movimiento] ([MovimientoId])
GO
ALTER TABLE [dbo].[doc_inv_movimiento] CHECK CONSTRAINT [FK_doc_inv_movimiento_cancelacion]
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD  CONSTRAINT [FK_doc_inv_movimiento_cat_sucursales] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_inv_movimiento] CHECK CONSTRAINT [FK_doc_inv_movimiento_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD  CONSTRAINT [FK_doc_inv_movimiento_cat_tipos_merma] FOREIGN KEY([TipoMermaId])
REFERENCES [dbo].[cat_tipos_mermas] ([TipoMermaId])
GO
ALTER TABLE [dbo].[doc_inv_movimiento] CHECK CONSTRAINT [FK_doc_inv_movimiento_cat_tipos_merma]
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD  CONSTRAINT [FK_doc_inv_movimiento_cat_tipos_movimiento_inventario] FOREIGN KEY([TipoMovimientoId])
REFERENCES [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId])
GO
ALTER TABLE [dbo].[doc_inv_movimiento] CHECK CONSTRAINT [FK_doc_inv_movimiento_cat_tipos_movimiento_inventario]
GO
ALTER TABLE [dbo].[doc_inv_movimiento_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_inv_movimiento_detalle_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_inv_movimiento_detalle] CHECK CONSTRAINT [FK_doc_inv_movimiento_detalle_cat_productos]
GO
ALTER TABLE [dbo].[doc_inv_movimiento_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_inv_movimiento_detalle_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_inv_movimiento_detalle] CHECK CONSTRAINT [FK_doc_inv_movimiento_detalle_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_inv_movimiento_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_inv_movimiento_detalle_doc_inv_movimiento] FOREIGN KEY([MovimientoId])
REFERENCES [dbo].[doc_inv_movimiento] ([MovimientoId])
GO
ALTER TABLE [dbo].[doc_inv_movimiento_detalle] CHECK CONSTRAINT [FK_doc_inv_movimiento_detalle_doc_inv_movimiento]
GO
ALTER TABLE [dbo].[doc_inventario_captura]  WITH CHECK ADD  CONSTRAINT [FK_doc_inventario_captura_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_inventario_captura] CHECK CONSTRAINT [FK_doc_inventario_captura_cat_productos]
GO
ALTER TABLE [dbo].[doc_inventario_captura]  WITH CHECK ADD  CONSTRAINT [FK_doc_inventario_captura_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_inventario_captura] CHECK CONSTRAINT [FK_doc_inventario_captura_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_inventario_captura]  WITH CHECK ADD  CONSTRAINT [FK_doc_inventario_captura_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_inventario_captura] CHECK CONSTRAINT [FK_doc_inventario_captura_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_inventario_registro]  WITH CHECK ADD  CONSTRAINT [FK_doc_inventario_registro_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_inventario_registro] CHECK CONSTRAINT [FK_doc_inventario_registro_cat_productos]
GO
ALTER TABLE [dbo].[doc_inventario_registro]  WITH CHECK ADD  CONSTRAINT [FK_doc_inventario_registro_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_inventario_registro] CHECK CONSTRAINT [FK_doc_inventario_registro_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_inventario_registro]  WITH CHECK ADD  CONSTRAINT [FK_doc_inventario_registro_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_inventario_registro] CHECK CONSTRAINT [FK_doc_inventario_registro_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_maiz_maseca_entrada]  WITH CHECK ADD  CONSTRAINT [FK_doc_maiz_maseca_entrada_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_maiz_maseca_entrada] CHECK CONSTRAINT [FK_doc_maiz_maseca_entrada_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_maiz_maseca_entrada]  WITH CHECK ADD  CONSTRAINT [FK_doc_maiz_maseca_entrada_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_maiz_maseca_entrada] CHECK CONSTRAINT [FK_doc_maiz_maseca_entrada_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_maiz_maseca_entrada]  WITH CHECK ADD  CONSTRAINT [FK_doc_maiz_maseca_entrada_cat_usuarios1] FOREIGN KEY([ModificadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_maiz_maseca_entrada] CHECK CONSTRAINT [FK_doc_maiz_maseca_entrada_cat_usuarios1]
GO
ALTER TABLE [dbo].[doc_maiz_maseca_rendimiento]  WITH CHECK ADD  CONSTRAINT [FK_doc_maiz_maseca_rendimiento_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_maiz_maseca_rendimiento] CHECK CONSTRAINT [FK_doc_maiz_maseca_rendimiento_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_maiz_maseca_rendimiento]  WITH CHECK ADD  CONSTRAINT [FK_doc_maiz_maseca_rendimiento_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_maiz_maseca_rendimiento] CHECK CONSTRAINT [FK_doc_maiz_maseca_rendimiento_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_maiz_maseca_rendimiento]  WITH CHECK ADD  CONSTRAINT [FK_doc_maiz_maseca_rendimiento_cat_usuarios1] FOREIGN KEY([ModificadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_maiz_maseca_rendimiento] CHECK CONSTRAINT [FK_doc_maiz_maseca_rendimiento_cat_usuarios1]
GO
ALTER TABLE [dbo].[doc_pagos]  WITH CHECK ADD  CONSTRAINT [FK_doc_pagos_cat_clientes] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[doc_pagos] CHECK CONSTRAINT [FK_doc_pagos_cat_clientes]
GO
ALTER TABLE [dbo].[doc_pagos]  WITH CHECK ADD  CONSTRAINT [FK_doc_pagos_cat_formas_pago] FOREIGN KEY([FormaPagoId])
REFERENCES [dbo].[cat_formas_pago] ([FormaPagoId])
GO
ALTER TABLE [dbo].[doc_pagos] CHECK CONSTRAINT [FK_doc_pagos_cat_formas_pago]
GO
ALTER TABLE [dbo].[doc_pagos]  WITH CHECK ADD  CONSTRAINT [FK_doc_pagos_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_pagos] CHECK CONSTRAINT [FK_doc_pagos_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_pagos]  WITH CHECK ADD  CONSTRAINT [FK_doc_pagos_doc_cargos] FOREIGN KEY([CargoId])
REFERENCES [dbo].[doc_cargos] ([CargoId])
GO
ALTER TABLE [dbo].[doc_pagos] CHECK CONSTRAINT [FK_doc_pagos_doc_cargos]
GO
ALTER TABLE [dbo].[doc_pagos_cancelaciones]  WITH CHECK ADD  CONSTRAINT [FK_doc_pagos_cancelaciones_cat_usuarios] FOREIGN KEY([CanceladoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_pagos_cancelaciones] CHECK CONSTRAINT [FK_doc_pagos_cancelaciones_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_pedidos]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_cat_clientes] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[doc_pedidos] CHECK CONSTRAINT [FK_doc_pedidos_cat_clientes]
GO
ALTER TABLE [dbo].[doc_pedidos]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_cat_municipios] FOREIGN KEY([CiudadId])
REFERENCES [dbo].[cat_municipios] ([MunicipioId])
GO
ALTER TABLE [dbo].[doc_pedidos] CHECK CONSTRAINT [FK_doc_pedidos_cat_municipios]
GO
ALTER TABLE [dbo].[doc_pedidos]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_pedidos] CHECK CONSTRAINT [FK_doc_pedidos_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_pedidos]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_pedidos] CHECK CONSTRAINT [FK_doc_pedidos_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_pedidos]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_doc_pedidos_configuracion] FOREIGN KEY([PedidoConfiguracionId])
REFERENCES [dbo].[doc_pedidos_configuracion] ([PedidoConfiguracionId])
GO
ALTER TABLE [dbo].[doc_pedidos] CHECK CONSTRAINT [FK_doc_pedidos_doc_pedidos_configuracion]
GO
ALTER TABLE [dbo].[doc_pedidos_cargos]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_cargos_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_pedidos_cargos] CHECK CONSTRAINT [FK_doc_pedidos_cargos_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_pedidos_cargos]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_cargos_doc_cargos] FOREIGN KEY([CargoId])
REFERENCES [dbo].[doc_cargos] ([CargoId])
GO
ALTER TABLE [dbo].[doc_pedidos_cargos] CHECK CONSTRAINT [FK_doc_pedidos_cargos_doc_cargos]
GO
ALTER TABLE [dbo].[doc_pedidos_cargos]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_cargos_doc_pedidos_orden] FOREIGN KEY([PedidoId])
REFERENCES [dbo].[doc_pedidos_orden] ([PedidoId])
GO
ALTER TABLE [dbo].[doc_pedidos_cargos] CHECK CONSTRAINT [FK_doc_pedidos_cargos_doc_pedidos_orden]
GO
ALTER TABLE [dbo].[doc_pedidos_clientes]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_clientes_cat_clientes] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[doc_pedidos_clientes] CHECK CONSTRAINT [FK_doc_pedidos_clientes_cat_clientes]
GO
ALTER TABLE [dbo].[doc_pedidos_clientes]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_clientes_cat_clientes_direcciones] FOREIGN KEY([ClienteDireccionId])
REFERENCES [dbo].[cat_clientes_direcciones] ([ClienteDireccionId])
GO
ALTER TABLE [dbo].[doc_pedidos_clientes] CHECK CONSTRAINT [FK_doc_pedidos_clientes_cat_clientes_direcciones]
GO
ALTER TABLE [dbo].[doc_pedidos_clientes]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_clientes_cat_estatus_pedido] FOREIGN KEY([EstatusId])
REFERENCES [dbo].[cat_estatus_pedido] ([EstatusPedidoId])
GO
ALTER TABLE [dbo].[doc_pedidos_clientes] CHECK CONSTRAINT [FK_doc_pedidos_clientes_cat_estatus_pedido]
GO
ALTER TABLE [dbo].[doc_pedidos_clientes]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_clientes_cat_sitios_entrega_pedido] FOREIGN KEY([SitioEntregaId])
REFERENCES [dbo].[cat_sitios_entrega_pedido] ([SitioEntregaPedidoId])
GO
ALTER TABLE [dbo].[doc_pedidos_clientes] CHECK CONSTRAINT [FK_doc_pedidos_clientes_cat_sitios_entrega_pedido]
GO
ALTER TABLE [dbo].[doc_pedidos_clientes]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_clientes_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_pedidos_clientes] CHECK CONSTRAINT [FK_doc_pedidos_clientes_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_pedidos_clientes]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_clientes_doc_pedidos_configuracion] FOREIGN KEY([PedidoConfiguracionId])
REFERENCES [dbo].[doc_pedidos_configuracion] ([PedidoConfiguracionId])
GO
ALTER TABLE [dbo].[doc_pedidos_clientes] CHECK CONSTRAINT [FK_doc_pedidos_clientes_doc_pedidos_configuracion]
GO
ALTER TABLE [dbo].[doc_pedidos_clientes_det]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_clientes_det_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_pedidos_clientes_det] CHECK CONSTRAINT [FK_doc_pedidos_clientes_det_cat_productos]
GO
ALTER TABLE [dbo].[doc_pedidos_clientes_det]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_clientes_det_doc_pedidos_clientes] FOREIGN KEY([PedidoClienteDetId])
REFERENCES [dbo].[doc_pedidos_clientes] ([PedidoClienteId])
GO
ALTER TABLE [dbo].[doc_pedidos_clientes_det] CHECK CONSTRAINT [FK_doc_pedidos_clientes_det_doc_pedidos_clientes]
GO
ALTER TABLE [dbo].[doc_pedidos_configuracion]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_configuracion_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_pedidos_configuracion] CHECK CONSTRAINT [FK_doc_pedidos_configuracion_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_pedidos_configuracion]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_configuracion_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_pedidos_configuracion] CHECK CONSTRAINT [FK_doc_pedidos_configuracion_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_pedidos_configuracion]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_configuracion_cat_usuarios1] FOREIGN KEY([ModificadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_pedidos_configuracion] CHECK CONSTRAINT [FK_doc_pedidos_configuracion_cat_usuarios1]
GO
ALTER TABLE [dbo].[doc_pedidos_configuracion_det]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_configuracion_det_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_pedidos_configuracion_det] CHECK CONSTRAINT [FK_doc_pedidos_configuracion_det_cat_productos]
GO
ALTER TABLE [dbo].[doc_pedidos_configuracion_det]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_configuracion_det_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_pedidos_configuracion_det] CHECK CONSTRAINT [FK_doc_pedidos_configuracion_det_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_pedidos_configuracion_det]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_configuracion_det_doc_pedidos_configuracion] FOREIGN KEY([PedidoConfiguracionId])
REFERENCES [dbo].[doc_pedidos_configuracion] ([PedidoConfiguracionId])
GO
ALTER TABLE [dbo].[doc_pedidos_configuracion_det] CHECK CONSTRAINT [FK_doc_pedidos_configuracion_det_doc_pedidos_configuracion]
GO
ALTER TABLE [dbo].[doc_pedidos_orden]  WITH CHECK ADD FOREIGN KEY([SucursalCobroId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_pedidos_orden]  WITH CHECK ADD  CONSTRAINT [FK_cat_rest_comandas_orden_cat_clientes] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden] CHECK CONSTRAINT [FK_cat_rest_comandas_orden_cat_clientes]
GO
ALTER TABLE [dbo].[doc_pedidos_orden]  WITH CHECK ADD  CONSTRAINT [FK_cat_rest_comandas_orden_cat_rest_comandas] FOREIGN KEY([ComandaId])
REFERENCES [dbo].[cat_rest_comandas] ([ComandaId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden] CHECK CONSTRAINT [FK_cat_rest_comandas_orden_cat_rest_comandas]
GO
ALTER TABLE [dbo].[doc_pedidos_orden]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_cat_cajas] FOREIGN KEY([CajaId])
REFERENCES [dbo].[cat_cajas] ([Clave])
GO
ALTER TABLE [dbo].[doc_pedidos_orden] CHECK CONSTRAINT [FK_doc_pedidos_orden_cat_cajas]
GO
ALTER TABLE [dbo].[doc_pedidos_orden]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_pedidos_orden] CHECK CONSTRAINT [FK_doc_pedidos_orden_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_pedidos_orden]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_cat_tipos_pedido] FOREIGN KEY([TipoPedidoId])
REFERENCES [dbo].[cat_tipos_pedido] ([TipoPedidoId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden] CHECK CONSTRAINT [FK_doc_pedidos_orden_cat_tipos_pedido]
GO
ALTER TABLE [dbo].[doc_pedidos_orden]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_pedidos_orden] CHECK CONSTRAINT [FK_doc_pedidos_orden_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_pedidos_orden]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_doc_cargos] FOREIGN KEY([CargoId])
REFERENCES [dbo].[doc_cargos] ([CargoId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden] CHECK CONSTRAINT [FK_doc_pedidos_orden_doc_cargos]
GO
ALTER TABLE [dbo].[doc_pedidos_orden]  WITH CHECK ADD  CONSTRAINT [FK_Pedidos_Ventas] FOREIGN KEY([VentaId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden] CHECK CONSTRAINT [FK_Pedidos_Ventas]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_adicional]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_adicional_cat_rest_platillo_adicionales] FOREIGN KEY([AdicionalId])
REFERENCES [dbo].[cat_rest_platillo_adicionales] ([Id])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_adicional] CHECK CONSTRAINT [FK_doc_pedidos_orden_adicional_cat_rest_platillo_adicionales]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_adicional]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_adicional_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_adicional] CHECK CONSTRAINT [FK_doc_pedidos_orden_adicional_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_adicional]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_adicional_doc_pedidos_orden_detalle] FOREIGN KEY([PedidoDetalleId])
REFERENCES [dbo].[doc_pedidos_orden_detalle] ([PedidoDetalleId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_adicional] CHECK CONSTRAINT [FK_doc_pedidos_orden_adicional_doc_pedidos_orden_detalle]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_cargos]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_cargos_cat_cargos_adicionales] FOREIGN KEY([CargoAdicionalId])
REFERENCES [dbo].[cat_cargos_adicionales] ([CargoAdicionalId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_cargos] CHECK CONSTRAINT [FK_doc_pedidos_orden_cargos_cat_cargos_adicionales]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_cargos]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_cargos_doc_pedidos_orden] FOREIGN KEY([PedidoId])
REFERENCES [dbo].[doc_pedidos_orden] ([PedidoId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_cargos] CHECK CONSTRAINT [FK_doc_pedidos_orden_cargos_doc_pedidos_orden]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_detalle]  WITH CHECK ADD FOREIGN KEY([PromocionCMId])
REFERENCES [dbo].[doc_promociones_cm] ([PromocionCMId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_detalle_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_detalle] CHECK CONSTRAINT [FK_doc_pedidos_orden_detalle_cat_productos]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_detalle_cat_rest_comandas] FOREIGN KEY([ComandaId])
REFERENCES [dbo].[cat_rest_comandas] ([ComandaId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_detalle] CHECK CONSTRAINT [FK_doc_pedidos_orden_detalle_cat_rest_comandas]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_detalle_doc_pedidos_orden] FOREIGN KEY([PedidoId])
REFERENCES [dbo].[doc_pedidos_orden] ([PedidoId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_detalle] CHECK CONSTRAINT [FK_doc_pedidos_orden_detalle_doc_pedidos_orden]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_detalle]  WITH CHECK ADD  CONSTRAINT [FK_pedidos_orden_detalle_Tipo_Descuento] FOREIGN KEY([TipoDescuentoId])
REFERENCES [dbo].[cat_tipos_descuento] ([TipoDescuentoId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_detalle] CHECK CONSTRAINT [FK_pedidos_orden_detalle_Tipo_Descuento]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_detalle_impresion]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_detalle_impresion_doc_pedidos_orden_detalle] FOREIGN KEY([PedidoDetalleId])
REFERENCES [dbo].[doc_pedidos_orden_detalle] ([PedidoDetalleId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_detalle_impresion] CHECK CONSTRAINT [FK_doc_pedidos_orden_detalle_impresion_doc_pedidos_orden_detalle]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_ingre]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_ingre_cat_productos_base] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_ingre] CHECK CONSTRAINT [FK_doc_pedidos_orden_ingre_cat_productos_base]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_ingre]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_ingre_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_ingre] CHECK CONSTRAINT [FK_doc_pedidos_orden_ingre_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_ingre]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_ingre_doc_pedidos_orden_detalle] FOREIGN KEY([PedidoDetalleId])
REFERENCES [dbo].[doc_pedidos_orden_detalle] ([PedidoDetalleId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_ingre] CHECK CONSTRAINT [FK_doc_pedidos_orden_ingre_doc_pedidos_orden_detalle]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_mesa]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_mesa_cat_rest_mesas] FOREIGN KEY([MesaId])
REFERENCES [dbo].[cat_rest_mesas] ([MesaId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_mesa] CHECK CONSTRAINT [FK_doc_pedidos_orden_mesa_cat_rest_mesas]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_mesa]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_mesa_doc_pedidos_orden] FOREIGN KEY([PedidoOrdenId])
REFERENCES [dbo].[doc_pedidos_orden] ([PedidoId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_mesa] CHECK CONSTRAINT [FK_doc_pedidos_orden_mesa_doc_pedidos_orden]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_mesero]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_mesero_doc_pedidos_orden] FOREIGN KEY([PedidoOrdenId])
REFERENCES [dbo].[doc_pedidos_orden] ([PedidoId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_mesero] CHECK CONSTRAINT [FK_doc_pedidos_orden_mesero_doc_pedidos_orden]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_mesero]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_mesero_rh_empleados] FOREIGN KEY([EmpleadoId])
REFERENCES [dbo].[rh_empleados] ([NumEmpleado])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_mesero] CHECK CONSTRAINT [FK_doc_pedidos_orden_mesero_rh_empleados]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_programacion]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_programacion_cat_clientes] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_programacion] CHECK CONSTRAINT [FK_doc_pedidos_orden_programacion_cat_clientes]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_programacion]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_programacion_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_programacion] CHECK CONSTRAINT [FK_doc_pedidos_orden_programacion_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_programacion]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_programacion_doc_pedidos_orden] FOREIGN KEY([PedidoId])
REFERENCES [dbo].[doc_pedidos_orden] ([PedidoId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_programacion] CHECK CONSTRAINT [FK_doc_pedidos_orden_programacion_doc_pedidos_orden]
GO
ALTER TABLE [dbo].[doc_pedidos_proveedor]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_proveedor_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_pedidos_proveedor] CHECK CONSTRAINT [FK_doc_pedidos_proveedor_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_pedidos_proveedor]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_proveedor_cat_sucursales1] FOREIGN KEY([SucursalProveedorId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_pedidos_proveedor] CHECK CONSTRAINT [FK_doc_pedidos_proveedor_cat_sucursales1]
GO
ALTER TABLE [dbo].[doc_pedidos_proveedor]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_proveedor_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_pedidos_proveedor] CHECK CONSTRAINT [FK_doc_pedidos_proveedor_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_pedidos_proveedor]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_proveedor_estatus_pedido] FOREIGN KEY([EstatusPedidoId])
REFERENCES [dbo].[cat_estatus_pedido] ([EstatusPedidoId])
GO
ALTER TABLE [dbo].[doc_pedidos_proveedor] CHECK CONSTRAINT [FK_doc_pedidos_proveedor_estatus_pedido]
GO
ALTER TABLE [dbo].[doc_pedidos_proveedor_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_proveedor_detalle_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_pedidos_proveedor_detalle] CHECK CONSTRAINT [FK_doc_pedidos_proveedor_detalle_cat_productos]
GO
ALTER TABLE [dbo].[doc_pedidos_proveedor_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_proveedor_detalle_doc_pedidos_proveedor] FOREIGN KEY([PedidoProveedorId])
REFERENCES [dbo].[doc_pedidos_proveedor] ([Id])
GO
ALTER TABLE [dbo].[doc_pedidos_proveedor_detalle] CHECK CONSTRAINT [FK_doc_pedidos_proveedor_detalle_doc_pedidos_proveedor]
GO
ALTER TABLE [dbo].[doc_precios_especiales]  WITH CHECK ADD  CONSTRAINT [FK_doc_precios_especiales_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_precios_especiales] CHECK CONSTRAINT [FK_doc_precios_especiales_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_precios_especiales_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_precios_especiales_detalle_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_precios_especiales_detalle] CHECK CONSTRAINT [FK_doc_precios_especiales_detalle_cat_productos]
GO
ALTER TABLE [dbo].[doc_precios_especiales_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_precios_especiales_detalle_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_precios_especiales_detalle] CHECK CONSTRAINT [FK_doc_precios_especiales_detalle_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_precios_especiales_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_precios_especiales_detalle_cat_usuarios1] FOREIGN KEY([ModificadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_precios_especiales_detalle] CHECK CONSTRAINT [FK_doc_precios_especiales_detalle_cat_usuarios1]
GO
ALTER TABLE [dbo].[doc_precios_especiales_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_precios_especiales_detalle_doc_precios_especiales] FOREIGN KEY([PrecioEspeciaId])
REFERENCES [dbo].[doc_precios_especiales] ([Id])
GO
ALTER TABLE [dbo].[doc_precios_especiales_detalle] CHECK CONSTRAINT [FK_doc_precios_especiales_detalle_doc_precios_especiales]
GO
ALTER TABLE [dbo].[doc_produccion]  WITH CHECK ADD FOREIGN KEY([EstatusProduccionId])
REFERENCES [dbo].[cat_estatus_produccion] ([EstatusProduccionId])
GO
ALTER TABLE [dbo].[doc_produccion]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_produccion] CHECK CONSTRAINT [FK_doc_produccion_cat_productos]
GO
ALTER TABLE [dbo].[doc_produccion]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_produccion] CHECK CONSTRAINT [FK_doc_produccion_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_produccion]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_produccion] CHECK CONSTRAINT [FK_doc_produccion_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_produccion]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_doc_produccion_solicitud] FOREIGN KEY([ProduccionSolicitudId])
REFERENCES [dbo].[doc_produccion_solicitud] ([ProduccionSolicitudId])
GO
ALTER TABLE [dbo].[doc_produccion] CHECK CONSTRAINT [FK_doc_produccion_doc_produccion_solicitud]
GO
ALTER TABLE [dbo].[doc_produccion_conceptos]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_conceptos_cat_conceptos] FOREIGN KEY([ConceptoId])
REFERENCES [dbo].[cat_conceptos] ([ConceptoId])
GO
ALTER TABLE [dbo].[doc_produccion_conceptos] CHECK CONSTRAINT [FK_doc_produccion_conceptos_cat_conceptos]
GO
ALTER TABLE [dbo].[doc_produccion_conceptos]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_conceptos_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_produccion_conceptos] CHECK CONSTRAINT [FK_doc_produccion_conceptos_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_produccion_conceptos]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_conceptos_cat_usuarios1] FOREIGN KEY([ModificadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_produccion_conceptos] CHECK CONSTRAINT [FK_doc_produccion_conceptos_cat_usuarios1]
GO
ALTER TABLE [dbo].[doc_produccion_conceptos]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_conceptos_doc_produccion] FOREIGN KEY([ProduccionId])
REFERENCES [dbo].[doc_produccion] ([ProduccionId])
GO
ALTER TABLE [dbo].[doc_produccion_conceptos] CHECK CONSTRAINT [FK_doc_produccion_conceptos_doc_produccion]
GO
ALTER TABLE [dbo].[doc_produccion_entrada]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_entrada_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_produccion_entrada] CHECK CONSTRAINT [FK_doc_produccion_entrada_cat_productos]
GO
ALTER TABLE [dbo].[doc_produccion_entrada]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_entrada_cat_unidadesmed] FOREIGN KEY([UnidadId])
REFERENCES [dbo].[cat_unidadesmed] ([Clave])
GO
ALTER TABLE [dbo].[doc_produccion_entrada] CHECK CONSTRAINT [FK_doc_produccion_entrada_cat_unidadesmed]
GO
ALTER TABLE [dbo].[doc_produccion_entrada]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_entrada_doc_produccion] FOREIGN KEY([ProduccionId])
REFERENCES [dbo].[doc_produccion] ([ProduccionId])
GO
ALTER TABLE [dbo].[doc_produccion_entrada] CHECK CONSTRAINT [FK_doc_produccion_entrada_doc_produccion]
GO
ALTER TABLE [dbo].[doc_produccion_finalizada]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_finalizada_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_produccion_finalizada] CHECK CONSTRAINT [FK_doc_produccion_finalizada_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_produccion_movs_inventario]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_movs_inventario_doc_inv_movimiento] FOREIGN KEY([MovimientoInventarioId])
REFERENCES [dbo].[doc_inv_movimiento] ([MovimientoId])
GO
ALTER TABLE [dbo].[doc_produccion_movs_inventario] CHECK CONSTRAINT [FK_doc_produccion_movs_inventario_doc_inv_movimiento]
GO
ALTER TABLE [dbo].[doc_produccion_movs_inventario]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_movs_inventario_doc_produccion] FOREIGN KEY([ProduccionId])
REFERENCES [dbo].[doc_produccion] ([ProduccionId])
GO
ALTER TABLE [dbo].[doc_produccion_movs_inventario] CHECK CONSTRAINT [FK_doc_produccion_movs_inventario_doc_produccion]
GO
ALTER TABLE [dbo].[doc_produccion_salida]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_salida_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_produccion_salida] CHECK CONSTRAINT [FK_doc_produccion_salida_cat_productos]
GO
ALTER TABLE [dbo].[doc_produccion_salida]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_salida_cat_unidadesmed] FOREIGN KEY([UnidadId])
REFERENCES [dbo].[cat_unidadesmed] ([Clave])
GO
ALTER TABLE [dbo].[doc_produccion_salida] CHECK CONSTRAINT [FK_doc_produccion_salida_cat_unidadesmed]
GO
ALTER TABLE [dbo].[doc_produccion_salida]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_salida_doc_produccion] FOREIGN KEY([ProduccionId])
REFERENCES [dbo].[doc_produccion] ([ProduccionId])
GO
ALTER TABLE [dbo].[doc_produccion_salida] CHECK CONSTRAINT [FK_doc_produccion_salida_doc_produccion]
GO
ALTER TABLE [dbo].[doc_produccion_solicitud]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_solicitud_cat_departamentos] FOREIGN KEY([DepartamentoId])
REFERENCES [dbo].[cat_departamentos] ([DepartamentoId])
GO
ALTER TABLE [dbo].[doc_produccion_solicitud] CHECK CONSTRAINT [FK_doc_produccion_solicitud_cat_departamentos]
GO
ALTER TABLE [dbo].[doc_produccion_solicitud]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_solicitud_cat_sucursales] FOREIGN KEY([DeSucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_produccion_solicitud] CHECK CONSTRAINT [FK_doc_produccion_solicitud_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_produccion_solicitud]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_solicitud_cat_sucursales1] FOREIGN KEY([ParaSucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_produccion_solicitud] CHECK CONSTRAINT [FK_doc_produccion_solicitud_cat_sucursales1]
GO
ALTER TABLE [dbo].[doc_produccion_solicitud]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_solicitud_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_produccion_solicitud] CHECK CONSTRAINT [FK_doc_produccion_solicitud_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_produccion_solicitud]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_solicitud_doc_produccion] FOREIGN KEY([ProduccionId])
REFERENCES [dbo].[doc_produccion] ([ProduccionId])
GO
ALTER TABLE [dbo].[doc_produccion_solicitud] CHECK CONSTRAINT [FK_doc_produccion_solicitud_doc_produccion]
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_aceptacion]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_solicitud_aceptacion_cat_unidadesmed] FOREIGN KEY([UnidadId])
REFERENCES [dbo].[cat_unidadesmed] ([Clave])
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_aceptacion] CHECK CONSTRAINT [FK_doc_produccion_solicitud_aceptacion_cat_unidadesmed]
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_aceptacion]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_solicitud_aceptacion_cat_usuarios] FOREIGN KEY([AceptadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_aceptacion] CHECK CONSTRAINT [FK_doc_produccion_solicitud_aceptacion_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_aceptacion]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_solicitud_aceptacion_doc_produccion_solicitud_detalle] FOREIGN KEY([ProduccionSolicitudDetalleId])
REFERENCES [dbo].[doc_produccion_solicitud_detalle] ([Id])
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_aceptacion] CHECK CONSTRAINT [FK_doc_produccion_solicitud_aceptacion_doc_produccion_solicitud_detalle]
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_ajuste_unidad]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_solicitud_ajuste_unidad_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_ajuste_unidad] CHECK CONSTRAINT [FK_doc_produccion_solicitud_ajuste_unidad_cat_productos]
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_ajuste_unidad]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_solicitud_ajuste_unidad_cat_unidadesmed] FOREIGN KEY([UnidadId])
REFERENCES [dbo].[cat_unidadesmed] ([Clave])
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_ajuste_unidad] CHECK CONSTRAINT [FK_doc_produccion_solicitud_ajuste_unidad_cat_unidadesmed]
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_ajuste_unidad]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_solicitud_ajuste_unidad_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_ajuste_unidad] CHECK CONSTRAINT [FK_doc_produccion_solicitud_ajuste_unidad_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_ajuste_unidad]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_solicitud_ajuste_unidad_doc_produccion_solicitud_detalle] FOREIGN KEY([ProduccionSolicitudDetalleId])
REFERENCES [dbo].[doc_produccion_solicitud_detalle] ([Id])
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_ajuste_unidad] CHECK CONSTRAINT [FK_doc_produccion_solicitud_ajuste_unidad_doc_produccion_solicitud_detalle]
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_solicitud_detalle_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_detalle] CHECK CONSTRAINT [FK_doc_produccion_solicitud_detalle_cat_productos]
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_solicitud_detalle_cat_unidadesmed] FOREIGN KEY([UnidadId])
REFERENCES [dbo].[cat_unidadesmed] ([Clave])
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_detalle] CHECK CONSTRAINT [FK_doc_produccion_solicitud_detalle_cat_unidadesmed]
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_solicitud_detalle_doc_produccion_solicitud] FOREIGN KEY([ProduccionSolicitudId])
REFERENCES [dbo].[doc_produccion_solicitud] ([ProduccionSolicitudId])
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_detalle] CHECK CONSTRAINT [FK_doc_produccion_solicitud_detalle_doc_produccion_solicitud]
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_requerido]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_solicitud_requerido_cat_productos] FOREIGN KEY([ProductoRequeridoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_requerido] CHECK CONSTRAINT [FK_doc_produccion_solicitud_requerido_cat_productos]
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_requerido]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_solicitud_requerido_cat_unidadesmed] FOREIGN KEY([UnidadRequeridaId])
REFERENCES [dbo].[cat_unidadesmed] ([Clave])
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_requerido] CHECK CONSTRAINT [FK_doc_produccion_solicitud_requerido_cat_unidadesmed]
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_requerido]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_solicitud_requerido_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_requerido] CHECK CONSTRAINT [FK_doc_produccion_solicitud_requerido_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_requerido]  WITH CHECK ADD  CONSTRAINT [FK_doc_produccion_solicitud_requerido_doc_produccion_solicitud_detalle] FOREIGN KEY([ProduccionSolicitudDetalleId])
REFERENCES [dbo].[doc_produccion_solicitud_detalle] ([Id])
GO
ALTER TABLE [dbo].[doc_produccion_solicitud_requerido] CHECK CONSTRAINT [FK_doc_produccion_solicitud_requerido_doc_produccion_solicitud_detalle]
GO
ALTER TABLE [dbo].[doc_productos_compra]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_compra_cat_proveedores] FOREIGN KEY([ProveedorId])
REFERENCES [dbo].[cat_proveedores] ([ProveedorId])
GO
ALTER TABLE [dbo].[doc_productos_compra] CHECK CONSTRAINT [FK_doc_productos_compra_cat_proveedores]
GO
ALTER TABLE [dbo].[doc_productos_compra]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_compra_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_productos_compra] CHECK CONSTRAINT [FK_doc_productos_compra_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_productos_compra]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_compra_cat_usuarios1] FOREIGN KEY([ModificadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_productos_compra] CHECK CONSTRAINT [FK_doc_productos_compra_cat_usuarios1]
GO
ALTER TABLE [dbo].[doc_productos_compra]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_compra_cat_usuarios2] FOREIGN KEY([CanceladoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_productos_compra] CHECK CONSTRAINT [FK_doc_productos_compra_cat_usuarios2]
GO
ALTER TABLE [dbo].[doc_productos_compra]  WITH CHECK ADD  CONSTRAINT [FK_Productos_Compra_Suursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_productos_compra] CHECK CONSTRAINT [FK_Productos_Compra_Suursales]
GO
ALTER TABLE [dbo].[doc_productos_compra_cargos]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_compra_cargos_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_productos_compra_cargos] CHECK CONSTRAINT [FK_doc_productos_compra_cargos_cat_productos]
GO
ALTER TABLE [dbo].[doc_productos_compra_cargos]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_compra_cargos_doc_productos_compra] FOREIGN KEY([ProductoCompraId])
REFERENCES [dbo].[doc_productos_compra] ([ProductoCompraId])
GO
ALTER TABLE [dbo].[doc_productos_compra_cargos] CHECK CONSTRAINT [FK_doc_productos_compra_cargos_doc_productos_compra]
GO
ALTER TABLE [dbo].[doc_productos_compra_cargos]  WITH CHECK ADD  CONSTRAINT [FK_Productos_compra_cargos_proveedores] FOREIGN KEY([ProveedorId])
REFERENCES [dbo].[cat_proveedores] ([ProveedorId])
GO
ALTER TABLE [dbo].[doc_productos_compra_cargos] CHECK CONSTRAINT [FK_Productos_compra_cargos_proveedores]
GO
ALTER TABLE [dbo].[doc_productos_compra_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_compra_detalle_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_productos_compra_detalle] CHECK CONSTRAINT [FK_doc_productos_compra_detalle_cat_productos]
GO
ALTER TABLE [dbo].[doc_productos_compra_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_compra_detalle_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_productos_compra_detalle] CHECK CONSTRAINT [FK_doc_productos_compra_detalle_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_productos_compra_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_compra_detalle_doc_productos_compra] FOREIGN KEY([ProductoCompraId])
REFERENCES [dbo].[doc_productos_compra] ([ProductoCompraId])
GO
ALTER TABLE [dbo].[doc_productos_compra_detalle] CHECK CONSTRAINT [FK_doc_productos_compra_detalle_doc_productos_compra]
GO
ALTER TABLE [dbo].[doc_productos_existencias_diario]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_existencias_diario_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_productos_existencias_diario] CHECK CONSTRAINT [FK_doc_productos_existencias_diario_cat_productos]
GO
ALTER TABLE [dbo].[doc_productos_existencias_diario]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_existencias_diario_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_productos_existencias_diario] CHECK CONSTRAINT [FK_doc_productos_existencias_diario_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_productos_existencias_diario]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_existencias_diario_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_productos_existencias_diario] CHECK CONSTRAINT [FK_doc_productos_existencias_diario_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_productos_importacion_bitacora]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_importacion_bitacora_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_productos_importacion_bitacora] CHECK CONSTRAINT [FK_doc_productos_importacion_bitacora_cat_productos]
GO
ALTER TABLE [dbo].[doc_productos_importacion_bitacora]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_importacion_bitacora_cat_tipos_movimiento_inventario] FOREIGN KEY([TipoMovimientoInventarioId])
REFERENCES [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId])
GO
ALTER TABLE [dbo].[doc_productos_importacion_bitacora] CHECK CONSTRAINT [FK_doc_productos_importacion_bitacora_cat_tipos_movimiento_inventario]
GO
ALTER TABLE [dbo].[doc_productos_importacion_bitacora]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_importacion_bitacora_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_productos_importacion_bitacora] CHECK CONSTRAINT [FK_doc_productos_importacion_bitacora_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_productos_max_min]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_max_min_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_productos_max_min] CHECK CONSTRAINT [FK_doc_productos_max_min_cat_productos]
GO
ALTER TABLE [dbo].[doc_productos_max_min]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_max_min_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_productos_max_min] CHECK CONSTRAINT [FK_doc_productos_max_min_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_productos_minimo]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_minimo_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_productos_minimo] CHECK CONSTRAINT [FK_doc_productos_minimo_cat_productos]
GO
ALTER TABLE [dbo].[doc_productos_minimo]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_minimo_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_productos_minimo] CHECK CONSTRAINT [FK_doc_productos_minimo_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_productos_sobrantes_config]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_sobrantes_config_cat_productos] FOREIGN KEY([ProductoConvertirId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_productos_sobrantes_config] CHECK CONSTRAINT [FK_doc_productos_sobrantes_config_cat_productos]
GO
ALTER TABLE [dbo].[doc_productos_sobrantes_config]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_sobrantes_config_cat_productos1] FOREIGN KEY([ProductoSobranteId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_productos_sobrantes_config] CHECK CONSTRAINT [FK_doc_productos_sobrantes_config_cat_productos1]
GO
ALTER TABLE [dbo].[doc_productos_sobrantes_config]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_sobrantes_config_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_productos_sobrantes_config] CHECK CONSTRAINT [FK_doc_productos_sobrantes_config_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_productos_sobrantes_registro]  WITH CHECK ADD FOREIGN KEY([CerradoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_productos_sobrantes_registro]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_sobrantes_registro_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_productos_sobrantes_registro] CHECK CONSTRAINT [FK_doc_productos_sobrantes_registro_cat_productos]
GO
ALTER TABLE [dbo].[doc_productos_sobrantes_registro]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_sobrantes_registro_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_productos_sobrantes_registro] CHECK CONSTRAINT [FK_doc_productos_sobrantes_registro_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_productos_sobrantes_registro]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_sobrantes_registro_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_productos_sobrantes_registro] CHECK CONSTRAINT [FK_doc_productos_sobrantes_registro_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_productos_sobrantes_regitro_inventario]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_sobrantes_regitro_inventario_doc_inv_movimiento_detalle] FOREIGN KEY([MovimientoDetalleId])
REFERENCES [dbo].[doc_inv_movimiento_detalle] ([MovimientoDetalleId])
GO
ALTER TABLE [dbo].[doc_productos_sobrantes_regitro_inventario] CHECK CONSTRAINT [FK_doc_productos_sobrantes_regitro_inventario_doc_inv_movimiento_detalle]
GO
ALTER TABLE [dbo].[doc_productos_sobrantes_regitro_inventario]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_sobrantes_regitro_inventario_doc_productos_sobrantes_registro] FOREIGN KEY([SobranteRegsitroId])
REFERENCES [dbo].[doc_productos_sobrantes_registro] ([Id])
GO
ALTER TABLE [dbo].[doc_productos_sobrantes_regitro_inventario] CHECK CONSTRAINT [FK_doc_productos_sobrantes_regitro_inventario_doc_productos_sobrantes_registro]
GO
ALTER TABLE [dbo].[doc_promociones]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_cat_empresas] FOREIGN KEY([EmpresaId])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[doc_promociones] CHECK CONSTRAINT [FK_doc_promociones_cat_empresas]
GO
ALTER TABLE [dbo].[doc_promociones]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_promociones] CHECK CONSTRAINT [FK_doc_promociones_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_promociones]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_promociones] CHECK CONSTRAINT [FK_doc_promociones_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_promociones_cm]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_cm_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_promociones_cm] CHECK CONSTRAINT [FK_doc_promociones_cm_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_promociones_cm]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_cm_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_promociones_cm] CHECK CONSTRAINT [FK_doc_promociones_cm_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_promociones_cm_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_cm_detalle_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_promociones_cm_detalle] CHECK CONSTRAINT [FK_doc_promociones_cm_detalle_cat_productos]
GO
ALTER TABLE [dbo].[doc_promociones_cm_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_cm_detalle_doc_promociones_cm] FOREIGN KEY([PromocionCMId])
REFERENCES [dbo].[doc_promociones_cm] ([PromocionCMId])
GO
ALTER TABLE [dbo].[doc_promociones_cm_detalle] CHECK CONSTRAINT [FK_doc_promociones_cm_detalle_doc_promociones_cm]
GO
ALTER TABLE [dbo].[doc_promociones_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_detalle_cat_familias] FOREIGN KEY([FamiliaId])
REFERENCES [dbo].[cat_familias] ([Clave])
GO
ALTER TABLE [dbo].[doc_promociones_detalle] CHECK CONSTRAINT [FK_doc_promociones_detalle_cat_familias]
GO
ALTER TABLE [dbo].[doc_promociones_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_detalle_cat_lineas] FOREIGN KEY([LineaId])
REFERENCES [dbo].[cat_lineas] ([Clave])
GO
ALTER TABLE [dbo].[doc_promociones_detalle] CHECK CONSTRAINT [FK_doc_promociones_detalle_cat_lineas]
GO
ALTER TABLE [dbo].[doc_promociones_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_detalle_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_promociones_detalle] CHECK CONSTRAINT [FK_doc_promociones_detalle_cat_productos]
GO
ALTER TABLE [dbo].[doc_promociones_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_detalle_cat_subfamilias] FOREIGN KEY([Subfamilia])
REFERENCES [dbo].[cat_subfamilias] ([Clave])
GO
ALTER TABLE [dbo].[doc_promociones_detalle] CHECK CONSTRAINT [FK_doc_promociones_detalle_cat_subfamilias]
GO
ALTER TABLE [dbo].[doc_promociones_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_detalle_doc_promociones] FOREIGN KEY([PromocionId])
REFERENCES [dbo].[doc_promociones] ([PromocionId])
GO
ALTER TABLE [dbo].[doc_promociones_detalle] CHECK CONSTRAINT [FK_doc_promociones_detalle_doc_promociones]
GO
ALTER TABLE [dbo].[doc_promociones_excepcion]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_excepcion_cat_familias] FOREIGN KEY([FamiliaId])
REFERENCES [dbo].[cat_familias] ([Clave])
GO
ALTER TABLE [dbo].[doc_promociones_excepcion] CHECK CONSTRAINT [FK_doc_promociones_excepcion_cat_familias]
GO
ALTER TABLE [dbo].[doc_promociones_excepcion]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_excepcion_cat_lineas] FOREIGN KEY([LineaId])
REFERENCES [dbo].[cat_lineas] ([Clave])
GO
ALTER TABLE [dbo].[doc_promociones_excepcion] CHECK CONSTRAINT [FK_doc_promociones_excepcion_cat_lineas]
GO
ALTER TABLE [dbo].[doc_promociones_excepcion]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_excepcion_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_promociones_excepcion] CHECK CONSTRAINT [FK_doc_promociones_excepcion_cat_productos]
GO
ALTER TABLE [dbo].[doc_promociones_excepcion]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_excepcion_cat_subfamilias] FOREIGN KEY([Subfamilia])
REFERENCES [dbo].[cat_subfamilias] ([Clave])
GO
ALTER TABLE [dbo].[doc_promociones_excepcion] CHECK CONSTRAINT [FK_doc_promociones_excepcion_cat_subfamilias]
GO
ALTER TABLE [dbo].[doc_promociones_excepcion]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_excepcion_doc_promociones] FOREIGN KEY([PromocionId])
REFERENCES [dbo].[doc_promociones] ([PromocionId])
GO
ALTER TABLE [dbo].[doc_promociones_excepcion] CHECK CONSTRAINT [FK_doc_promociones_excepcion_doc_promociones]
GO
ALTER TABLE [dbo].[doc_reimpresion_ticket]  WITH CHECK ADD  CONSTRAINT [FK_doc_reimpresion_ticket_cat_cajas] FOREIGN KEY([CajaId])
REFERENCES [dbo].[cat_cajas] ([Clave])
GO
ALTER TABLE [dbo].[doc_reimpresion_ticket] CHECK CONSTRAINT [FK_doc_reimpresion_ticket_cat_cajas]
GO
ALTER TABLE [dbo].[doc_reimpresion_ticket]  WITH CHECK ADD  CONSTRAINT [FK_doc_reimpresion_ticket_doc_ventas] FOREIGN KEY([VentaId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_reimpresion_ticket] CHECK CONSTRAINT [FK_doc_reimpresion_ticket_doc_ventas]
GO
ALTER TABLE [dbo].[doc_requisiciones]  WITH CHECK ADD  CONSTRAINT [FK_doc_requisiciones_cat_estatus] FOREIGN KEY([EstatusId])
REFERENCES [dbo].[cat_estatus] ([EstatusId])
GO
ALTER TABLE [dbo].[doc_requisiciones] CHECK CONSTRAINT [FK_doc_requisiciones_cat_estatus]
GO
ALTER TABLE [dbo].[doc_requisiciones]  WITH CHECK ADD  CONSTRAINT [FK_doc_requisiciones_cat_proveedores] FOREIGN KEY([ProveedorId])
REFERENCES [dbo].[cat_proveedores] ([ProveedorId])
GO
ALTER TABLE [dbo].[doc_requisiciones] CHECK CONSTRAINT [FK_doc_requisiciones_cat_proveedores]
GO
ALTER TABLE [dbo].[doc_requisiciones]  WITH CHECK ADD  CONSTRAINT [FK_doc_requisiciones_cat_tipos_requisiciones] FOREIGN KEY([TipoRequisicionId])
REFERENCES [dbo].[cat_tipos_requisiciones] ([TipoRequisicionId])
GO
ALTER TABLE [dbo].[doc_requisiciones] CHECK CONSTRAINT [FK_doc_requisiciones_cat_tipos_requisiciones]
GO
ALTER TABLE [dbo].[doc_requisiciones]  WITH CHECK ADD  CONSTRAINT [FK_doc_requisiciones_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_requisiciones] CHECK CONSTRAINT [FK_doc_requisiciones_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_requisiciones]  WITH CHECK ADD  CONSTRAINT [FK_doc_requisiciones_doc_requisiciones] FOREIGN KEY([RequisicionPadreId])
REFERENCES [dbo].[doc_requisiciones] ([RequisicionId])
GO
ALTER TABLE [dbo].[doc_requisiciones] CHECK CONSTRAINT [FK_doc_requisiciones_doc_requisiciones]
GO
ALTER TABLE [dbo].[doc_requisiciones_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_requisiciones_detalle_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_requisiciones_detalle] CHECK CONSTRAINT [FK_doc_requisiciones_detalle_cat_productos]
GO
ALTER TABLE [dbo].[doc_requisiciones_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_requisiciones_detalle_doc_requisiciones] FOREIGN KEY([RequisicionId])
REFERENCES [dbo].[doc_requisiciones] ([RequisicionId])
GO
ALTER TABLE [dbo].[doc_requisiciones_detalle] CHECK CONSTRAINT [FK_doc_requisiciones_detalle_doc_requisiciones]
GO
ALTER TABLE [dbo].[doc_retiros]  WITH CHECK ADD  CONSTRAINT [FK_doc_retiros_cat_cajas] FOREIGN KEY([CajaId])
REFERENCES [dbo].[cat_cajas] ([Clave])
GO
ALTER TABLE [dbo].[doc_retiros] CHECK CONSTRAINT [FK_doc_retiros_cat_cajas]
GO
ALTER TABLE [dbo].[doc_retiros]  WITH CHECK ADD  CONSTRAINT [FK_doc_retiros_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_retiros] CHECK CONSTRAINT [FK_doc_retiros_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_retiros]  WITH CHECK ADD  CONSTRAINT [FK_doc_retiros_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_retiros] CHECK CONSTRAINT [FK_doc_retiros_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_retiros_denominaciones]  WITH CHECK ADD  CONSTRAINT [FK_doc_retiros_denominaciones_cat_denominaciones] FOREIGN KEY([DenominacionId])
REFERENCES [dbo].[cat_denominaciones] ([Clave])
GO
ALTER TABLE [dbo].[doc_retiros_denominaciones] CHECK CONSTRAINT [FK_doc_retiros_denominaciones_cat_denominaciones]
GO
ALTER TABLE [dbo].[doc_retiros_denominaciones]  WITH CHECK ADD  CONSTRAINT [FK_doc_retiros_denominaciones_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_retiros_denominaciones] CHECK CONSTRAINT [FK_doc_retiros_denominaciones_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_retiros_denominaciones]  WITH CHECK ADD  CONSTRAINT [FK_doc_retiros_denominaciones_doc_retiros] FOREIGN KEY([RetiroId])
REFERENCES [dbo].[doc_retiros] ([RetiroId])
GO
ALTER TABLE [dbo].[doc_retiros_denominaciones] CHECK CONSTRAINT [FK_doc_retiros_denominaciones_doc_retiros]
GO
ALTER TABLE [dbo].[doc_sesiones_punto_venta]  WITH CHECK ADD  CONSTRAINT [FK_doc_sesiones_punto_venta_cat_cajas] FOREIGN KEY([CajaId])
REFERENCES [dbo].[cat_cajas] ([Clave])
GO
ALTER TABLE [dbo].[doc_sesiones_punto_venta] CHECK CONSTRAINT [FK_doc_sesiones_punto_venta_cat_cajas]
GO
ALTER TABLE [dbo].[doc_sesiones_punto_venta]  WITH CHECK ADD  CONSTRAINT [FK_doc_sesiones_punto_venta_cat_usuarios] FOREIGN KEY([UsuarioId])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_sesiones_punto_venta] CHECK CONSTRAINT [FK_doc_sesiones_punto_venta_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_sesiones_punto_venta]  WITH CHECK ADD  CONSTRAINT [FK_doc_sesiones_punto_venta_doc_corte_caja] FOREIGN KEY([CorteCajaId])
REFERENCES [dbo].[doc_corte_caja] ([CorteCajaId])
GO
ALTER TABLE [dbo].[doc_sesiones_punto_venta] CHECK CONSTRAINT [FK_doc_sesiones_punto_venta_doc_corte_caja]
GO
ALTER TABLE [dbo].[doc_sucursales_productos_recepcion]  WITH CHECK ADD  CONSTRAINT [FK_doc_sucursales_productos_recepcion_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_sucursales_productos_recepcion] CHECK CONSTRAINT [FK_doc_sucursales_productos_recepcion_cat_productos]
GO
ALTER TABLE [dbo].[doc_sucursales_productos_recepcion]  WITH CHECK ADD  CONSTRAINT [FK_doc_sucursales_productos_recepcion_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_sucursales_productos_recepcion] CHECK CONSTRAINT [FK_doc_sucursales_productos_recepcion_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_ventas]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_cat_clientes] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[doc_ventas] CHECK CONSTRAINT [FK_doc_ventas_cat_clientes]
GO
ALTER TABLE [dbo].[doc_ventas]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_cat_usuarios] FOREIGN KEY([UsuarioCreacionId])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_ventas] CHECK CONSTRAINT [FK_doc_ventas_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_ventas]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_cat_usuarios1] FOREIGN KEY([UsuarioCancelacionId])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_ventas] CHECK CONSTRAINT [FK_doc_ventas_cat_usuarios1]
GO
ALTER TABLE [dbo].[doc_ventas]  WITH CHECK ADD  CONSTRAINT [FK_VentasCaja] FOREIGN KEY([CajaId])
REFERENCES [dbo].[cat_cajas] ([Clave])
GO
ALTER TABLE [dbo].[doc_ventas] CHECK CONSTRAINT [FK_VentasCaja]
GO
ALTER TABLE [dbo].[doc_ventas]  WITH CHECK ADD  CONSTRAINT [FK_VentasSucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_ventas] CHECK CONSTRAINT [FK_VentasSucursales]
GO
ALTER TABLE [dbo].[doc_ventas_detalle]  WITH CHECK ADD FOREIGN KEY([PromocionCMId])
REFERENCES [dbo].[doc_promociones_cm] ([PromocionCMId])
GO
ALTER TABLE [dbo].[doc_ventas_detalle]  WITH CHECK ADD FOREIGN KEY([TipoDescuentoId])
REFERENCES [dbo].[cat_tipos_descuento] ([TipoDescuentoId])
GO
ALTER TABLE [dbo].[doc_ventas_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_detalle_cat_cargos_Adicionales] FOREIGN KEY([CargoAdicionalId])
REFERENCES [dbo].[cat_cargos_adicionales] ([CargoAdicionalId])
GO
ALTER TABLE [dbo].[doc_ventas_detalle] CHECK CONSTRAINT [FK_doc_ventas_detalle_cat_cargos_Adicionales]
GO
ALTER TABLE [dbo].[doc_ventas_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_detalle_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_ventas_detalle] CHECK CONSTRAINT [FK_doc_ventas_detalle_cat_productos]
GO
ALTER TABLE [dbo].[doc_ventas_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_detalle_cat_usuarios] FOREIGN KEY([UsuarioCreacionId])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_ventas_detalle] CHECK CONSTRAINT [FK_doc_ventas_detalle_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_ventas_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_detalle_doc_ventas] FOREIGN KEY([VentaId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_ventas_detalle] CHECK CONSTRAINT [FK_doc_ventas_detalle_doc_ventas]
GO
ALTER TABLE [dbo].[doc_ventas_detalle]  WITH CHECK ADD  CONSTRAINT [FK_Ventas_CargoDetalle] FOREIGN KEY([CargoDetalleId])
REFERENCES [dbo].[doc_cargos_detalle] ([CargoDetalleId])
GO
ALTER TABLE [dbo].[doc_ventas_detalle] CHECK CONSTRAINT [FK_Ventas_CargoDetalle]
GO
ALTER TABLE [dbo].[doc_ventas_formas_pago]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_formas_pago_cat_formas_pago] FOREIGN KEY([FormaPagoId])
REFERENCES [dbo].[cat_formas_pago] ([FormaPagoId])
GO
ALTER TABLE [dbo].[doc_ventas_formas_pago] CHECK CONSTRAINT [FK_doc_ventas_formas_pago_cat_formas_pago]
GO
ALTER TABLE [dbo].[doc_ventas_formas_pago]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_formas_pago_cat_usuarios] FOREIGN KEY([UsuarioCreacionId])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_ventas_formas_pago] CHECK CONSTRAINT [FK_doc_ventas_formas_pago_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_ventas_formas_pago]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_formas_pago_doc_ventas] FOREIGN KEY([VentaId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_ventas_formas_pago] CHECK CONSTRAINT [FK_doc_ventas_formas_pago_doc_ventas]
GO
ALTER TABLE [dbo].[doc_ventas_formas_pago_vale]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_formas_pago_vale_cat_tipos_vale] FOREIGN KEY([TipoValeId])
REFERENCES [dbo].[cat_tipos_vale] ([TipoValeId])
GO
ALTER TABLE [dbo].[doc_ventas_formas_pago_vale] CHECK CONSTRAINT [FK_doc_ventas_formas_pago_vale_cat_tipos_vale]
GO
ALTER TABLE [dbo].[doc_ventas_formas_pago_vale]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_formas_pago_vale_doc_devoluciones] FOREIGN KEY([DevolucionId])
REFERENCES [dbo].[doc_devoluciones] ([DevolucionId])
GO
ALTER TABLE [dbo].[doc_ventas_formas_pago_vale] CHECK CONSTRAINT [FK_doc_ventas_formas_pago_vale_doc_devoluciones]
GO
ALTER TABLE [dbo].[doc_ventas_pagos]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_pagos_doc_pagos] FOREIGN KEY([PagoId])
REFERENCES [dbo].[doc_pagos] ([PagoId])
GO
ALTER TABLE [dbo].[doc_ventas_pagos] CHECK CONSTRAINT [FK_doc_ventas_pagos_doc_pagos]
GO
ALTER TABLE [dbo].[doc_ventas_pagos]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_pagos_doc_ventas] FOREIGN KEY([VentaId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_ventas_pagos] CHECK CONSTRAINT [FK_doc_ventas_pagos_doc_ventas]
GO
ALTER TABLE [dbo].[doc_web_carrito]  WITH CHECK ADD  CONSTRAINT [FK_Carrito_Cliente] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[doc_web_carrito] CHECK CONSTRAINT [FK_Carrito_Cliente]
GO
ALTER TABLE [dbo].[doc_web_carrito]  WITH CHECK ADD  CONSTRAINT [FK_Carrito_Ventas] FOREIGN KEY([VentaId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_web_carrito] CHECK CONSTRAINT [FK_Carrito_Ventas]
GO
ALTER TABLE [dbo].[doc_web_carrito]  WITH CHECK ADD  CONSTRAINT [FK_doc_web_carrito_cat_estados] FOREIGN KEY([EnvioEstadoId])
REFERENCES [dbo].[cat_estados] ([EstadoId])
GO
ALTER TABLE [dbo].[doc_web_carrito] CHECK CONSTRAINT [FK_doc_web_carrito_cat_estados]
GO
ALTER TABLE [dbo].[doc_web_carrito_detalle]  WITH CHECK ADD  CONSTRAINT [FK_Carrito_Cargo_Detalle] FOREIGN KEY([CargoDetalleId])
REFERENCES [dbo].[doc_cargos_detalle] ([CargoDetalleId])
GO
ALTER TABLE [dbo].[doc_web_carrito_detalle] CHECK CONSTRAINT [FK_Carrito_Cargo_Detalle]
GO
ALTER TABLE [dbo].[doc_web_carrito_detalle]  WITH CHECK ADD  CONSTRAINT [FK_Carrito_CarritoDetalle] FOREIGN KEY([Id])
REFERENCES [dbo].[doc_web_carrito] ([id])
GO
ALTER TABLE [dbo].[doc_web_carrito_detalle] CHECK CONSTRAINT [FK_Carrito_CarritoDetalle]
GO
ALTER TABLE [dbo].[doc_web_carrito_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_web_carrito_detalle_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_web_carrito_detalle] CHECK CONSTRAINT [FK_doc_web_carrito_detalle_cat_productos]
GO
ALTER TABLE [dbo].[doc_web_carrito_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_web_carrito_detalle_doc_web_carrito] FOREIGN KEY([uUID])
REFERENCES [dbo].[doc_web_carrito] ([uUID])
GO
ALTER TABLE [dbo].[doc_web_carrito_detalle] CHECK CONSTRAINT [FK_doc_web_carrito_detalle_doc_web_carrito]
GO
ALTER TABLE [dbo].[rh_departamentos]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_departamentos]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_departamentos]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_departamentos]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleado_puestos]  WITH CHECK ADD  CONSTRAINT [FK_rh_empleado_puestos_rh_empleados] FOREIGN KEY([EmpleadoId])
REFERENCES [dbo].[rh_empleados] ([NumEmpleado])
GO
ALTER TABLE [dbo].[rh_empleado_puestos] CHECK CONSTRAINT [FK_rh_empleado_puestos_rh_empleados]
GO
ALTER TABLE [dbo].[rh_empleado_puestos]  WITH CHECK ADD  CONSTRAINT [FK_rh_empleado_puestos_rh_puestos] FOREIGN KEY([PuestoId])
REFERENCES [dbo].[rh_puestos] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleado_puestos] CHECK CONSTRAINT [FK_rh_empleado_puestos_rh_puestos]
GO
ALTER TABLE [dbo].[rh_empleados]  WITH CHECK ADD FOREIGN KEY([Departamento])
REFERENCES [dbo].[rh_departamentos] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleados]  WITH CHECK ADD FOREIGN KEY([Departamento])
REFERENCES [dbo].[rh_departamentos] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleados]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleados]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleados]  WITH CHECK ADD FOREIGN KEY([FormaPago])
REFERENCES [dbo].[rh_formaspagonom] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleados]  WITH CHECK ADD FOREIGN KEY([FormaPago])
REFERENCES [dbo].[rh_formaspagonom] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleados]  WITH CHECK ADD FOREIGN KEY([Puesto])
REFERENCES [dbo].[rh_puestos] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleados]  WITH CHECK ADD FOREIGN KEY([Puesto])
REFERENCES [dbo].[rh_puestos] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleados]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleados]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleados]  WITH CHECK ADD FOREIGN KEY([TipoContrato])
REFERENCES [dbo].[rh_tipos_contrato] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleados]  WITH CHECK ADD FOREIGN KEY([TipoContrato])
REFERENCES [dbo].[rh_tipos_contrato] ([Clave])
GO
ALTER TABLE [dbo].[rh_estatus_empleados]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_estatus_empleados]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_estatus_empleados]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_estatus_empleados]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_formaspagonom]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_formaspagonom]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_formaspagonom]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_formaspagonom]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_puestos]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_puestos]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_puestos]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_puestos]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_tipos_contrato]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_tipos_contrato]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_tipos_contrato]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_tipos_contrato]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[sis_bitacora_errores]  WITH CHECK ADD  CONSTRAINT [FK_sis_bitacora_errores_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[sis_bitacora_errores] CHECK CONSTRAINT [FK_sis_bitacora_errores_cat_usuarios]
GO
ALTER TABLE [dbo].[sis_bitacora_general]  WITH CHECK ADD  CONSTRAINT [FK_sis_bitacora_general_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[sis_bitacora_general] CHECK CONSTRAINT [FK_sis_bitacora_general_cat_sucursales]
GO
ALTER TABLE [dbo].[sis_bitacora_general]  WITH CHECK ADD  CONSTRAINT [FK_sis_bitacora_general_cat_sucursales1] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[sis_bitacora_general] CHECK CONSTRAINT [FK_sis_bitacora_general_cat_sucursales1]
GO
ALTER TABLE [dbo].[sis_cuenta]  WITH CHECK ADD  CONSTRAINT [FK_sis_cuenta_cat_empresas] FOREIGN KEY([EmpresaId])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[sis_cuenta] CHECK CONSTRAINT [FK_sis_cuenta_cat_empresas]
GO
ALTER TABLE [dbo].[sis_menu]  WITH CHECK ADD  CONSTRAINT [FK_sis_menu_sis_menu] FOREIGN KEY([MenuPadreId])
REFERENCES [dbo].[sis_menu] ([MenuId])
GO
ALTER TABLE [dbo].[sis_menu] CHECK CONSTRAINT [FK_sis_menu_sis_menu]
GO
ALTER TABLE [dbo].[sis_perfiles_menu]  WITH CHECK ADD  CONSTRAINT [FK_sis_perfiles_menu_sis_menu] FOREIGN KEY([MenuId])
REFERENCES [dbo].[sis_menu] ([MenuId])
GO
ALTER TABLE [dbo].[sis_perfiles_menu] CHECK CONSTRAINT [FK_sis_perfiles_menu_sis_menu]
GO
ALTER TABLE [dbo].[sis_perfiles_menu]  WITH CHECK ADD  CONSTRAINT [FK_sis_perfiles_menu_sis_perfiles] FOREIGN KEY([PerfilId])
REFERENCES [dbo].[sis_perfiles] ([PerfilId])
GO
ALTER TABLE [dbo].[sis_perfiles_menu] CHECK CONSTRAINT [FK_sis_perfiles_menu_sis_perfiles]
GO
ALTER TABLE [dbo].[sis_preferencias_empresa]  WITH CHECK ADD  CONSTRAINT [FK_sis_preferencias_empresa_sis_preferencias] FOREIGN KEY([PreferenciaId])
REFERENCES [dbo].[sis_preferencias] ([Id])
GO
ALTER TABLE [dbo].[sis_preferencias_empresa] CHECK CONSTRAINT [FK_sis_preferencias_empresa_sis_preferencias]
GO
ALTER TABLE [dbo].[sis_preferencias_sucursales]  WITH CHECK ADD  CONSTRAINT [FK_sis_preferencias_sucursales_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[sis_preferencias_sucursales] CHECK CONSTRAINT [FK_sis_preferencias_sucursales_cat_sucursales]
GO
ALTER TABLE [dbo].[sis_preferencias_sucursales]  WITH CHECK ADD  CONSTRAINT [FK_sis_preferencias_sucursales_sis_preferencias] FOREIGN KEY([PreferenciaId])
REFERENCES [dbo].[sis_preferencias] ([Id])
GO
ALTER TABLE [dbo].[sis_preferencias_sucursales] CHECK CONSTRAINT [FK_sis_preferencias_sucursales_sis_preferencias]
GO
ALTER TABLE [dbo].[sis_roles_perfiles]  WITH CHECK ADD  CONSTRAINT [FK_sis_roles_perfiles_sis_perfiles] FOREIGN KEY([PerfilId])
REFERENCES [dbo].[sis_perfiles] ([PerfilId])
GO
ALTER TABLE [dbo].[sis_roles_perfiles] CHECK CONSTRAINT [FK_sis_roles_perfiles_sis_perfiles]
GO
ALTER TABLE [dbo].[sis_roles_perfiles]  WITH CHECK ADD  CONSTRAINT [FK_sis_roles_perfiles_sis_roles] FOREIGN KEY([RolId])
REFERENCES [dbo].[sis_roles] ([RolId])
GO
ALTER TABLE [dbo].[sis_roles_perfiles] CHECK CONSTRAINT [FK_sis_roles_perfiles_sis_roles]
GO
ALTER TABLE [dbo].[sis_usuarios_perfiles]  WITH CHECK ADD  CONSTRAINT [FK_sis_usuarios_perfiles_cat_usuarios] FOREIGN KEY([UsuarioId])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[sis_usuarios_perfiles] CHECK CONSTRAINT [FK_sis_usuarios_perfiles_cat_usuarios]
GO
ALTER TABLE [dbo].[sis_usuarios_roles]  WITH CHECK ADD  CONSTRAINT [FK_sis_usuarios_roles_cat_usuarios] FOREIGN KEY([UsuarioId])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[sis_usuarios_roles] CHECK CONSTRAINT [FK_sis_usuarios_roles_cat_usuarios]
GO
ALTER TABLE [dbo].[sis_usuarios_roles]  WITH CHECK ADD  CONSTRAINT [FK_sis_usuarios_roles_sis_roles] FOREIGN KEY([RolId])
REFERENCES [dbo].[sis_roles] ([RolId])
GO
ALTER TABLE [dbo].[sis_usuarios_roles] CHECK CONSTRAINT [FK_sis_usuarios_roles_sis_roles]
GO
ALTER TABLE [dbo].[sis_versiones_detalle]  WITH CHECK ADD  CONSTRAINT [FK_sis_versiones_detalle_sis_versiones] FOREIGN KEY([VersionId])
REFERENCES [dbo].[sis_versiones] ([VersionId])
GO
ALTER TABLE [dbo].[sis_versiones_detalle] CHECK CONSTRAINT [FK_sis_versiones_detalle_sis_versiones]
GO
/****** Object:  StoredProcedure [dbo].[doc_corte_caja_denominaciones_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create Proc [dbo].[doc_corte_caja_denominaciones_ins]
@pCorteCajaId int,
@pDenominacionId int,
@pCantidad int,
@pValor money,
@pTotal money,
@pCreadoPor int
as

	insert into [dbo].[doc_corte_caja_denominaciones](
		CorteCajaId,
		DenominacionId,
		Cantidad,
		Valor,
		Total,
		CreadoPor,
		CreadoEl
	)
	values(
		@pCorteCajaId,
		@pDenominacionId,
		@pCantidad,
		@pValor,
		@pTotal,
		@pCreadoPor,
		getdate()
		
	)





GO
/****** Object:  StoredProcedure [dbo].[doc_inv_movimiento_detalle_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[doc_inv_movimiento_detalle_ins]
@pMovimientoDetalleId	int out,
@pMovimientoId	int,
@pProductoId	int,
@pConsecutivo	smallint,
@pCantidad	decimal(14,3),
@pPrecioUnitario	money,
@pImporte	money,
@pDisponible	decimal(14,3),
@pCreadoPor	int
as


select @pMovimientoDetalleId = isnull(max(MovimientoDetalleId),0) + 1
from [doc_inv_movimiento_detalle]

INSERT INTO [dbo].[doc_inv_movimiento_detalle]
           ([MovimientoDetalleId]
           ,[MovimientoId]
           ,[ProductoId]
           ,[Consecutivo]
           ,[Cantidad]
           ,[PrecioUnitario]
           ,[Importe]
           ,[Disponible]
           ,[CreadoPor]
           ,[CreadoEl])
     VALUES
           (@pMovimientoDetalleId,
           @pMovimientoId,
           @pProductoId, 
           @pConsecutivo, 
           @pCantidad, 
           @pPrecioUnitario, 
           @pImporte, 
           @pDisponible, 
           @pCreadoPor, 
           getdate() )






GO
/****** Object:  StoredProcedure [dbo].[p_Actualizar_CompraListaPrecios]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- p_Actualizar_CompraListaPrecios 5,0,1,''
CREATE proc [dbo].[p_Actualizar_CompraListaPrecios]
@pProductoCompraId int,
@pCompraDirectaId int,
@pUsuarioId int,
@pError varchar(200) out
as

	/**********VALIDACIONES********************/
	declare @activo bit,
			@productoId int,
			@precio money,
			@porcUtilidad decimal(5,2),
			@idAux int,
			@precioAnterior money,
			@cambioPrecioPorcUtilidad bit,
			@cambioPrecioIncUtilidad bit,
			@sucursalId int,
			@porcTotImpuestos decimal(6,2)

	if(@pProductoCompraId > 0)
	begin
		select @activo =Activo,
			@sucursalId = SucursalId
		from doc_productos_compra
		where ProductoCompraId = @pProductoCompraId
	end
	if(@pCompraDirectaId > 0)
	begin
		select @activo =Activo,
			@sucursalId = SucursalId
		from doc_inv_movimiento
		where MovimientoId = @pCompraDirectaId
	end

	if(
		@activo = 0
	)
	begin
		set @pError = 'No s epueden realizar cambios de precios sobre un movimiento cancelado'
		return	
	end

	Create Table #tmpProductos
	(
		ProductoId int,
		PRecioCompra money
	)

	if(isnull(@pProductoCompraId,0) > 0)
	begin
		insert into #tmpProductos
		select ProductoId,PrecioCompra
		from doc_productos_compra_detalle
		where ProductoCompraId = @pProductoCompraId
	end

	if(isnull(@pCompraDirectaId,0) > 0)
	begin
		insert into #tmpProductos
		select ProductoId,PrecioUnitario
		from doc_inv_movimiento_detalle md
		inner join doc_inv_movimiento m on m.MovimientoId = md.MovimientoId
		where m.MovimientoId = @pCompraDirectaId and
		m.Activo = 1 and
		m.Autorizado = 1 and
		m.TipoMovimientoId = 7--Entrada directa

	end	
	

	select @productoID = MIn(productoId)
	from #tmpProductos

	while @productoId is not null
	Begin

		select @cambioPrecioPorcUtilidad = CalculaPrecioPorcUtilidad,
			@cambioPrecioIncUtilidad = CalculaPrecioIncUtilidad 
		from cat_productos_config_sucursal
		where ProductoId = @productoId and
		SucursalId = @sucursalId

		

		select @precio = PrecioCompra
		from #tmpProductos

		

		if(
			@cambioPrecioIncUtilidad = 1
		)
		begin

			select @porcTotImpuestos = sum(isnull(i.Porcentaje,0))
			from cat_productos_impuestos pi
			inner join cat_impuestos i on i.Clave = pi.ImpuestoId
			where pi.ProductoId = @productoId

			select @precio = case when isnull(@porcTotImpuestos,0) = 0 then  @precio + isnull(p2.IncUtilidadValor,0) 
									else 
									
									(
										(@precio / (1 + (@porcTotImpuestos / 100))) + isnull(p2.IncUtilidadValor,0) 
									) * (1 + (@porcTotImpuestos / 100))
							end,
				
				@precioAnterior = isnull(pp.Precio,0)
			from #tmpProductos tmp
			inner join cat_productos p on p.ProductoId = tmp.ProductoId
			inner join cat_productos_config_sucursal p2 on p2.ProductoId = p.ProductoId and
													p2.SucursalId = @sucursalId		
			
			left join cat_productos_precios pp on pp.IdProducto = p.ProductoId and
										pp.IdPrecio = 1
			where tmp.productoid = @productoId
		end

		if(
			@cambioPrecioPorcUtilidad = 1
		)
		begin
			select @precio = @precio + (@precio * (isnull(p2.PorcUtilidadValor,0) / 100)),
				
				@precioAnterior = isnull(pp.Precio,0)
			from #tmpProductos tmp
			inner join cat_productos p on p.ProductoId = tmp.ProductoId
			inner join cat_productos_config_sucursal p2 on p2.ProductoId = p.ProductoId and
													p2.SucursalId = @sucursalId
			left join cat_productos_precios pp on pp.IdProducto = p.ProductoId and
										pp.IdPrecio = 1
			where tmp.productoid = @productoId
		end

		--select @cambioPrecioPorcUtilidad,@cambioPrecioIncUtilidad,@precio

		if(@precio  > @precioAnterior
		and
		(@cambioPrecioIncUtilidad = 1 or @cambioPrecioPorcUtilidad = 1)
		)
		begin

			if exists (
				select 1
				from cat_productos_precios
				where IdProducto = @productoId and
				IdPrecio = 1
			)
			begin		

				update cat_productos_precios
				set Precio = @precio
				where IdProducto = @productoId
				and IdPrecio = 1
			End
			Else
			Begin
				select  @idAux  =isnull(max(IdProductoPrecio),0) + 1
				from cat_productos_precios

				insert into cat_productos_precios(
					IdProductoPrecio,IdProducto,IdPrecio,PorcDescuento,MontoDescuento,Precio
				)
				select @idAux,@productoId,1,0,0, @precio

			End			
			
			exec [dbo].[p_ActualizarListaPrecios] @productoId,null,null,0,@precio
			
		End

		select @productoID = MIn(productoId)
		from #tmpProductos
		where productoId > @productoId

	End

	--IF(@cambioPrecioIncUtilidad = 1 oR @cambioPrecioPorcUtilidad = 1)
	--BEGIN
		update doc_productos_compra
		set PrecioAfectado = 1
		where  ProductoCompraId = @pProductoCompraId
	--END











GO
/****** Object:  StoredProcedure [dbo].[p_actualizar_perfiles_menu]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE proc [dbo].[p_actualizar_perfiles_menu]
@pPerfilId varchar(100),
@pMenuIdsActualizados varchar(500),
@pmenuIdsAEliminar varchar(500)
as
	BEGIN TRAN

	if @pmenuIdsAEliminar is not null and @pmenuIdsAEliminar <> ''
	begin

		DECLARE @sqlCommandDelete varchar(1000);
		DECLARE @columnValues varchar(500);
		SET @sqlCommandDelete = 'delete from dbo.sis_perfiles_menu where perfilId = ' +  @pPerfilId + ' and menuId in ' + @pmenuIdsAEliminar;
		
		EXEC (@sqlCommandDelete)

	end

	if @pMenuIdsActualizados is not null and @pMenuIdsActualizados <> ''	
	BEGIN
		DECLARE @sqlCommand varchar(1000);
		DECLARE @columnList varchar(75);
		SET @columnList = 'perfilId , menuId , creadoEl';
		SET @sqlCommand = 'INSERT INTO dbo.sis_perfiles_menu
		(' +  @columnList + ') VALUES ' + @pMenuIdsActualizados;
		
		EXEC (@sqlCommand)
	END

	COMMIT TRAN

GO
/****** Object:  StoredProcedure [dbo].[p_ActualizarListaPrecios]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_ActualizarListaPrecios 2,0,0,0,200
CREATE PROC [dbo].[p_ActualizarListaPrecios]
@pProductoId INT,
@pPrecioId INT,
@pDescuento MONEY,
@pMontoDescuento MONEY OUT,
@pPrecioFinal MONEY out
AS

	declare	 @precioVta MONEY,
			@precioSinImp MONEY,
			@porcImpuestos decimal(5,2),
			@subtotal MONEY,
			@impuestos MONEY,
			@idAux int

	SELECT @precioVta = Precio
	FROM dbo.cat_productos_precios pre	
	inner join cat_productos p on p.ProductoId = pre.idProducto
	WHERE IdPrecio = 1 and--PRECIO VTA 
	IdProducto = @pProductoId

	SELECT @porcImpuestos = ISNULL(SUM(ISNULL(i.Porcentaje,0)),0)
	FROM dbo.cat_productos_impuestos PI
	INNER JOIN dbo.cat_impuestos I ON I.Clave = PI.ImpuestoId
	WHERE ProductoId = @pProductoId



	IF(@porcImpuestos > 0)
	begin
		SET @impuestos = @precioVta - ( @precioVta / (1+ (@porcImpuestos/100)))
		SET @subtotal = @precioVta - @impuestos
		SET @precioSinImp = @subtotal
	END
    ELSE
    BEGIN
		SET @impuestos = 0 
		SET @subtotal = @precioVta
		SET @precioSinImp = @subtotal
    end
    
	

	/*************ASEGURARSE QUE EXISTAN TODOS LOS PRECIOS PARA EL PRODUCTO *****************/
	BEGIN TRAN

	DECLARE @IdProductoPrecio INT
    SELECT @IdProductoPrecio = ISNULL(MAX(IdProductoPrecio),0)
	FROM cat_productos_precios

	INSERT INTO dbo.cat_productos_precios
	(
	    IdProductoPrecio,
	    IdProducto,
	    IdPrecio,
	    PorcDescuento,
	    MontoDescuento,
	    Precio
	)
	SELECT ROW_NUMBER() OVER(ORDER BY IdPrecio ASC) + @IdProductoPrecio,
	@pProductoId,
	p.IdPrecio,
	0,
	0,
	ISNULL(@precioVta,@pPrecioFinal)
	FROM dbo.cat_precios p
	where not EXISTS (
		SELECT 1
		FROM dbo.cat_productos_precios
		WHERE IdProducto = @pProductoId AND
        IdPrecio = p.IdPrecio
	)

	if @@error <> 0
	BEGIN
		ROLLBACK TRAN
		GOTO fin
    END


	SELECT @idAux = ISNULL(MAX(id),0)
	FROM [cat_productos_cambio_precio]
	
    
	INSERT INTO [dbo].[cat_productos_cambio_precio](
		Id,				ProductoId,		PrecioId,		PrecioAnterior,			PrecioNuevo,
		FechaRegistro,	UsuarioRegistroId)
	SELECT ROW_NUMBER() OVER(ORDER BY IdPrecio ASC) + @idAux,			IdProducto,		IdPrecio,		Precio,					
	(@precioSinImp -  (
								@precioSinImp * (
											CASE WHEN ISNULL(@pPrecioId,0) > 0 THEN @pDescuento 
													ELSE PorcDescuento
											END
											/100
											)
								))
								*
								(1+(@porcImpuestos/100)),
								
	GETDATE(),
	NULL				
	FROM cat_productos_precios
	WHERE IdProducto = @pProductoId AND
	ISNULL(@pPrecioId,0) IN (0,IdPrecio) AND
    IdPrecio > 1	

	
	if @@error <> 0
	BEGIN
		ROLLBACK TRAN
		GOTO fin
    END

	UPDATE dbo.cat_productos_precios
	SET Precio = (@precioSinImp -  (
								@precioSinImp * (
											CASE WHEN ISNULL(@pPrecioId,0) > 0 THEN @pDescuento 
													ELSE PorcDescuento
											END
											/100
											)
								))
								*
								(1+(@porcImpuestos/100)),
		MontoDescuento = (
								@precioSinImp * (
											CASE WHEN ISNULL(@pPrecioId,0) > 0 THEN @pDescuento 
													ELSE PorcDescuento
											END
											/100
											)
								),
		PorcDescuento = CASE 
							WHEN ISNULL(@pPrecioId,0) > 0 THEN @pDescuento 
							ELSE PorcDescuento
						END
	WHERE IdProducto = @pProductoId AND
	ISNULL(@pPrecioId,0) IN (0,IdPrecio) AND
    IdPrecio > 1


	if @@error <> 0
	BEGIN
		ROLLBACK TRAN
		GOTO fin
    END
    

	COMMIT TRAN

	fin:

	SELECT @pPrecioFinal = Precio,
			@pMontoDescuento = MontoDescuento
	FROM dbo.cat_productos_precios
	WHERE ISNULL(@pPrecioId,1) = IdPrecio AND
    @pProductoId = IdProducto

	






GO
/****** Object:  StoredProcedure [dbo].[p_afecta_inventario_cero]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_afecta_inventario_cero 9,1
create proc [dbo].[p_afecta_inventario_cero]
@pSucursalId INT,
@pUsuarioId INT
AS


	DECLARE @Id INT

	SELECT @Id = MAX(Id)
	FROM doc_inventario_captura

	INSERT INTO doc_inventario_captura(Id,SucursalId,ProductoId,Cantidad,CreadoPor,CreadoEl,Cerrado)
	SELECT @Id+ ROW_NUMBER() OVER(ORDER BY PE.ProductoId ASC) ,PE.SucursalId,PE.ProductoId,0,@pUsuarioId,GETDATE(),0
	FROM cat_productos_existencias PE
	WHERE PE.SucursalId = @pSucursalId


	EXEC [dbo].[p_inventario_cierre] @pSucursalId,@pUsuarioId
GO
/****** Object:  StoredProcedure [dbo].[p_api_clientes_registro_demo]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_api_clientes_registro_demo 'daniel','danw217@gmail.com',1,''
CREATE proc [dbo].[p_api_clientes_registro_demo]
@pNombre varchar(100),
@pEmail varchar(100),
@pGiro smallint,
@pError varchar(250) out,
@pProductosId varchar(100)

as

	
	set @pProductosId = '1,2'
	declare @uuid Uniqueidentifier;
	declare @KeyClient varchar(150),
			@clienteId int,
			@notificacionId int

	select splitdata 
	into #tmpProductos
	from[dbo].[fnSplitString](@pProductosId,',')

	set @uuid = NEWID();
	set @KeyClient = dbo.fn_ENCODE_TO_BASE64(@uuid)

	if exists(
		select 1
		from cat_clientes_contacto
		where ltrim(rtrim(email)) =ltrim(rtrim(@pEmail)) 
	)
	begin

		set @pError = 'Ya existe un usuario registrado con este EMAIL'
		return;
	end

	select @clienteId = isnull(max(ClienteId),0)+1
	from cat_clientes
	
	BEGIN TRY  

		begin tran

		insert into cat_clientes(ClienteId,Nombre,GiroNegocioId,Activo)
		select @clienteId,@pNombre,@pGiro,1

		insert into cat_clientes_contacto(ClienteId,Email,CreadoEl)
		select @clienteId,@pEmail,getdate()

		declare  @pClienteLicenciaId int

		select @pClienteLicenciaId = isnull(max(ClienteLicenciaId),0) + 1
		from doc_clientes_licencias

		insert into doc_clientes_licencias(
			ClienteLicenciaId,ClienteId,ProductoId,FechaVigencia,
			Vigente,CreadoEl,ModificadoEl
		)
		select @pClienteLicenciaId + ROW_NUMBER() OVER(ORDER BY pl.ProductoId ASC) ,@clienteId,pl.ProductoId,
		case when pl.UnidadLicencia = 'd' then dateadd(dd,pl.TiempoLicencia+1,getdate())
			when pl.UnidadLicencia = 'm' then dateadd(mm,pl.TiempoLicencia+1,getdate())
			when pl.UnidadLicencia = 'y' then dateadd(yy,pl.TiempoLicencia+1,getdate())
		end,1,getdate(),null

		from #tmpProductos p
		inner join cat_productos_licencias pl on pl.ProductoId = cast(p.splitdata as int)
		group by pl.ProductoId,pl.UnidadLicencia,pl.TiempoLicencia


		select @notificacionId = isnull(max(notificacionId),0) + 1
		from sis_notificaciones 

		insert into sis_notificaciones(
		NotificacionId,Para,Asunto,Mensaje,FechaProgramadaEnvio,Enviada,
		FechaEnvio,CreadoPor,CreadoEl,ModificadoPor,ModificadoEl,De
		)
		select @notificacionId,@pEmail,'Trinn - DEMO Punto de Venta',Html,getdate(),0,
		null,1,getdate(),null,null,'contacto@trinn.com.mx'
		from sis_correos_tipos 
		where TipoCorreoId = 1 --Registro DEMO

		commit tran
	END TRY  
	BEGIN CATCH  
		rollback tran
		set @pError = error_message()
		
	END CATCH  
 


	


	




GO
/****** Object:  StoredProcedure [dbo].[p_BuscarProductos]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_BuscarProductos '1',1
CREATE PROC [dbo].[p_BuscarProductos]
@pText VARCHAR(100),
@pBuscarSoloPorClave bit,
@pSucursalId int=0,
@pSoloConExistencia bit=0
AS

SELECT PRO.Clave,
		Descripcion = pro.Descripcion +' '+ isnull(pro.Talla,''),
		Unidad = u.Descripcion ,
		Precio = isnull(precio.Precio,0),
		ID = pro.ProductoId,
		impuestos = CASE WHEN  SUM(imp2.Porcentaje)  > 0 
					THEN (SUM(imp2.Porcentaje) / 100) * ISNULL(precio.Precio,0)
					ELSE 0
				END,
		porcImpuestos = SUM(imp2.Porcentaje),
		Foto = (SELECT foto FROM cat_productos t1 WHERE t1.ProductoId = pro.ProductoId),
		pro.Estatus,
		pro.ProdVtaBascula
FROM dbo.cat_productos pro
inner join cat_productos_existencias pe on pe.ProductoId = pro.ProductoId
left JOIN dbo.cat_productos_precios precio ON 
						precio.IdProducto = pro.ProductoId AND
                        precio.IdPrecio = 1 --publico gral
LEFT JOIN dbo.cat_productos_impuestos imp ON imp.ProductoId = pro.ProductoId
LEFT JOIN dbo.cat_impuestos imp2 ON imp2.Clave = imp.ImpuestoId
left JOIN dbo.cat_unidadesmed u ON u.Clave = pro.ClaveUnidadMedida
WHERE @pSucursalId in (0,pe.SucursalId) AND
(
	@pSoloConExistencia = 0 OR
	(@pSoloConExistencia = 1 AND pe.ExistenciaTeorica > 0)
) AND
(pro.Descripcion LIKE '%'+RTRIM(@pText)+'%' AND @pBuscarSoloPorClave = 0)
OR
(pro.DescripcionCorta LIKE '%'+RTRIM(@pText)+'%' AND @pBuscarSoloPorClave = 0)
OR
(pro.Clave like '%'+RTRIM(@pText)+'%' AND @pBuscarSoloPorClave = 0)
OR
(pro.Clave = RTRIM(@pText) AND @pBuscarSoloPorClave = 1)
GROUP BY PRO.Clave,
		pro.Descripcion,
		u.Descripcion,
		precio.Precio,
		pro.ProductoId,
		pro.Estatus,
		pro.Talla,
		pro.ProdVtaBascula
ORDER BY pro.Descripcion









GO
/****** Object:  StoredProcedure [dbo].[p_caja_efectivo_disponible_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- [p_caja_efectivo_disponible_sel] 1, '20180710'
CREATE Proc [dbo].[p_caja_efectivo_disponible_sel]
@pCajaId int,
@pFecha datetime
as

	declare @efectivoTotalCaja money,
		@retiros money,
		@fechaUltimoCorte datetime,
		@gastos money,
		@pagosApartados money

	/**********Obtener la fecha del ultimo corte************/

	select @fechaUltimoCorte = max(FechaCorte)
	from doc_corte_caja
	where CajaId = @pCajaId

	if(@fechaUltimoCorte is null)
	begin
		select @fechaUltimoCorte = '19000101'
	end

	select @pagosApartados = sum(ap.Importe)
	from doc_apartados_pagos ap
	inner join doc_apartados a on a.ApartadoId = ap.Apartadoid
	where a.CajaId =  @pCajaId and
	ap.FechaPago > @fechaUltimoCorte

	

	select @efectivoTotalCaja = isnull(sum(Cantidad),0)
	from doc_ventas v
	inner join doc_ventas_formas_pago dfp on dfp.VentaId = v.VentaId
	where fecha > @fechaUltimoCorte and
	CajaId = @pCajaId and
	FormaPagoId = 1 and
	v.Activo = 1

	select @gastos = isnull(sum(Monto),0)
	from doc_gastos
	where cajaId = @pCajaId and
	CreadoEl > @fechaUltimoCorte

	select @retiros = isnull(sum(MontoRetiro),0)
	from doc_retiros r
	where r.FechaRetiro > @fechaUltimoCorte
	and r.cajaId  = @pCajaId

	select Disponible = isnull(@efectivoTotalCaja,0) + isnull(@pagosApartados,0) - 
						isnull(@retiros,0) - isnull(@gastos,0)







GO
/****** Object:  StoredProcedure [dbo].[p_calcular_existencias]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- [p_calcular_existencias] 6,21,543072
CREATE Proc [dbo].[p_calcular_existencias]
@pSucursalId int,
@pProductoId int,
@pMovimientoDetalleId int = 0
as
BEGIN



	declare @entradas float,
			@entradasAnt float,
			@salidasInv float,
			@salidasVentas float,
			@salidasAnt float,
			@salidasTot float,
			@existencia float,
			@existenciaAnt float,
			@costoUltimaCompra money,
			@costoPromedio money,
			@valuadoCostoUCompra money,
			@valuadoCostoPromedio money,		
			@tipoMovimiento int,
			@ultimoValorCtoProm money,
			@actualValorMov money,
			@disopnible decimal(14,2),
			@apartado decimal(14,2),
			@esMatriz bit=0,
			@costoPromedioMatriz float,
			@costoUltCompraMatriz float,
			@lastMovId int,
			@existenciaDia float

	set @esMatriz = case when @pSucursalId = 1 then 1 else 0 end
	select @tipoMovimiento = m.TipoMovimientoId
	from doc_inv_movimiento m
	inner join doc_inv_movimiento_detalle md on md.MovimientoId = m.MovimientoId
	where md.MovimientoDetalleId = @pMovimientoDetalleId


	

	select @entradas = ISNULL(SUM(MD.Cantidad),0)
	from doc_inv_movimiento m
	inner join doc_inv_movimiento_detalle md on  m.FechaCorteExistencia IS  NULL AND
												md.MovimientoId = m.MovimientoId and
												md.ProductoId = @pProductoId	
	INNER JOIN cat_tipos_movimiento_inventario 	tm on tm.TipoMovimientoInventarioId = m.TipoMovimientoId and
											tm.EsEntrada=1												
	where (m.Activo =1 OR m.Cancelado = 1) and
	m.Autorizado = 1 and
	m.SucursalId = @pSucursalId


	select @salidasInv = ISNULL(SUM(MD.Cantidad),0)
	from doc_inv_movimiento m
	inner join doc_inv_movimiento_detalle md on m.FechaCorteExistencia IS  NULL AND
												md.MovimientoId = m.MovimientoId and
												md.ProductoId = @pProductoId	
	INNER JOIN cat_tipos_movimiento_inventario 	tm on tm.TipoMovimientoInventarioId = m.TipoMovimientoId and
											tm.EsEntrada=0												
	where (m.Activo =1 OR m.Cancelado = 1) and
	m.Autorizado = 1 and
	m.SucursalId = @pSucursalId and
	md.MovimientoDetalleId <= @pMovimientoDetalleId

	SELECT @existenciaDia = ISNULL(Existencia,0)
	FROM doc_productos_existencias_diario PE
	WHERE PE.ProductoId = @pProductoId AND
	PE.SucursalId = @pSucursalId AND
	CONVERT(VARCHAR,PE.FechaCorteExistencia,112) = CONVERT(VARCHAR,[dbo].[fn_GetDateTimeServer](),112)
	

	set @salidasTot = isnull(@salidasInv,0) 
	set @existencia = isnull(@existenciaDia,0) + isnull(@entradas,0) - isnull(@salidasTot,0)
	

	select top 1 @costoUltimaCompra = isnull(md.PrecioUnitario,0)
	from doc_inv_movimiento m
	inner join doc_inv_movimiento_detalle md on md.MovimientoId = m.MovimientoId
	where m.Activo = 1 and
	isnull(m.Cancelado,0) = 0 and
	m.Autorizado = 1 and
	m.TipoMovimientoId in (2,3,7) and
	md.ProductoId = @pProductoId
	order by md.CreadoEl desc	
	
	IF(ISNULL(@costoUltimaCompra,0)=0)
	BEGIN
		SELECT @costoUltimaCompra = CostoCapturaUsuario
		FROM cat_productos_existencias
		WHERE ProductoId = @pProductoId AND
		SucursalId = @pSucursalId
	END

	
	set @valuadoCostoUCompra = ISNULL(isnull(@costoUltimaCompra,0) * isnull(@existencia,0),0)
								


	/***********Calcular valor inventario******************/
	if(
		@tipoMovimiento in (2,3,7)
	)
	begin

		select top 1 @ultimoValorCtoProm =md.ValCostoPromedio
		from doc_inv_movimiento m
		inner join doc_inv_movimiento_detalle md on md.MovimientoId = m.MovimientoId
		left join cat_productos_existencias pe on pe.ProductoId = md.ProductoId and
											pe.SucursalId = m.SucursalId
		where md.MovimientoDetalleId <> @pMovimientoDetalleId and
		m.Activo = 1 and
		md.ProductoId = @pProductoId
		order by  md.MovimientoDetalleId desc

		select @actualValorMov = (isnull(PrecioUnitario,0) * isnull(Cantidad,0)) + isnull(Flete,0) +  isnull(Comisiones,0)
		from doc_inv_movimiento_detalle
		where MovimientoDetalleId = @pMovimientoDetalleId		

		set @costoPromedio = CASE WHEN ISNULL(@existencia,0) > 0 THEN cast((@ultimoValorCtoProm + @actualValorMov) / ISNULL(@existencia,0) as decimal(15,2)) ELSE 0 END

			
		select @ultimoValorCtoProm,@actualValorMov,@costoPromedio

	end
	Else
	Begin
		SELECT top 1 @costoPromedio = isnull(CostoPromedio,0)
		from doc_inv_movimiento_detalle md
		inner join doc_inv_movimiento m on m.MovimientoId = md.MovimientoId
		where ProductoId = @pProductoId  and
		m.Sucursalid = @pSucursalId and
		md.MovimientoDetalleId < @pMovimientoDetalleId and
		m.Activo = 1
		order by md.MovimientoDetalleId desc

	End

	/****VALOR COSTO PROMEDIO*****/
	set @valuadoCostoPromedio = ISNULL(isnull(@costoPromedio,0) * isnull(@existencia,0),0)
								


	/**********************************APARTADOS***************************/
	SELECT @apartado = isnull(sum(ap.Cantidad),0)
	FROM doc_apartados a
	inner join doc_apartados_productos ap on ap.ApartadoId = a.ApartadoId
	where ap.ProductoId = @pProductoId
	and a.VentaId is null 
	and a.Activo = 1
	/***********************************************************************/



	update doc_inv_movimiento_detalle
		set Disponible = ISNULL(@existencia,0),
			CostoPromedio = cast(case when ISNULL(@costoPromedio,0) =0 then isnull(pe.CostoPromedio,0)
										  else ISNULL(@costoPromedio,0) 
									end as money)			
							,
			CostoUltimaCompra = ISNULL(@costoUltimaCompra,0),
									
			ValorMovimiento = ISNULL(Cantidad,0) * ISNULL(PrecioUnitario,0)
		from doc_inv_movimiento_detalle md
		left join cat_productos_existencias pe on pe.ProductoId = md.ProductoId and
								pe.SucursalId = @pSucursalId
		where MovimientoDetalleId = @pMovimientoDetalleId 

		update doc_inv_movimiento_detalle
		set 		
			ValCostoPromedio = cast(isnull(CostoPromedio,0) * isnull(Disponible,0) as money),
			ValCostoUltimaCompra = cast(isnull(CostoUltimaCompra,0) * isnull(Disponible,0) as money)
		from doc_inv_movimiento_detalle md		
		where MovimientoDetalleId = @pMovimientoDetalleId 

		/*****SI SON NEGATIVOS PONER CERO*****/
		update doc_inv_movimiento_detalle
		set 		
			ValCostoPromedio =case when isnull(ValCostoPromedio,0) <0 then 0 else ValCostoPromedio end,
			ValCostoUltimaCompra = case when isnull(ValCostoUltimaCompra,0) <0 then 0 else ValCostoUltimaCompra end,
			ValorMovimiento = case when isnull(ValorMovimiento,0) <0 then 0 else ValorMovimiento end
		from doc_inv_movimiento_detalle md		
		where MovimientoDetalleId = @pMovimientoDetalleId 

	/********************************************************/

	IF NOT EXISTS(
		SELECT 1
		FROM cat_productos_existencias
		WHERE productoid = @pProductoId
		and SucursalId = @pSucursalId
	)
	BEGIN
		INSERT INTO cat_productos_existencias(
			ProductoId,				SucursalId,				ExistenciaTeorica,		CostoUltimaCompra,		
			CostoPromedio,			ValCostoUltimaCompra,	ValCostoPromedio,		ModificadoEl,			
			CreadoEl,				Apartado,				Disponible
		)
		VALUES(
			@pProductoId,			@pSucursalId,		isnull(@existencia,0),		
			cast(isnull(@costoUltimaCompra,0) as money),			
			cast(
						case when isnull(@costoPromedio,0) = 0 and isnull(@costoUltimaCompra,0) > 0 then 
									isnull(@costoUltimaCompra,0) 
							 else ISNULL(@costoPromedio,0) end as money
						),
			cast(ISNULL(@valuadoCostoUCompra,0) as money),	
			cast(ISNULL(@valuadoCostoPromedio,0) as money),
			getdate(),					getdate(),
			isnull(@apartado,0),		isnull(@existencia,0) - isnull(@apartado,0)
		
		)
	END
	Else
	Begin
		update cat_productos_existencias
		SET ExistenciaTeorica = ISNULL(@existencia,0),
			CostoPromedio = CAST(case when isnull(@costoPromedio,0) = 0  
										then ISNULL(CostoPromedio,0) else isnull(@costoPromedio,0) 
								
									end AS MONEY),
			CostoUltimaCompra = 
							cast(case when isnull(@costoUltimaCompra,0) = 0  
										then ISNULL(CostoUltimaCompra,0) else isnull(@costoUltimaCompra,0) 
								
									end as money),
			
			Apartado = isnull(@apartado,0),
			Disponible = isnull(@existencia,0) - isnull(@apartado,0)
		where ProductoId = @pProductoId and
		SucursalId = @pSucursalId

		update cat_productos_existencias
		SET ValCostoUltimaCompra = cast(CostoUltimaCompra * Disponible as money),
		ValCostoPromedio = cast(CostoPromedio * Disponible as money)
		where ProductoId = @pProductoId and
		SucursalId = @pSucursalId
	End

	/****SI SON NEGATIVOS PONER CERO ***/
	update cat_productos_existencias
	SET ValCostoUltimaCompra = case when isnull(ValCostoUltimaCompra,0) <0 then 0 else ValCostoUltimaCompra end,
		ValCostoPromedio = case when isnull(ValCostoPromedio,0) <0 then 0 else ValCostoPromedio end
	where ProductoId = @pProductoId and
	SucursalId = @pSucursalId

	

END

	

		
	
	











GO
/****** Object:  StoredProcedure [dbo].[p_cat_clientes_ins_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_cat_clientes_ins_upd]
@pClienteId int out,
@pNombre varchar(500),
@pRFC varchar(15),
@pCalle varchar(100),
@pNumeroExt varchar(10),
@pNumeroInt varchar(10),
@pColonia varchar(50),
@pCodigoPostal varchar(5),
@pEstadoId int,
@pMunicipioId int,
@pPaisId int,
@pTelefono varchar(15),
@pTelefono2 varchar(15),
@pTipoClienteId int,
@pDiasCredito smallint,
@pLimiteCredito money,
@pAntecedenteId int,
@pCreditoDisponible money,
@pSaldoGlobal money,
@pActivo bit,
@pClienteEspecial bit,
@pClienteGral bit,
@pPrecioId tinyint,
@pGiroId int,
@pClienteAutoId int out,
@pModelo varchar(150),
@pColor varchar(50),
@pPlacas varchar(20),
@pObservaciones varchar(300)
as



	if isnull(@pClienteId,0) = 0
	begin


		select @pClienteId = isnull(max(ClienteId),0) + 1
		from cat_clientes


		insert into cat_clientes(
			ClienteId,	Nombre,		RFC,		Calle,		NumeroExt,		NumeroInt,
			Colonia,	CodigoPostal,EstadoId,	MunicipioId,PaisId,			Telefono,
			Telefono2,	TipoClienteId,DiasCredito,LimiteCredito,AntecedenteId,CreditoDisponible,
			SaldoGlobal,Activo,		ClienteEspecial,ClienteGral,PrecioId,	GiroId
		)
		select @pClienteId,@pNombre,@pRFC,@pCalle,@pNumeroExt,@pNumeroInt,
		@pColonia,	@pCodigoPostal,@pEstadoId,@pMunicipioId,@pPaisId,@pTelefono,
		@pTelefono2,@pTipoClienteId,@pDiasCredito,@pLimiteCredito,@pAntecedenteId,@pCreditoDisponible,
		@pSaldoGlobal,1,@pClienteEspecial,@pClienteGral,@pPrecioId,@pGiroId


	

	End
	Else
	Begin
		update cat_clientes
		set Nombre = @pNombre,		RFC=@pRFC,		Calle=@pCalle,		NumeroExt=@pNumeroExt,		
			NumeroInt=@pNumeroInt,	Colonia=@pColonia,	CodigoPostal=@pCodigoPostal,
			EstadoId=@pEstadoId,	
			MunicipioId=@pMunicipioId,
			PaisId=@pPaisId,			
			Telefono=@pTelefono,
			Telefono2=@pTelefono2,	
			TipoClienteId=@pTipoClienteId,
			DiasCredito=@pDiasCredito,
			LimiteCredito=@pLimiteCredito,
			AntecedenteId=@pAntecedenteId,
			CreditoDisponible=@pCreditoDisponible,
			SaldoGlobal=@pSaldoGlobal,
			Activo=@pActivo,		
			ClienteEspecial=@pClienteEspecial,
			ClienteGral=@pClienteGral,
			PrecioId=@pPrecioId,
			GiroId=@pGiroId
		Where ClienteId = @pClienteId
	End

	if isnull(@pClienteAutoId,0) = 0
	begin

		select @pClienteAutoId = isnull(max(ClienteAutoId),0) +1
		from cat_clientes_automovil

		insert into cat_clientes_automovil(
		ClienteAutoId,	ClienteId,	Modelo,	Color,
		Placas,				Observaciones,CreadoEl
		)
		select @pClienteAutoId,@pClienteId, @pModelo,@pColor,
		@pPlacas,@pObservaciones,GETDATE()
	end
	Else
	Begin
		Update cat_clientes_automovil
		set Modelo=@pModelo,	
		Color = @pColor,
		Placas = @pPlacas,				
		Observaciones = @pObservaciones
		where ClienteAutoId = @pClienteAutoId
	End


	


GO
/****** Object:  StoredProcedure [dbo].[p_cat_configuracion_ini_exis]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_cat_configuracion_ini_exis]
@pSucursalId int
as

	declare @exis bit = 1,
			@productosCount int = 0,
			@ticketConfig bit = 0

	select @productosCount = isnull(count(distinct p.Clave),0)
	from cat_productos p
	where p.ProductoId > 0

	select @ticketConfig = 1
	from cat_configuracion_ticket_venta
	where SucursalId = @pSucursalId and
	(
		rtrim(isnull(TextoCabecera1,'')) <> '' OR
		rtrim(isnull(TextoCabecera2,'')) <> '' OR
		rtrim(isnull(TextoPie,'')) <> ''
	)

	set @exis =case when @productosCount = 0 OR @ticketConfig = 0 then 0 else 2 end

	select Existe = @exis
	


	

GO
/****** Object:  StoredProcedure [dbo].[p_cat_configuracion_ins_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[p_cat_configuracion_ins_upd]
@pConfiguradorId	int,
@pUnaFormaPago	bit,
@pMasUnaFormaPago	bit,
@pCosteoUEPS	bit,
@pCosteoPEPS	bit,
@pCosteoPromedio	bit,
@pAfectarInventarioLinea	bit,
@pAfectarInventarioManual	bit,
@pAfectarInventarioCorte	bit,
@pEnlazarPuntoVentaInventario	bit,
@pCajeroIncluirDetalleVenta	bit,
@pCajeroReqClaveSupervisor	bit,
@pSuperIncluirDetalleVenta	bit,
@pSuperIncluirVentaTel	bit,
@pSuperIncluirDetGastos	bit,
@pSuperEmail1	varchar(100),
@pSuperEmail2	varchar(100),
@pSuperEmail3	varchar(100),
@pSuperEmail4	varchar(100),
@pRetiroMontoEfec	money,
@pRetiroLectura	bit,
@pRetiroEscritura	bit,
@pNombreImpresora	varchar(200),
@pHardwareCaracterCajon	varchar(50),
@pEmpleadoPorcDescuento	decimal(5,2),
@pEmpleadoGlobal	bit,
@pEmpleadoIndividual	bit,
@pMontoImpresionTicket	money,
@pApartadoAnticipo1	money,
@pApartadoAnticipoHasta1	money,
@pApartadoAnticipo2	money,
@pApatadoAnticipoEnAdelante2	money,
@pPorcentajeUtilidadProd	decimal(5,2),
@pDesgloceMontoTicket	bit,
@pRetiroReqClaveSup bit,
@pCajDeclaracionFondoCorte bit,
@pSupDeclaracionFondoCorte bit,
@pvistaPreviaImpresion bit,
@pCajeroCorteDetGasto bit,
@pSupCorteDetGasto bit,
@pCajeroCorteCancelaciones bit,
@pSupCorteCancelaciones bit,
@pDevDiasVale	tinyint,
@pDevDiasGarantia	tinyint,
@pDevHorasGarantia	tinyint,
@pApartadoDiasLiq tinyint,
@pApartadoDiasProrroga tinyint,
@pReqClaveSupReimpresionTicketPV	bit,
@pReqClaveSupCancelaTicketPV	bit,
@pReqClaveSupGastosPV	bit,
@pReqClaveSupDevolucionPV	bit,
@pReqClaveSupApartadoPV	bit,
@pReqClaveSupExistenciaPV	bit,
@pCorteCajaIncluirExistencia bit,
@pImprimirTicketMediaCarta bit,
@pSolicitarComanda bit,
@pGiro varchar(50),
@pPedidoAnticipoPorc decimal(5,2),
@pPedidoPoliticaId int
as

	update cat_configuracion
	set 
		UnaFormaPago = @pUnaFormaPago,
		MasUnaFormaPago=@pMasUnaFormaPago,
		CosteoUEPS=@pCosteoUEPS,
		CosteoPEPS=@pCosteoPEPS,
		CosteoPromedio=@pCosteoPromedio,
		AfectarInventarioLinea=@pAfectarInventarioLinea,
		AfectarInventarioManual=@pAfectarInventarioManual,
		AfectarInventarioCorte=@pAfectarInventarioCorte,
		EnlazarPuntoVentaInventario=@pEnlazarPuntoVentaInventario,
		CajeroIncluirDetalleVenta=@pCajeroIncluirDetalleVenta,
		CajeroReqClaveSupervisor=@pCajeroReqClaveSupervisor,
		SuperIncluirDetalleVenta=@pSuperIncluirDetalleVenta,
		SuperIncluirVentaTel=@pSuperIncluirVentaTel,
		SuperIncluirDetGastos=@pSuperIncluirDetGastos,
		SuperEmail1=@pSuperEmail1,
		SuperEmail2=@pSuperEmail2,
		SuperEmail3=@pSuperEmail3,
		SuperEmail4=@pSuperEmail4,
		RetiroMontoEfec=@pRetiroMontoEfec,
		RetiroLectura=@pRetiroLectura,
		RetiroEscritura=@pRetiroEscritura,
		NombreImpresora=@pNombreImpresora,
		HardwareCaracterCajon=@pHardwareCaracterCajon,
		EmpleadoPorcDescuento=@pEmpleadoPorcDescuento,
		EmpleadoGlobal=@pEmpleadoGlobal,
		EmpleadoIndividual=@pEmpleadoIndividual,
		MontoImpresionTicket=@pMontoImpresionTicket,
		ApartadoAnticipo1=@pApartadoAnticipo1,
		ApartadoAnticipoHasta1=@pApartadoAnticipoHasta1,
		ApartadoAnticipo2=@pApartadoAnticipo2,
		ApatadoAnticipoEnAdelante2=@pApatadoAnticipoEnAdelante2,
		PorcentajeUtilidadProd=@pPorcentajeUtilidadProd,
		DesgloceMontoTicket=@pDesgloceMontoTicket,
		RetiroReqClaveSup = @pRetiroReqClaveSup,
		CajDeclaracionFondoCorte = @pCajDeclaracionFondoCorte,
		SupDeclaracionFondoCorte = @pSupDeclaracionFondoCorte,
		vistaPreviaImpresion=@pvistaPreviaImpresion,
		CajeroCorteDetGasto = @pCajeroCorteDetGasto,
		SupCorteDetGasto = @pSupCorteDetGasto,
		CajeroCorteCancelaciones = @pCajeroCorteCancelaciones,
		SupCorteCancelaciones = @pSupCorteCancelaciones,
		DevDiasVale = @pDevDiasVale,
		DevDiasGarantia=@pDevDiasGarantia,
		DevHorasGarantia=@pDevHorasGarantia,
		ApartadoDiasLiq = @pApartadoDiasLiq,
		ApartadoDiasProrroga = @pApartadoDiasProrroga,
		ReqClaveSupReimpresionTicketPV	=@pReqClaveSupReimpresionTicketPV,
		ReqClaveSupCancelaTicketPV	=@pReqClaveSupCancelaTicketPV,
		ReqClaveSupGastosPV	=@pReqClaveSupGastosPV,
		ReqClaveSupDevolucionPV	=@pReqClaveSupDevolucionPV,
		ReqClaveSupApartadoPV	=@pReqClaveSupApartadoPV,
		ReqClaveSupExistenciaPV	=@pReqClaveSupExistenciaPV,
		CorteCajaIncluirExistencia = @pCorteCajaIncluirExistencia,
		ImprimirTicketMediaCarta = @pImprimirTicketMediaCarta,
		SolicitarComanda = @pSolicitarComanda,
		Giro = @pGiro,
		PedidoAnticipoPorc = @pPedidoAnticipoPorc,
		PedidoPoliticaId = @pPedidoPoliticaId
where ConfiguradorId = 1















GO
/****** Object:  StoredProcedure [dbo].[p_cat_configuracion_rec_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_cat_configuracion_rec_upd]
@pAplicaRec bit
as

	if exists(
		select 1
		from  sys.databases
		where name = 'ERPTemp'
	)
	begin
		update ERPTemp..cat_configuracion
		set TieneRec = @pAplicaRec
	end

	if exists(
		select 1
		from  sys.databases
		where name = 'ERPProd'
	)
	begin
		update ERPProd..cat_configuracion
		set TieneRec = @pAplicaRec
	end

	

	
GO
/****** Object:  StoredProcedure [dbo].[p_cat_configuracion_rest_ins_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_cat_configuracion_rest_ins_upd]
@pId int,
@pSolicitarFolioComanda bit
as

	if not exists(
		select 1
		from [cat_configuracion_restaurante]
	)
	begin
		set @pId = 1

		insert into [cat_configuracion_restaurante]
		select @pId,@pSolicitarFolioComanda
		
	end
	Else
	begin

		update [cat_configuracion_restaurante]
		set SolicitarFolioComanda = @pSolicitarFolioComanda
	end
GO
/****** Object:  StoredProcedure [dbo].[p_cat_configuracion_ticket_apartado_ins_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[p_cat_configuracion_ticket_apartado_ins_upd]
@pConfiguracionTicketVentaId	int OUT,
@pSucursalId	int,
@pTextoCabecera1	varchar(250),
@pTextoCabecera2	varchar(250),
@pTextoPie	varchar(250),
@pCreadoPor	int,
@pSerieTicket varchar(5)
as

	if(isnull(@pConfiguracionTicketVentaId,0) = 0)
	begin
		select @pConfiguracionTicketVentaId = isnull(max(ConfiguracionTicketVentaId),0) + 1
		from cat_configuracion_ticket_apartado


		insert into cat_configuracion_ticket_apartado(
		ConfiguracionTicketVentaId,		SucursalId,		TextoCabecera1,		TextoCabecera2,
		TextoPie,						CreadoEl,		CreadoPor,			Serie
		)
		values(
			@pConfiguracionTicketVentaId,		@pSucursalId,		@pTextoCabecera1,		@pTextoCabecera2,
			@pTextoPie,						getdate(),		@pCreadoPor,	@pSerieTicket
		)
	end
	Else
	begin

		update cat_configuracion_ticket_apartado
		set TextoCabecera1 = @pTextoCabecera1,
			TextoCabecera2 = @pTextoCabecera2,
			TextoPie = @pTextoPie,
			Serie = @pSerieTicket
		where ConfiguracionTicketVentaId = @pConfiguracionTicketVentaId
	End

	





GO
/****** Object:  StoredProcedure [dbo].[p_cat_configuracion_ticket_venta_ins_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[p_cat_configuracion_ticket_venta_ins_upd]
@pConfiguracionTicketVentaId	int OUT,
@pSucursalId	int,
@pTextoCabecera1	varchar(250),
@pTextoCabecera2	varchar(250),
@pTextoPie	varchar(250),
@pCreadoPor	int,
@pSerieTicket varchar(5)
as

	if(isnull(@pConfiguracionTicketVentaId,0) = 0)
	begin
		select @pConfiguracionTicketVentaId = isnull(max(ConfiguracionTicketVentaId),0) + 1
		from cat_configuracion_ticket_venta


		insert into cat_configuracion_ticket_venta(
		ConfiguracionTicketVentaId,		SucursalId,		TextoCabecera1,		TextoCabecera2,
		TextoPie,						CreadoEl,		CreadoPor,			Serie
		)
		values(
			@pConfiguracionTicketVentaId,		@pSucursalId,		@pTextoCabecera1,		@pTextoCabecera2,
			@pTextoPie,						getdate(),		@pCreadoPor,	@pSerieTicket
		)
	end
	Else
	begin

		update cat_configuracion_ticket_venta
		set TextoCabecera1 = @pTextoCabecera1,
			TextoCabecera2 = @pTextoCabecera2,
			TextoPie = @pTextoPie,
			Serie  = @pSerieTicket
		where ConfiguracionTicketVentaId = @pConfiguracionTicketVentaId
	End

	

	





GO
/****** Object:  StoredProcedure [dbo].[p_cat_gastos_deducibles_del]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_cat_gastos_deducibles_del]
	@Id INT
AS
BEGIN
	DELETE cat_gastos_deducibles
	
	WHERE Id = @Id
END
GO
/****** Object:  StoredProcedure [dbo].[p_cat_gastos_deducibles_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_cat_gastos_deducibles_ins]
	@Id INT OUT,
	@GastoConceptoId INT
AS
BEGIN
	INSERT INTO cat_gastos_deducibles (GastoConceptoId, CreadoEl)
	VALUES (@GastoConceptoId, GETDATE())

	SET @Id = SCOPE_IDENTITY()
END
GO
/****** Object:  StoredProcedure [dbo].[p_cat_gastos_deducibles_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[p_cat_gastos_deducibles_sel]
AS

	SELECT Id=ISNULL(GD.Id,0),
		GastoConceptoId = ISNULL(G.Clave,0),
		GastoConcepto = g.Descripcion,
		CreadoEl = GD.CreadoEl
	FROM cat_gastos G
	LEFT JOIN cat_gastos_deducibles GD ON GD.GastoConceptoId = G.Clave
	ORDER BY ISNULL(GD.Id,0) DESC

	
	
GO
/****** Object:  StoredProcedure [dbo].[p_cat_gastos_deducibles_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_cat_gastos_deducibles_upd]
	@Id INT,
	@GastoConceptoId INT,
	@CreadoEl DATETIME
AS
BEGIN
	UPDATE cat_gastos_deducibles
	SET GastoConceptoId = @GastoConceptoId,
		CreadoEl = @CreadoEl
	WHERE Id = @Id
END
GO
/****** Object:  StoredProcedure [dbo].[p_cat_gatos_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[p_cat_gatos_sel]
AS

	select Clave,
	Descripcion,
	ClaveCentroCosto,
	Estatus,
	Empresa,
	Sucursal,
	Monto,
	Observaciones,
	ConceptoId,
	CreadoPor,
	CreadoEl,
	CajaId
	from [dbo].[cat_gastos]
GO
/****** Object:  StoredProcedure [dbo].[p_cat_impuestos_grd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_cat_impuestos_grd ''
	CREATE PROC [dbo].[p_cat_impuestos_grd]
@pBuscar VARCHAR(100)
AS

	SELECT imp.Clave,
			imp.CodigoSAT,
			imp.Descripcion,
			Abreviatura = abr.AbreviaturaSAT,
			imp.OrdenImpresion,
			Clasificacion = cla.NombreSAT,
			TipoFactor = fac.NombreFactorSAT,
			imp.Porcentaje,
			imp.CuotaFija,
			imp.DecimalesPorcCuota,
			imp.DesglosarImpPrecioVta,
			imp.AgregarImpPrecioVta 
	FROM dbo.cat_impuestos imp
	INNER JOIN dbo.cat_tipo_factor_SAT fac ON fac.Clave = imp.IdTipoFactor
	INNER JOIN dbo.cat_clasificacion_impuestos cla ON cla.Clave = imp.IdClasificacionImpuesto
	INNER JOIN dbo.cat_abreviaturas_SAT abr ON abr.Clave = imp.IdAbreviatura
	WHERE Descripcion LIKE '%'+RTRIM(@pBuscar)+'%' OR @pBuscar = ''





GO
/****** Object:  StoredProcedure [dbo].[p_cat_productos_agrupados_detalle_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_cat_productos_agrupados_detalle_ins]
@pProductoAgrupadoId int,
@pProductoId int
as

	declare @especificaciones varchar(500)

	select @especificaciones = Especificaciones
	from cat_productos_agrupados
	where ProductoAgrupadoId = @pProductoAgrupadoId 

	insert into [dbo].[cat_productos_agrupados_detalle](
		ProductoAgrupadoId,ProductoId,CreadoEl
	)
	select @pProductoAgrupadoId,@pProductoId,getdate()

	--update cat_productos
	--set Especificaciones = @especificaciones
	--where ProductoId = @pProductoId


	update cat_productos 
	set Liquidacion = pa1.Liquidacion
	from cat_productos p
	inner join cat_productos_agrupados_detalle pa on pa.ProductoId = p.ProductoId
	inner join cat_productos_agrupados pa1 on pa1.ProductoAgrupadoId = pa.ProductoAgrupadoId
	where pa1.ProductoAgrupadoId = @pProductoAgrupadoId




GO
/****** Object:  StoredProcedure [dbo].[p_cat_productos_agrupados_ins_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc [dbo].[p_cat_productos_agrupados_ins_upd]
@pProductoAgrupadoId	int out,	
@pProductoId	int,
@pEspecificaciones varchar(500),
@pLiquidacion bit
as

	declare @Descripcion	varchar(60),
			@DescripcionCorta	varchar(30)

	select @Descripcion =Descripcion ,
		@DescripcionCorta = DescripcionCorta,
		@pEspecificaciones = Especificaciones
	from cat_productos
	where ProductoId =@pProductoId 

	if isnull(@pProductoAgrupadoId,0) = 0
	begin

		select @pProductoAgrupadoId = isnull(max(ProductoAgrupadoId),0) + 1
		from cat_productos_agrupados
		
		insert into cat_productos_agrupados(
			ProductoAgrupadoId,Descripcion,DescripcionCorta,CreadoEl,Especificaciones,ProductoId,
			Liquidacion
		)
		values(
			@pProductoAgrupadoId,@Descripcion,@DescripcionCorta,getdate(),@pEspecificaciones,@pProductoId,
			@pLiquidacion
		)

		insert into cat_productos_agrupados_detalle(ProductoAgrupadoId,ProductoId,CreadoEl)
		values(@pProductoAgrupadoId,@pProductoId,getdate())
	end
	Else
	Begin
		
		update 	cat_productos_agrupados
		set Descripcion=@Descripcion,
			DescripcionCorta=@DescripcionCorta,
			Especificaciones=@pEspecificaciones,
			ProductoId = @pProductoId,
			Liquidacion = @pLiquidacion
		where ProductoAgrupadoId = @pProductoAgrupadoId


		--update cat_productos
		--set Especificaciones = CASE WHEN ISNULL(@pEspecificaciones,'') = '' THEN Especificaciones
		--						ELSE @pEspecificaciones
		--						end
		--from cat_productos p
		--inner join cat_productos_agrupados pa on pa.ProductoId = p.ProductoId
		--where pa.ProductoAgrupadoId = @pProductoAgrupadoId

	End

	update cat_productos 
	set Liquidacion = @pLiquidacion
	from cat_productos p
	inner join cat_productos_agrupados_detalle pa on pa.ProductoId = p.ProductoId
	where pa.ProductoAgrupadoId = @pProductoAgrupadoId

	


GO
/****** Object:  StoredProcedure [dbo].[p_cat_productos_base_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_cat_productos_base_sel 5
CREATE PROC [dbo].[p_cat_productos_base_sel]
@ProductoId INT
as

	SELECT 
		PB.ProductoMateriaPrimaId,
		P.ProductoId,
		Producto = P.DescripcionCorta,
		PB.ProductoBaseId,
		ProductoBase = P2.DescripcionCorta,		
		PB.Cantidad,
		UnidadId = PB.UnidadCocinaId,
		Unidad = U.DescripcionCorta,
		ProduccionPorUnidadMP = CASE WHEN PB.Cantidad > 0 THEN 1 / PB.Cantidad ELSE 0 END
	FROM cat_productos_base PB
	INNER JOIN cat_productos P ON P.ProductoId = PB.ProductoId
	INNER JOIN cat_productos P2 ON P2.ProductoId = PB.ProductoBaseId
	INNER JOIN cat_unidadesmed U ON U.Clave = PB.UnidadCocinaId
	WHERE P.ProductoId = @ProductoId
GO
/****** Object:  StoredProcedure [dbo].[p_cat_productos_config_sucursal_ins_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[p_cat_productos_config_sucursal_ins_upd]
@pProductoId	int,
@pSucursalId	int,
@pCalculaPrecioPorcUtilidad	bit,
@pCalculaPrecioIncUtilidad	bit,
@pCalculaPrecioManual	bit,
@pPorcUtilidadValor	decimal(6,2),
@pIncUtilidadValor	money,
@pCreadoPor	int
as

	if not exists (
		select 1
		from cat_productos_config_sucursal
		where productoid = @pProductoId and
		sucursalid = @pSucursalId
	)
	begin

		insert into [cat_productos_config_sucursal](
			ProductoId,			SucursalId,		CalculaPrecioPorcUtilidad,		CalculaPrecioIncUtilidad,
			CalculaPrecioManual,CreadoPor,		CreadoEl,						PorcUtilidadValor,
			IncUtilidadValor
		)
		values(
			@pProductoId,			@pSucursalId,		@pCalculaPrecioPorcUtilidad,		@pCalculaPrecioIncUtilidad,
			@pCalculaPrecioManual,	@pCreadoPor,		getdate(),				@pPorcUtilidadValor,
			@pIncUtilidadValor
		)
		
	end
	else
	begin
		update [cat_productos_config_sucursal]
		set CalculaPrecioPorcUtilidad = @pCalculaPrecioPorcUtilidad,		
			CalculaPrecioIncUtilidad = @pCalculaPrecioIncUtilidad,
			CalculaPrecioManual = @pCalculaPrecioManual,
			PorcUtilidadValor = @pPorcUtilidadValor,
			IncUtilidadValor = @pIncUtilidadValor
		where ProductoId = @pProductoId and
		SucursalId = @pSucursalId
		
	end







GO
/****** Object:  StoredProcedure [dbo].[p_cat_productos_grd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_cat_productos_grd 1
CREATE proc [dbo].[p_cat_productos_grd]
@pEmpresaId int
as

	select p.ProductoId,
			p.Clave,
			p.Descripcion,
			p.DescripcionCorta,
			p.FechaAlta,
			p.ClaveMarca,
			Marca =mar.Descripcion,
			p.ClaveFamilia,
			Familia = fam.Descripcion,
			p.ClaveSubFamilia,
			Subfamilia = sfam.Descripcion,
			p.ClaveLinea,
			Linea = li.Descripcion,
			p.ClaveUnidadMedida,
			Unidad = um.Descripcion,
			p.ClaveInventariadoPor,
			p.ClaveVendidaPor,
			p.Estatus,
			p.ProductoTerminado,
			p.Inventariable,
			p.MateriaPrima,
			p.ProdParaVenta,
			p.ProdVtaBascula,
			p.Seriado,
			p.NumeroDecimales,
			p.PorcDescuentoEmpleado,
			p.ContenidoCaja,
			p.Empresa,
			p.Sucursal,
			p.ClaveAlmacen,
			p.ClaveAnden,
			p.ClaveLote,
			p.FechaCaducidad,
			p.MinimoInventario,
			p.MaximoInventario,
			p.PorcUtilidad,
			p.Talla,
			p.ParaSexo,
			p.Color,
			p.Color2,
			p.SobrePedido,
			p.Especificaciones,
			p.Liquidacion ,
			Foto = FileByte
	from cat_productos p
	left join cat_productos_imagenes pi on pi.ProductoId = p.ProductoId and
									pi.Principal = 1
	inner join cat_familias fam on fam.Clave = p.ClaveFamilia
	inner join cat_subfamilias sfam on sfam.Clave = p.ClaveSubFamilia
	inner join cat_lineas li on li.Clave = p.ClaveLinea
	inner join cat_unidadesmed um on um.Clave = p.ClaveUnidadMedida
	left join cat_marcas mar on mar.Clave = p.ClaveMarca
	WHERE P.empresa = @pEmpresaId
GO
/****** Object:  StoredProcedure [dbo].[p_cat_productos_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROC [dbo].[p_cat_productos_ins]
@pProductoId	int out,
@pClave	varchar(30),
@pDescripcion	varchar(60),
@pDescripcionCorta	varchar(30),
@pFechaAlta	date,
@pClaveMarca	int,
@pClaveFamilia	int,
@pClaveSubFamilia	int,
@pClaveLinea	int,
@pClaveUnidadMedida	int,
@pClaveInventariadoPor	int,
@pClaveVendidaPor	int,
@pEstatus	bit,
@pProductoTerminado	bit,
@pInventariable	bit,
@pMateriaPrima	bit,
@pProdParaVenta	bit,
@pProdVtaBascula	bit,
@pSeriado	bit,
@pNumeroDecimales	tinyint,
@pPorcDescuentoEmpleado	numeric(19,2),
@pContenidoCaja	int,
@pEmpresa	int,
@pSucursal	INT,
@pFoto	IMAGE,
@pClaveAlmacen INT,
@pClaveAnden INT,
@pClaveLote INT,
@pFechaCaducidad DATETIME,
@pMinimoInventario DECIMAL(14,2),
@pMaximoInventario DECIMAL(14,2),
@pPorcUtilidad decimal(5,2),
@pTalla varchar(5),
@pColor varchar(10),
@pColor2 varchar(10),
@pEspecificaciones varchar(500),
@pSobrePedido bit
as


SELECT @pProductoId = ISNULL(MAX(ProductoId),0) + 1
FROM dbo.cat_productos


INSERT INTO dbo.cat_productos
(
    ProductoId,
    Clave,
    Descripcion,
    DescripcionCorta,
    FechaAlta,
    ClaveMarca,
    ClaveFamilia,
    ClaveSubFamilia,
    ClaveLinea,
    ClaveUnidadMedida,
    ClaveInventariadoPor,
    ClaveVendidaPor,
    Estatus,
    ProductoTerminado,
    Inventariable,
    MateriaPrima,
    ProdParaVenta,
    ProdVtaBascula,
    Seriado,
    NumeroDecimales,
    PorcDescuentoEmpleado,
    ContenidoCaja,
    Empresa,
    Sucursal,
    Foto,
	ClaveAlmacen,
	ClaveAnden,
	ClaveLote,
	FechaCaducidad,
	MinimoInventario,
	MaximoInventario,
	PorcUtilidad,
	Talla,
	Color,
	Color2,
	Especificaciones,
	SobrePedido,
	CodigoBarras
)
VALUES
(	@pProductoId,
    @pClave,
    @pDescripcion,
    @pDescripcionCorta,
    @pFechaAlta,
    @pClaveMarca,
    @pClaveFamilia,
    @pClaveSubFamilia,
    @pClaveLinea,
    @pClaveUnidadMedida,
    @pClaveInventariadoPor,
    @pClaveVendidaPor,
    @pEstatus,
    @pProductoTerminado,
    @pInventariable,
    @pMateriaPrima,
    @pProdParaVenta,
    @pProdVtaBascula,
    @pSeriado,
    @pNumeroDecimales,
    @pPorcDescuentoEmpleado,
    @pContenidoCaja,
    @pEmpresa,
    @pSucursal,
    @pFoto,
	@pClaveAlmacen,
	@pClaveAnden,
	@pClaveLote,
	@pFechaCaducidad,
	@pMinimoInventario,
	@pMaximoInventario,
	@pPorcUtilidad,
	@pTalla,
	@pColor,
	@pColor2,
	@pEspecificaciones,
	@pSobrePedido,
	@pClave
    )	


insert into cat_productos_existencias(
	ProductoId,	SucursalId,	ExistenciaTeorica,	CostoUltimaCompra,
	CostoPromedio,	ValCostoUltimaCompra,	ValCostoPromedio,
	ModificadoEl,	CreadoEl
)
select @pProductoId,@pSucursal,0,0,0,0,0,getdate(),getdate()

















GO
/****** Object:  StoredProcedure [dbo].[p_cat_productos_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[p_cat_productos_upd]
@pProductoId	int,
@pClave	varchar(30),
@pDescripcion	varchar(60),
@pDescripcionCorta	varchar(30),
@pFechaAlta	date,
@pClaveMarca	int,
@pClaveFamilia	int,
@pClaveSubFamilia	int,
@pClaveLinea	int,
@pClaveUnidadMedida	int,
@pClaveInventariadoPor	int,
@pClaveVendidaPor	int,
@pEstatus	bit,
@pProductoTerminado	bit,
@pInventariable	bit,
@pMateriaPrima	bit,
@pProdParaVenta	bit,
@pProdVtaBascula	bit,
@pSeriado	bit,
@pNumeroDecimales	tinyint,
@pPorcDescuentoEmpleado	numeric(19,2),
@pContenidoCaja	int,
@pEmpresa	int,
@pSucursal	INT,
@pFoto	IMAGE,
@pClaveAlmacen INT,
@pClaveAnden INT,
@pClaveLote INT,
@pFechaCaducidad datetime,
@pMinimoInventario DECIMAL(14,2),
@pMaximoInventario DECIMAL(14,2),
@pPorcUtilidad decimal(5,2),
@pTalla varchar(5),
@pColor varchar(10),
@pColor2 varchar(10),
@pEspecificaciones varchar(500),
@pSobrePedido bit
as

update dbo.cat_productos
set
    
    Clave = @pClave,
    Descripcion = @pDescripcion,
    DescripcionCorta = @pDescripcionCorta,
    --FechaAlta = @pFechaAlta,
    ClaveMarca = @pClaveMarca,
    ClaveFamilia = @pClaveFamilia,
    ClaveSubFamilia = @pClaveSubFamilia,
    ClaveLinea = @pClaveLinea,
    ClaveUnidadMedida = @pClaveUnidadMedida,
    ClaveInventariadoPor = @pClaveInventariadoPor,
    ClaveVendidaPor = @pClaveVendidaPor,
    Estatus = @pEstatus,
    ProductoTerminado = @pProductoTerminado,
    Inventariable = @pInventariable,
    MateriaPrima = @pMateriaPrima,
    ProdParaVenta = @pProdParaVenta,
    ProdVtaBascula = @pProdVtaBascula,
    Seriado = @pSeriado,
    NumeroDecimales = @pNumeroDecimales,
    PorcDescuentoEmpleado = @pPorcDescuentoEmpleado,
    ContenidoCaja = @pContenidoCaja,
    Empresa = @pEmpresa,
    Sucursal = @pSucursal,
    Foto = @pFoto,
	ClaveAlmacen = @pClaveAlmacen,
	ClaveAnden = @pClaveAnden,
	ClaveLote = @pClaveLote,
	FechaCaducidad = @pFechaCaducidad,
	MinimoInventario = @pMinimoInventario,
	MaximoInventario = @pMaximoInventario,
	PorcUtilidad = @pPorcUtilidad,
	TallA = @pTalla,
	Color = @pColor,
	Color2 = @pColor2,
	Especificaciones = @pEspecificaciones,
	SobrePedido = @pSobrePedido
	WHERE ProductoId = @pProductoId









GO
/****** Object:  StoredProcedure [dbo].[p_cat_rest_comandas_gen]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_cat_rest_comandas_gen]
@pSucursalId int,
@pFolioInicio int,
@pFolioFin int,
@pCreadoPor int
as

	declare @folio int,
			@comandaId int

	select @folio = @pFolioInicio

	while @folio <= @pFolioFin
	begin

		select @comandaId = isnull(max(ComandaId),0)+1
		from cat_rest_comandas

		insert into cat_rest_comandas(
		ComandaId,		SucursalId,		Folio,		Disponible,
		CreadoPor,		CreadoEl
		)
			select @comandaId,@pSucursalId,@folio,1,
			@pCreadoPor,getdate()

		select 	@folio = @folio + 1
	end

	
GO
/****** Object:  StoredProcedure [dbo].[p_cat_rest_mesas_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [p_cat_rest_mesas_sel] 1
CREATE PROC [dbo].[p_cat_rest_mesas_sel]
@pSucursalId INT
AS

	SELECT DISTINCT POM.MesaId
	INTO #TMP_MESAS
	FROM doc_pedidos_orden PO	
	INNER JOIN doc_pedidos_orden_mesa POM ON POM.PedidoOrdenId = PO.PedidoId
	WHERE PO.SucursalId = @pSucursalId AND
	PO.Activo = 1 AND
	PO.VentaId IS NULL

	SELECT M.MesaId,
		SucursalId,
		Nombre,
		Descripcion,
		Activo,
		CreadoEl,
		CreadoPor,
		ModificadoEl,
		ModificadoPor,
		Ocupada = CAST(CASE WHEN TM.MesaId IS NULL THEN 0 ELSE 1 END AS BIT)
	FROM cat_rest_mesas M
	LEFT JOIN #TMP_MESAS TM ON TM.MesaId = M.MesaId
	WHERE SucursalId = @pSucursalId AND
	Activo = 1
GO
/****** Object:  StoredProcedure [dbo].[p_cat_rest_platillo_adicionales_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_cat_rest_platillo_adicionales_sel 1
CREATE PROC [dbo].[p_cat_rest_platillo_adicionales_sel]
@pProductoId INT
AS

	SELECT DISTINCT pa.*
	FROM cat_productos P
	INNER JOIN cat_rest_platillo_adicionales_sfam PAF ON PAF.SubfamiliaId = P.ClaveSubFamilia
	INNER JOIN cat_rest_platillo_adicionales PA ON PA.Id = PAF.PlatilloAdicionalId
	WHERE p.ProductoId = @pProductoId

	UNION 
	
	SELECT PA.*
	FROM cat_rest_platillo_adicionales PA 
	WHERE PA.MostrarSiempre = 1
GO
/****** Object:  StoredProcedure [dbo].[p_cat_subfamilias_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_cat_subfamilias_sel 1
CREATE PROC [dbo].[p_cat_subfamilias_sel]
@pSoloParaVenta BIT=0
AS

	SELECT F.Clave,
			F.Descripcion
	FROM cat_subfamilias F
	INNER JOIN cat_productos P ON F.Clave = P.ClaveSubFamilia
	WHERE @pSoloParaVenta = 0 OR (@pSoloParaVenta = 1 AND P.ProdParaVenta = 1) AND
	F.Descripcion <> 'CARGOS'
	GROUP BY F.Clave,
			F.Descripcion
	ORDER BY F.Descripcion
GO
/****** Object:  StoredProcedure [dbo].[p_cat_sucursales_grd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_cat_sucursales_grd ''
CREATE PROC [dbo].[p_cat_sucursales_grd]
@pText VARCHAR(100)

AS
	SELECT Clave,NombreSucursal,Empresa,Estatus ,
	Calle,
	Colonia,
	NoExt = rtrim(NoExt),
	NoInt  = rtrim(NoInt),
	Ciudad,
	Estado,
	Pais,
	Telefono1,
	Telefono2,
	cp,
	ServidorMailSMTP,
	ServidorMailFrom,
	ServidorMailPort,
	ServidorMailPassword
	FROM dbo.cat_sucursales
	WHERE NombreSucursal LIKE '%'+RTRIM(@pText)+'%'
	OR RTRIM(@pText) = ''
	OR CAST(Clave AS varchar) = @pText









GO
/****** Object:  StoredProcedure [dbo].[p_cat_sucursales_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[p_cat_sucursales_ins]
@pClave	int,
@pEmpresa	int,
@pCalle	varchar(50),
@pColonia	varchar(50),
@pNoExt	nchar(40),
@pNoInt	nchar(40),
@pCiudad	varchar(60),
@pEstado	varchar(60),
@pPais	varchar(60),
@pTelefono1	varchar(40),
@pTelefono2	varchar(40),
@pEmail	varchar(60),
@pEstatus	BIT,
@pNombreSucursal	varchar(60),
@pCp varchar(5),
@pServidorMailSMTP varchar(50),
@pServidorMailFrom varchar(70), 
@pServidorMailPort smallint,
@pServidorMailPassword varchar(50) 
as

INSERT INTO dbo.cat_sucursales
(
    Clave,
    Empresa,
    Calle,
    Colonia,
    NoExt,
    NoInt,
    Ciudad,
    Estado,
    Pais,
    Telefono1,
    Telefono2,
    Email,
    Estatus,
    NombreSucursal,
	cp,
	ServidorMailSMTP,
	ServidorMailFrom,
	ServidorMailPort,
	ServidorMailPassword
)
VALUES
(	@pClave,
    @pEmpresa,
    @pCalle,
    @pColonia,
    @pNoExt,
    @pNoInt,
    @pCiudad,
    @pEstado,
    @pPais,
    @pTelefono1,
    @pTelefono2,
    @pEmail,
    @pEstatus,
    @pNombreSucursal,
	@pcp,
	@pServidorMailSMTP,
	@pServidorMailFrom,
	@pServidorMailPort,
	@pServidorMailPassword
    )






GO
/****** Object:  StoredProcedure [dbo].[p_cat_sucursales_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[p_cat_sucursales_upd]
@pClave	int,
@pEmpresa	int,
@pCalle	varchar(50),
@pColonia	varchar(50),
@pNoExt	nchar(40),
@pNoInt	nchar(40),
@pCiudad	varchar(60),
@pEstado	varchar(60),
@pPais	varchar(60),
@pTelefono1	varchar(40),
@pTelefono2	varchar(40),
@pEmail	varchar(60),
@pEstatus	BIT,
@pNombreSucursal	varchar(60),
@pCp varchar(5),
@pServidorMailSMTP varchar(50),
@pServidorMailFrom varchar(70), 
@pServidorMailPort smallint,
@pServidorMailPassword varchar(50) 
as

update dbo.cat_sucursales
set
    Clave=@pClave,
    Empresa = @pEmpresa,
    Calle = @pCalle,
    Colonia = @pColonia,
    NoExt = @pNoExt,
    NoInt = @pNoInt,
    Ciudad = @pCiudad,
    Estado = @pEstado,
    Pais = @pPais,
    Telefono1 = @pTelefono1,
    Telefono2 = @pTelefono2,
    Email = @pEmail,
    Estatus = @pEstatus,
    NombreSucursal = @pNombreSucursal,
	cp = @pCp,
	ServidorMailSMTP = @pServidorMailSMTP,
	ServidorMailFrom = @pServidorMailFrom,
	ServidorMailPort = @pServidorMailPort,
	ServidorMailPassword=@pServidorMailPassword
	WHERE Clave = @pClave






GO
/****** Object:  StoredProcedure [dbo].[p_cat_usuarios_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_cat_usuarios_sel 1
Create proc [dbo].[p_cat_usuarios_sel]
@pUsuarioId INT
AS

	SELECT u.IdUsuario,
		u.NombreUsuario,
		rh.Nombre,
		rh.NumEmpleado
	FROM cat_usuarios u
	LEFT JOIN rh_empleados RH ON RH.NumEmpleado = u.IdEmpleado
GO
/****** Object:  StoredProcedure [dbo].[p_chart_ventas_mes]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_chart_ventas_mes 0
CREATE PROC [dbo].[p_chart_ventas_mes]
@pSucursalId INT
AS


	DECLARE @Fecha DATETIME = GETDATE()

	CREATE TABLE #TMP_ANIOMES
	(
		Anio INT,
		Mes INT,
		ID INT,
		NombreMes VARCHAR(50)
	)

	INSERT INTO #TMP_ANIOMES(Anio,Mes,ID,NombreMes)
	SELECT YEAR(GETDATE()),MONTH(GETDATE()),1, DATENAME(MONTH,GETDATE())
	UNION
	SELECT YEAR(DATEADD(MONTH,-1,GETDATE())),MONTH(DATEADD(MONTH,-1,GETDATE())),2,DATENAME(MONTH,DATEADD(MONTH,-1,GETDATE()))
	UNION
	SELECT YEAR(DATEADD(MONTH,-2,GETDATE())),MONTH(DATEADD(MONTH,-2,GETDATE())),3,DATENAME(MONTH,DATEADD(MONTH,-2,GETDATE()))

	SELECT Producto = CASE WHEN P.ProductoId IN (1,2) THEN P.Descripcion ELSE 'OTROS' END,
			TMP.ID,
			TMP.Anio,
			TMP.Mes,
			VD.Total,
			TMP.NombreMes
	INTO #TMP_RESULT
	FROM doc_ventas_detalle VD
	INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId AND V.Activo = 1
	INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId
	INNER JOIN #TMP_ANIOMES TMP ON TMP.Anio = YEAR(V.Fecha) AND
									TMP.Mes = MONTH(V.Fecha)
	WHERE @pSucursalId IN(0,V.SucursalId)

	

	SELECT Producto,
		   Mes3 = SUM(CASE WHEN TMP.ID = 1 THEN Total ELSE 0 END),
		   Mes2 = SUM(CASE WHEN TMP.ID = 2 THEN Total ELSE 0 END),
		   Mes1 = SUM(CASE WHEN TMP.ID = 3 THEN Total ELSE 0 END),
		   ID = CAST(ROW_NUMBER() OVER(ORDER BY Producto ASC)  AS INT)
	FROM #TMP_Result TMP
	GROUP BY Producto
	
GO
/****** Object:  StoredProcedure [dbo].[p_chart_ventas_sucursal_meses_series]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_ventas_sucursal_meses 0,6,1
create proc [dbo].[p_chart_ventas_sucursal_meses_series]
@pSucursalId INT,
@pMesesAtras INT=6,
@pTipoResultado INT=1,
@pUsuarioId INT
AS

	

	CREATE TABLE #RESULT_VALUES(
		Mes VARCHAR(250),
		Sucursal1 VARCHAR(100),
		Sucursal2 VARCHAR(100),
		Sucursal3 VARCHAR(100),
		Sucursal4 VARCHAR(100),
		Sucursal5 VARCHAR(100),
		Sucursal6 VARCHAR(100),
		Sucursal7 VARCHAR(100),
		Sucursal8 VARCHAR(100),
		Sucursal9 VARCHAR(100),
		Sucursal10 VARCHAR(100),
		Sucursal11 VARCHAR(100),
		Sucursal12 VARCHAR(100),
		Sucursal13 VARCHAR(100),
		Sucursal14 VARCHAR(100),
		Sucursal15 VARCHAR(100),
		Sucursal16 VARCHAR(100),
		Sucursal17 VARCHAR(100),
		Sucursal18 VARCHAR(100),
		Sucursal19 VARCHAR(100),
		Sucursal20 VARCHAR(100),
		Sucursal21 VARCHAR(100),
		Sucursal22 VARCHAR(100),
		Sucursal23 VARCHAR(100),
		Sucursal24 VARCHAR(100),
		Sucursal25 VARCHAR(100),
		Sucursal26 VARCHAR(100),
		Sucursal27 VARCHAR(100),
		Sucursal28 VARCHAR(100),
		Sucursal29 VARCHAR(100),
		Sucursal30 VARCHAR(100),
		Sucursal31 VARCHAR(100),
		Sucursal32 VARCHAR(100),
		Sucursal33 VARCHAR(100),
		Sucursal34 VARCHAR(100),
		Sucursal35 VARCHAR(100),
		Sucursal36 VARCHAR(100),
		Sucursal37 VARCHAR(100),
		Sucursal38 VARCHAR(100),
		Sucursal39 VARCHAR(100),
		Sucursal40 VARCHAR(100)

	
	)

	declare @FechaInicio DATETIME=dateadd(MONTH,-@pMesesAtras,GETDATE())

	SET @FechaInicio = DATEADD(month, DATEDIFF(month, 0, @FechaInicio), 0)

	SELECT SucursalId= S.Clave,
		Sucursal = S.NombreSucursal,
		V.Fecha,
		v.TotalVenta
	INTO #TMP_VENTAS
	FROM cat_sucursales S
	
	INNER JOIN doc_ventas V ON V.SucursalId = S.Clave AND
						@pSucursalId IN(0,S.Clave) AND
						CAST(V.Fecha AS DATE) BETWEEN  CAST(@FechaInicio AS DATE) AND CAST(GETDATE() AS DATE)


	
	
	SELECT 
		
		i=IDENTITY(int,1,1),
		SucursalId = R.SucursalId,
		R.Sucursal
	INTO #TMP_SUCURSALES
	FROM #TMP_VENTAS R
	GROUP BY R.SucursalId,R.Sucursal
	ORDER BY R.Sucursal

	SELECT * FROM #TMP_SUCURSALES
GO
/****** Object:  StoredProcedure [dbo].[p_cliente_web_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[p_cliente_web_ins]
@pClienteId int out,
@pEmail varchar(150),
@pPassword varchar(20),
@pNombre varchar(500)
as
begin
	select @pClienteId = isnull(MAX(ClienteId),0) + 1
	from [cat_clientes]

	begin tran

	insert into [dbo].[cat_clientes](
		ClienteId,Nombre,Activo
	)
	select @pClienteId,@pNombre,1

	if @@ERROR <> 0
	begin
		rollback tran
		goto fin
	end

	insert into [dbo].[cat_clientes_web](
		ClienteId,Email,Password,CreadoEl
	)
	select @pClienteId,@pEmail,@pPassword,GETDATE()

	if @@ERROR <> 0
	begin
		rollback tran
		goto fin
	end


	commit tran

	fin:
	end




GO
/****** Object:  StoredProcedure [dbo].[p_corte_caja_generacion]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- p_corte_caja_generacion 20,1,'2022-12-02 23:06:34.020',0,1
CREATE Proc [dbo].[p_corte_caja_generacion]
@pCajaId int,
@pUsuarioId int,
@pFechaHoraCorte datetime,
@pCorteCajaId int out,
@pPermitirCorteEnCero bit
as


	declare @fechaUltimoCorte datetime,
		@corteCajaId int,
		@gastos money,
		@retiros money,
		@ventaIniId int,
		@ventaFinId int,
		@sucursalId int,
		@esSupervisorGral bit,
		@cajeroOrigId int,
		@totalApartados money,
		@error varchar(300)


	


	select @esSupervisorGral = usu.EsSupervisor
	from cat_usuarios usu
	where usu.IdUsuario = @pUsuarioId	


	select @pFechaHoraCorte = case when max(Fecha) > dbo.fn_GetDateTimeServer() then max(Fecha) else dbo.fn_GetDateTimeServer() end
	from doc_ventas
	where activo = 1

	set @pFechaHoraCorte = isnull(@pFechaHoraCorte,dbo.fn_GetDateTimeServer())


	select @fechaUltimoCorte = isnull(max(FechaCorte),'19000101')
	from doc_corte_caja
	where CajaId = @pCajaId

	select @sucursalId  =Sucursal
	from cat_cajas
	where Clave = @pCajaId

	
	--exec	p_doc_ventas_rec @sucursalId,@error out,@pCajaId,@pUsuarioId,@pFechaHoraCorte,@pCorteCajaId,@pPermitirCorteEnCero
	

	if(isnull(@error,'') <> '')
	begin
		RAISERROR (15600,-1,-1, @error);  
		return
	end


	if @fechaUltimoCorte = '19000101' 
	begin
		select @fechaUltimoCorte = min(Fecha)
		from doc_ventas
		where CajaId = @pCajaId
	end

	begin tran

	select @corteCajaId = isnull(max(CorteCajaId),0) + 1
	from doc_corte_caja

	select @pCorteCajaId = @corteCajaId


	--validar CANCELACIONES
	if not exists(
		select 1
		from doc_ventas v
		where cajaId = @pCajaId and
		FechaCancelacion between 
		@fechaUltimoCorte and @pFechaHoraCorte
		and v.activo = 1 
		--and (
		--	UsuarioCreacionId = @pUsuarioId or
		--	@esSupervisorGral = 1
		--)
	)
	--validar retiros
	and not exists(
		select 1
		from doc_retiros r
		where 
		--(
		--	r.CreadoPor = @pUsuarioId or
		--	@esSupervisorGral = 1
		--) and
		r.CajaId = @pCajaId and
		r.FechaRetiro between @fechaUltimoCorte and @pFechaHoraCorte
	)
	--validar gastos
	and not exists(
		select 1
		from doc_gastos g
		where g.CajaId = @pCajaId and
		--(
		--	g.CreadoPor = @pUsuarioId or
		--	@esSupervisorGral = 1
		--) and
		g.CreadoEl between @fechaUltimoCorte and @pFechaHoraCorte
	)
	--validar devoluciones
	and not exists(
		select 1
		from doc_devoluciones dev
		where 
		--(
		--	dev.CreadoPor = @pUsuarioId or
		--	@esSupervisorGral = 1
		--) and
		dev.CreadoEl between @fechaUltimoCorte and @pFechaHoraCorte
		
	)
		
	--validar apartados
	and not exists (
		select 1
		from doc_apartados a
		inner join doc_apartados_pagos ap on ap.ApartadoId = a.ApartadoId
		where a.CajaId = @pCajaId  and
		ap.FechaPago between 
		@fechaUltimoCorte and @pFechaHoraCorte and
		a.Activo = 1 
		--and
		--(
		--	ap.CreadoPor = @pUsuarioId or
		--	@esSupervisorGral = 1
		--)
	)	
	--
	if not exists (
		select 1
		from doc_ventas v
		where cajaId = @pCajaId and
		Fecha between 
		@fechaUltimoCorte and @pFechaHoraCorte
		and v.activo = 1 
		--and (
		--	v.UsuarioCreacionId = @pUsuarioId 
		--	or
		--	@esSupervisorGral = 1
		--)
		having isnull(max(ventaid),0) > 0
	)	
	AND @pPermitirCorteEnCero = 0
	begin
		RAISERROR (15600,-1,-1, 'No hay movimientos para generar el corte');  
		
		goto fin
	
	end

	/************LIMITAR LAS VENTAS QUE SE PUEDEN CONSIDERAR EN EL CORTE*****************/
	select *
	into #tmpVentas
	from doc_ventas
	where cajaId = @pCajaId and
	Fecha between 
	@fechaUltimoCorte and @pFechaHoraCorte --AND
	--(
	--	UsuarioCreacionId = @pUsuarioId
	--	or
	--	@esSupervisorGral = 1
	--)
	--Quitar los tickets de apartados
	and ventaId not in (
		select VentaId
		from doc_apartados
		where isnull(ventaid,0) > 0
	) AND VentaId NOT IN (
		SELECT VentaId 
		FROM doc_corte_caja_ventas
	)
	ORDER BY VentaId

	if(@esSupervisorGral = 1)
		select @cajeroOrigId = UsuarioCreacionId
		from #tmpVentas

	select @totalApartados = isnull(Sum(Cantidad),0)
	from [dbo].[doc_apartados_formas_pago] fp
	inner join doc_apartados_pagos ap on ap.ApartadoPagoId = fp.ApartadoPagoId
	where ap.Cajaid = @pCajaId AND
	FechaPago between @fechaUltimoCorte and @pFechaHoraCorte 
	group by fp.FormaPagoId

	

	insert into doc_corte_caja(
		CorteCajaId,	CajaId,		CreadoEl,		CreadoPor,
		VentaIniId,		VentaFinId,	FechaApertura,	FechaCorte,
		TotalCorte,		TotalIngresos,TotalEgresos)
	select @corteCajaId, @pCajaId, dbo.fn_GetDateTimeServer(),		@pUsuarioId,
		min(VentaId),	max(ventaid),@fechaUltimoCorte,	@pFechaHoraCorte,
		isnull(sum(
			case when v.Activo = 1 then TotalVenta 
				else 0
			end
		),0)+ isnull(@totalApartados,0), 
		isnull(sum(case when v.Activo = 1 then TotalVenta 
				else 0
			end),0) + isnull(@totalApartados,0),			0
	from #tmpVentas v
	--where cajaId = @pCajaId and
	--Fecha between 
	--@fechaUltimoCorte and @pFechaHoraCorte AND
	--UsuarioCreacionId = @pUsuarioId
	

	
	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end


	insert into doc_corte_caja_ventas(CorteId,VentaId,CreadoEl)
	select @corteCajaId, v.VentaId,dbo.fn_GetDateTimeServer()
	from #tmpVentas v

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	select @gastos = isnull(sum(Monto),0)
	from doc_gastos
	where activo = 1 and
	cajaid = @pCajaId and
	creadoEl between @fechaUltimoCorte and @pFechaHoraCorte 
	--and
	--(
	--	CreadoPor = @pUsuarioId
	--	or
	--	@esSupervisorGral = 1
	--)

	select @retiros = sum(MontoRetiro)
	from doc_retiros r
	where r.SucursalId = @sucursalId AND
	--(
	--	r.CreadoPor = @pUsuarioId
	--	or
	--	@esSupervisorGral = 1
	--) and
	r.CajaId = @pCajaId and
	r.FechaRetiro  between @fechaUltimoCorte and @pFechaHoraCorte 


	update doc_corte_caja
	set TotalEgresos = isnull(@gastos,0) + isnull(@retiros,0)
	where CorteCajaId = @corteCajaId

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	insert into doc_corte_caja_egresos(CorteCajaId,Gastos)
	select @corteCajaId,@gastos

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	select @ventaIniId=VentaIniId,
		@ventaFinId=VentaFinId
	from doc_corte_caja
	where cortecajaId = @corteCajaId

	SELECT @ventaIniId,@ventaFinId

	insert into [dbo].[doc_corte_caja_fp](
		CorteCajaId,FormaPagoId,Total,CreadoEl
	)
	select @corteCajaId,vfp.FormaPagoId,sum(ISNULL(Cantidad,0)),dbo.fn_GetDateTimeServer()
	from [dbo].[doc_ventas_formas_pago] vfp
	inner join #tmpVentas v on v.ventaId = vfp.ventaId
	where v.VentaId between @ventaIniId and @ventaFinId
	and v.Activo = 1	AND
	vfp.Cantidad < 100000
	group by vfp.FormaPagoId


	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	insert into [doc_corte_caja_fp_apartado](
		CorteCajaId,FormaPagoId,Total,CreadoEl
	)
	select @corteCajaId,fp.FormaPagoId,isnull(Sum(Cantidad),0),dbo.fn_GetDateTimeServer()
	from [dbo].[doc_apartados_formas_pago] fp
	inner join doc_apartados_pagos ap on ap.ApartadoPagoId = fp.ApartadoPagoId
	where ap.Cajaid = @pCajaId AND
	FechaPago between @fechaUltimoCorte and @pFechaHoraCorte 
	group by fp.FormaPagoId



	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	

	insert into [dbo].[doc_corte_caja_apartados_pagos](
		CorteCajaId,ApartadoPagoId,CreadoEl
	)
	select @corteCajaId,ap.ApartadoPagoId,dbo.fn_GetDateTimeServer()
	from  doc_apartados_pagos ap 
	where ap.Cajaid = @pCajaId AND
	ap.FechaPago between @fechaUltimoCorte and @pFechaHoraCorte 
	group by ap.ApartadoPagoId


	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end



	/*****Cerrar la sesi�n del cajero****************/
	declare @pSesionId int	

	
	update 	doc_sesiones_punto_venta
	set 	Finalizada = 1,
			FechaCorte = dbo.fn_GetDateTimeServer(),
			CorteAplicado = 1,
			CorteCajaId = @corteCajaId
	where SesionId in(
		select  s.SesionId
		from doc_sesiones_punto_venta  s		
		inner join cat_usuarios ua on ua.IdUsuario = s.UsuarioId
		where s.CajaId = @pCajaId and
		isnull(s.Finalizada,0) = 0 
	)

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	--Actualizar declaración de fondo
	update doc_declaracion_fondo_inicial
	SET CorteCajaId = @corteCajaId
	where CajaId = @pCajaId and	
	CorteCajaId IS NULL

	
	
		
	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	

	commit tran


	fin:


	--exec p_doc_productos_existencias_diario_upd @sucursalId,@pUsuarioId,''








GO
/****** Object:  StoredProcedure [dbo].[p_corte_caja_generacion_previo]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_corte_caja_generacion_previo 1,2,'15/02/2019 12:20:47',0,1
CREATE Proc [dbo].[p_corte_caja_generacion_previo]
@pCajaId int,
@pUsuarioId int,
@pFechaHoraCorte datetime,
@pCorteCajaId int out,
@pPermitirCorteEnCero bit
as


	declare @fechaUltimoCorte datetime,
		@corteCajaId int,
		@gastos money,
		@retiros money,
		@ventaIniId int,
		@ventaFinId int,
		@sucursalId int,
		@esSupervisorGral bit,
		@cajeroOrigId int

	/***Limpiar tablas***/
	select CorteCajaId
	into #tmpCorteCaja_temp
	from [doc_corte_caja_previo]
	where CreadoPor = @pUsuarioId	


	delete [doc_corte_caja_apartados_pagos]
	from [doc_corte_caja_apartados_pagos] a
	inner join #tmpCorteCaja_temp tmp on tmp.CorteCajaId = a.CorteCajaId

	delete doc_corte_caja_denominaciones_previo
	from doc_corte_caja_denominaciones_previo a
	inner join #tmpCorteCaja_temp tmp on tmp.CorteCajaId = a.CorteCajaId

	delete doc_corte_caja_egresos_previo
	from doc_corte_caja_egresos_previo a
	inner join #tmpCorteCaja_temp tmp on tmp.CorteCajaId = a.CorteCajaId

	delete doc_corte_caja_fp_apartado_previo
	from doc_corte_caja_fp_apartado_previo a
	inner join #tmpCorteCaja_temp tmp on tmp.CorteCajaId = a.CorteCajaId

	delete doc_corte_caja_fp_previo
	from doc_corte_caja_fp_previo a
	inner join #tmpCorteCaja_temp tmp on tmp.CorteCajaId = a.CorteCajaId

	delete doc_corte_caja_previo
	from doc_corte_caja_previo a
	inner join #tmpCorteCaja_temp tmp on tmp.CorteCajaId = a.CorteCajaId

	delete doc_corte_caja_ventas_previo
	from doc_corte_caja_ventas_previo a
	inner join #tmpCorteCaja_temp tmp on tmp.CorteCajaId = a.CorteId
	/*******************************/
	


	select @esSupervisorGral = usu.EsSupervisor
	from cat_usuarios usu
	where usu.IdUsuario = @pUsuarioId	


	--select @pFechaHoraCorte =  max(FechaCorte)--case when max(FechaCorte) > dbo.fn_GetDateTimeServer() then max(FechaCorte) else dbo.fn_GetDateTimeServer() end
	--from doc_corte_caja_previo
	--where CajaId = @pCajaId

	

	set @pFechaHoraCorte = isnull(@pFechaHoraCorte,dbo.fn_GetDateTimeServer())


	

	
	if(@fechaUltimoCorte is null)
	begin
		select @fechaUltimoCorte = isnull(max(FechaCorte),dateadd(day,-1,getdate()))
		from doc_corte_caja
		where CajaId = @pCajaId 
	end

	

	select @sucursalId  =Sucursal
	from cat_cajas
	where Clave = @pCajaId

	


	if isnull(@fechaUltimoCorte,'19000101') = '19000101' 
	begin
		select @fechaUltimoCorte = min(Fecha)
		from doc_ventas
		where CajaId = @pCajaId
	end

	begin tran

	select @corteCajaId = isnull(max(CorteCajaId),0) + 1
	from doc_corte_caja_previo

	select @pCorteCajaId = @corteCajaId


	--validar CANCELACIONES
	if not exists(
		select 1
		from doc_ventas v
		where cajaId = @pCajaId and
		FechaCancelacion between 
		@fechaUltimoCorte and @pFechaHoraCorte
		and v.activo = 1 
		--and (
		--	UsuarioCreacionId = @pUsuarioId or
		--	@esSupervisorGral = 1
		--)
	)
	--validar retiros
	and not exists(
		select 1
		from doc_retiros r
		where 
		--(
		--	r.CreadoPor = @pUsuarioId or
		--	@esSupervisorGral = 1
		--) and
		r.CajaId = @pCajaId and
		r.FechaRetiro between @fechaUltimoCorte and @pFechaHoraCorte
	)
	--validar gastos
	and not exists(
		select 1
		from doc_gastos g
		where g.CajaId = @pCajaId and
		--(
		--	g.CreadoPor = @pUsuarioId or
		--	@esSupervisorGral = 1
		--) and
		g.CreadoEl between @fechaUltimoCorte and @pFechaHoraCorte
	)
	--validar devoluciones
	and not exists(
		select 1
		from doc_devoluciones dev
		where 
		--(
		--	dev.CreadoPor = @pUsuarioId or
		--	@esSupervisorGral = 1
		--) and
		dev.CreadoEl between @fechaUltimoCorte and @pFechaHoraCorte
		
	)
		
	--validar apartados
	and not exists (
		select 1
		from doc_apartados a
		inner join doc_apartados_pagos ap on ap.ApartadoId = a.ApartadoId
		where a.CajaId = @pCajaId  and
		ap.FechaPago between 
		@fechaUltimoCorte and @pFechaHoraCorte and
		a.Activo = 1 
		--and
		--(
		--	ap.CreadoPor = @pUsuarioId or
		--	@esSupervisorGral = 1
		--)
	)	
	--
	if not exists (
		select 1
		from doc_ventas v
		where cajaId = @pCajaId and
		Fecha between 
		@fechaUltimoCorte and @pFechaHoraCorte
		and v.activo = 1 
		--and (
		--	v.UsuarioCreacionId = @pUsuarioId 
		--	or
		--	@esSupervisorGral = 1
		--)
		having isnull(max(ventaid),0) > 0
	)	
	AND @pPermitirCorteEnCero = 0
	begin
		RAISERROR (15600,-1,-1, 'No hay movimientos para generar el corte');  
		
		goto fin
	
	end

	/************LIMITAR LAS VENTAS QUE SE PUEDEN CONSIDERAR EN EL CORTE*****************/
	select *
	into #tmpVentas
	from doc_ventas
	where cajaId = @pCajaId and
	UsuarioCreacionId = @pUsuarioId AND

	Fecha between 
	@fechaUltimoCorte and @pFechaHoraCorte --AND
	--(
	--	UsuarioCreacionId = @pUsuarioId
	--	or
	--	@esSupervisorGral = 1
	--)
	--Quitar los tickets de apartados
	and ventaId not in (
		select VentaId
		from doc_apartados
		where isnull(ventaid,0) > 0
	)

	if(@esSupervisorGral = 1)
		select @cajeroOrigId = UsuarioCreacionId
		from #tmpVentas

	insert into doc_corte_caja_previo(
		CorteCajaId,	CajaId,		CreadoEl,		CreadoPor,
		VentaIniId,		VentaFinId,	FechaApertura,	FechaCorte,
		TotalCorte,		TotalIngresos,TotalEgresos)
	select @corteCajaId, @pCajaId, dbo.fn_GetDateTimeServer(),		@pUsuarioId,
		min(VentaId),	max(ventaid),isnull(@fechaUltimoCorte,dbo.fn_GetDateTimeServer()),	@pFechaHoraCorte,
		isnull(sum(
			case when v.Activo = 1 then TotalVenta 
				else 0
			end
		),0), isnull(sum(case when v.Activo = 1 then TotalVenta 
				else 0
			end),0),			0
	from #tmpVentas v
	--where cajaId = @pCajaId and
	--Fecha between 
	--@fechaUltimoCorte and @pFechaHoraCorte AND
	--UsuarioCreacionId = @pUsuarioId
	

	
	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end


	insert into doc_corte_caja_ventas_previo(CorteId,VentaId,CreadoEl)
	select @corteCajaId, v.VentaId,dbo.fn_GetDateTimeServer()
	from #tmpVentas v

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	select @gastos = isnull(sum(Monto),0)
	from doc_gastos
	where activo = 1 and
	cajaid = @pCajaId and
	creadoEl between @fechaUltimoCorte and @pFechaHoraCorte 
	--and
	--(
	--	CreadoPor = @pUsuarioId
	--	or
	--	@esSupervisorGral = 1
	--)

	select @retiros = sum(MontoRetiro)
	from doc_retiros r
	where r.SucursalId = @sucursalId AND
	--(
	--	r.CreadoPor = @pUsuarioId
	--	or
	--	@esSupervisorGral = 1
	--) and
	r.CajaId = @pCajaId and
	r.FechaRetiro  between @fechaUltimoCorte and @pFechaHoraCorte 


	update doc_corte_caja_previo
	set TotalEgresos = isnull(@gastos,0) + isnull(@retiros,0)
	where CorteCajaId = @corteCajaId

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	insert into doc_corte_caja_egresos_previo(CorteCajaId,Gastos)
	select @corteCajaId,@gastos

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	select @ventaIniId=VentaIniId,
		@ventaFinId=VentaFinId
	from doc_corte_caja_previo
	where cortecajaId = @corteCajaId
	
	insert into [dbo].[doc_corte_caja_fp_previo](
		CorteCajaId,FormaPagoId,Total,CreadoEl
	)
	select @corteCajaId,vfp.FormaPagoId,sum(Cantidad),dbo.fn_GetDateTimeServer()
	from [dbo].[doc_ventas_formas_pago] vfp
	inner join #tmpVentas v on v.ventaId = vfp.ventaId
	where v.VentaId between @ventaIniId and @ventaFinId
	and v.Activo = 1
	--AND (
	--	V.UsuarioCreacionId = @pUsuarioId
	--	or
	--	@esSupervisorGral = 1
	--)
	group by vfp.FormaPagoId


	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	insert into [doc_corte_caja_fp_apartado_previo](
		CorteCajaId,FormaPagoId,Total,CreadoEl
	)
	select @corteCajaId,fp.FormaPagoId,isnull(Sum(Cantidad),0),dbo.fn_GetDateTimeServer()
	from [dbo].[doc_apartados_formas_pago] fp
	inner join doc_apartados_pagos ap on ap.ApartadoPagoId = fp.ApartadoPagoId
	where ap.Cajaid = @pCajaId AND
	FechaPago between @fechaUltimoCorte and @pFechaHoraCorte 
	group by fp.FormaPagoId



	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	insert into [dbo].[doc_corte_caja_apartados_pagos_previo](
		CorteCajaId,ApartadoPagoId,CreadoEl
	)
	select @corteCajaId,ap.ApartadoPagoId,dbo.fn_GetDateTimeServer()
	from  doc_apartados_pagos ap 
	where ap.Cajaid = @pCajaId AND
	ap.FechaPago between @fechaUltimoCorte and @pFechaHoraCorte 
	group by ap.ApartadoPagoId


	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end



	
	commit tran


	fin:







GO
/****** Object:  StoredProcedure [dbo].[p_corte_caja_generacion_temp]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_corte_caja_generacion 1,1,'20180516',0
create Proc [dbo].[p_corte_caja_generacion_temp]
@pCajaId int,
@pUsuarioId int,
@pFechaHoraCorte datetime,
@pCorteCajaId int out,
@pPermitirCorteEnCero bit
as


	declare @fechaUltimoCorte datetime,
		@corteCajaId int,
		@gastos money,
		@retiros money,
		@ventaIniId int,
		@ventaFinId int,
		@sucursalId int,
		@esSupervisorGral bit,
		@cajeroOrigId int,
		@totalApartados money,
		@error varchar(300)


	


	select @esSupervisorGral = usu.EsSupervisor
	from cat_usuarios usu
	where usu.IdUsuario = @pUsuarioId	


	select @pFechaHoraCorte = case when max(Fecha) > getdate() then max(Fecha) else getdate() end
	from doc_ventas
	where activo = 1

	set @pFechaHoraCorte = isnull(@pFechaHoraCorte,getdate())


	select @fechaUltimoCorte = isnull(max(FechaCorte),'19000101')
	from doc_corte_caja
	where CajaId = @pCajaId

	select @sucursalId  =Sucursal
	from cat_cajas
	where Clave = @pCajaId


	


	if @fechaUltimoCorte = '19000101' 
	begin
		select @fechaUltimoCorte = min(Fecha)
		from doc_ventas
		where CajaId = @pCajaId
	end

	begin tran

	select @corteCajaId = isnull(max(CorteCajaId),0) + 1
	from doc_corte_caja

	select @pCorteCajaId = @corteCajaId


	--validar CANCELACIONES
	if not exists(
		select 1
		from doc_ventas v
		where cajaId = @pCajaId and
		FechaCancelacion between 
		@fechaUltimoCorte and @pFechaHoraCorte
		and v.activo = 1 
		--and (
		--	UsuarioCreacionId = @pUsuarioId or
		--	@esSupervisorGral = 1
		--)
	)
	--validar retiros
	and not exists(
		select 1
		from doc_retiros r
		where 
		--(
		--	r.CreadoPor = @pUsuarioId or
		--	@esSupervisorGral = 1
		--) and
		r.CajaId = @pCajaId and
		r.FechaRetiro between @fechaUltimoCorte and @pFechaHoraCorte
	)
	--validar gastos
	and not exists(
		select 1
		from doc_gastos g
		where g.CajaId = @pCajaId and
		--(
		--	g.CreadoPor = @pUsuarioId or
		--	@esSupervisorGral = 1
		--) and
		g.CreadoEl between @fechaUltimoCorte and @pFechaHoraCorte
	)
	--validar devoluciones
	and not exists(
		select 1
		from doc_devoluciones dev
		where 
		--(
		--	dev.CreadoPor = @pUsuarioId or
		--	@esSupervisorGral = 1
		--) and
		dev.CreadoEl between @fechaUltimoCorte and @pFechaHoraCorte
		
	)
		
	--validar apartados
	and not exists (
		select 1
		from doc_apartados a
		inner join doc_apartados_pagos ap on ap.ApartadoId = a.ApartadoId
		where a.CajaId = @pCajaId  and
		ap.FechaPago between 
		@fechaUltimoCorte and @pFechaHoraCorte and
		a.Activo = 1 
		--and
		--(
		--	ap.CreadoPor = @pUsuarioId or
		--	@esSupervisorGral = 1
		--)
	)	
	--
	if not exists (
		select 1
		from doc_ventas v
		where cajaId = @pCajaId and
		Fecha between 
		@fechaUltimoCorte and @pFechaHoraCorte
		and v.activo = 1 
		--and (
		--	v.UsuarioCreacionId = @pUsuarioId 
		--	or
		--	@esSupervisorGral = 1
		--)
		having isnull(max(ventaid),0) > 0
	)	
	AND @pPermitirCorteEnCero = 0
	begin
		RAISERROR (15600,-1,-1, 'No hay movimientos para generar el corte');  
		
		goto fin
	
	end

	/************LIMITAR LAS VENTAS QUE SE PUEDEN CONSIDERAR EN EL CORTE*****************/
	select *
	into #tmpVentas
	from doc_ventas
	where cajaId = @pCajaId and
	Fecha between 
	@fechaUltimoCorte and @pFechaHoraCorte --AND
	--(
	--	UsuarioCreacionId = @pUsuarioId
	--	or
	--	@esSupervisorGral = 1
	--)
	--Quitar los tickets de apartados
	and ventaId not in (
		select VentaId
		from doc_apartados
		where isnull(ventaid,0) > 0
	)

	if(@esSupervisorGral = 1)
		select @cajeroOrigId = UsuarioCreacionId
		from #tmpVentas

	select @totalApartados = isnull(Sum(Cantidad),0)
	from [dbo].[doc_apartados_formas_pago] fp
	inner join doc_apartados_pagos ap on ap.ApartadoPagoId = fp.ApartadoPagoId
	where ap.Cajaid = @pCajaId AND
	FechaPago between @fechaUltimoCorte and @pFechaHoraCorte 
	group by fp.FormaPagoId

	insert into doc_corte_caja(
		CorteCajaId,	CajaId,		CreadoEl,		CreadoPor,
		VentaIniId,		VentaFinId,	FechaApertura,	FechaCorte,
		TotalCorte,		TotalIngresos,TotalEgresos)
	select @corteCajaId, @pCajaId, getdate(),		@pUsuarioId,
		min(VentaId),	max(ventaid),@fechaUltimoCorte,	@pFechaHoraCorte,
		isnull(sum(
			case when v.Activo = 1 then TotalVenta 
				else 0
			end
		),0)+ isnull(@totalApartados,0), 
		isnull(sum(case when v.Activo = 1 then TotalVenta 
				else 0
			end),0) + isnull(@totalApartados,0),			0
	from #tmpVentas v
	--where cajaId = @pCajaId and
	--Fecha between 
	--@fechaUltimoCorte and @pFechaHoraCorte AND
	--UsuarioCreacionId = @pUsuarioId
	

	
	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end


	insert into doc_corte_caja_ventas(CorteId,VentaId,CreadoEl)
	select @corteCajaId, v.VentaId,GETDATE()
	from #tmpVentas v

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	select @gastos = isnull(sum(Monto),0)
	from doc_gastos
	where activo = 1 and
	cajaid = @pCajaId and
	creadoEl between @fechaUltimoCorte and @pFechaHoraCorte 
	--and
	--(
	--	CreadoPor = @pUsuarioId
	--	or
	--	@esSupervisorGral = 1
	--)

	select @retiros = sum(MontoRetiro)
	from doc_retiros r
	where r.SucursalId = @sucursalId AND
	--(
	--	r.CreadoPor = @pUsuarioId
	--	or
	--	@esSupervisorGral = 1
	--) and
	r.CajaId = @pCajaId and
	r.FechaRetiro  between @fechaUltimoCorte and @pFechaHoraCorte 


	update doc_corte_caja
	set TotalEgresos = isnull(@gastos,0) + isnull(@retiros,0)
	where CorteCajaId = @corteCajaId

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	insert into doc_corte_caja_egresos(CorteCajaId,Gastos)
	select @corteCajaId,@gastos

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	select @ventaIniId=VentaIniId,
		@ventaFinId=VentaFinId
	from doc_corte_caja
	where cortecajaId = @corteCajaId
	
	insert into [dbo].[doc_corte_caja_fp](
		CorteCajaId,FormaPagoId,Total,CreadoEl
	)
	select @corteCajaId,vfp.FormaPagoId,sum(Cantidad),getdate()
	from [dbo].[doc_ventas_formas_pago] vfp
	inner join #tmpVentas v on v.ventaId = vfp.ventaId
	where v.VentaId between @ventaIniId and @ventaFinId
	and v.Activo = 1
	--AND (
	--	V.UsuarioCreacionId = @pUsuarioId
	--	or
	--	@esSupervisorGral = 1
	--)
	group by vfp.FormaPagoId


	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	insert into [doc_corte_caja_fp_apartado](
		CorteCajaId,FormaPagoId,Total,CreadoEl
	)
	select @corteCajaId,fp.FormaPagoId,isnull(Sum(Cantidad),0),GETDATE()
	from [dbo].[doc_apartados_formas_pago] fp
	inner join doc_apartados_pagos ap on ap.ApartadoPagoId = fp.ApartadoPagoId
	where ap.Cajaid = @pCajaId AND
	FechaPago between @fechaUltimoCorte and @pFechaHoraCorte 
	group by fp.FormaPagoId



	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	

	insert into [dbo].[doc_corte_caja_apartados_pagos](
		CorteCajaId,ApartadoPagoId,CreadoEl
	)
	select @corteCajaId,ap.ApartadoPagoId,GETDATE()
	from  doc_apartados_pagos ap 
	where ap.Cajaid = @pCajaId AND
	ap.FechaPago between @fechaUltimoCorte and @pFechaHoraCorte 
	group by ap.ApartadoPagoId


	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end



	/*****Cerrar la sesión del cajero****************/
	declare @pSesionId int

	

	
	update 	doc_sesiones_punto_venta
	set 	Finalizada = 1,
			FechaCorte = getdate(),
			CorteAplicado = 1,
			CorteCajaId = @corteCajaId
	where 	
		SesionId in(
		select  s.SesionId
			from doc_sesiones_punto_venta  s		
			inner join cat_usuarios ua on ua.IdUsuario = s.UsuarioId
			where s.CajaId = @pCajaId and
			isnull(s.Finalizada,0) = 0 
	)
		
	

	
	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	commit tran


	fin:





GO
/****** Object:  StoredProcedure [dbo].[p_corte_caja_inventario_generacion]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- [p_corte_caja_inventario_generacion] 3,'20230307','20230307'
CREATE PROC [dbo].[p_corte_caja_inventario_generacion]
@pSucursalId INT,      
@pFechaIni DATETIME,      
@pFechaFin DATETIME      
as      
begin       
 DECLARE @TotalRetiros MONEY,      
  @MasaUsadaEnTortilla DECIMAL(14,3),      
  @MasaTotal DECIMAL(14,3),      
  @MetodoCalculo VARCHAR(50)='',      
  @fechaRegistroSobrantes DATETIME  ,
  @rendimientoPorTiarada DECIMAL(14,3)
      
  SELECT @fechaRegistroSobrantes = DATEADD(MINUTE,-1,max(CerradoEl))      
  FROM doc_productos_sobrantes_registro      
  where CONVERT(VARCHAR,CreadoEl,112) = CONVERT(VARCHAR,@pFechaFin,112)      
      
 SELECT @MetodoCalculo = CAST(ISNULL(Valor,'')   AS VARCHAR)  
 FROM sis_preferencias_sucursales PS    
 INNER JOIN sis_preferencias P ON P.ID = PS.PreferenciaId AND    
    P.Preferencia = 'CCaja-TortilleriaMetodoCalculo'    
 WHERE SucursalId = @pSucursalId        
      
CREATE TABLE #TMP_TOTAL_TORTILLA (Cantidad decimal(14,3), DESCRIPCION VARCHAR(100))      
CREATE TABLE #TMP_TOTAL_MASA (Cantidad decimal(14,3), DESCRIPCION VARCHAR(100))      

 CREATE TABLE #TMP_RESULTADO      
 (      
  Fila int identity(1,1),      
  TipoMovimiento VARCHAR(450),      
  Concepto VARCHAR(450),      
  Abono BIT,      
  Cantidad decimal(14,3),      
  PrecioUnitario MONEY,      
  Monto  decimal(14,3),      
  TotalAnalisisCorteCaja MONEY NULL,      
  TotalDescuentos MONEY NULL,      
  TotalEntregadoSucursal  MONEY NULL,      
  Diferencia MONEY NULL  
 )      
      
 CREATE TABLE #TMP_MOVS_INVENTARIO_EXCLUIR(      
  MovimientoId INT,      
  MovimientoDetalleId INT      
 )      
   
 create table #PreciosProductoHistorico (ProductoId int, UltimoPrecio decimal(16,6), FechaRegistro date)  
  
 insert into #PreciosProductoHistorico (ProductoId, UltimoPrecio, FechaRegistro)  
 select distinct ProductoId, PrecioNuevo, FechaRegistro  
 from   
  (select ProductoId, PrecioNuevo, FechaRegistro= cast(FechaRegistro as date),    
     ROW_NUMBER() OVER(partition by ProductoId order by ProductoId asc, cast(FechaRegistro as date) desc) AS Row#  
   from [cat_productos_cambio_precio]   
   where cast(FechaRegistro as date)<=@pFechaIni) as t1   
 where Row#= 1  
   
 INSERT INTO #TMP_MOVS_INVENTARIO_EXCLUIR(MovimientoId,MovimientoDetalleId)      
 SELECT IMD.MovimientoId,IMD.MovimientoDetalleId      
 FROM doc_productos_sobrantes_regitro_inventario PSR      
 INNER JOIN doc_inv_movimiento_detalle IMD ON IMD.MovimientoDetalleId = PSR.MovimientoDetalleId      
 INNER JOIN doc_inv_movimiento IM ON IM.MovimientoId = IMD.MovimientoId      
 WHERE IM.SucursalId = @pSucursalId AND      
 convert(varchar,IM.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)      
 GROUP BY IMD.MovimientoId,IMD.MovimientoDetalleId      
      
 SELECT p.ProductoId,      
  Precio = ISNULL(MAX(VD.PrecioUnitario),MAX(isnull(t10.UltimoPrecio,PP.Precio)))      
 INTO #TMP_PRECIOS      
 FROM cat_productos P      
 left JOIN cat_productos_precios PP ON PP.IdProducto = P.ProductoId AND      
          pp.IdPrecio = 1      
 left JOIN doc_ventas_detalle VD ON VD.ProductoId = P.ProductoId AND      
        CONVERT(VARCHAR,VD.FechaCreacion,112)  BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND  CONVERT(VARCHAR,@pFechaFin,112)    
 left join #PreciosProductoHistorico t10 on t10.ProductoId= p.ProductoId  
 GROUP BY P.ProductoId       
      
  
 --PRECIO MASA FRIA      
 INSERT INTO #TMP_PRECIOS      
 SELECT P1.ProductoId,      
  PRecio = PRE.Precio      
 FROM cat_productos P1      
 INNER JOIN cat_productos P2 ON P2.Descripcion = 'TORTILLA'      
 INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = P2.ProductoId      
 WHERE P1.Descripcion LIKE '%MASA%FRIA%'      
       
      
 SELECT @TotalRetiros = sum(R.MontoRetiro)      
 FROM doc_retiros R      
 WHERE R.SucursalId = @pSucursalId AND      
 CONVERT(VARCHAR,R.FechaRetiro,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)      
      
 /***********************************************ENTRADAS********************************************/      
 IF(@MetodoCalculo = '' OR @MetodoCalculo = 'MODE-TIRADAS')  
 BEGIN       
   INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)      
   SELECT '1.1-ENTRADAS MASA Y TORTILLA','MASA',1,SUM(DATOS.MasaKg),PRE.Precio,SUM(DATOS.MasaKg) * PRE.Precio      
   FROM doc_corte_caja_datos_entrada DATOS      
   INNER JOIN cat_productos P ON P.Descripcion = 'MASA'      
   INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = P.ProductoId      
   WHERE DATOS.SucursalId = @pSucursalId AND      
   CONVERT(VARCHAR,DATOS.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)      
   GROUP BY PRE.Precio      
      
   INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)      
   SELECT '1.1-ENTRADAS MASA Y TORTILLA','TORTILLA',1,SUM(DATOS.TiradaTortillaKg),PRE.Precio,SUM(DATOS.TiradaTortillaKg) * PRE.Precio      
   FROM doc_corte_caja_datos_entrada DATOS      
   INNER JOIN cat_productos P ON P.Descripcion = 'TORTILLA'      
   INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = P.ProductoId      
   WHERE DATOS.SucursalId = @pSucursalId AND      
   CONVERT(VARCHAR,DATOS.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)      
   GROUP BY PRE.Precio    
 END  
  
 IF(@MetodoCalculo = 'MODE-MAIZ')  
   BEGIN    
    
   INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)    
   SELECT '1.1-ENTRADAS MASA Y TORTILLA','TORTILLA',1,MR.TortillaTotalRendimiento,P.Precio,P.Precio * MR.TortillaTotalRendimiento  
   FROM [dbo].[doc_maiz_maseca_rendimiento] MR  
   INNER JOIN #TMP_PRECIOS P ON P.ProductoId = 1   
   WHERE MR.SucursalId = @pSucursalId AND  
   CONVERT(VARCHAR,MR.Fecha,112) = CONVERT(VARCHAR,DATEADD(Day,-1,@pFechaIni),112)  
  END  
      
     
      
 SELECT @MasaTotal = SUM(Cantidad)      
 FROM #TMP_RESULTADO      
 WHERE TipoMovimiento = '1.1-ENTRADAS MASA Y TORTILLA'      
      
 --MASA FRIA      
       
 INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)      
 SELECT '1.1-ENTRADAS MASA Y TORTILLA',p.Descripcion +' '+ (CAST(SUM(MD.Cantidad) AS VARCHAR)),1,(SUM(md.Cantidad)/40*33),pp.Precio,(SUM(MD.Cantidad)/40*33) * pp.Precio      
 FROM doc_inv_movimiento_detalle MD      
 INNER JOIN cat_productos P ON P.ProductoId = MD.ProductoId      
 INNER JOIN #TMP_PRECIOS PP ON PP.ProductoId = 1 --TORTILLA     
 INNER JOIN doc_inv_movimiento M ON M.MovimientoId = MD.MovimientoId AND      
      P.Descripcion like '%MASA%FRIA%'      
 WHERE CONVERT(VARCHAR,M.FechaMovimiento,112) BETWEEN CONVERT(VARCHAR,DATEADD(dd,-1,@pFechaIni),112) AND CONVERT(VARCHAR,DATEADD(DD,-1,@pFechaFin),112) AND      
 MD.Cantidad  > 0      
 GROUP BY p.Descripcion,pp.Precio      
  
insert into #TMP_TOTAL_MASA(Cantidad, DESCRIPCION)
select (Cantidad/40.000), Concepto
from 
#TMP_RESULTADO where Concepto like '%MASA%FRIA%' 

insert into #TMP_TOTAL_MASA(Cantidad, DESCRIPCION)
select (TiradaTortilla*40.000), 'Rendimiento tirada'
from doc_corte_caja_datos_entrada 
where cast(CreadoEl as date) = @pFechaIni

 /*****ENTRADAS DE PAGOS DE PEDIDOS DE DÍAS ANTERIORES*****/  
    INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)    
 SELECT '1.1-1-PAGOS PEDIDOS DE DÍAS ANTERIORES' ,CLI.Nombre,1,SUM(VD.Cantidad),MAX(VD.PrecioUnitario),SUM(VD.Cantidad)* MAX(VD.PrecioUnitario)  
 FROM doc_ventas V  
 INNER JOIN cat_clientes CLI ON CLI.ClienteId = V.ClienteId           
 INNER JOIN doc_pedidos_orden PO ON V.SucursalId = @pSucursalId AND  
        CONVERT(VARCHAR,V.Fecha,112) = CONVERT(VARCHAR,@pFechaFin,112) AND  
        PO.VentaId = V.VentaId AND   
        CONVERT(VARCHAR,PO.CreadoEl,112) < CONVERT(VARCHAR,V.Fecha,112)  
 INNER JOIN doc_ventas_detalle VD ON VD.VentaId = V.VentaId   
 GROUP BY CLI.Nombre  
      
 --TORTILLA ENTRADA POR TRASPASO      
 INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)      
 SELECT '1.2-ENTRADA POR TRASPASO',p.clave +'-'+ P.Descripcion ,1,SUM(IMD.Cantidad),PP.Precio,PP.Precio * SUM(IMD.Cantidad)      
 FROM doc_inv_movimiento IM      
 INNER JOIN doc_inv_movimiento_detalle IMD ON IMD.MovimientoId = IM.MovimientoId      
 INNER JOIN cat_productos P ON P.ProductoId = IMD.ProductoId AND P.ProdVtaBascula = 1 AND P.ProductoId = 1 --SOLO TORTILLA      
 INNER JOIN cat_tipos_movimiento_inventario TMI ON TMI.TipoMovimientoInventarioId = IM.TipoMovimientoId AND      
            TMI.TipoMovimientoInventarioId in (3,5)      
 INNER JOIN #TMP_PRECIOS PP ON PP.ProductoId = P.ProductoId   
 WHERE IM.SucursalId = @pSucursalId AND      
 CONVERT(VARCHAR,IM.FechaMovimiento,112) BETWEEN   CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)AND       
 IMD.MovimientoDetalleId NOT IN (SELECT MovimientoDetalleId FROM #TMP_MOVS_INVENTARIO_EXCLUIR)      
 group by PP.Precio,P.Descripcion,p.clave      
      
       
      
 --VENTA MASA Y TORTILLA      
 --INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)      
 --SELECT '1.1-VENTA MASA Y TORTILLA',      
 --  P.CLAVE + '-'+P.Descripcion + CASE WHEN ISNULL(MIN(v.ClienteId),0) > 0 THEN '-(PEDIDO MAYOREO CONTADO)' ELSE '-(VENTA MOSTRADOR)' END,      
 --  1,      
 --  SUM(VD.Cantidad),      
 --  PRE.Precio,      
 --  SUM(VD.Cantidad) * PRE.Precio      
 --FROM doc_ventas_detalle VD      
 --INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId      
 --INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId AND P.ProdVtaBascula = 1 AND      
 --       P.ProductoId = 1 --TORTILLA      
 --INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = VD.ProductoId              
 --LEFT JOIN doc_pedidos_orden PO ON PO.VentaId = V.VentaId      
 --WHERE V.SucursalId = @pSucursalId AND      
 --V.Activo = 1 AND      
 --CONVERT(VARCHAR,V.FechaCreacion,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND      
 --PO.VentaId IS NULL AND      
 --VD.PrecioUnitario > 0      
 --GROUP BY P.CLAVE,P.Descripcion,PRE.Precio,v.ClienteId      
 --order by p.CLAVE      
      
      
 ----PEDIDO MAYOREO      
 --INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)      
 --SELECT '1.1-VENTA MASA Y TORTILLA',      
 --  P.CLAVE + '-'+P.Descripcion  + '-(VENTA MAYOREO)',      
 --  1,      
 --  SUM(VD.Cantidad),      
 --  PRE.Precio,      
 --  SUM(VD.Cantidad) * PRE.Precio      
 --FROM doc_ventas_detalle VD      
 --INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId and vd.ProductoId = 1      
 --INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId       
 --INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = VD.ProductoId        
 --LEFT JOIN doc_pedidos_orden PO ON PO.VentaId = V.VentaId      
 --WHERE V.SucursalId = @pSucursalId AND      
 --V.Activo = 1 AND      
 --CONVERT(VARCHAR,V.FechaCreacion,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND      
 --PO.VentaId IS NOT NULL      
 --GROUP BY P.CLAVE,P.Descripcion,PRE.Precio      
 --order by p.CLAVE      
      
      
 --PEDIDO MAYOREO POR PAGAR      
 --INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)      
 --SELECT '1.1-VENTA MASA Y TORTILLA',p.CLave + '-' +p.Descripcion + '-(VENTA MAYOREO POR PAGAR)',1,      
 --SUM(POD.Cantidad),      
 --PRE.Precio,      
 --SUM(POD.Cantidad) * PRE.Precio      
 --FROM doc_pedidos_orden PO      
 --INNER JOIN doc_pedidos_orden_detalle POD ON POD.PedidoId = PO.PedidoId   AND      
 --         PO.Activo = 1 AND      
 --         PO.SucursalId = @pSucursalId and      
 --         pod.ProductoId = 1      
 --INNER JOIN cat_productos P ON P.ProductoId = POD.ProductoId      
 --INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = POD.ProductoId          
 --WHERE CONVERT(VARCHAR,PO.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)      
 --GROUP BY p.Descripcion,PRE.Precio,p.CLave       
      
 --SELECT @MasaUsadaEnTortilla = SUM(Cantidad) * 1.21      
 --FROM #TMP_RESULTADO      
 --WHERE TipoMovimiento = '1.1-VENTA MASA Y TORTILLA'      
      
       
      
 --INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)      
 --SELECT '1.1-VENTA MASA Y TORTILLA',P.Descripcion,1,(ISNULL(@MasaTotal,0) - ISNULL(@MasaUsadaEnTortilla,0)),PP.Precio,PP.Precio * (ISNULL(@MasaTotal,0) - ISNULL(@MasaUsadaEnTortilla,0))      
 --FROM cat_productos P      
 --INNER JOIN cat_productos_precios PP ON PP.IdProducto = P.ProductoId AND      
 --      PP.IdPrecio = 1      
 --WHERE P.ProductoId = 2     
      
       
      
       
      
 --VENTAS REGISTRADAS      
 INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)      
 SELECT '1.3-VENTAS POR PRODUCTO',      
   P.CLAVE + '-'+P.Descripcion,      
   1,      
   SUM(VD.Cantidad),      
   pre.Precio,      
   SUM(VD.Cantidad) * PRE.Precio      
 FROM doc_ventas_detalle VD      
 INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId      
 INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId AND P.ProdVtaBascula = 0      
 INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = VD.ProductoId      
 --LEFT JOIN doc_pedidos_orden PO ON PO.VentaId = V.VentaId      
 WHERE V.SucursalId = @pSucursalId AND      
 V.Activo = 1 AND      
 CONVERT(VARCHAR,V.FechaCreacion,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)     
 -- and PO.VentaId IS NULL      
 GROUP BY P.CLAVE,P.Descripcion,PRE.Precio,p.orden      
 order by p.Orden      
      
       
 /********************FALTANTES DE PRODUCTOS MOSTRADOR*************************/      
 INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)      
 SELECT '1.4-FALTANTES PRODUCTO MOSTRADOR',P.Clave +'-'+ P.Descripcion,1,   PSR.CantidadInventario - PSR.CantidadSobrante, pre.Precio, (PSR.CantidadInventario - PSR.CantidadSobrante) * pre.Precio    
 FROM doc_productos_sobrantes_registro PSR      
 INNER JOIN cat_productos P ON P.ProductoId = PSR.ProductoId AND      
       P.ProdVtaBascula = 0       
 left join #TMP_PRECIOS PRE on pre.ProductoId= p.ProductoId  
 WHERE PSR.SucursalId = @pSucursalId AND      
 CONVERT(VARCHAR,PSR.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND      
 ISNULL(PSR.CantidadSobrante,0) < ISNULL(PSR.CantidadInventario,0)      
 ORDER BY P.ORDEN      
    
 /**********************************GRAMOS A FAVOR EN CONTRA***************************************/    
create table #GramosFavorEnContra (ProductoId int, PrecioProducto decimal(16,6), ClaveTipoGramos smallint, PrecioPorGramo decimal(16,6), GramosPesados decimal(16,6),   
         Total decimal(16,6), GramosVendidos_EnBase_Al_Total decimal(16,6), ResultadoGramos decimal(16,6), ImporteGramos decimal(16,6))     
  
insert into #GramosFavorEnContra(ProductoId, PrecioProducto, PrecioPorGramo, GramosPesados, Total, GramosVendidos_EnBase_Al_Total)     
select ProductoId,   PrecioProducto= PrecioUnitario,    
PrecioPorgramo= (PrecioUnitario/1000),   GramosPesados=(Cantidad*1000),  Total,   GramosVendidos_EnBase_Al_Total= (Total/(PrecioUnitario/1000))    
from      
 doc_ventas t1   
inner join     
 doc_ventas_detalle t2 on t2.VentaId= t1.VentaId    
where    
 isnull(t1.clienteid,0)=0 and   t1.SucursalId=@pSucursalId and     
 cast(t1.FechaCreacion as date)  between  cast(@pFechaIni as date) and cast(@pFechaFin as date) and   
 PrecioUnitario>0     
 --and    
 --cast(FechaCreacion as date)  ='20221123' and   ProductoId in (1,2) and   Total>0   
update #GramosFavorEnContra set ResultadoGramos= ((GramosPesados)-(Total/(PrecioPorgramo)))    
  
update #GramosFavorEnContra set ClaveTipoGramos= 1 /*A favor*/, ImporteGramos= PrecioPorGramo*ResultadoGramos   
where ResultadoGramos>0    
  
update #GramosFavorEnContra set ClaveTipoGramos= 2 /*En contra*/, ImporteGramos= PrecioPorGramo*ResultadoGramos where ResultadoGramos<0    
  
delete #GramosFavorEnContra where ISNULL(ResultadoGramos, 0)= 0    
    
 /***************************************************************************************************************/    
      
       
 --GRAMOS EN CONTRA      
 INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)      
 SELECT  TipoMovimiento= '1.5-GRAMOS EN CONTRA',       
  Concepto= max(t2.Clave) +'-'+ max(t2.Descripcion),       
  Abono= 1,   
  Cantidad= ((sum(ResultadoGramos))/1000.00000)*-1,  
  PrecioUnitario= PrecioProducto,   
  Monto= sum(ImporteGramos)*-1    
from #GramosFavorEnContra t1 inner join   
 cat_productos t2 on t2.ProductoId= t1.ProductoId     
where t1.ClaveTipoGramos= 2    
group  by ClaveTipoGramos, t1.ProductoId, PrecioProducto  order by t1.ProductoId    
       
       
       
      
      
      
 /**********************DESCUENTOS***********************************************/      
 INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)      
 SELECT '2-SOBRANTES/DESPERDICIO/CONSUMO EMPLEADOS Y CORTESÍA',p.Descripcion,0,sum(PSR.CantidadSobrante),pp.Precio,PSR.CantidadSobrante* pp.Precio      
 FROM doc_productos_sobrantes_registro PSR      
 INNER JOIN cat_productos P ON P.ProductoId = PSR.ProductoId AND p.ProdVtaBascula = 1 AND PSR.SucursalId = @pSucursalId AND      
          P.Descripcion NOT LIKE '%MASA%FRIA%'      
 INNER JOIN #TMP_PRECIOS PP ON PP.ProductoId = p.ProductoId   
 WHERE CONVERT(VARCHAR,PSR.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)      
 GROUP BY p.Descripcion,pp.Precio,PSR.CantidadSobrante      
  
  
  iNSERT INTO #TMP_TOTAL_TORTILLA(Cantidad, DESCRIPCION )/**/
 SELECT sum(PSR.CantidadSobrante), max(p.descripcion)    
 FROM doc_productos_sobrantes_registro PSR      
 INNER JOIN cat_productos P ON P.ProductoId = PSR.ProductoId AND p.ProdVtaBascula = 1 AND PSR.SucursalId = @pSucursalId 
 INNER JOIN #TMP_PRECIOS PP ON PP.ProductoId = p.ProductoId   
 WHERE P.ProductoId in(745,1) /*DESPERDICIO TORTILLA y tortilla*/ and 
 CONVERT(VARCHAR,PSR.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)      
 GROUP BY p.Descripcion,pp.Precio,PSR.CantidadSobrante     


 iNSERT INTO #TMP_TOTAL_MASA(Cantidad, DESCRIPCION )/**/
 SELECT (sum(PSR.CantidadSobrante)/40.0000)*-1, max(p.descripcion)    
 FROM doc_productos_sobrantes_registro PSR      
 INNER JOIN cat_productos P ON P.ProductoId = PSR.ProductoId AND p.ProdVtaBascula = 1 AND PSR.SucursalId = @pSucursalId 
 INNER JOIN #TMP_PRECIOS PP ON PP.ProductoId = p.ProductoId   
 WHERE P.ProductoId in(742, 744) /*DESPERDICIO TORTILLA y tortilla*/ and 
 CONVERT(VARCHAR,PSR.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)      
 GROUP BY p.Descripcion,pp.Precio,PSR.CantidadSobrante     
  
 --CORTESIA      
 INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)      
 SELECT '2-SOBRANTES/DESPERDICIO/CONSUMO EMPLEADOS Y CORTESÍA','(CONSUMO EMPLEADO)'+P.Descripcion + ' Folio:'+v.Folio,0,VD.Cantidad,PP.Precio,VD.Cantidad * PP.Precio      
 FROM doc_ventas_detalle VD      
 INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId AND      
           ISNULL(VD.Total,0) = 0      
 INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId AND P.ProdVtaBascula = 1      
 INNER JOIN #TMP_PRECIOS PP ON PP.ProductoId = p.ProductoId   
 WHERE CONVERT(VARCHAR,V.FechaCreacion,112) BETWEEN  CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND      
 V.SucursalId = @pSucursalId and      
 v.Activo = 1      
 order by P.Descripcion    
 
 iNSERT INTO #TMP_TOTAL_TORTILLA(Cantidad, DESCRIPCION )/**/
 SELECT VD.Cantidad, 'Consumo empleado y cortesia'     
 FROM doc_ventas_detalle VD      
 INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId AND      
           ISNULL(VD.Total,0) = 0      
 INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId AND P.ProdVtaBascula = 1      
 INNER JOIN #TMP_PRECIOS PP ON PP.ProductoId = p.ProductoId   
 WHERE 
 PP.ProductoId= 1 and /*tortilla*/
 CONVERT(VARCHAR,V.FechaCreacion,112) BETWEEN  CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND      
 V.SucursalId = @pSucursalId and      
 v.Activo = 1      
 order by P.Descripcion    
  
 /*****ENTRADAS DE PAGOS DE PEDIDOS DE DÍAS ANTERIORES*****/  
    INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)    
 SELECT '2.1-PAGOS PEDIDOS DE DÍAS ANTERIORES' ,CLI.Nombre,0,SUM(VD.Cantidad),MAX(VD.PrecioUnitario),SUM(VD.Cantidad)* MAX(VD.PrecioUnitario)  
 FROM doc_ventas V  
 INNER JOIN cat_clientes CLI ON CLI.ClienteId = V.ClienteId           
 INNER JOIN doc_pedidos_orden PO ON V.SucursalId = @pSucursalId AND  
        CONVERT(VARCHAR,V.Fecha,112) = CONVERT(VARCHAR,@pFechaFin,112) AND  
        PO.VentaId = V.VentaId AND   
        CONVERT(VARCHAR,PO.CreadoEl,112) < CONVERT(VARCHAR,V.Fecha,112)  
 INNER JOIN doc_ventas_detalle VD ON VD.VentaId = V.VentaId   
 GROUP BY CLI.Nombre  
      
 /********************SOBRANTES DE PRODUCTOS MOSTRADOR*************************/      
 --INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)      
 --SELECT '2.1-SOBRANTES PRODUCTO MOSTRADOR',P.Clave +'-'+ P.Descripcion,0,ISNULL(PSR.CantidadSobrante,0) - ISNULL(PSR.CantidadInventario,0),      
 --  PP.Precio,       
 --  (ISNULL(PSR.CantidadSobrante,0) - ISNULL(PSR.CantidadInventario,0)) * pp.Precio      
 --FROM doc_productos_sobrantes_registro PSR      
 --INNER JOIN cat_productos P ON P.ProductoId = PSR.ProductoId AND      
 --      P.ProdVtaBascula = 0      
 --INNER JOIN #TMP_PRECIOS PP ON PP.ProductoId = p.ProductoId   
 --WHERE PSR.SucursalId = @pSucursalId AND      
 --CONVERT(VARCHAR,PSR.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND      
 --ISNULL(PSR.CantidadSobrante,0) > ISNULL(PSR.CantidadInventario,0)      
 --ORDER BY  P.Orden      
      
      
 --INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)      
 --SELECT '2.1.1-GASTOS',G.Obervaciones,0,1,g.Monto,g.Monto      
 --FROM doc_gastos G      
 --WHERE CONVERT(VARCHAR,G.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND      
 --G.SucursalId = @pSucursalId and      
 --G.Activo = 1      
      
      
 --PEDIDO MAYOREO       
      
 INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)      
 SELECT '2.2-PEDIDOS MAYOREO PAGADO',      
   P.CLAVE + '-'+P.Descripcion + CASE WHEN ISNULL(MIN(v.ClienteId),0) > 0 THEN '-(PEDIDO MAYOREO PAGADO '+CLI.Nombre+')'  ELSE '-(VENTA MOSTRADOR)' END,      
   0,      
   SUM(VD.Cantidad),      
   vd.PrecioUnitario,      
   CASE WHEN ISNULL(MIN(v.ClienteId),0) > 0       
     THEN (SUM(VD.Cantidad) * MAX(pre.Precio)) - (SUM(VD.Cantidad) * vd.PrecioUnitario)      
     ELSE (SUM(VD.Cantidad) * vd.PrecioUnitario)      
   END      
 FROM doc_ventas_detalle VD      
 INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId      
 INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId AND P.ProdVtaBascula = 1 AND      
        P.ProductoId IN( 1,2) --TORTILLA      
 INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = VD.ProductoId       
 LEFT JOIN cat_clientes CLI ON CLI.ClienteId = V.ClienteId      
 LEFT JOIN doc_pedidos_orden PO ON PO.VentaId = V.VentaId      
 WHERE V.SucursalId = @pSucursalId AND      
 V.Activo = 1 AND      
 CONVERT(VARCHAR,V.FechaCreacion,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND      
 PO.VentaId IS NULL AND      
 VD.PrecioUnitario > 0 AND      
 v.ClienteId IS NOT NULL      
 GROUP BY P.CLAVE,P.Descripcion,vd.PrecioUnitario,v.ClienteId,CLI.Nombre      
 order by p.CLAVE      
      
      
 --PEDIDO MAYOREO POR PAGAR      
 /*INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)      
 SELECT '2.3-PEDIDOS MAYOREO POR PAGAR',p.Descripcion,0,SUM(POD.Cantidad),      
 PRE.Precio,      
 SUM(POD.Cantidad) * PRE.Precio      
 FROM doc_pedidos_orden PO      
 INNER JOIN doc_pedidos_orden_detalle POD ON POD.PedidoId = PO.PedidoId   AND      
          PO.Activo = 1 AND      
          PO.SucursalId = @pSucursalId       
 INNER JOIN cat_productos P ON P.ProductoId = POD.ProductoId      
 INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = POD.ProductoId          
 WHERE CONVERT(VARCHAR,PO.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)      
 GROUP BY p.Descripcion,PRE.Precio      
  */  
    
create table #Pedido_mayoreo_por_pagar(ProductoId int, ClaveProducto varchar(50), Descripcion varchar(100), PrecioUnitario decimal (16,6), Cantidad decimal (16,6),            TipoBasculaBitacoraId int, TipoDetalle varchar(100), Total decimal (16,6))  
insert into #Pedido_mayoreo_por_pagar(ProductoId, ClaveProducto, Descripcion, PrecioUnitario,  Cantidad, TipoBasculaBitacoraId, TipoDetalle, Total)  
select   ProductoId= t2.ProductoId,  
Clave= max(t4.clave),  
DescripcionCorta= Concat(max(t4.Descripcion),' (', max(t3.Nombre), ')' ),  
PrecioUnitario= max(pre.Precio),  Cantidad=  sum(t2.Cantidad),  TipoBasculaBitacoraId= 15,  --Venta Mayoreo por Pagar,  
Tipo = '2.3-PEDIDOS MAYOREO POR PAGAR',    Total=SUM(t2.Cantidad) * max(PRE.Precio)      
from doc_pedidos_orden t1   
inner join doc_pedidos_orden_detalle t2 on t2.PedidoId= t1.PedidoId  
inner join cat_clientes t3 on t3.ClienteId= t1.ClienteId  
inner join cat_productos t4 on t4.ProductoId= t2.ProductoId  
INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = t4.ProductoId          
where t1.SucursalId= @pSucursalId  and   cast(t1.CreadoEl as date)  between  cast(@pFechaIni as date) and 
cast(@pFechaFin as date)  and t2.ProductoId IN (1,2) /*Masa y tortilla*/ and   
isnull(Parallevar, 0)= 0 AND t1.VentaId IS NULL  
group by 
t1.ClienteId, t2.ProductoId  order by t2.ProductoId   

INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)     
select TipoDetalle, Descripcion, Abono= 0, Cantidad, PrecioUnitario, Total  
from #Pedido_mayoreo_por_pagar  
      
 --TRASPASOS      
 INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)      
 SELECT '2.4-TRASPASO/SALIDA',P.Descripcion,0,SUM(IMD.Cantidad),PP.Precio,PP.Precio * SUM(IMD.Cantidad)      
 FROM doc_inv_movimiento IM      
 INNER JOIN doc_inv_movimiento_detalle IMD ON IMD.MovimientoId = IM.MovimientoId      
 INNER JOIN cat_productos P ON P.ProductoId = IMD.ProductoId AND P.Descripcion NOT LIKE '%MASA%FRIA%' AND      
            P.ProductoId IN( 1,2)      
 INNER JOIN cat_tipos_movimiento_inventario TMI ON TMI.TipoMovimientoInventarioId = IM.TipoMovimientoId AND      
            TMI.TipoMovimientoInventarioId in (4,6)      
 INNER JOIN #TMP_PRECIOS PP ON PP.ProductoId = p.ProductoId   
 WHERE IM.SucursalId = @pSucursalId AND      
 CONVERT(VARCHAR,IM.FechaMovimiento,112) BETWEEN   CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)AND  
 IM.FechaMovimiento < @fechaRegistroSobrantes  
 group by PP.Precio,P.Descripcion      
 
 INSERT INTO #TMP_TOTAL_TORTILLA(Cantidad, DESCRIPCION )/**/
 SELECT SUM(IMD.Cantidad) , 'TRASPASO/SALIDA TORTILLA'
 FROM 
 doc_inv_movimiento IM      
 INNER JOIN doc_inv_movimiento_detalle IMD ON IMD.MovimientoId = IM.MovimientoId      
 INNER JOIN cat_productos P ON P.ProductoId = IMD.ProductoId  AND      
            P.ProductoId = 1 /*TORTILLA*/
 INNER JOIN cat_tipos_movimiento_inventario TMI ON TMI.TipoMovimientoInventarioId = IM.TipoMovimientoId AND      
            TMI.TipoMovimientoInventarioId in (4,6)      
 INNER JOIN #TMP_PRECIOS PP ON PP.ProductoId = p.ProductoId   
 WHERE IM.SucursalId = @pSucursalId AND      
 CONVERT(VARCHAR,IM.FechaMovimiento,112) BETWEEN   CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)AND  
 IM.FechaMovimiento < @fechaRegistroSobrantes  
 group by PP.Precio,P.Descripcion  
  
  
 --TRASPASOS  MOSTRADOR  
 --INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)      
 --SELECT '2.4-TRASPASO/SALIDA',P.Descripcion,0,SUM(IMD.Cantidad),PP.Precio,PP.Precio * SUM(IMD.Cantidad)      
 --FROM doc_inv_movimiento IM      
 --INNER JOIN doc_inv_movimiento_detalle IMD ON IMD.MovimientoId = IM.MovimientoId      
 --INNER JOIN cat_productos P ON P.ProductoId = IMD.ProductoId AND P.Descripcion NOT LIKE '%MASA%FRIA%' AND      
 --           P.ProductoId NOT IN( 1,2)      
 --INNER JOIN cat_tipos_movimiento_inventario TMI ON TMI.TipoMovimientoInventarioId = IM.TipoMovimientoId AND      
 --           TMI.TipoMovimientoInventarioId in (4,6)      
 --INNER JOIN #TMP_PRECIOS PP ON PP.ProductoId = p.ProductoId   
 --WHERE IM.SucursalId = @pSucursalId AND      
 --CONVERT(VARCHAR,IM.CreadoEl,112) BETWEEN   CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)AND       
 --IMD.MovimientoDetalleId NOT IN (SELECT MovimientoDetalleId FROM #TMP_MOVS_INVENTARIO_EXCLUIR) AND      
 --IM.FechaMovimiento < @fechaRegistroSobrantes      
 --group by PP.Precio,P.Descripcion      
      
      
       
      
       
 /************************GRAMOS A FAVOR***********************************/      
  INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)      
  SELECT  TipoMovimiento= '2.7-GRAMOS A FAVOR',     Concepto= max(t2.Clave) +'-'+ max(t2.Descripcion),     Abono= 0,   
  Cantidad= (sum(ResultadoGramos))/1000,PrecioUnitario= PrecioProducto, Monto= sum(ImporteGramos)     
  from #GramosFavorEnContra t1 inner join cat_productos t2 on t2.ProductoId= t1.ProductoId     
  where t1.ClaveTipoGramos= 1  group  by ClaveTipoGramos, t1.ProductoId, PrecioProducto  order by t1.ProductoId     
      
 update #TMP_RESULTADO      
 set Monto = Monto * -1      
 where Abono = 0      
      
       
 UPDATE #TMP_RESULTADO      
 SET TotalEntregadoSucursal = ISNULL(@TotalRetiros,0),      
  TotalAnalisisCorteCaja = ISNULL((SELECT SUM(Monto) FROM #TMP_RESULTADO WHERE Abono = 1),0)- ISNULL((SELECT SUM(Monto)*-1 FROM #TMP_RESULTADO WHERE Abono = 0),0)  ,      
  TotalDescuentos = ISNULL((SELECT SUM(Monto)*-1 FROM #TMP_RESULTADO WHERE Abono = 0),0)      
      
 UPDATE #TMP_RESULTADO      
 SET Diferencia = (TotalAnalisisCorteCaja  - TotalEntregadoSucursal ) *-1  
      
       
 /***********************************RESULTADOS******************************/      
 INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)      
 SELECT TOP 1 '3-BALANCE FINAL','Total An?lisis Corte Caja',0,1,TotalAnalisisCorteCaja,TotalAnalisisCorteCaja      
 FROM #TMP_RESULTADO      
 union      
 SELECT TOP 1 '3-BALANCE FINAL','Total Descuentos',0,1,TotalDescuentos,TotalDescuentos      
 FROM #TMP_RESULTADO      
 union      
 SELECT TOP 1 '3-BALANCE FINAL','Total Entregado En Sucursal',0,1,TotalEntregadoSucursal,TotalEntregadoSucursal      
 FROM #TMP_RESULTADO      
 union      
 SELECT TOP 1 '3-BALANCE FINAL','Diferencia',0,1,Diferencia,Diferencia      
 FROM #TMP_RESULTADO      
      
      
 /******************PESO INTELIGENTE****************************/      
      
 /********************INDEFINIDOS*******************/      
 SELECT       
  ID= IDENTITY(INT,1,1),      
  ProductoId = NULL,      
  Clave = NULL,      
  DescripcionCorta = 'INDEFINIDO',      
  BB.Cantidad,      
  TipoBasculaBitacoraId= CASE WHEN BB.TipoBasculaBitacoraId IS NULL THEN 0 ELSE BB.TipoBasculaBitacoraId  END ,      
  Tipo = ISNULL(TBB.Nombre,'INDEFINIDO'),      
  BB.Fecha,      
  Hora = DATEPART(HH,BB.Fecha),      
  Minuto = DATEPART(MM, BB.Fecha),      
  Segundo = 0   ,  
  PrecioSeccion = CAST(0 AS FLOAT)  
 INTO #TMP_DATOS      
 FROM doc_basculas_bitacora BB      
 INNER join cat_tipos_bascula_bitacora TBB ON TBB.TipoBasculaBitacoraId = BB.TipoBasculaBitacoraId        
 WHERE CONVERT(VARCHAR,Fecha,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND      
 BB.ProductoId IS NULL AND      
 TBB.TipoBasculaBitacoraId = 4   AND  
 BB.VentaId IS NULL  
 ORDER BY BB.Fecha       
      
      
       
       
      
      
 /********************TORTILLA/MASA VENTA*****************r**/      
   
   INSERT INTO  #TMP_DATOS(ProductoId,Clave,DescripcionCorta,Cantidad,TipoBasculaBitacoraId,Tipo,Fecha,Hora,Minuto,Segundo)      
 SELECT       
        
  ProductoId = P.ProductoId,      
  Clave = ISNULL(P.Clave,''),      
  DescripcionCorta = ISNULL(p.DescripcionCorta,'INDEFINIDO'),      
  BB.Cantidad,      
  TipoBasculaBitacoraId= CASE WHEN BB.TipoBasculaBitacoraId IS NULL THEN 0 ELSE BB.TipoBasculaBitacoraId  END ,      
  Tipo = ISNULL(TBB.Nombre,'INDEFINIDO'),      
  BB.Fecha,      
  Hora = DATEPART(HH,BB.Fecha),      
  Minuto = DATEPART(MM, BB.Fecha),      
  Segundo = DATEPART(SECOND,BB.Fecha)      
       
 FROM doc_basculas_bitacora BB      
 INNER JOIN cat_productos P ON P.ProductoId = BB.ProductoId      
 INNER join cat_tipos_bascula_bitacora TBB ON TBB.TipoBasculaBitacoraId = BB.TipoBasculaBitacoraId      
 INNER JOIN doc_ventas V ON V.VentaId = BB.VentaId AND V.ClienteId IS NULL   
 WHERE CONVERT(VARCHAR,BB.Fecha,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND      
 --BB.SucursalId = @pSucursalId AND      
 P.productoid IN (1,2) AND      
 BB.TipoBasculaBitacoraId  = 1 AND--VENTA MOSTRADOR      
 BB.VentaId IS NOT NULL   
   
 group by P.Clave,P.ProductoId,p.DescripcionCorta,BB.Fecha,BB.Cantidad,BB.TipoBasculaBitacoraId,TBB.Nombre      
 ORDER BY BB.Fecha      
  
  
  /********************TORTILLA/MASA VENTA PEDIDO PAGADOS*****************r**/      
   
   INSERT INTO  #TMP_DATOS(ProductoId,Clave,DescripcionCorta,Cantidad,TipoBasculaBitacoraId,Tipo,Fecha,Hora,Minuto,Segundo)      
 SELECT       
        
  ProductoId = P.ProductoId,      
  Clave = ISNULL(P.Clave,''),      
  DescripcionCorta = ISNULL(p.DescripcionCorta,'INDEFINIDO'),      
  BB.Cantidad,      
  TipoBasculaBitacoraId= CASE WHEN BB.TipoBasculaBitacoraId IS NULL THEN 0 ELSE BB.TipoBasculaBitacoraId  END ,      
  Tipo = ISNULL('VENTA MAYOREO PAGADO','INDEFINIDO'),      
  BB.Fecha,      
  Hora = DATEPART(HH,BB.Fecha),      
  Minuto = DATEPART(MM, BB.Fecha),      
  Segundo = DATEPART(SECOND,BB.Fecha)     
       
 FROM doc_basculas_bitacora BB      
 INNER JOIN cat_productos P ON P.ProductoId = BB.ProductoId      
 INNER join cat_tipos_bascula_bitacora TBB ON TBB.TipoBasculaBitacoraId = BB.TipoBasculaBitacoraId      
 INNER JOIN doc_ventas V ON V.VentaId = BB.VentaId AND V.ClienteId IS NOT NULL   
 WHERE CONVERT(VARCHAR,BB.Fecha,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND      
 --BB.SucursalId = @pSucursalId AND      
 P.productoid IN (1,2) AND      
 BB.TipoBasculaBitacoraId  = 1 AND--VENTA MOSTRADOR      
 BB.VentaId IS NOT NULL   
   
 group by P.Clave,P.ProductoId,p.DescripcionCorta,BB.Fecha,BB.Cantidad,BB.TipoBasculaBitacoraId,TBB.Nombre      
 ORDER BY BB.Fecha      
      
      
      
 /********************TORTILLA/MASA PRECIO EMPLEADO*****************r**/      
 INSERT INTO  #TMP_DATOS(ProductoId,Clave,DescripcionCorta,Cantidad,TipoBasculaBitacoraId,Tipo,Fecha,Hora,Minuto,Segundo)      
 SELECT       
        
  ProductoId = P.ProductoId,      
  Clave = ISNULL(P.Clave,''),      
  DescripcionCorta = ISNULL(p.DescripcionCorta,'INDEFINIDO'),      
  BB.Cantidad,      
  TipoBasculaBitacoraId= CASE WHEN BB.TipoBasculaBitacoraId IS NULL THEN 0 ELSE BB.TipoBasculaBitacoraId  END ,      
  Tipo = ISNULL(TBB.Nombre,'INDEFINIDO'),      
  BB.Fecha,   
  Hora = DATEPART(HH,BB.Fecha),      
  Minuto = DATEPART(MM, BB.Fecha),      
  Segundo = DATEPART(SECOND,BB.Fecha)      
       
 FROM doc_basculas_bitacora BB      
 INNER JOIN cat_productos P ON P.ProductoId = BB.ProductoId      
 INNER join cat_tipos_bascula_bitacora TBB ON TBB.TipoBasculaBitacoraId = BB.TipoBasculaBitacoraId      
     
 WHERE CONVERT(VARCHAR,BB.Fecha,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND      
 --BB.SucursalId = @pSucursalId AND      
 P.productoid IN (1,2) AND      
 BB.TipoBasculaBitacoraId  = 14 --PRECIO EMPLEADO      
 group by P.Clave,P.ProductoId,p.DescripcionCorta,BB.Fecha,BB.Cantidad,BB.TipoBasculaBitacoraId,TBB.Nombre      
 ORDER BY BB.Fecha      
      
      
      
 /********************TORTILLA/MASA POR PAGAR*****************r**/      
 INSERT INTO  #TMP_DATOS(ProductoId,Clave,DescripcionCorta,Cantidad,TipoBasculaBitacoraId,Tipo,Fecha,Hora,Minuto,Segundo)      
 SELECT       
        
  ProductoId = P.ProductoId,      
  Clave = ISNULL(P.Clave,''),      
  DescripcionCorta = ISNULL(p.DescripcionCorta,'INDEFINIDO'),      
  BB.Cantidad,      
  TipoBasculaBitacoraId= CASE WHEN BB.TipoBasculaBitacoraId IS NULL THEN 0 ELSE BB.TipoBasculaBitacoraId  END ,      
  Tipo = ISNULL('PEDIDO MAYOREO POR PAGAR','INDEFINIDO'),      
  VD.CreadoEl,      
  Hora = DATEPART(HH,VD.CreadoEl),      
  Minuto = DATEPART(MM, VD.CreadoEl),      
  Segundo = DATEPART(SECOND,VD.CreadoEl)      
       
 FROM doc_basculas_bitacora BB      
 INNER JOIN cat_productos P ON P.ProductoId = BB.ProductoId      
 INNER join cat_tipos_bascula_bitacora TBB ON TBB.TipoBasculaBitacoraId = BB.TipoBasculaBitacoraId      
 INNER JOIN doc_pedidos_orden_detalle VD ON VD.ProductoId = BB.ProductoId AND      
         CONVERT(VARCHAR,VD.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND      
         VD.Cantidad = BB.Cantidad       
 WHERE CONVERT(VARCHAR,Fecha,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND      
 --BB.SucursalId = @pSucursalId AND      
 P.productoid IN (1,2) AND      
 BB.TipoBasculaBitacoraId  = 15 --PRECIO EMPLEADO      
 group by P.Clave,P.ProductoId,p.DescripcionCorta,VD.CreadoEl,BB.Cantidad,BB.TipoBasculaBitacoraId,TBB.Nombre      
 ORDER BY VD.CreadoEl      
       
      
       
 SELECT       
  ID = MAX(ID),      
  ProductoId,      
  --Cantidad = MAX(Cantidad),      
  TipoBasculaBitacoraId,      
  --Fecha = MAX(Fecha),      
  Tipo,      
  Hora,      
  Minuto,      
  Segundo      
 INTO #TMP_FILTRO_MOVS      
 FROM #TMP_DATOS      
 WHERE ISNULL(ProductoId,0) = 0      
 GROUP BY ProductoId,Hora, Minuto,Segundo,TipoBasculaBitacoraId,Tipo      
       
      
      
 INSERT INTO #TMP_FILTRO_MOVS      
 SELECT       
  ID = MAX(ID),      
  ProductoId,        
  TipoBasculaBitacoraId,        
  Tipo,      
  Hora,      
  Minuto,      
  0      
       
 FROM #TMP_DATOS      
 WHERE ISNULL(ProductoId,0) > 0      
 GROUP BY ProductoId,Hora, Minuto,TipoBasculaBitacoraId,Tipo,ID      
      
      
 /******************************PESO INTELIGENTE****************************************/      
 INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)       
 SELECT       
  '4 PESO INTELIGENTE (RESUMEN)',        
  Producto = ISNULL(P.Clave,'') +'-'+ ISNULL(p.DescripcionCorta,'') + ' (' + TMP.Tipo + ')',      
  0,      
  Cantidad = ISNULL(CASE WHEN TMP.TipoBasculaBitacoraId IN (12,14) THEN SUM(TMPD.Cantidad) * -1 ELSE SUM(TMPD.Cantidad) END,0),      
  ISNULL(MAX(pp.Precio),0),      
  Total = ISNULL(CASE WHEN TMP.TipoBasculaBitacoraId IN (12,14) THEN SUM(TMPD.Cantidad) * MAX(pp.Precio) *-1 ELSE SUM(TMPD.Cantidad) * MAX(pp.Precio) END,0)       
 FROM #TMP_FILTRO_MOVS TMP      
 INNER JOIN #TMP_DATOS TMPD ON TMPD.ID = TMP.ID      
 LEFT JOIN cat_productos P ON P.ProductoId = TMP.ProductoId      
 left JOIN #TMP_PRECIOS PP ON PP.ProductoId = p.ProductoId   
 GROUP BY TMP.ProductoId,P.Clave,p.DescripcionCorta,TMP.TipoBasculaBitacoraId,TMP.Tipo      
   
   

 iNSERT INTO #TMP_TOTAL_TORTILLA(Cantidad, DESCRIPCION )/**/      
 select Cantidad, 'Indefinido' 
 from #TMP_RESULTADO where TipoMovimiento like '4 PESO INTELIGENTE (RESUMEN)' and Concepto like '%- (Indefinido)%'
  
 iNSERT INTO #TMP_TOTAL_TORTILLA(Cantidad, DESCRIPCION )/**/      
 SELECT         
  Cantidad = ISNULL(SUM(TMPD.Cantidad),0),      
  ISNULL(P.Clave,'') +'-'+ ISNULL(p.DescripcionCorta,'') + ' (' + TMP.Tipo + ')'
  FROM #TMP_FILTRO_MOVS TMP      
 INNER JOIN #TMP_DATOS TMPD ON TMPD.ID = TMP.ID      
 LEFT JOIN cat_productos P ON P.ProductoId = TMP.ProductoId      
 left JOIN #TMP_PRECIOS PP ON PP.ProductoId = p.ProductoId   
 WHERE TMP.ProductoId= 1 and TMP.TipoBasculaBitacoraId not IN (12,14) 
 GROUP BY TMP.ProductoId,P.Clave,p.DescripcionCorta,TMP.TipoBasculaBitacoraId,TMP.Tipo 
 
 SELECT @rendimientoPorTiarada = SUM(Cantidad)
 FROM #TMP_TOTAL_MASA

 SELECT @rendimientoPorTiarada = (@rendimientoPorTiarada / SUM(Cantidad)  ) * 40
 FROM #TMP_TOTAL_TORTILLA

 
 
 -- INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)      
 -- SELECT '5 RENDIMINETO POR TIRADA',
	--	'1-RENDIMIENTO: ', 0, 
	--	Cantidad= 0,
	--	PrecioUnitario= 0,Monto= 0

	--update #TMP_RESULTADO
	--SET Cantidad = @rendimientoPorTiarada
	--where TipoMovimiento = '5 RENDIMINETO POR TIRADA'

 SELECT Fila ,      
  TipoMovimiento,      
  Concepto,      
  Abono,      
  Cantidad,      
  PrecioUnitario,      
  Monto,      
  TotalAnalisisCorteCaja = ISNULL(TotalAnalisisCorteCaja,0),      
  TotalDescuentos = ISNULL(TotalDescuentos,0),      
  TotalEntregadoSucursal = ISNULL(TotalEntregadoSucursal,0),      
  Diferencia = ISNULL(Diferencia,0)      
 FROM #TMP_RESULTADO      
 order by Fila    
end    
  
GO
/****** Object:  StoredProcedure [dbo].[p_corte_caja_validaMovs]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_corte_caja_validaMovs 9,3,'20220921',0
CREATE Proc [dbo].[p_corte_caja_validaMovs]
@pCajaId int,
@pUsuarioId int,
@pFechaHoraCorte datetime,
@pHayMovimientos bit out
as

	set @pHayMovimientos = 0
	set dateformat dmy
	declare @fechaUltimoCorte datetime,
		@corteCajaId int,
		@gastos money,
		@ventaIniId int,
		@ventaFinId int,
		@error varchar(500) = '',
		@esSupervisorGral bit

		set @pFechaHoraCorte = dbo.fn_GetDateTimeServer()

	select @fechaUltimoCorte = isnull(max(FechaCorte),'19000101')
	from doc_corte_caja
	where CajaId = @pCajaId	

	

	select @esSupervisorGral = EsSupervisor
	from cat_usuarios
	where IdUsuario = @pUsuarioId

	--validar CANCELACIONES
	if not exists(
		select 1
		from doc_ventas v
		where cajaId = @pCajaId and
		FechaCancelacion between 
		@fechaUltimoCorte and @pFechaHoraCorte
		and v.activo = 1 
		and (
			UsuarioCreacionId = @pUsuarioId OR
			@esSupervisorGral = 1
		)
	)
	--validar retiros
	and not exists(
		select 1
		from doc_retiros r
		where 
		(
			r.CreadoPor = @pUsuarioId
			OR
			@esSupervisorGral = 1
		)
		 and
		
			r.CajaId = @pCajaId 
			
		 and
		r.FechaRetiro between @fechaUltimoCorte and @pFechaHoraCorte
	)
	--validar gastos
	and not exists(
		select 1
		from doc_gastos g
		where g.CajaId = @pCajaId and
		(
			g.CreadoPor = @pUsuarioId
			OR
			@esSupervisorGral = 1
		) and
		g.CreadoEl between @fechaUltimoCorte and @pFechaHoraCorte
	)
	--validar devoluciones
	and not exists(
		select 1
		from doc_devoluciones dev
		where (
			dev.CreadoPor = @pUsuarioId
			OR
			@esSupervisorGral =1
		) and
		dev.CreadoEl between @fechaUltimoCorte and @pFechaHoraCorte
		
	)
	--Validar ventas
	and not exists (
		select 1
		from doc_ventas v
		where cajaId = @pCajaId and
		Fecha between 
		@fechaUltimoCorte and @pFechaHoraCorte
		and v.activo = 1 
		and (
			UsuarioCreacionId = @pUsuarioId
			OR
			@esSupervisorGral = 1
		)
		
	)
	--validar apartados
	and not exists (
		select 1
		from doc_apartados a
		inner join doc_apartados_pagos ap on ap.ApartadoId = a.ApartadoId
		where a.CajaId = @pCajaId  and
		ap.FechaPago between 
		@fechaUltimoCorte and @pFechaHoraCorte and
		a.Activo = 1 and
		(
			ap.CreadoPor = @pUsuarioId
			or 
			@esSupervisorGral = 1
		)
	)	
	
	begin
		set @error= 'No hay movimientos para generar el corte'		
		set @pHayMovimientos = 0
	
	end
	else
		set @pHayMovimientos = 1

	select @error











GO
/****** Object:  StoredProcedure [dbo].[p_doc_aceptaciones_sucursal_grd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select * from doc_inv_movimiento
-- p_doc_aceptaciones_sucursal_grd 1070
CREATE PROC [dbo].[p_doc_aceptaciones_sucursal_grd]
@pMovimientoId INT
AS


	SELECT AD.Id,
			ID.MovimientoId,
		   ID.MovimientoDetalleId,
		   p.ProductoId,
		   Producto = P.Descripcion,
		   CantidadMovimiento = ID.Cantidad,
		   CantidadReal = AD.CantidadReal,
		   AD.MovimientoDetalleAjusteId
	FROM doc_inv_movimiento I
	INNER JOIN doc_inv_movimiento_detalle ID ON ID.MovimientoId = I.MovimientoId
	INNER JOIN cat_productos P ON P.ProductoId = ID.ProductoId
	LEFT JOIN doc_aceptaciones_sucursal_detalle AD ON AD.MovimientoDetalleId = ID.MovimientoDetalleId
	WHERE I.MovimientoId = @pMovimientoId

GO
/****** Object:  StoredProcedure [dbo].[p_doc_apartado_venta_generacion]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- p_doc_apartado_venta_generacion 3,1,0
CREATE proc [dbo].[p_doc_apartado_venta_generacion]
@pApartadoId int,
@pCreadoPor int,
@pVentaId bigint out
as

	declare 
		@descuentoTotal money,
		@impuestos money,
		@subtotal money,
		@total money,
		@ventaDetalleId int

	select @pVentaId = isnull(max(VentaId),0) + 1
	from doc_ventas

	select @descuentoTotal = isnull(sum(Descuentos),0),
		@impuestos = isnull(sum(Impuestos),0),
		@subtotal = isnull(sum(Subtotal),0),
		@total = isnull(sum(Total),0)
	from doc_apartados_productos
	where ApartadoId = @pApartadoId

	
	
	begin tran

	insert into doc_ventas(
		VentaId,			Folio,				Fecha,				ClienteId,
		DescuentoVentaSiNo,	PorcDescuentoVenta,	MontoDescuentoVenta,DescuentoEnPartidas,
		TotalDescuento,		Impuestos,			SubTotal,			TotalVenta,
		TotalRecibido,		Cambio,				Activo,				UsuarioCreacionId,
		FechaCreacion,		UsuarioCancelacionId,FechaCancelacion,	SucursalId,
		CajaId
	)
	select @pVentaId,		@pVentaId,			GETDATE(),			ClienteId,
	case when isnull(@descuentoTotal,0) > 0 then 1 else 0 end,
	0,0,@descuentoTotal,
	@descuentoTotal,		@impuestos,			@subtotal,			@total,
		@total ,				0,					1,					@pCreadoPor,
		GETDATE(),			null,				null,				SucursalId,
		CajaId
	from doc_apartados a	
	where ApartadoId = @pApartadoId

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	select @ventaDetalleId= isnull(max(VentaDetalleId),0) + 1
	from doc_ventas_detalle

	insert into doc_ventas_detalle(
		VentaDetalleId,			VentaId,		ProductoId,		Cantidad,
		PrecioUnitario,			PorcDescuneto,	Descuento,		Impuestos,
		Total,					UsuarioCreacionId,FechaCreacion
	)
	select ROW_NUMBER() OVER(ORDER BY ApartadoProductoId ASC) + @ventaDetalleId ,		@pVentaId,		ProductoId,		Cantidad,
		Precio,					POrcentajeDescuento,Descuentos,	Impuestos,
		Total,					@pCreadoPor,GETDATE()				
	from doc_apartados_productos
	where ApartadoId = @pApartadoId


	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	

	
	--if @@error <> 0
	--begin
	--	rollback tran
	--	goto fin
	--end

	update doc_apartados
	set VentaId = @pVentaId
	where ApartadoId = @pApartadoId

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end


	insert into doc_ventas_formas_pago(
		FormaPagoId,	VentaId,	Cantidad,	FechaCreacion,
		UsuarioCreacionId,digitoVerificador
	)
	select isnull(FormaPagoId,1),@pVentaId,Importe = sum(fp.cantidad),getdate(),
	@pCreadoPor,max(digitoverificador)
	from doc_apartados_formas_pago fp
	inner join doc_apartados_pagos ap on ap.ApartadoPagoId = fp.ApartadoPagoId
	where ap.ApartadoId = @pApartadoId and
	fp.cantidad > 0
	group by fp.FormaPagoId


	if @@error <> 0
	begin
		rollback tran
		goto fin
	end


	commit tran
	fin:
	






GO
/****** Object:  StoredProcedure [dbo].[p_doc_apartados_consulta_grd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_doc_apartados_consulta_grd 1,'D'
create proc [dbo].[p_doc_apartados_consulta_grd]
@pSucursalId int,
@pTexto varchar(200),
@pSoloConSaldo bit
as

	select a.ClienteId,
		c.Nombre,
		Saldo = sum(a.Saldo)
	from doc_apartados a
	inner join cat_clientes c on c.ClienteId = a.ClienteId
	where a.SucursalId = @pSucursalId 
	and
	(
		cast(a.ClienteId as varchar) = cast(@pTexto as varchar) OR
		c.Nombre like '%'+rtrim(@pTexto)+'%'
	)
	group by a.ClienteId,c.Nombre
	having (sum(a.Saldo) > 0 and @pSoloConSaldo = 1)
	OR
	@pSoloConSaldo = 0




GO
/****** Object:  StoredProcedure [dbo].[p_doc_apartados_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE pROC [dbo].[p_doc_apartados_ins]
@pApartadoId	int out,
@pSucursalId	int,
@pClienteId	int,
@pTotalApartado	money,
@pSaldo	money,
@pCreadoPor	int,
@pCajaId int
as

	declare @fechaVencimiento datetime,
			@fechaProrroga datetime,
			@diasLiquidacion int,
			@diasProrroga int

	select @diasLiquidacion = ApartadoDiasLiq,
		@diasProrroga = ApartadoDiasProrroga
	from cat_configuracion

	set @fechaVencimiento = DATEADD(dd,@diasLiquidacion,getdate())
	set @fechaProrroga = DATEADD(dd,@diasProrroga,@fechaVencimiento)
	

	select @pApartadoId = isnull(max(ApartadoId),0)+1
	from doc_apartados

	

	insert into doc_apartados(
		ApartadoId,	SucursalId,	ClienteId,	TotalApartado,
		Saldo,		Activo,		CreadoEl,	CreadoPor,
		FechaLimite,FechaProrroga,VentaId,	CajaId
	)
	select @pApartadoId,	@pSucursalId,	@pClienteId,	@pTotalApartado,
		@pSaldo,		1,		getdate(),	@pCreadoPor,
		@fechaVencimiento,@fechaProrroga,null,@pCajaId

	

	







GO
/****** Object:  StoredProcedure [dbo].[p_doc_apartados_mov_inv]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[p_doc_apartados_mov_inv]
@pApartadoId int
as

	declare @MovimientoId int,
			@MovimientoDetalleId int,
			@consecutivo int

	select @MovimientoId = isnull(max(MovimientoId),0) + 1
	from doc_inv_movimiento

	select @consecutivo = isnull(max(Consecutivo),0)+1
	from doc_inv_movimiento
	where TipoMovimientoId = 17

	begin tran

	insert into doc_inv_movimiento(
		MovimientoId,	SucursalId,	FolioMovimiento,	TipoMovimientoId,
		FechaMovimiento,HoraMovimiento,Comentarios,		ImporteTotal,
		Activo,			CreadoPor,		CreadoEl,		Autorizado,
		FechaAutoriza,	SucursalDestinoId,AutorizadoPor,FechaCancelacion,
		ProductoCompraId,Consecutivo,SucursalOrigenId,	VentaId,
		MovimientoRefId,Cancelado
	)
	select @MovimientoId,SucursalId,@consecutivo,17,
	GETDATE(),			GETDATE(),	'',					TotalApartado,
	1,				CreadoPor,		GETDATE(),			1,
	GETDATE(),			NULL,			CreadoPor,		null,
	null,				@consecutivo,SucursalId,		null,
	null,				0
	from doc_apartados
	where ApartadoId = @pApartadoId

	if @@ERROR <> 0
	begin
		rollback tran
		goto fin
	end

	select @MovimientoDetalleId = isnull(max(MovimientoDetalleId),0)+1

	from doc_inv_movimiento_detalle
	insert into doc_inv_movimiento_detalle(
		MovimientoDetalleId,	MovimientoId,	ProductoId,		Consecutivo,
		Cantidad,				PrecioUnitario,	Importe,		Disponible,
		CreadoPor,				CreadoEl,		CostoUltimaCompra,CostoPromedio,
		ValCostoUltimaCompra,	ValCostoPromedio,ValorMovimiento
	)
	SELECT @MovimientoDetalleId + ROW_NUMBER() OVER(ORDER BY ProductoId ASC) ,@MovimientoId,	ProductoId,ROW_NUMBER() OVER(ORDER BY ProductoId ASC) ,
	Cantidad,					Precio,			Total,			Cantidad,
	CreadoPor,					GETDATE(),		null,			null,
	null,						null,			null
	FROM doc_apartados_productos
	WHERE ApartadoId = @pApartadoId

	if @@ERROR <> 0
	begin
		rollback tran
		goto fin
	end

	commit tran
	fin:


	








GO
/****** Object:  StoredProcedure [dbo].[p_doc_apartados_pagos_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[p_doc_apartados_pagos_ins]
@pApartadoPagoId	int out,
@pApartadoId	int,
@pImporte	money,
@pFechaPago	datetime,
@pCreadoPor	int,
@pAnticipo bit,
@pFormaPagoId int,
@pDigitoVerificador varchar(20),
@pCajaId int
as

	declare	 @pagos money,
			@total money

		begin tran		

		if(@pApartadoPagoId = 0)
		begin 		

			select @pApartadoPagoId=isnull(max(ApartadoPagoId),0)+1
			from doc_apartados_pagos 


			insert into doc_apartados_pagos(
				ApartadoPagoId,ApartadoId,Importe,FechaPago,CreadoPor,Anticipo,CajaId
			)
			values(
				@pApartadoPagoId,@pApartadoId,@pImporte,GETDATE(),@pCreadoPor,@pAnticipo,@pCajaId
			)

			if @@error <> 0
			begin
				rollback tran
				goto fin
			end
		end

		insert into doc_apartados_formas_pago(
			ApartadoPagoId,	FormaPagoId,	DigitoVerificador,CreadoEl,Cantidad
		)
		select @pApartadoPagoId,@pFormaPagoId,@pDigitoVerificador,GETDATE(),@pImporte

		if @@error <> 0
		begin
				rollback tran
				goto fin
		end

		update doc_apartados_pagos
		set Importe = (select sum(isnull(cantidad,0)) from doc_apartados_formas_pago st1 where st1.ApartadoPagoId = @pApartadoPagoId)
		where ApartadoPagoId = @pApartadoPagoId

		if @@error <> 0
		begin
				rollback tran
				goto fin
		end

		/**Actualizar saldo***/

		select @total = TotalApartado
		from doc_apartados
		where ApartadoId = @pApartadoId

		select @pagos = isnull(sum(Importe),0)
		from doc_apartados_pagos
		where ApartadoId = @pApartadoId

		update doc_apartados
		set Saldo = @total - @pagos
		where ApartadoId = @pApartadoId

		if @@error <> 0
		begin
			rollback tran
			goto fin
		end


		commit tran
		fin:












GO
/****** Object:  StoredProcedure [dbo].[p_doc_apartados_productos_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[p_doc_apartados_productos_ins]
@pApartadoProductoId	int out,
@pApartadoId	int,
@pProductoId	int,
@pCantidad	decimal(7,2),
@pPrecio	money,
@pCreadoPor	int,
@pSubTotal money,
@pImpuestos money,
@pDescuentos money,
@pPorcDescuneto decimal(6,2),
@pTotal money
as

	select @pApartadoProductoId = isnull(max(ApartadoProductoId),0) + 1
	from doc_apartados_productos

	begin tran
	
	insert into doc_apartados_productos(
		ApartadoProductoId,	ApartadoId,	ProductoId,	Cantidad,
		Precio,				CreadoEl,	CreadoPor,	ModificadoEl,
		ModificadoPor,		Total,		Subtotal,	Impuestos,
		Descuentos,			POrcentajeDescuento
	)
	select @pApartadoProductoId,@pApartadoId,@pProductoId,@pCantidad,
	@pPrecio,				GETDATE(),	@pCreadoPor,null,
	null,					@pTotal,
	@pSubTotal,@pImpuestos,@pDescuentos,@pPorcDescuneto

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	update doc_apartados_productos
		set Descuentos = (cantidad * precio ) - Total
	where ApartadoProductoId = @pApartadoProductoId

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	commit tran

	fin:
	





GO
/****** Object:  StoredProcedure [dbo].[p_doc_cliente_licencia_gen]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_doc_cliente_licencia_gen]
@pVentaId int
as 

	declare @ClienteLicenciaId int

	select @ClienteLicenciaId = isnull(max(ClienteLicenciaId),0) +1
	from doc_clientes_licencias
	
	insert into doc_clientes_licencias(
		ClienteLicenciaId,		ClienteId,		ProductoId,		FechaVigencia,
		Vigente,				CreadoEl,		ModificadoEl
	)
	select ROW_NUMBER() OVER(ORDER BY v.VentaId ASC),v.ClienteId,vd.ProductoId,
	case when pl.UnidadLicencia = 'd' then dateadd(dd,pl.TiempoLicencia,getdate())
		when pl.UnidadLicencia = 'm' then dateadd(mm,pl.TiempoLicencia,getdate())
		when pl.UnidadLicencia = 'y' then dateadd(yy,pl.TiempoLicencia,getdate())
	end,1,getdate(),getdate()
	from doc_ventas v
	inner join doc_ventas_detalle vd on vd.VentaId = v.VentaId
	inner join cat_productos_licencias pl on pl.ProductoId = vd.ProductoId
	where v.VentaId = @pVentaId and
	v.ClienteId is not null 

	if @@ROWCOUNT <= 0
		RAISERROR (15600,-1,-1, 'No fue posible generar la licencia del usuario');

	
GO
/****** Object:  StoredProcedure [dbo].[p_doc_clientes_licencia_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[p_doc_clientes_licencia_sel]
@pKeyClient varchar(100)--,
--@pTipoProducto varchar(20),
--@pVersion varchar(20)
as

	select cl.ClienteLicenciaId,
		cl.ClienteId,
		cl.ProductoId,
		cl.FechaVigencia,
		cl.Vigente,
		cl.CreadoEl,
		cl.ModificadoEl
	from doc_clientes_licencias cl
	inner join cat_clientes c on c.ClienteId = cl.clienteId
	where --cl.productoId = @pProductoId and
	c.KeyClient = @pKeyClient


GO
/****** Object:  StoredProcedure [dbo].[p_doc_cocimiento_habilitar]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_doc_cocimiento_habilitar]
@pSucursalId INT
AS

	DECLARE @cocimientoGrupoId INT


	SELECT C.*
	into #tmpCocimientos
	FROM doc_cocimientos C
	INNER JOIN doc_produccion P ON P.ProduccionId = C.ProduccionId AND
							P.SucursalId = @pSucursalId AND
							CONVERT(VARCHAR,C.FechaCocimiento,112) < CONVERT(VARCHAR,GETDATE(),112)

	INSERT INTO doc_cocimientos_grupos(SucursalId,CreadoEl,CreadoPor)
	VALUES(@pSucursalId,GETDATE(),1)

	SET @cocimientoGrupoId = SCOPE_IDENTITY()

	UPDATE doc_cocimientos
	SET FechaHabilitado = GETDATE()
	FROM doc_cocimientos C
	INNER JOIN #tmpCocimientos TMP ON TMP.CocimientoId = C.CocimientoId
	

	INSERT INTO doc_cocimientos_grupos_detalle(CocimientoGrupoId,CocimientoId,CreadoEl)
	SELECT @cocimientoGrupoId,CocimientoId,GETDATE()	
	FROM #tmpCocimientos
GO
/****** Object:  StoredProcedure [dbo].[p_doc_corte_caja_grd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- [p_doc_corte_caja_grd] 2,2,'20180501','20180504'
CREATE Proc [dbo].[p_doc_corte_caja_grd]
@pSucursalId int,
@pUsuarioId int,
@pFechaDel DateTime,
@pFechaAl DateTime
as

	


	select CC.CajaId,
		CC.TotalCorte,
		CC.TotalEgresos,
		CC.TotalIngresos,
		CC.CreadoEl,
		cc.CorteCajaId,
		Sucursal = suc.NombreSucursal,
		Caja = c.Descripcion
	from doc_corte_caja cc
	inner join cat_cajas c on c.Clave = cc.CajaId
	inner join cat_sucursales suc on suc.clave = c.sucursal
	inner join cat_usuarios usu on usu.IdUsuario = @pUsuarioId
	where c.Sucursal = @pSucursalId and
	(
		@pUsuarioId in (cc.CreadoPor,0) 
		OR
		usu.EsSupervisor = 1

	) and
	convert(varchar,cc.CreadoEl,112) between convert(varchar,@pFechaDel,112) and convert(varchar,@pFechaAl,112)
	ORDER BY CC.CorteCajaId DESC






GO
/****** Object:  StoredProcedure [dbo].[p_doc_corte_caja_tortilleria]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_doc_corte_caja_tortilleria 6,'20230315','20230315',1
CREATE PROC [dbo].[p_doc_corte_caja_tortilleria]
@pSucursalId INT,
@pFechaIni DATETIME,
@pFechaFin DATETIME,
@pUsuarioId INT
AS

	DECLARE @SacosMaiz FLOAT,
		@SacosMaseca FLOAT,
		@KilosTortillaTotal FLOAT,
		@PrecioTortilla FLOAT,
		@MasaProdFinal FLOAT,
		@TotalEntradas FLOAT,
		@TotalRetiros FLOAT,
		@SobranteMasaDiaAnterior FLOAT,
		@GramosMermaMayoreoKilo FLOAT=.07

	 CREATE TABLE #TMP_TIPOS(
		TipoId INT,
		Tipo VARCHAR(250)
	 )
	 
	 CREATE TABLE #TMP_RESULTADO      
	 (      
	  Fila int identity(1,1),      
	  TipoId INT,      
	  Concepto VARCHAR(450),      
	  Abono BIT,      
	  Cantidad decimal(14,3),      
	  PrecioUnitario MONEY,      
	  Total  decimal(14,3),
	  Clave  varchar(50) NULL,
	  Mostrar BIT NULL DEFAULT 1,
	  TotalEntradas DECIMAL(14,3) NULL,
	  TotalDescuentos DECIMAL(14,3) NULL,
	  TotalRetiros DECIMAL(14,3) NULL,
	  TotalDiferencia DECIMAL(14,3) NULL,
	  TotalRequerido DECIMAL(14,3) NULL,
	  TotalRegistradoSistema DECIMAL(14,3) NULL
	 )      

	 SELECT VD.ProductoId,Fecha = CAST(V.Fecha AS date),Precio = MAX(VD.PrecioUnitario)
	 INTO #TMP_PRECIOS_HIS
	 FROM doc_ventas_detalle VD
	 INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId
	 WHERE V.SucursalId = @pSucursalId AND
	 V.ClienteId IS NULL AND
	 CAST(V.Fecha AS date) BETWEEN CAST(@pFechaIni AS DATE)AND CAST(@pFechaFin AS date) 
	 GROUP BY VD.ProductoId,CAST(V.Fecha AS date)


	 SELECT @SobranteMasaDiaAnterior = SUM(PS.CantidadSobrante)
	 FROM doc_productos_sobrantes_registro PS
	 INNER JOIN cat_productos P ON P.ProductoId = PS.ProductoId AND
								P.Clave IN('2','S001')
	 WHERE CAST(PS.CerradoEl AS date) BETWEEN DATEADD(DAY,-1,CAST(@pFechaIni AS DATE)) AND DATEADD(DAY,-1,CAST(@pFechaFin AS date)) AND
	 PS.SucursalId = @pSucursalId AND
	 PS.Cerrado = 1

	 
	 INSERT INTO #TMP_TIPOS
	 SELECT 1,'1. PRODUCCI�N'
	 UNION
	 SELECT 2,'2. VENTAS MASA'
	 UNION
	 SELECT 3,'3. ENTRADAS POR TRASPASO'
	 UNION
	 SELECT 4,'4. PRODUCCI�N TORTILLA'
	 UNION
	 SELECT  5,'5. ENTRADAS POR VENTA DE PRODUCTO'
	 UNION
	 SELECT  6,'6. DESCUENTO SOBRANTES'
	 UNION
	 SELECT  7,'7. DESCUENTO VENTAS MAYOREO'
	 UNION
	 SELECT  8,'8. DESCUENTO POR GRAMOS EN CONTRA'
	 UNION
	 SELECT  9,'8. GASTOS CAJA CHICA'
	 UNION
	 SELECT 10,'9. SALIDAS POR TRASPASO'

	  SELECT @SacosMaiz = ISNULL(SUM(T1.MaizSacos),0),
			@SacosMaseca = ISNULL(SUM(T1.MasecaSacos),0),
			@KilosTortillaTotal = ISNULL(SUM(T1.TortillaTotalRendimiento),0)
	  FROM doc_maiz_maseca_rendimiento T1
	  WHERE CAST(T1.Fecha AS date) BETWEEN DATEADD(DAY,-1,CAST(@pFechaIni AS date)) AND DATEADD(DAY,-1,CAST(@pFechaFin AS DATE))
	  AND T1.SucursalId = @pSucursalId
	  GROUP BY T1.SucursalId

	  SET @MasaProdFinal = ISNULL(@KilosTortillaTotal,0) / .800

	  /************PRODUCCI�N ESTIMADA************/
	  INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	  VALUES(1,'Total Sacos Maiz',1,ISNULL(@SacosMaiz,0),0,0,'MAIZS')

	  INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	  VALUES(1,'Total Sacos Maseca',1,ISNULL(@SacosMaseca,0),0,0,'MASECAS')

	   INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	  SELECT 1,'Masa - Sobrante d�a anterior',1,ISNULL(@SobranteMasaDiaAnterior,0),0, 0,'MASA_DIA_ANT'

	  SET @MasaProdFinal = ISNULL(@MasaProdFinal,0) + ISNULL(@SobranteMasaDiaAnterior,0)

	  INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	  SELECT 1,'Masa - Kg Estimados Producci�n',1,ISNULL(@MasaProdFinal,0),0, 0,'MASA_PROD'

	  INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave,Mostrar)
	  SELECT 1,'Kg Estimados Prod Tortilla',1,(ISNULL(@MasaProdFinal,0)*.8),P.Precio, P.Precio * (ISNULL(@MasaProdFinal,0)*.8),'TORTPROD',0
	  FROM #TMP_PRECIOS_HIS P WHERE P.ProductoId = 1

	  
	  /***********VENTA MAYOREO*************/
	  INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	  SELECT 2,'Tortilla - Venta Mayoreo Pagado Atrasado' ,0,SUM(VD.Cantidad),VD.PrecioUnitario,SUM(VD.Cantidad) * VD.PrecioUnitario,'VTORT_MAY_ATRAS'
	  FROM doc_ventas_detalle VD
	  INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId
	  INNER JOIN doc_pedidos_orden PO ON PO.VentaId = V.VentaId AND
									CAST(PO.CreadoEl AS date) < CAST(V.Fecha AS date)
	  WHERE VD.ProductoId = 1 AND--TORTILLA
	  CAST(V.Fecha AS DATE) BETWEEN CAST(@pFechaIni AS DATE) AND CAST(@pFechaFin AS date) AND
	  V.SucursalId = @pSucursalId  AND
	  V.ClienteId IS NOT NULL AND
	  V.Activo = 1
	  GROUP BY VD.ProductoId,VD.PrecioUnitario

	   IF NOT EXISTS (SELECT 1 FROM #TMP_RESULTADO WHERE Clave = 'VTORT_MAY_ATRAS') 
	  INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	  SELECT 2,'Tortilla - Venta Mayoreo Pagado Atrasado' ,0,0,0,0,'VTORT_MAY_ATRAS'

	  /***************************************************************/

	  --INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	  --SELECT 2,'Masa - Ventas Mostrador',1,SUM(VD.Cantidad),VD.PrecioUnitario,SUM(VD.Cantidad) * VD.PrecioUnitario,'VMASA_MOSTRADOR'
	  --FROM doc_ventas_detalle VD
	  --INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId
	  --WHERE VD.ProductoId = 2 AND--MASA
	  --CAST(V.Fecha AS DATE) BETWEEN CAST(@pFechaIni AS DATE) AND CAST(@pFechaFin AS date) AND
	  --V.SucursalId = @pSucursalId  AND
	  --V.ClienteId IS NULL AND
	  --V.Activo = 1
	  --GROUP BY VD.ProductoId,VD.PrecioUnitario

	 
	 

	  /*********************************************************************************/
	 -- INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	 -- SELECT 2,'Masa - Venta Mayoreo Pagado el Mismo d�a' ,1,
		--SUM(POD.CantidadOriginal),pod.PrecioUnitario,SUM(POD.CantidadOriginal) * pod.PrecioUnitario,'VMASA_MAY_DIA'
	 -- FROM doc_pedidos_orden_detalle POD
	 -- INNER JOIN doc_pedidos_orden PO ON PO.PedidoId = POD.PedidoId 
	 -- INNER JOIN doc_ventas V ON V.VentaId = PO.VentaId AND
		--					V.Activo = 1 AND
		--					CAST(V.Fecha AS DATE) BETWEEN CAST(@pFechaIni AS DATE) AND CAST(@pFechaFin AS date) 
	 --  INNER JOIN #TMP_PRECIOS_HIS PRE ON PRE.ProductoId = POD.ProductoId
	 -- WHERE PO.SucursalId = @pSucursalId AND
	 -- CAST(PO.CreadoEl AS date) BETWEEN CAST(@pFechaIni AS DATE) AND CAST(@pFechaFin AS date) AND
	 -- PO.VentaId IS NOT NULL AND
	 -- --PO.Activo = 1 AND
	 -- POD.ProductoId = 2
	 -- GROUP BY pod.PrecioUnitario

	 -- SELECT 2,'Masa - Venta Mayoreo Pagado el Mismo d�a' ,1,
		--SUM(VD.Cantidad),VD.PrecioUnitario,SUM(VD.Cantidad) * VD.PrecioUnitario,'VMASA_MAY_DIA'
	 -- FROM doc_ventas_detalle VD
	 -- INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId
	 -- INNER JOIN doc_pedidos_orden PO ON PO.VentaId = V.VentaId 
	 -- INNER JOIN doc_pedidos_orden_detalle POD ON POD.PedidoId = PO.PedidoId
	 -- WHERE VD.ProductoId = 2 AND--MASA
	 -- CAST(V.Fecha AS DATE) BETWEEN CAST(@pFechaIni AS DATE) AND CAST(@pFechaFin AS date) AND
	 -- V.SucursalId = @pSucursalId  AND
	 -- V.ClienteId IS NOT NULL AND
	 -- V.Activo = 1 AND
	 -- (CAST(PO.CreadoEl AS date) = CAST(V.Fecha AS date) OR PO.CreadoEl IS NULL)
	 -- GROUP BY VD.ProductoId,VD.PrecioUnitario

	  --IF NOT EXISTS (SELECT 1 FROM #TMP_RESULTADO WHERE Clave = 'VMASA_MAY_DIA') 
	  --INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	  --SELECT 2,'Masa - Venta Mayoreo Pagado el Mismo d�a' ,0,0,0,0,'VMASA_MAY_DIA'
	 
	  /**************************DEVOLUCIONES DE MASA*********************************************************/


	  /************************************************************************************/

	  INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	  SELECT 2,'Masa - Venta Mayoreo Pagado Atrasado' ,0,SUM(VD.Cantidad),VD.PrecioUnitario,SUM(VD.Cantidad) * VD.PrecioUnitario,'VMASA_MAY_ATRAS'
	  FROM doc_ventas_detalle VD
	  INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId
	  INNER JOIN doc_pedidos_orden PO ON PO.VentaId = V.VentaId AND
									CAST(PO.CreadoEl AS date) < CAST(V.Fecha AS date)
	  WHERE VD.ProductoId = 2 AND--MASA
	  CAST(V.Fecha AS DATE) BETWEEN CAST(@pFechaIni AS DATE) AND CAST(@pFechaFin AS date) AND
	  V.SucursalId = @pSucursalId  AND
	  V.ClienteId IS NOT NULL AND
	  V.Activo = 1
	  GROUP BY VD.ProductoId,VD.PrecioUnitario

	   IF NOT EXISTS (SELECT 1 FROM #TMP_RESULTADO WHERE Clave = 'VMASA_MAY_ATRAS') 
	  INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	  SELECT 2,'Masa - Venta Mayoreo Pagado Atrasado' ,0,0,0,0,'VMASA_MAY_ATRAS'




	  /***********ENTRADAS POR TRASPASO*************/
	   INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	  SELECT 3,'Tortilla - Traspaso Entrada',1,ISNULL(SUM(MD.Cantidad),0),P.Precio,P.Precio * ISNULL(SUM(MD.Cantidad),0),'TORT_E_TRAS'
	  FROM doc_inv_movimiento M
	  INNER JOIN doc_inv_movimiento_Detalle MD ON MD.MovimientoId = M.MovimientoId AND
										MD.ProductoId = 1 AND--TORTILLA
										M.SucursalId = @pSucursalId AND
										  CAST(M.FechaMovimiento AS DATE) BETWEEN CAST(@pFechaIni AS DATE) AND CAST(@pFechaFin AS DATE) AND
										  M.Activo = 1
	 INNER JOIN #TMP_PRECIOS_HIS P ON P.ProductoId = MD.ProductoId AND CAST(P.Fecha AS DATE) = CAST(M.FechaMovimiento AS date)
	 INNER JOIN cat_tipos_movimiento_inventario TM ON TM.TipoMovimientoInventarioId = M.TipoMovimientoId AND
											EsEntrada = 1 AND
											TM.TipoMovimientoInventarioId = 3
	  GROUP BY P.Precio


	  INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	  SELECT 3,'Masa - Traspaso Entrada',1,ISNULL(SUM(MD.Cantidad),0),P.Precio,P.Precio * ISNULL(SUM(MD.Cantidad),0),'MASA_E_TRAS'
	  FROM doc_inv_movimiento M
	  INNER JOIN doc_inv_movimiento_Detalle MD ON MD.MovimientoId = M.MovimientoId AND
										MD.ProductoId = 2 AND--TORTILLA
										M.SucursalId = @pSucursalId AND
										  CAST(M.FechaMovimiento AS DATE) BETWEEN CAST(@pFechaIni AS DATE) AND CAST(@pFechaFin AS DATE) AND
										  M.Activo = 1
	 INNER JOIN #TMP_PRECIOS_HIS P ON P.ProductoId = MD.ProductoId AND CAST(P.Fecha AS DATE) = CAST(M.FechaMovimiento AS date)
	 INNER JOIN cat_tipos_movimiento_inventario TM ON TM.TipoMovimientoInventarioId = M.TipoMovimientoId AND
											EsEntrada = 1 AND
											TM.TipoMovimientoInventarioId = 3
	 GROUP BY P.Precio

	 SELECT @MasaProdFinal = ISNULL(Cantidad,0)
	 FROM #TMP_RESULTADO WHERE CLAVE IN( 'MASA_PROD')

	 --SELECT @MasaProdFinal = @MasaProdFinal - SUM(Cantidad)
	 --FROM #TMP_RESULTADO WHERE CLAVE IN(  'VMASA_MAY_DIA','VMASA_MOSTRADOR')

	 

	 INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	 SELECT 1,'Tortilla - Kg Producci�n Estimado',1,ISNULL(@MasaProdFinal,0) * .8 ,ISNULL(MAX(Precio),0),ISNULL(MAX(Precio),0)*ISNULL(@MasaProdFinal,0) * .8 ,'TORT_PROD_F'
	 FROM #TMP_PRECIOS_HIS P 
	 WHERE P.ProductoId = 1 

	 
	 /****************************************************************************/
	INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	SELECT 5,P.Descripcion,1,SUM(VD.Cantidad),VD.PrecioUnitario,VD.PrecioUnitario * SUM(VD.Cantidad),'PROD_VENTA'
	FROM doc_ventas_detalle VD
	INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId AND
							V.SucursalId = @pSucursalId AND
							CAST(V.Fecha AS date) BETWEEN CAST(@pFechaIni  AS DATE) AND CAST(@pFechaFin AS date) and
							VD.ProductoId NOT IN(1,2) AND
							V.Activo = 1
	INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId
	GROUP BY P.Descripcion,VD.PrecioUnitario

	 SELECT @TotalEntradas = SUM(Total)
	 FROM #TMP_RESULTADO
	 WHERE Clave IN( 'VTORT_MAY_ATRAS','VMASA_MOSTRADOR','VMASA_MAY_DIA','VMASA_MAY_ATRAS','TORT_E_TRAS','TORT_PROD_F','PROD_VENTA')


	 /*****************SOBRANTES****************************************************/
	 INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	 SELECT 6,P.Descripcion,0,PS.CantidadSobrante,MAX(PRE.Precio),PS.CantidadSobrante * MAX(PRE.Precio),'TORT_SOBRANTE'
	 from doc_productos_sobrantes_registro PS
	 INNER JOIN cat_productos P ON P.ProductoId = PS.ProductoId AND
									P.Descripcion LIKE '%DESPERDICIO%TORTILLA%' AND
									CAST(PS.CerradoEl AS DATE) BETWEEN CAST(@pFechaIni AS date) AND  CAST(@pFechaFin AS date)
	 INNER JOIN #TMP_PRECIOS_HIS PRE ON PRE.ProductoId = 1 
	 WHERE PS.SucursalId = @pSucursalId
	 GROUP BY P.Descripcion,PS.CantidadSobrante

	  IF NOT EXISTS (SELECT 1 FROM #TMP_RESULTADO WHERE Clave = 'TORT_SOBRANTE') 
	  INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	  SELECT 6,'DESPERDICIO TORTILLA' ,0,0,0,0,'TORT_SOBRANTE'

	  /*************************************************************************/


	  INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	 SELECT 6,P.Descripcion,0,PS.CantidadSobrante,MAX(PRE.Precio),PS.CantidadSobrante * MAX(PRE.Precio),'MASA_SOBRANTE'
	 from doc_productos_sobrantes_registro PS
	 INNER JOIN cat_productos P ON P.ProductoId = PS.ProductoId AND
									P.Clave IN ('S001','S002','S003') AND
									CAST(PS.CreadoEl AS DATE) BETWEEN CAST(@pFechaIni AS date) AND  CAST(@pFechaFin AS date)
	 INNER JOIN #TMP_PRECIOS_HIS PRE ON PRE.ProductoId = 2
	 WHERE PS.SucursalId = @pSucursalId
	 GROUP BY P.Descripcion,PS.CantidadSobrante

	  IF NOT EXISTS (SELECT 1 FROM #TMP_RESULTADO WHERE Clave = 'MASA_SOBRANTE') 
	  INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	  SELECT 6,'DESPERDICIO/SOBRANTE MASA' ,0,0,0,0,'MASA_SOBRANTE'


	  /********************SOBRANTE MASA Y TORTILLA******************************/

	 INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	 SELECT 6,P.Descripcion,0,PS.CantidadSobrante,MAX(PRE.Precio),PS.CantidadSobrante * MAX(PRE.Precio),'TORTILLA_MASA_SOBRANTE'
	 from doc_productos_sobrantes_registro PS
	 INNER JOIN cat_productos P ON P.ProductoId = PS.ProductoId AND
									P.ProductoId IN (1,2) AND
									CAST(PS.CreadoEl AS DATE) BETWEEN CAST(@pFechaIni AS date) AND  CAST(@pFechaFin AS date)
	 INNER JOIN #TMP_PRECIOS_HIS PRE ON PRE.ProductoId = P.ProductoId
	 WHERE PS.SucursalId = @pSucursalId
	 GROUP BY P.Descripcion,PS.CantidadSobrante

	  


	  /*********************7. DESCUENTO VENTAS MAYOREO*******************************************************************/

	  /********************7. DESCUENTO VENTAS MAYOREO- Tortilla - Ajuste Monto por precio Preferencial Mayoreo********************************/
	  INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	  SELECT 7,'Tortilla - Ajuste Monto por precio Preferencial Mayoreo' ,0,
	  SUM(VD.Cantidad),
	  (ISNULL(P.Precio,0) - ISNULL(VD.PrecioUnitario,0)),
	  SUM(VD.Cantidad) * (ISNULL(P.Precio,0) - ISNULL(VD.PrecioUnitario,0)),
	  
	  'VTORT_MAY_DIA'
	  FROM doc_ventas_detalle VD
	  INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId
	  LEFT JOIN doc_pedidos_orden PO ON PO.VentaId = V.VentaId 
	  INNER JOIN #TMP_PRECIOS_HIS P ON P.ProductoId = VD.ProductoId AND CAST(P.Fecha AS date) = CAST(V.Fecha AS DATE)
	  WHERE VD.ProductoId = 1 AND--TORTILLA
	  CAST(V.Fecha AS DATE) BETWEEN CAST(@pFechaIni AS DATE) AND CAST(@pFechaFin AS date) AND
	  V.SucursalId = @pSucursalId  AND
	  V.ClienteId IS NOT NULL AND
	  V.Activo = 1 AND
	  (CAST(PO.CreadoEl AS date) = CAST(V.Fecha AS date) OR PO.CreadoEl IS NULL)
	  GROUP BY VD.ProductoId,VD.PrecioUnitario,P.Precio

	  /***************************************************************************************/
	  INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	  SELECT 7,'Masa - Ajuste Monto por precio Preferencial Mayoreo' ,0,
	  SUM(VD.Cantidad),
	  (ISNULL(P.Precio,0) - ISNULL(VD.PrecioUnitario,0)),
	  SUM(VD.Cantidad) * (ISNULL(P.Precio,0) - ISNULL(VD.PrecioUnitario,0)),
	  
	  'VMASA_MAY_DIA'
	  FROM doc_ventas_detalle VD
	  INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId
	  LEFT JOIN doc_pedidos_orden PO ON PO.VentaId = V.VentaId 
	  INNER JOIN #TMP_PRECIOS_HIS P ON P.ProductoId = VD.ProductoId AND CAST(P.Fecha AS date) = CAST(V.Fecha AS DATE)
	  WHERE VD.ProductoId = 2 AND--TORTILLA
	  CAST(V.Fecha AS DATE) BETWEEN CAST(@pFechaIni AS DATE) AND CAST(@pFechaFin AS date) AND
	  V.SucursalId = @pSucursalId  AND
	  V.ClienteId IS NOT NULL AND
	  V.Activo = 1 AND
	  (CAST(PO.CreadoEl AS date) = CAST(V.Fecha AS date) OR PO.CreadoEl IS NULL)
	  GROUP BY VD.ProductoId,VD.PrecioUnitario,P.Precio

	  IF NOT EXISTS (SELECT 1 FROM #TMP_RESULTADO WHERE Clave = 'VTORT_MAY_DIA') 
	  INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	  SELECT 7,'Tortilla - Ajuste Monto por precio Preferencial Mayoreo' ,0,0,0,0,'VMASA_MAY_DIA'

	  /******************7. DESCUENTO VENTAS MAYOREO. Pedido Tortilla Por Pagar********************************************************************/
	  INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	  SELECT 7,P.Descripcion + ' - Pedido Por Pagar',0,SUM(POD.Cantidad),POD.PrecioUnitario, POD.PrecioUnitario * SUM(POD.Cantidad),'POR_PAGAR'
	  FROM doc_pedidos_orden PO
	  INNER JOIN doc_pedidos_orden_detalle POD ON POD.PedidoId = PO.PedidoId  AND POD.ProductoId IN(1,2)
	  INNER JOIN cat_productos P ON P.ProductoId = POD.ProductoId
	  WHERE PO.SucursalId = @pSucursalId AND
	  PO.VentaId IS NULL AND
	  CAST(PO.CreadoEl AS DATE) BETWEEN CAST(@pFechaIni  AS DATE)AND CAST(@pFechaFin AS date) AND
	  ISNULL(PO.Cancelada,0) = 0
	  GROUP BY P.Descripcion ,POD.PrecioUnitario

	   IF NOT EXISTS (SELECT 1 FROM #TMP_RESULTADO WHERE Clave = 'POR_PAGAR') 
	  INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	  SELECT 7,'Pedidos por Pagar' ,0,0,0,0,'POR_PAGAR'


	  /******************7. DESCUENTO VENTAS MAYOREO. Devoluciones de Masa y Tortilla en Pedidos****************/
	  INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	  SELECT 7,P.Descripcion + '(Devoluci�n Mayoreo)',0,SUM(POD.CantidadDevolucion),PH.Precio,SUM(POD.CantidadDevolucion) * PH.Precio,'MAYOREO_DEVOLUCION'
	  FROM doc_pedidos_orden PO
	  INNER JOIN doc_pedidos_orden_detalle POD ON POD.PedidoId = PO.PedidoId AND
												CAST(PO.CreadoEl AS DATE) BETWEEN CAST(@pFechaIni AS date) AND CAST(@pFechaFin AS date) AND
												PO.VentaId IS NOT NULL AND
												PO.SucursalId = @pSucursalId
	 INNER JOIN cat_productos P ON P.ProductoId = POD.ProductoId 
	 INNER JOIN #TMP_PRECIOS_HIS PH ON PH.ProductoId = POD.ProductoId
	 GROUP BY P.Descripcion,PH.Precio




	  /******************8. DESCUENTO POR GRAMOS EN CONTRA**********************************************/
	 create table #GramosFavorEnContra (ProductoId int, PrecioProducto decimal(16,6), ClaveTipoGramos smallint, PrecioPorGramo decimal(16,6), GramosPesados decimal(16,6),   
         Total decimal(16,6), GramosVendidos_EnBase_Al_Total decimal(16,6), ResultadoGramos decimal(16,6), ImporteGramos decimal(16,6))     
  
		insert into #GramosFavorEnContra(ProductoId, PrecioProducto, PrecioPorGramo, GramosPesados, Total, GramosVendidos_EnBase_Al_Total)     
		select ProductoId,   PrecioProducto= PrecioUnitario,    
		PrecioPorgramo= (PrecioUnitario/1000),   GramosPesados=(Cantidad*1000),  Total,   GramosVendidos_EnBase_Al_Total= (Total/(PrecioUnitario/1000))    
		from      
		 doc_ventas t1   
		inner join     
		 doc_ventas_detalle t2 on t2.VentaId= t1.VentaId    
		where    
		 isnull(t1.clienteid,0)=0 and   t1.SucursalId=@pSucursalId and     
		 cast(t1.FechaCreacion as date)  between  cast(@pFechaIni as date) and cast(@pFechaFin as date) and   
		 PrecioUnitario>0     		 
		update #GramosFavorEnContra set ResultadoGramos= ((GramosPesados)-(Total/(PrecioPorgramo)))    
  
		update #GramosFavorEnContra set ClaveTipoGramos= 1 /*A favor*/, ImporteGramos= PrecioPorGramo*ResultadoGramos   
		where ResultadoGramos>0    
  
		update #GramosFavorEnContra set ClaveTipoGramos= 2 /*En contra*/, ImporteGramos= PrecioPorGramo*ResultadoGramos where ResultadoGramos<0    
  
		delete #GramosFavorEnContra where ISNULL(ResultadoGramos, 0)= 0    

		 INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)	 
		 SELECT  8,'Gramos en Contra - Gramos que se dieron de mas',		      
		  Abono= 0,   
		  Cantidad= ((sum(ResultadoGramos))/1000.00000),  
		  PrecioUnitario= PrecioProducto,   
		  Total= sum(ImporteGramos)    ,'GRAMOS_CONTRA'
		from #GramosFavorEnContra t1 inner join   
		 cat_productos t2 on t2.ProductoId= t1.ProductoId     
		where t1.ClaveTipoGramos= 1
		group  by ClaveTipoGramos, t1.ProductoId, PrecioProducto  order by t1.ProductoId   
		

		/********************************************************/
		INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	  SELECT 8,'Tortilla - Gramos en Contra Por Ventas Mayoreo' ,0,
	  SUM(VD.Cantidad) * @GramosMermaMayoreoKilo,
	  (ISNULL(P.Precio,0) - ISNULL(VD.PrecioUnitario,0)),
	  (SUM(VD.Cantidad) * @GramosMermaMayoreoKilo) * (ISNULL(P.Precio,0) - ISNULL(VD.PrecioUnitario,0)),
	  
	  'VTORT_MAY_DIA_MERMA'
	  FROM doc_ventas_detalle VD
	  INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId
	  LEFT JOIN doc_pedidos_orden PO ON PO.VentaId = V.VentaId 
	  INNER JOIN #TMP_PRECIOS_HIS P ON P.ProductoId = VD.ProductoId AND CAST(P.Fecha AS date) = CAST(V.Fecha AS DATE)
	  WHERE VD.ProductoId = 1 AND--TORTILLA
	  CAST(V.Fecha AS DATE) BETWEEN CAST(@pFechaIni AS DATE) AND CAST(@pFechaFin AS date) AND
	  V.SucursalId = @pSucursalId  AND
	  V.ClienteId IS NOT NULL AND
	  V.Activo = 1 AND
	  (CAST(PO.CreadoEl AS date) = CAST(V.Fecha AS date) OR PO.CreadoEl IS NULL)
	  GROUP BY VD.ProductoId,VD.PrecioUnitario,P.Precio



	/**************************9. GASTOS CAJA CHICA**********************************************************/
	INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)	
	SELECT 9,G.Obervaciones,0,1,G.Monto,G.Monto,'GASTOS_CCHICA'
	FROM doc_gastos G
	INNER JOIN cat_cajas C ON C.Clave = G.CajaId
	WHERE G.SucursalId = @pSucursalId AND
	ISNULL(G.Activo,0) = 1 AND
	CAST(G.CreadoEl AS date) BETWEEN CAST(@pFechaIni AS DATE)AND CAST(@pFechaFin AS date)

	 IF NOT EXISTS (SELECT 1 FROM #TMP_RESULTADO WHERE Clave = 'GASTOS_CCHICA') 
	  INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	  SELECT 9,'Gastos Caja Chica' ,0,0,0,0,'GASTOS_CCHICA'


	/*************************10.SALIDAS POR TRASPASO**********************************************************/
	 INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	  SELECT 10,PROD.Descripcion + '-' + TM.Descripcion,0,ISNULL(SUM(MD.Cantidad),0),P.Precio,P.Precio * ISNULL(SUM(MD.Cantidad),0),'TORT_S_TRAS'
	  FROM doc_inv_movimiento M
	  INNER JOIN doc_inv_movimiento_Detalle MD ON MD.MovimientoId = M.MovimientoId AND
										MD.ProductoId IN( 1,2) AND--TORTILLA
										M.SucursalId = @pSucursalId AND
										  CAST(M.FechaMovimiento AS DATE) BETWEEN CAST(@pFechaIni AS DATE) AND CAST(@pFechaFin AS DATE) AND
										  M.Activo = 1 AND
										  M.TipoMovimientoId IN (4)
	 INNER JOIN #TMP_PRECIOS_HIS P ON P.ProductoId = MD.ProductoId AND CAST(P.Fecha AS DATE) = CAST(M.FechaMovimiento AS date)
	 INNER JOIN cat_tipos_movimiento_inventario TM ON TM.TipoMovimientoInventarioId = M.TipoMovimientoId AND
											EsEntrada = 0
	 INNER JOIN cat_productos PROD ON PROD.ProductoId = MD.ProductoId
	  GROUP BY P.Precio,PROD.Descripcion,TM.Descripcion

	  IF NOT EXISTS (SELECT 1 FROM #TMP_RESULTADO WHERE Clave = 'TORT_S_TRAS') 
	  INSERT INTO #TMP_RESULTADO(TipoId,Concepto,Abono,Cantidad,PrecioUnitario,Total,Clave)
	  SELECT 10,'SALIDAS DE MASA Y TORTILLA' ,0,0,0,0,'TORT_S_TRAS'


	  /********************************************************/

	  UPDATE #TMP_RESULTADO
	  SET TotalEntradas =  @TotalEntradas

	  UPDATE #TMP_RESULTADO
	  SET TotalDescuentos = (SELECT SUM(Total) FROM #TMP_RESULTADO WHERE Abono = 0)

	  SELECT @TotalRetiros = SUM(MontoRetiro)
	  FROM doc_retiros 
	  where SucursalId = @pSucursalId AND
	  CAST(FechaRetiro AS date) BETWEEN CAST(@pFechaIni AS date) AND CAST(@pFechaFin AS date)

	  SELECT @TotalRetiros = ISNULL(@TotalRetiros,0) + ISNULL(SUM(CCD.Total),0)
	  FROM doc_corte_caja_denominaciones CCD 
	  INNER JOIN doc_corte_caja CC ON CC.CorteCajaId = CCD.CorteCajaId 
	  INNER JOIN cat_cajas C ON C.Clave = CC.CajaId AND
								C.Sucursal = @pSucursalId AND	
								CAST(CCD.CreadoEl AS DATE) BETWEEN CAST(@pFechaIni AS DATE) AND CAST(@pFechaFin AS date)

										
	  

	  UPDATE #TMP_RESULTADO
	  SET TotalRetiros = ISNULL(@TotalRetiros,0)

	  UPDATE #TMP_RESULTADO
	  SET TotalDiferencia = TotalRetiros - (ISNULL(TotalEntradas,0) - ISNULL(TotalDescuentos,0))

	  update #TMP_RESULTADO
		SET TotalRequerido = ISNULL(TotalEntradas,0) - ISNULL(TotalDescuentos,0)

	  UPDATE #TMP_RESULTADO
	  SET TotalRegistradoSistema = (SELECT ISNULL(SUM(V.TotalVenta),0) FROM doc_ventas V WHERE CAST(V.Fecha AS date) BETWEEN CAST(@pFechaIni AS date) AND CAST(@pFechaFin AS date) AND V.Activo = 1 AND V.SucursalId = @pSucursalId)
	  
	  update #TMP_RESULTADO
	  set Total = Total * -1
	  Where Abono = 0

	  SELECT Tipo = T.Tipo ,R.* FROM #TMP_RESULTADO R
	  INNER JOIN #TMP_TIPOS T  ON T.TipoId = R.TipoId
	  WHERE Mostrar = 1
	  Order by T.Tipo,R.Fila


GO
/****** Object:  StoredProcedure [dbo].[p_doc_devolucion_detalle_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[p_doc_devolucion_detalle_ins]
@pDevolucionDetId	int out,
@pDevolucionId	int,
@pVentaId	bigint,
@pProductoId	int,
@pCantidad	decimal(14,2),
@pTotal	money,
@pCreadoEl	datetime,
@pCreadoPor	int,
@pError varchar(250) out
as

	declare @pCantidadEnDevolucion decimal(5,2),
			@pCantidadTicket decimal(5,2),
			@error varchar(250)

	select @pCantidadEnDevolucion = isnull(sum(Cantidad),0)
	from doc_devoluciones_detalle  dd
	inner join doc_devoluciones d on d.DevolucionId = dd.DevolucionId
	where d.VentaId = @pVentaId and
	dd.ProductoId = @pProductoId

	select @pCantidadTicket = isnull(sum(vd.Cantidad),0)
	from doc_ventas v
	inner join doc_ventas_detalle vd on vd.VentaId = v.VentaId
	where v.VentaId = @pVentaId and
	vd.ProductoId = @pProductoId

	set @pCantidadEnDevolucion= isnull(@pCantidadEnDevolucion,0) + @pCantidad

	if(@pCantidadEnDevolucion > @pCantidadTicket)
	begin
		set @pError='Ya no se puede devolver mas cantidad para el producto '+cast(@pProductoId as varchar) + ' Disponible:'+cast((@pCantidadTicket-(@pCantidadEnDevolucion - @pCantidadTicket)) as varchar)
		
		return
	end

	select @pDevolucionDetId = isnull(max(DevolucionDetId),0)+1
	from doc_devoluciones_detalle

	insert into doc_devoluciones_detalle(
		DevolucionDetId,		DevolucionId,		VentaId,		ProductoId,
		Cantidad,				Total,				CreadoEl,		CreadoPor
	)	
	values(
		@pDevolucionDetId,		@pDevolucionId,		@pVentaId,		@pProductoId,
		@pCantidad,				@pTotal,				getdate(),		@pCreadoPor
	)







GO
/****** Object:  StoredProcedure [dbo].[p_doc_devolucion_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[p_doc_devolucion_ins]
@pDevolucionId int out,
@pVentaId bigint,
@pTotal money,
@pCreadoEl datetime,
@pCreadoPor int,
@pTipoDevolucionId int
as

	declare @fechaVencimiento datetime,
		@diasVencimientoVale int

	select @diasVencimientoVale = isnull(DevDiasVale,0)
	from cat_configuracion

	select @fechaVencimiento = DATEADD(dd,@diasVencimientoVale,getdate())

	


	select @pDevolucionId = isnull(max(DevolucionId),0) + 1
	from doc_devoluciones

	insert into doc_devoluciones(
		DevolucionId,VentaId,CreadoEl,CreadoPor,Total,TipoDevolucionId,
		FechaVencimiento
	)
	values(
		@pDevolucionId,@pVentaId,getdate(),@pCreadoPor,@pTotal,@pTipoDevolucionId,
		@fechaVencimiento
	)

	






GO
/****** Object:  StoredProcedure [dbo].[p_doc_devolucion_mov_inv_genera]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_doc_devolucion_mov_inv_genera 3,2
create proc [dbo].[p_doc_devolucion_mov_inv_genera]
@pDevolucionId int,
@pCreadoPor int
as

	declare @movimientoId int,
			@folioMov int,
			@sucursalId int

	select @movimientoId = max(MovimientoId)+1
	from doc_inv_movimiento

	select @sucursalId = v.SucursalId
	from doc_devoluciones dev
	inner join doc_ventas v on v.VentaId = dev.VentaId
	where dev.DevolucionId = @pDevolucionId


	select @folioMov = isnull(max(Consecutivo),0) +1 
	from doc_inv_movimiento
	where SucursalId = @sucursalId
	and TipoMovimientoId = 20 --Devolución	
	
	BEGIN TRAN

	insert into doc_inv_movimiento(
		MovimientoId,	SucursalId,	FolioMovimiento,	TipoMovimientoId,
		FechaMovimiento,HoraMovimiento,Comentarios,		ImporteTotal,
		Activo,			CreadoPor,	CreadoEl,			Autorizado,
		FechaAutoriza,	SucursalDestinoId,AutorizadoPor,FechaCancelacion,
		ProductoCompraId,Consecutivo,SucursalOrigenId,	VentaId,
		MovimientoRefId,Cancelado
	)
	select @movimientoId,@sucursalId,@folioMov,20,
	GETDATE(),GETDATE(),			'Devolución Folio:'+cast(@pDevolucionId as varchar),dev.Total,
	1,				@pCreadoPor,	GETDATE(),			1,
	GETDATE(),		NULL,				@pCreadoPor,	NULL,
	NULL,			@folioMov,		NULL,				NULL,
	NULL,				0
	from doc_devoluciones dev
	inner join doc_ventas v on v.VentaId = dev.VentaId
	WHERE dev.DevolucionId = @pDevolucionId

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		GOTO FIN
	END


	DECLARE @movimientoDetalleId int

	select @movimientoDetalleId = isnull(max(MovimientoDetalleId),0) + 1
	from doc_inv_movimiento_detalle

	INSERT INTO doc_inv_movimiento_detalle(
		MovimientoDetalleId,	MovimientoId,	ProductoId,		Consecutivo,
		Cantidad,				PrecioUnitario,	Importe,		Disponible,
		CreadoPor,				CreadoEl,		CostoUltimaCompra,CostoPromedio,
		ValCostoUltimaCompra,	ValCostoPromedio,ValorMovimiento
	)
	select row_number() over (order by DevolucionDetId) +@movimientoDetalleId,@movimientoId,d.ProductoId,row_number() over (order by DevolucionDetId),
	D.Cantidad,					d.Total/d.Cantidad,D.Total,D.Cantidad,
	@pCreadoPor,				GETDATE(),		null,			null,
	null,					null,				null
	from doc_devoluciones_detalle d
	where DevolucionId = @pDevolucionId

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		GOTO FIN
	END

	COMMIT TRAN

	FIN:



GO
/****** Object:  StoredProcedure [dbo].[p_doc_devoluciones_grid]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_doc_devoluciones_grid 1,0
CREATE Proc [dbo].[p_doc_devoluciones_grid]
@pVentaId int,
@pDevolucionId int
as

	
	select 
		dev.DevolucionId,
		dev2.DevolucionDetId,
		v.VentaId,
		vd.ProductoId,
		PrecioUnitario= CASE WHEN isnull(vd.Descuento,0) > 0 THEN 
							 cast(vd.PrecioUnitario - (isnull(vd.Descuento,0)/isnull(VD.Cantidad,0)) as decimal(14,2))
							 ELSE cast(vd.PrecioUnitario  as decimal(14,2))
							end,
		Producto=prod.Descripcion,
		Cantidad = isnull(dev2.Cantidad,0),
		Total = isnull(dev2.Total,0),
		Seleccionar = cast(case when dev2.DevolucionDetId is null then 0 else 1 end as bit),
		CantidadTicket = sum(vd.Cantidad) ,
		FechaTicket = v.FechaCreacion
		
	from doc_ventas v
	inner join doc_ventas_detalle vd on vd.VentaId = v.VentaId
	inner join cat_productos prod on prod.ProductoId = vd.ProductoId
	left join doc_devoluciones dev on
					--(
					--		(dev.DevolucionId = @pDevolucionId and
					--		@pDevolucionId > 0)
					--		Or 
					--		@pDevolucionId = 0
					--)
					--AND
					--(
					--	(
					--		dev.VentaId = @pVentaId 
					--		and @pVentaId > 0
					--	)
					--	OR @pVentaId = 0
					--) and
					dev.VentaId = v.VentaId and
					dev.DevolucionId = @pDevolucionId 
				
	left join doc_devoluciones_detalle dev2 on dev2.DevolucionId = dev.DevolucionId AND
												DEV2.ProductoId = VD.ProductoId
	where
	v.activo=1 and
	(
		(
			@pDevolucionId > 0 and dev.VentaId is not null
		)
		OR 
		(@pVentaId > 0 and v.VentaId = @pVentaId)
	)
	group by  v.VentaId,
		vd.ProductoId,
		vd.PrecioUnitario,
	prod.Descripcion,
	dev2.Cantidad,
	dev2.Total,
	dev.DevolucionId,
		dev2.DevolucionDetId,
		v.FechaCreacion,
		vd.Descuento,VD.Cantidad









GO
/****** Object:  StoredProcedure [dbo].[p_doc_gasto_del_valida]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_doc_gasto_del_valida 1
Create Proc [dbo].[p_doc_gasto_del_valida]
@pGastoId int
as

	declare @error varchar(250)=''
	
	if exists (
		select  1
		from doc_gastos g
		inner join doc_corte_caja cc on cc.CorteCajaId = cc.CorteCajaId
		where GastoId = @pGastoId  and
		g.CreadoEl between FechaApertura and FechaCorte

	)
	begin

		set @error = 'No es posible editar/eliminar el gasto, ya se realizó un corte de caja'
		
	end

	select error = @error





GO
/****** Object:  StoredProcedure [dbo].[p_doc_gastos_del]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_doc_gastos_del]
    @GastoId INT
AS
BEGIN
    DELETE FROM [dbo].[doc_gastos]
    WHERE [GastoId] = @GastoId
END
GO
/****** Object:  StoredProcedure [dbo].[p_doc_gastos_ins_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_doc_gastos_ins_upd]
    @GastoId INT OUT,
    @CentroCostoId INT,
    @GastoConceptoId INT,
    @Observaciones VARCHAR(300),
    @Monto MONEY,
    @CajaId INT=null,
   
    @CreadoPor INT,
    @SucursalId INT,
    @Activo BIT
AS
BEGIN

	if(ISNULL(@CentroCostoId,0) = 0 AND ISNULL(@GastoConceptoId,0) > 0)
	BEGIN
		SELECT @CentroCostoId = ClaveCentroCosto
		FROM cat_gastos
		WHERE Clave = @GastoConceptoId

	END


    IF ISNULL(@GastoId,0) = 0
    BEGIN

		SELECT @GastoId = ISNULL(MAX(GastoId),0)+1
		FROM doc_gastos

        -- Insertar nuevo registro
        INSERT INTO [dbo].[doc_gastos] (
			GastoId,
            [CentroCostoId],
            [GastoConceptoId],
            [Obervaciones],
            [Monto],
            [CajaId],
            [CreadoEl],
            [CreadoPor],
            [SucursalId],
            [Activo]
        )
        VALUES (
			@GastoId,
            @CentroCostoId,
            @GastoConceptoId,
            @Observaciones,
            @Monto,
            @CajaId,
            GETDATE(),
            @CreadoPor,
            @SucursalId,
            @Activo
        )

       
       
    END
    ELSE
    BEGIN
        -- Actualizar registro existente
        UPDATE [dbo].[doc_gastos]
        SET
            [CentroCostoId] = @CentroCostoId,
            [GastoConceptoId] = @GastoConceptoId,
            [Obervaciones] = @Observaciones,
            [Monto] = @Monto,
            [CajaId] = @CajaId,            
            [SucursalId] = @SucursalId,
            [Activo] = @Activo
        WHERE
            [GastoId] = @GastoId
    END
END
GO
/****** Object:  StoredProcedure [dbo].[p_doc_gastos_pivot_rpt]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_doc_gastos_pivot_rpt 0,'20231201','20231231'
CREATE PROC [dbo].[p_doc_gastos_pivot_rpt]
@pSucursalId INT,
@pDel DATETIME,
@pAl DATETIME,
@pUsuarioId INT
AS

	SELECT 
		Id = CAST(ROW_NUMBER() OVER(ORDER BY S.NombreSucursal ASC) AS INT),
		Sucursal = S.NombreSucursal,
		G.GastoConceptoId,
		Concepto = gc.Descripcion,
		Total = ISNULL(SUM(G.Monto),0)
	FROM doc_gastos G
	INNER JOIN cat_sucursales S ON S.Clave = G.SucursalId
	INNER JOIN cat_gastos GC ON GC.Clave = G.GastoConceptoId
	INNER JOIN cat_usuarios_sucursales US ON US.SucursalId = S.Clave AND
											US.UsuarioId = @pUsuarioId
	WHERE @pSucursalId  IN (G.SucursalId,0) AND
	G.Activo = 1 AND
	CAST(G.CreadoEl AS DATE) BETWEEN CAST(@pDel AS DATE) AND  CAST(@pAl AS DATE)
	GROUP BY S.NombreSucursal,gc.Descripcion,G.GastoConceptoId
	ORDER BY S.NombreSucursal,gc.Descripcion



GO
/****** Object:  StoredProcedure [dbo].[p_doc_gastos_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[p_doc_gastos_sel]
@SucursalId INT,
@FechaInicio DATETIME,
@FechaFin DATETIME,
@UsuarioId INT,
@SoloDeducibles BIT = 0
AS


SELECT G.GastoId,
	G.CentroCostoId,
	G.GastoConceptoId,
	Concepto = c.Descripcion,
	Observaciones = G.Obervaciones,
	G.Monto,
	G.CajaId,
	G.CreadoEl,
	G.CreadoPor,
	G.SucursalId,
	G.Activo,
	Sucursal = S.NombreSucursal
FROM doc_gastos G
INNER JOIN cat_usuarios_sucursales US ON US.UsuarioId = @UsuarioId AND
									G.SucursalId = US.SucursalId
INNER JOIN cat_gastos C ON C.Clave = g.GastoConceptoId AND
@SucursalId IN (0,G.SucursalId) AND
CAST(G.CreadoEl AS DATE) BETWEEN CAST(@FechaInicio AS DATE) AND CAST(@FechaFin AS DATE)
INNER JOIN cat_sucursales S ON S.Clave = G.SucursalId
LEFT JOIN cat_gastos_deducibles GD ON GD.GastoConceptoId = G.GastoConceptoId
WHERE @SoloDeducibles = 0 OR
(@SoloDeducibles = 1 AND GD.GastoConceptoId IS NOT NULL)
ORDER BY G.CreadoEl DESC

GO
/****** Object:  StoredProcedure [dbo].[p_doc_inv_movimiento_cancel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[p_doc_inv_movimiento_cancel]
@pMovimientoId int,
@pModificadoPor int
as

	update [doc_inv_movimiento]
	set --Activo = 1,
		FechaCancelacion = getdate(),
		Cancelado=1
		--Autorizado = 1
	where MovimientoId = @pMovimientoId






GO
/****** Object:  StoredProcedure [dbo].[p_doc_inv_movimiento_detalle_del]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[p_doc_inv_movimiento_detalle_del]
@pMovimientoId INT
AS

	DELETE doc_inv_movimiento_detalle
	WHERE MovimientoId = @pMovimientoId
GO
/****** Object:  StoredProcedure [dbo].[p_doc_inv_movimiento_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[p_doc_inv_movimiento_ins]
@pMovimientoId int out,
@pSucursalId int,
@pFolioMovimiento varchar(10),
@pTipoMovimientoId int,
@pFechaMovimiento datetime,
@pHoraMovimiento time(7),
@pComentarios varchar(250),
@pImporteTotal money,
@pCreadoPor int,
@pAutorizado	bit,
@pFechaAutoriza	datetime,
@pSucursalOrigenId	int,
@pSucursalDestinoId	int,
@pAutorizadoPor	int,
@pTipoMermaId int
as

	declare @consecutivo int

	select @pMovimientoId = isnull(max(MovimientoId),0) + 1
	from [doc_inv_movimiento]

	select @consecutivo = isnull(max(consecutivo),0)  + 1
	from [doc_inv_movimiento]
	where [TipoMovimientoId] = @pTipoMovimientoId
	and [SucursalId] = @pSucursalId

	set @pFolioMovimiento = cast(@consecutivo as varchar(20))



	INSERT INTO [dbo].[doc_inv_movimiento]
           ([MovimientoId]
           ,[SucursalId]
           ,[FolioMovimiento]
           ,[TipoMovimientoId]
           ,[FechaMovimiento]
           ,[HoraMovimiento]
           ,[Comentarios]
           ,[ImporteTotal]
           ,[Activo]
           ,[CreadoPor]
           ,[CreadoEl],
		   Autorizado,
		FechaAutoriza,
		SucursalDestinoId,
		AutorizadoPor,
		Consecutivo,
		SucursalOrigenId,
		TipoMermaId)
     VALUES
           (@pMovimientoId, 
           @pSucursalId,
           @pFolioMovimiento, 
           @pTipoMovimientoId,
           @pFechaMovimiento,
           @pHoraMovimiento,
           @pComentarios, 
           @pImporteTotal, 
           1,
           @pCreadoPor,
           getdate(),
		   @pAutorizado,
			@pFechaAutoriza,
			@pSucursalDestinoId,
			@pAutorizadoPor,
			@consecutivo,
			@pSucursalOrigenId,
			@pTipoMermaId
		   )







GO
/****** Object:  StoredProcedure [dbo].[p_doc_inv_movimiento_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_doc_inv_movimiento_sel]
@pSucursalId INT,
@pFechaMovimiento DATETIME,
@pTipoMovimiento INT
AS

	SELECT *
	FROM doc_inv_movimiento
	WHERE SucursalId = @pSucursalId AND
	CONVERT(VARCHAR,FechaMovimiento,112) = CONVERT(VARCHAR,@pFechaMovimiento,112) AND
	TipoMovimientoId = @pTipoMovimiento
GO
/****** Object:  StoredProcedure [dbo].[p_doc_inv_movimiento_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Proc [dbo].[p_doc_inv_movimiento_upd]
@pMovimientoId int out,
@pSucursalId int,
@pFolioMovimiento varchar(10),
@pTipoMovimientoId int,
@pFechaMovimiento datetime,
@pHoraMovimiento time(7),
@pComentarios varchar(250),
@pImporteTotal money,
@pCreadoPor int,
@pAutorizado	bit,
@pFechaAutoriza	datetime,
@pSucursalOrigenId	int,
@pSucursalDestinoId	int,
@pAutorizadoPor	int  ,
@pTipoMermaId int       
as

update [doc_inv_movimiento]
set
           [SucursalId] = @pSucursalId                                            
           ,[Comentarios]=@pComentarios
           ,[ImporteTotal]=@pImporteTotal
           ,[Activo]=1		   		
		   ,SucursalDestinoId = @pSucursalDestinoId	
		   ,SucursalOrigenId = @pSucursalOrigenId
		   ,TipoMermaId = @pTipoMermaId
where MovimientoId = @pMovimientoId







GO
/****** Object:  StoredProcedure [dbo].[p_doc_inventario_registro_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_doc_inventario_registro_sel 2,'20220201'
-- drop proc p_doc_inventario_registro_sel
CREATE PROC [dbo].[p_doc_inventario_registro_sel]
@pSucursalId INT,
@pFecha DATETIME
as
BEGIN

	SELECT 
			I.RegistroInventarioId,
			I.SucursalId,
			P.ProductoId,
			P.DescripcionCorta,
			CantidadReal = ISNULL(I.CantidadReal,0),
			Unidad = U.DescripcionCorta,
			CantidadTeorica = ISNULL(I.CantidadTeorica,PE.ExistenciaTeorica),
			I.Diferencia,
			I.CreadoEl,
			I.CreadoPor
	FROM cat_productos_existencias PE
	INNER JOIN cat_productos P ON P.ProductoId = PE.ProductoId
	INNER JOIN cat_unidadesmed U on U.Clave = P.ClaveUnidadMedida
	LEFT JOIN doc_inventario_registro I ON I.ProductoId = P.ProductoId AND
									CONVERT(VARCHAR,I.CreadoEl,112) = CONVERT(VARCHAR,@pFecha,112)
	WHERE P.Estatus = 1 AND
	P.Inventariable = 1 and
	PE.SucursalId = @pSucursalId

END
GO
/****** Object:  StoredProcedure [dbo].[p_doc_maiz_maseca_entrada_del]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[p_doc_maiz_maseca_entrada_del]
@Id INT,
@UsuarioId INT
AS

	UPDATE [doc_maiz_maseca_entrada]
	SET Activo = 0,
		ModificadoPor = @UsuarioId,
		ModificadoEl = getdate()
	WHERE Id = @Id
GO
/****** Object:  StoredProcedure [dbo].[p_doc_maiz_maseca_entrada_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_doc_maiz_maseca_entrada_ins]
(
    @SucursalId INT,
    @Fecha DATETIME,
    @MaizSacos DECIMAL(14, 3),
    @MasecaSacos DECIMAL(14, 3),
    @CreadoPor INT,
  
    @ModificadoPor INT = NULL,
    @ModificadoEl DATETIME = NULL
)
AS
BEGIN
    INSERT INTO [dbo].[doc_maiz_maseca_entrada] 
    (
        [SucursalId],
        [Fecha],
        [MaizSacos],
        [MasecaSacos],
        [CreadoPor],
        [CreadoEl],
        [ModificadoPor],
        [ModificadoEl],
		Activo
    )
    VALUES
    (
        @SucursalId,
        @Fecha,
        @MaizSacos,
        @MasecaSacos,
        @CreadoPor,
        GETDATE(),
        @ModificadoPor,
        null,
		1
    )
END
GO
/****** Object:  StoredProcedure [dbo].[p_doc_maiz_maseca_entrada_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_doc_maiz_maseca_entrada_sel 0,'20231001','20231001',1
CREATE PROC [dbo].[p_doc_maiz_maseca_entrada_sel]
@SucursalId INT,
@Del DATETIME,
@Al  DATETIME,
@UsuarioId INT
AS

	
	

	SELECT Id,
		M.SucursalId,
		Sucursal = S.NombreSucursal,
		Fecha,
		MaizSacos,
		MasecaSacos,
		CreadoPor,
		M.CreadoEl,
		ModificadoPor,
		ModificadoEl
	FROM [doc_maiz_maseca_entrada] M
	INNER JOIN cat_usuarios_sucursales US ON US.SucursalId = M.SucursalId AND
										US.UsuarioId = @UsuarioId
	INNER JOIN cat_sucursales  S ON S.Clave = M.SucursalId
	WHERE @SucursalId IN (M.SucursalId ,0) AND  
	M.Activo = 1 AND
	CAST(Fecha AS DATE) BETWEEN CAST(@Del AS DATE) AND CAST(@Al AS  DATE)

GO
/****** Object:  StoredProcedure [dbo].[p_doc_maiz_maseca_rendimiento_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_doc_maiz_maseca_rendimiento_sel]
@SucursalId INT,
@Del DATETIME,
@Al DATETIME,
@UsuarioId INT
AS
BEGIN

	SELECT MR.Id,
			SucursalId = MR.SucursalId,
			Sucursal = S.NombreSucursal,
			Fecha = MR.Fecha,
			MaizSacos = MR.MaizSacos,
			MasecaSacos = MR.MasecaSacos
	FROM doc_maiz_maseca_rendimiento MR
	INNER JOIN cat_sucursales S ON S.Clave = MR.SucursalId
	INNER JOIN cat_usuarios_sucursales US ON US.SucursalId = MR.SucursalId AND
									US.UsuarioId = @UsuarioId
	WHERE @SucursalId IN(0,mr.SucursalId) AND
	CAST(MR.Fecha AS DATE) BETWEEN CAST(@Del AS DATE) AND CAST(@Al AS DATE)

END
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedido_promo_cm_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_doc_pedido_promo_cm_ins]
@pPedidoId int,
@pProductoId int,
@pPromocionCMId int,
@pImporte money,
@pCreadoPor int,
@pError varchar(250) out
as


	declare @PedidoDetalleId int,
			@porcimpuestos decimal(5,2),
			@impuestos decimal(5,2),
			@subTotal money


	BEGIN TRY  

		select @PedidoDetalleId = isnull(max(PedidoDetalleId),0)+1
		from doc_pedidos_orden_detalle		

		--CREAR PARTIDA DE DESCUENTO
		select @porcimpuestos = sum(i.Porcentaje) / 100
		from cat_productos_impuestos pim
		inner join cat_impuestos i on i.Clave = pim.ImpuestoId
		where ProductoId = @pProductoId


		set @impuestos = isnull((@porcimpuestos * @pImporte),0)

		set @subTotal = isnull(@pImporte,0) - isnull(@impuestos,0)
		
		insert into doc_pedidos_orden_detalle(
			PedidoDetalleId,	PedidoId,		ProductoId,	Cantidad,
			PrecioUnitario,		PorcDescuento,Descuento,	Impuestos,
			Notas,				Total,		CreadoPor,		CreadoEl,
			TasaIVA,			Impreso,	ComandaId,		Parallevar,
			Cancelado,			TipoDescuentoId,PromocionCMId
		)
		select @PedidoDetalleId,@pPedidoId,		p.ProductoId,1,
		(isnull(@pImporte,0) * -1),				0,			0,		(@impuestos*-1),
		'',					(@pImporte*-1),	@pCreadoPor,	GETDATE(),
		isnull(@porcimpuestos,0),			0,			null,			0,
		0,						1/*Promocion*/,@pPromocionCMId
		from cat_productos p
		where ProductoId = 0 and --Producto para promociones
		@pPromocionCMId > 0
		--Marcar el detalle con la promoci�n
		update doc_pedidos_orden_detalle
		set PromocionCMId = @pPromocionCMId
		where PedidoId = @pPedidoId and
		ProductoId = @pProductoId and
		PromocionCMId is null


	END TRY  
	BEGIN CATCH  
		set @pError = ERROR_MESSAGE()
	END CATCH  
	
	
	
	
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_cargos_calculo]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
create proc [dbo].[p_doc_pedidos_cargos_calculo]
@pPedidoId int,
@pCreadoPor int
as

	declare @uberEats bit,
			@productoUberEats int,
			@totalVenta money,
			@porc decimal(5,2),
			@montoConf money,
			@montoProducto money,
			@productoDetalleId int,
			@sucursalId int

	select @uberEats = UberEats,
		@productoUberEats = pd.PedidoDetalleId,
		@totalVenta = p.Total	,
		@sucursalId = p.SucursalId
	from doc_pedidos_orden p
	left join doc_pedidos_orden_detalle pd on pd.PedidoId = p.PedidoId and
										pd.CargoAdicionalId = 1 and--UBER EATS
										isnull(pd.Cancelado,0) = 0
	
	where p.PedidoId = @pPedidoId
	
	if(@uberEats = 1)
	begin

		select @montoConf = ca.MontoFijo,
		@porc = ca.PorcentajeVenta
		from doc_cargo_adicional_config ca
		where ca.SucursalId = @sucursalId

		select @totalVenta = sum(Total)
		from doc_pedidos_orden_detalle
		where PedidoId = @pPedidoId and
		isnull(Cancelado,0) = 0 and
		ProductoId <> -1 --UBER EATS		

		set @montoProducto = case when isnull(@montoConf,0) > 0 then @montoConf
								  else @totalVenta * (isnull(@porc,0)/100)
							 end		
		
		if (isnull(@productoUberEats,0) = 0)
		begin

			

			select @productoDetalleId = isnull(max(PedidoDetalleId),0) + 1
			from doc_pedidos_orden_detalle

			insert into doc_pedidos_orden_detalle(
				PedidoDetalleId,	PedidoId,		ProductoId,	Cantidad,
				PrecioUnitario,		PorcDescuento,	Descuento,	Impuestos,
				Notas,				Total,			CreadoPor,	CreadoEl,
				TasaIVA,			Impreso,		ComandaId,	Parallevar,
				Cancelado,			TipoDescuentoId,PromocionCMId,CargoAdicionalId
			)
			select @productoDetalleId,@pPedidoId,	-1,			1,
			@montoProducto,			0,				0,			0,
			'',						@montoProducto,	@pCreadoPor,getdate(),
			0,						1,				null,		0,
			0,					null,				null,		1

		end
		else
		begin

			update doc_pedidos_orden_detalle
			set Total = isnull(@montoProducto,0),
				PrecioUnitario = isnull(@montoProducto,0)
			where PedidoDetalleId =  @productoUberEats
		end

		--Marcar toda la venta para llevar
		update doc_pedidos_orden_detalle
		set Parallevar = 1
		where PedidoId = @pPedidoId 
	end
	else
	begin

		update doc_pedidos_orden_detalle
		set Cancelado = 1
		where PedidoId = @pPedidoId and
		CargoAdicionalId = 1-- UBER EATS
	end


	

GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_adicional_del]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_doc_pedidos_orden_adicional_del]
@pPedidoDetalleId int
as


	delete [dbo].[doc_pedidos_orden_adicional]
	where PedidoDetalleId = @pPedidoDetalleId
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_adicional_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_doc_pedidos_orden_adicional_ins]
@pPedidoDetalleId int,
@pAdicionalId int,
@pCreadoPor int
as
		insert into doc_pedidos_orden_adicional(PedidoDetalleId,AdicionalId,CreadoEl,CreadoPor)
		select @pPedidoDetalleId,@pAdicionalId,getdate(),@pCreadoPor
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_buscar]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_doc_pedidos_orden_buscar]
@pMesasId varchar(500),
@pComandaId int
as


	select mesaId = splitdata
	into #tmpMesas
	from [dbo].[fnSplitString](@pMesasId,',')


	select PedidoId = isnull(max(p.PedidoId),0)
	from doc_pedidos_orden p
	inner join doc_pedidos_orden_mesa pm on pm.PedidoOrdenId = p.PedidoId
	inner join #tmpMesas m on m.mesaId = pm.MesaId
	where p.VentaId is null and
	isnull(p.MotivoCancelacion,'') = ''
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_cancelacion]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[p_doc_pedidos_orden_cancelacion]
@pPedidoId int,
@pMotivoCancelacion varchar(150),
@pCanceladoPor int
as

	update doc_pedidos_orden
	set Cancelada = 1,
		FechaCancelacion = getdate(),
		MotivoCancelacion = @pMotivoCancelacion,
		CanceladoPor = @pCanceladoPor,
		Activo = 0
	where PedidoId = @pPedidoId
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_detalle_cargo_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_doc_pedidos_orden_detalle_cargo_upd]
@pPedidoId INT,
@pPorcentaje decimal(14,2)
AS
BEGIN

	update doc_pedidos_orden_detalle
	set CargoAdicionalMonto = (Cantidad * PrecioUnitario) * (ISNULL(@pPOrcentaje,0)/100)
	WHERE PedidoId = @pPedidoId

	update doc_pedidos_orden_detalle
	set Total = (Cantidad * PrecioUnitario) +  CargoAdicionalMonto
	WHERE PedidoId = @pPedidoId

	update doc_pedidos_orden
	SET Total = (SELECT SUM(Total) FROM doc_pedidos_orden_detalle WHERE PedidoId = @pPedidoId AND Activo = 1)
	where PedidoId = @pPedidoId
END
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_detalle_del]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE proc [dbo].[p_doc_pedidos_orden_detalle_del]
@pPedidoDetalleId int
as

	declare @promocionCMId int,
		@pedidoId int,
		@comandaId int,
		@pedidoDetallePromoId int

	select @promocionCMId = PromocionCMId ,
		@pedidoId = PedidoId,
		@comandaId = ComandaId
	from doc_pedidos_orden_detalle
	where PedidoDetalleId = @pPedidoDetalleId

	if isnull(@promocionCMId,0) > 0
	begin
		select @pedidoDetallePromoId  = min(PedidoDetalleId) 
		from doc_pedidos_orden_detalle
		where PedidoDetalleId > @pPedidoDetalleId and ProductoId = 0 and
		PedidoId = @pedidoId

		update doc_pedidos_orden_detalle
		set Cantidad = 0,
			Cancelado = 1,		
			Descuento = 0,
			Impuestos = 0,
			Total = 0
		where PromocionCMId = @promocionCMId and
		isnull(Cancelado,0) = 0 and
		PedidoId = @pedidoId and
		PedidoDetalleId =@pedidoDetallePromoId AND
		ProductoId = 0 --Solo promociones
	end

	update doc_pedidos_orden_detalle
	set Cantidad = 0,
		Cancelado = 1,		
		Descuento = 0,
		Impuestos = 0,
		Total = 0
	where PedidoDetalleId = @pPedidoDetalleId

	update doc_pedidos_orden
	set Total = (select sum(s1.Total) from doc_pedidos_orden_detalle s1 where s1.pedidoid = @pedidoId),
		Impuestos = (select sum(s1.Impuestos) from doc_pedidos_orden_detalle s1 where s1.pedidoid = @pedidoId)
	where PedidoId =@pedidoId

	update doc_pedidos_orden
	set Subtotal = isnull(Total,0) - isnull(Impuestos,0)
	where PedidoId =@pedidoId

	

	



GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_detalle_insupd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[p_doc_pedidos_orden_detalle_insupd]
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
@pComandaId int OUT,
@pTipoDescuentoId tinyint,
@pDescripcion varchar(500),
@pError varchar(250) out
as

	declare @sucursalId int,
			@porcIVA decimal(5,2),
			@PromocionCMId int,
			@ImportePromoCM money,
			@Error varchar(250)

	select @sucursalId = SucursalId
	from doc_pedidos_orden
	where PedidoId = @pPedidoId

	if isnull(@pDescripcion,'') = ''
	begin
		select @pDescripcion = DescripcionCorta
		from cat_productos
		where ProductoId = @pProductoId
	end

	create table #tmpPromocion
	(
		PromocionId int,
		ProdutoId	int,
		PorcentajeDescuento decimal(5,2),
		MontoDescuento money,
		PromocionCMId int
	)

	--BEGIN TRY 

	--Begin tran

	select @pTipoDescuentoId = 3
	from doc_pedidos_orden o
	inner join cat_clientes c on c.ClienteId = o.ClienteId and
								c.EmpleadoId is not null
	where PedidoId = @pPedidoId

	if(isnull(@pPorcDescuento,0) = 0 and isnull(@pTipoDescuentoId,0) = 0 )
	begin
		
		insert into #tmpPromocion(PromocionId,ProdutoId,PorcentajeDescuento,MontoDescuento,PromocionCMId)
		exec p_producto_promocion_sel @sucursalId,@pProductoId,@pPedidoiD,@pPedidoDetalleId
		
		--Promociones normales
		if exists (
		select 1
		from #tmpPromocion
		where PromocionId > 0
		)
		begin
			select @pPorcDescuento = isnull(PorcentajeDescuento,0)
			from #tmpPromocion

			set @pTipoDescuentoId = 1
		end
		--Promociones CM
		if exists (
			select 1
			from #tmpPromocion
			where isnull(PromocionCMId,0) > 0
		)
		begin
			select @pPorcDescuento = 0,
				@PromocionCMId = PromocionCMId,
				@ImportePromoCM = MontoDescuento
			from #tmpPromocion			

			exec p_doc_pedido_promo_cm_ins @pPedidoId,@pProductoId,@PromocionCMId,
				@ImportePromoCM,@pCreadoPor,@Error out 

			if isnull(@Error,'') <> ''
			begin
				RAISERROR (15600,-1,-1, @Error);  
				set @pError = @Error
			end
		end


	end

	--Si es cortes�a
	if @pTipoDescuentoId = 2
	begin
		set @pPorcDescuento = 100
	end	

	--Si es descuento empleado
	if @pTipoDescuentoId = 3
	begin

		select @pPorcDescuento = isnull(EmpleadoPorcDescuento,0)
		from cat_configuracion 

	end

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
	set @pDescuento = (@pTotal * (@pPorcDescuento/100))
	set @pTotal = @pTotal - @pDescuento

	set @pImpuestos = case when @porcIVA > 0 then @pTotal * @porcIVA else 0 end

	

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
			TasaIVA,			Impreso,	Parallevar,	ComandaId,	TipoDescuentoId, Descripcion
		)
		select @pPedidoDetalleId,	@pPedidoId,		@pProductoId,	@pCantidad,		@pPrecioUnitario,	@pPorcDescuento,
			@pDescuento,			@pImpuestos,	@pNotas,		@pTotal  ,		@pCreadoPor,		getdate(),
			@pTasaIVA,			0,			@pParallevar, @pComandaId,case when @pTipoDescuentoId =0 then null else @pTipoDescuentoId end,
			@pDescripcion
	
	
		if(isnull(@pPorcDescuento,0) = 0 and isnull(@pTipoDescuentoId,0) = 0 )
	begin
		
		insert into #tmpPromocion(PromocionId,ProdutoId,PorcentajeDescuento,MontoDescuento,PromocionCMId)
		exec p_producto_promocion_sel @sucursalId,@pProductoId,@pPedidoiD,@pPedidoDetalleId
		
		--Promociones normales
		if exists (
		select 1
		from #tmpPromocion
		where PromocionId > 0
		)
		begin
			select @pPorcDescuento = isnull(PorcentajeDescuento,0)
			from #tmpPromocion

			set @pTipoDescuentoId = 1
		end
		--Promociones CM
		if exists (
			select 1
			from #tmpPromocion
			where isnull(PromocionCMId,0) > 0
		)
		begin
			select @pPorcDescuento = 0,
				@PromocionCMId = PromocionCMId,
				@ImportePromoCM = MontoDescuento
			from #tmpPromocion			

			exec p_doc_pedido_promo_cm_ins @pPedidoId,@pProductoId,@PromocionCMId,
				@ImportePromoCM,@pCreadoPor,@Error out 

			if isnull(@Error,'') <> ''
			begin
				RAISERROR (15600,-1,-1, @Error);  
				set @pError = @Error
			end
		end


	end
	
	end
	Else
	Begin
		update [doc_pedidos_orden_detalle]
		set Parallevar = @pParallevar
		WHERE PedidoDetalleId = @pPedidoDetalleId

	End



	EXEC p_doc_pedidos_cargos_calculo @pPedidoId,@pCreadoPor

	
	update doc_pedidos_orden
	set Descuento = (select isnull(sum(Descuento),0) from doc_pedidos_orden_detalle where PedidoId = @pPedidoId and isnull(Cancelado,0)=0)
	where PedidoId = @pPedidoId

	update doc_pedidos_orden
	set Total = (select isnull(sum(Total),0) from doc_pedidos_orden_detalle where PedidoId = @pPedidoId and isnull(Cancelado,0)=0) - isnull(Descuento,0),
		Impuestos = (select isnull(sum(Impuestos),0) from doc_pedidos_orden_detalle where PedidoId = @pPedidoId and isnull(Cancelado,0)=0)
	where PedidoId = @pPedidoId

	update doc_pedidos_orden
	set Subtotal = Total-isnull(Impuestos,0)
	where PedidoId = @pPedidoId

	--commit tran

	--END TRY  
	--BEGIN CATCH  
	--	rollback tran
	--	set @pError = ERROR_MESSAGE()
	--END CATCH  





GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_detalle_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_doc_pedidos_orden_detalle_upd]
@pPedidoDetalleId int,
@pCantidad decimal(14,3),
@pImpreso bit
as

	update doc_pedidos_orden_detalle
	set Impreso = @pImpreso,
		Cantidad = @pCantidad
	where PedidoDetalleId = @pPedidoDetalleId
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_ingre_del]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_doc_pedidos_orden_ingre_del]
@pPedidoDetalleId int
as


	delete doc_pedidos_orden_ingre
	where PedidoDetalleId = @pPedidoDetalleId

	
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_ingre_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_doc_pedidos_orden_ingre_ins]
@pPedidoDetalleId int,
@pProductoMateriaPrimaId int,
@pCon bit,
@pSin bit,
@pCreadoPor int
as

	insert into doc_pedidos_orden_ingre(PedidoDetalleId,ProductoId,CreadoEl,CreadoPor,Con, Sin)
	select @pPedidoDetalleId,@pProductoMateriaPrimaId,getdate(),@pCreadoPor,@pCon,@pSin
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_insupd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[p_doc_pedidos_orden_insupd]
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
@pUberEats bit,
@pPara varchar(30),
@pNotas varchar(250),
@pCargoId int=null
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
			Activo,CreadoEl,CreadoPor,Personas,FechaApertura,FechaCierre,UberEats,Para,Notas,CargoId
		)
		select @pPedidoId,@pSucursalId,@pComandaId,@pPorcDescuento,@pSubtotal,@pDescuento,@pImpuestos,@pTotal,@pClienteId,@pMotivoCancelacion,
			1,getdate(),@pCreadoPor,@pPersonas,@pFechaApertura,@pFechaCierre,@pUberEats,@pPara,@pNotas,@pCargoId
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
			UberEats = @pUberEats,
			Para = @pPara,
			Notas = @pNotas
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



GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_mesa_del]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_doc_pedidos_orden_mesa_del]
@pPedidoOrdenId int
as


	delete doc_pedidos_orden_mesa
	where PedidoOrdenId = @pPedidoOrdenId

GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_mesa_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_doc_pedidos_orden_mesa_ins]
@pPedidoOrdenId int,
@pMesaId int
as


	insert into doc_pedidos_orden_mesa(
		PedidoOrdenId,MesaId,CreadoEl
	)
	select @pPedidoOrdenId,@pMesaId,getdate()

GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_mesero_del]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_doc_pedidos_orden_mesero_del]
@pPedidoOrdenId int
as

	delete [doc_pedidos_orden_mesero]
	where PedidoOrdenId = @pPedidoOrdenId
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_mesero_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_doc_pedidos_orden_mesero_ins]
@pPedidoOrdenId int,
@pEmpleadoId int
as

	insert into [dbo].[doc_pedidos_orden_mesero](
		PedidoOrdenId,EmpleadoId,CreadoEl
	)
	select @pPedidoOrdenId,@pEmpleadoId,getdate()
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_total_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_doc_pedidos_orden_total_upd]
@pPedidoId INT
AS
BEGIN
	DECLARE @total MONEY

	SELECT @total = ISNULL(SUM(Total),0)
	FROM doc_pedidos_orden_detalle
	WHERE PedidoId = @pPedidoId AND
	ISNULL(Cancelado,0)= 0

	UPDATE doc_pedidos_orden
	SET Total = @total
	WHERE PedidoId = @pPedidoId

END
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_ordenes_detalle_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- p_doc_pedidos_ordenes_detalle_sel 10,'20221017','20221017',3
CREATE proc [dbo].[p_doc_pedidos_ordenes_detalle_sel]
@pSucursalId INT,
@pFechaProgIni DateTime,
@pFechaProgFin DateTime,
@pTipoPedidoId INT
AS

	SELECT po.PedidoId,
		POD.PedidoDetalleId,
		POD.Cantidad,
		Clave = P.Clave,
		Descripcion = P.DescripcionCorta,
		PO.Total,
		POD.PrecioUnitario,
		P.ProductoId,
		RegistradoPor = U.NombreUsuario,
		Cliente = C.Nombre,
		CantidadPendienteBascula = CASE WHEN P.ProdVtaBascula = 1 THEN POD.Cantidad - ISNULL(SUM(BB.Cantidad),0) ELSE 0 END,
		po.TipoPedidoId,
		pop.FechaProgramada,
		pop.HoraProgramada,
		VentaId = ISNULL(v.VentaId,0),
		TipoCaja = ISNULL(TCAJA.Nombre,'En Sucursal'),
		RequiereBascula = p.ProdVtaBascula,
		TotalDetalle = POD.Total
	FROM doc_pedidos_orden PO
	INNER JOIN doc_pedidos_orden_detalle POD ON POD.PedidoId = po.PedidoId AND
					PO.SucursalId = @pSucursalId AND
					ISNULL(POD.Cancelado,0) = 0
	INNER JOIN cat_productos P ON P.ProductoId = POD.ProductoId
	INNER JOIN cat_usuarios U ON U.IdUsuario = PO.CreadoPor
	LEFT JOIN cat_cajas CAJA ON CAJA.Clave = PO.CajaId 
	LEFT JOIN cat_tipos_cajas TCAJA ON TCAJA.TipoCajaId = CAJA.TipoCajaId
	LEFT JOIN doc_basculas_bitacora BB ON BB.PedidoDetalleId = POD.PedidoDetalleId
	LEFT JOIN doc_pedidos_orden_programacion POP ON POP.PedidoId = PO.PedidoId
	LEFT JOIN cat_clientes C ON C.ClienteId = PO.ClienteId
	LEFT JOIN doc_ventas V ON V.VentaId = PO.VentaId AND V.Activo = 1
	WHERE (CONVERT(VARCHAR,POP.FechaProgramada,112) <= CONVERT(VARCHAR,@pFechaProgFin,112) AND po.TipoPedidoId = @pTipoPedidoId) or
	(CONVERT(VARCHAR,PO.CreadoEl,112) <= CONVERT(VARCHAR,@pFechaProgFin,112) AND po.TipoPedidoId = @pTipoPedidoId)
	OR @pTipoPedidoId = 0
	GROUP BY po.PedidoId,
		POD.PedidoDetalleId,
		POD.Cantidad,
		P.Clave,
		P.DescripcionCorta,
		PO.Total,
		POD.PrecioUnitario,
		P.ProductoId,
		U.NombreUsuario,
		C.Nombre,
		po.TipoPedidoId,
		pop.FechaProgramada,
		pop.HoraProgramada,
		v.VentaId,
		TCAJA.Nombre,
		p.ProdVtaBascula,
		POD.Total






GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_pendientes_proveedor_grd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_doc_pedidos_pendientes_proveedor_grd '20231123',1
CREATE PROC [dbo].[p_doc_pedidos_pendientes_proveedor_grd]
@FechaEntrega DATETIME,
@UsuarioId int
AS

	SELECT 
				
		ProductoId = ISNULL(P.ProductoId,0),
		Producto = ISNULL(P.Descripcion,''),
		Cantidad = ISNULL(SUM(PPD.Cantidad),0),
		CantidadDevolucion = ISNULL(SUM(PPD.CantidadDevolucion),0)
	FROM cat_productos P
	INNER JOIN cat_familias F ON F.Clave = P.ClaveFamilia AND 
							(F.Descripcion LIKE '%GUISOS%' OR F.Descripcion LIKE '%CHILES%' OR 
							F.Descripcion LIKE '%SALSAS%'  OR
							F.Descripcion LIKE '%BOTANAS%')
	
	INNER JOIN doc_pedidos_proveedor_detalle PPD ON PPD.ProductoId = P.ProductoId
	INNER JOIN doc_pedidos_proveedor PP ON PP.Id = PPD.PedidoProveedorId 
	INNER JOIN cat_usuarios_sucursales US ON US.UsuarioId = @UsuarioId AND
										US.SucursalId = PP.SucursalProveedorId
	WHERE  ISNULL(PP.EstatusPedidoId,0) >= 2 AND
	CAST(PP.FechaPedido AS DATE) = CAST(@FechaEntrega AS DATE) and
	ppd.Cantidad > 0
 
	GROUP BY P.ProductoId,P.Descripcion
	ORDER BY P.Descripcion


GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_proveedor_aprobar]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[p_doc_pedidos_proveedor_aprobar]
@pSucursalId INT,
@pFechaPedido DATETIME,
@pEstatusClaveIni VARCHAR(50),
@pEstatusClaveFin VARCHAR(50),
@pUsuarioId INT,
@pError VARCHAR(250) = '' OUT
AS

	BEGIN TRAN
	BEGIN TRY

	UPDATE doc_pedidos_proveedor
	SET EstatusPedidoId = E.EstatusPedidoId,
		CreadoPor = @pUsuarioId		
	FROM doc_pedidos_proveedor P
	INNER JOIN cat_estatus_pedido E ON E.Clave = @pEstatusClaveFin
	INNER JOIN cat_estatus_pedido PE ON PE.EstatusPedidoId = P.EstatusPedidoId AND
										PE.Clave = @pEstatusClaveIni
	--Asegurarse que el usuario tenga permiso
	INNER JOIN cat_usuarios_sucursales US ON US.UsuarioId = @pUsuarioId and
										US.SucursalId = P.SucursalProveedorId
	WHERE P.SucursalProveedorId = @pSucursalId AND
	ISNULL(P.Terminado,0) = 0 AND
	CASt(P.FechaPedido AS DATE) = CAST(@pFechaPedido AS DATE)

	COMMIT TRAN

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @pError = ERROR_MESSAGE()
	END CATCH
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_proveedor_del]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[p_doc_pedidos_proveedor_del]
    @Id INT
AS
BEGIN
    DELETE FROM [dbo].[doc_pedidos_proveedor]
    WHERE [Id] = @Id;
END;
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_proveedor_detalle_del]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_doc_pedidos_proveedor_detalle_del]
    @Id INT
AS
BEGIN
    DELETE FROM [dbo].[doc_pedidos_proveedor_detalle]
    WHERE [Id] = @Id;
END;
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_proveedor_detalle_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_doc_pedidos_proveedor_detalle_ins]
	@Id INT OUT,
    @PedidoProveedorId INT,
    @ProductoId INT,
    @Cantidad DECIMAL(14, 2),
    @CantidadDevolucion DECIMAL(14, 2),
    @CreadoPor INT
AS
BEGIN
    INSERT INTO [dbo].[doc_pedidos_proveedor_detalle] (
        [PedidoProveedorId],
        [ProductoId],
        [Cantidad],
        [CreadoEl],
        [CreadoPor],
		CantidadDevolucion
    )
    VALUES (
        @PedidoProveedorId,
        @ProductoId,
        @Cantidad,
        GETDATE(),
        @CreadoPor,
		@CantidadDevolucion
    );

	set @Id = SCOPE_IDENTITY()
END;
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_proveedor_detalle_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_doc_pedidos_proveedor_detalle_upd]
    @Id INT,
    @PedidoProveedorId INT,
    @ProductoId INT,
    @Cantidad DECIMAL(14, 2),
    @CantidadDevolucion DECIMAL(14, 2),
    @CreadoPor INT
AS
BEGIN
    UPDATE [dbo].[doc_pedidos_proveedor_detalle]
    SET
        [PedidoProveedorId] = @PedidoProveedorId,
        [ProductoId] = @ProductoId,
        [Cantidad] = @Cantidad,
		CantidadDevolucion = @CantidadDevolucion
    WHERE
        [Id] = @Id;
END;
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_proveedor_grd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_doc_pedidos_proveedor_grd 4,1
create PROC [dbo].[p_doc_pedidos_proveedor_grd]
@PedidoProveedorId INT,
@UsuarioId int
AS

	SELECT 
		Id=ISNULL(ppd.Id,0),
		PedidoProveedorId = ISNULL(@PedidoProveedorId,0),
		ProductoId = ISNULL(P.ProductoId,0),
		Producto = ISNULL(P.Descripcion,''),
		Cantidad = ISNULL(PPD.Cantidad,0),
		CantidadDevolucion = ISNULL(PPD.CantidadDevolucion,0)
	FROM cat_productos P
	INNER JOIN cat_familias F ON F.Clave = P.ClaveFamilia AND 
							(F.Descripcion LIKE '%GUISOS%' OR F.Descripcion LIKE '%CHILES%' OR 
							F.Descripcion LIKE '%SALSAS%'  OR
							F.Descripcion LIKE '%BOTANAS%')
	LEFT JOIN doc_pedidos_proveedor PP ON PP.Id = @PedidoProveedorId
	LEFT JOIN doc_pedidos_proveedor_detalle PPD ON PPD.PedidoProveedorId = PP.Id AND
									PPD.ProductoId = P.ProductoId
	WHERE ISNULL(PP.EstatusPedidoId,0) <= 1 
	OR ( ISNULL(PP.EstatusPedidoId,0) >= 2 AND ISNULL(PPD.Cantidad,0) >0)
	
	ORDER BY P.Descripcion



	
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_proveedor_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_doc_pedidos_proveedor_ins]
	@Id INT OUT,
    @SucursalId INT,
    @FechaRegistro DATETIME,
    @FechaPedido DATETIME,
    @SucursalProveedorId INT,
    @Comentarios VARCHAR(250),
    @Terminado BIT,
    @CreadoPor INT,
    @FechaTerminado DATETIME
AS
BEGIN
    INSERT INTO [dbo].[doc_pedidos_proveedor] (
        [SucursalId],
        [FechaRegistro],
        [FechaPedido],
        [SucursalProveedorId],
        [Comentarios],
        [Terminado],
        [CreadoPor],
        [FechaTerminado],
		EstatusPedidoId
    )
    VALUES (
        @SucursalId,
        @FechaRegistro,
        @FechaPedido,
        @SucursalProveedorId,
        @Comentarios,
        @Terminado,
        @CreadoPor,
        @FechaTerminado,
		1
    );

	SET @Id = SCOPE_IDENTITY()
END;
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_proveedor_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_doc_pedidos_proveedor_upd]
    @Id INT,
    @SucursalId INT,
    @FechaRegistro DATETIME,
    @FechaPedido DATETIME,
    @SucursalProveedorId INT,
    @Comentarios VARCHAR(250),
    @Terminado BIT,
    @CreadoPor INT,
    @FechaTerminado DATETIME,
	@EstatusPedidoId INT
AS
BEGIN
    UPDATE [dbo].[doc_pedidos_proveedor]
    SET
        [SucursalId] = @SucursalId,
        [FechaRegistro] = @FechaRegistro,
        [FechaPedido] = @FechaPedido,
        [SucursalProveedorId] = @SucursalProveedorId,
        [Comentarios] = @Comentarios,
        [Terminado] = @Terminado,
        [CreadoPor] = @CreadoPor,
        [FechaTerminado] = @FechaTerminado,
		EstatusPedidoId =CASE WHEN  @EstatusPedidoId = 0 THEN NULL ELSE @EstatusPedidoId END
    WHERE
        [Id] = @Id;
END;
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidosproveedor_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_doc_pedidosproveedor_sel 0,0,0,1,0
CREATE PROC [dbo].[p_doc_pedidosproveedor_sel]
@Id INT,
@SucursalId INT,
@SucursalProveedorId INT,
@UsuarioId INT,
@Seguimiento BIT=0
AS

	SELECT 
		DISTINCT
		PP.Id,
		PP.SucursalId,
		Sucursal = S.NombreSucursal,
		PP.FechaRegistro,
		PP.FechaPedido,
		PP.SucursalProveedorId,
		PP.Comentarios,
		PP.Terminado,
		PP.CreadoPor,
		PP.FechaTerminado,
		EstatusPedidoId = ISNULL(PP.EstatusPedidoId,''),
		EstatusPedido = ISNULL(EP.Descripcion,'(SIN ESTATUS)'),
		EstatusClave = ISNULL(EP.Clave,''),
		Proveedor = P.NombreSucursal
	FROM doc_pedidos_proveedor PP
	INNER JOIN cat_sucursales S ON S.Clave = pp.SucursalId
	INNER JOIN cat_sucursales P ON P.Clave = pp.SucursalProveedorId
	LEFT JOIN cat_usuarios_sucursales US ON US.UsuarioId = @UsuarioId AND
										US.SucursalId = PP.SucursalId 
	LEFT JOIN cat_usuarios_sucursales US2 ON US2.UsuarioId = @UsuarioId AND
										US2.SucursalId = PP.SucursalProveedorId
	LEFT JOIN cat_estatus_pedido EP ON EP.EstatusPedidoId = PP.EstatusPedidoId
	WHERE @Id IN (0,PP.Id) AND
	@SucursalId IN (0,PP.SucursalId) AND
	@SucursalProveedorId IN (0,PP.SucursalProveedorId) AND
	(
		(ISNULL(@Seguimiento,0) = 0 AND US.SucursalId = PP.SucursalId ) OR
		(ISNULL(@Seguimiento,0) = 1 AND US2.SucursalId = PP.SucursalProveedorId AND PP.EstatusPedidoId >=2) 
	)
	order by PP.FechaRegistro DESC
GO
/****** Object:  StoredProcedure [dbo].[p_doc_precios_especiales_grd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_doc_precios_especiales_grd 1,'COLA',0
CREATE PROC [dbo].[p_doc_precios_especiales_grd]
@pPrecioEspecialId INT,
@pBuscar varchar(250),
@pSoloConPrecioEspecial BIT
AS

	SELECT 
		PrecioEspecialId = PE.Id,
		PrecioEspecialDetalleId = ped.Id,
		PE.Id,
		p.ProductoId,
		p.Clave,
		Producto = p.Descripcion,
		Familia = f.Descripcion,
		PrecioVenta = PP.Precio,
		PED.PrecioEspecial,
		PED.MontoAdicional,
		PrecioEspecialFinal = CASE WHEN ISNULL(PED.PrecioEspecial,0) > 0 THEN ISNULL(PED.PrecioEspecial,0)
								WHEN ISNULL(PED.MontoAdicional,0) > 0 THEN ISNULL(PP.Precio,0) + ISNULL(PED.MontoAdicional,0)
								ELSE PP.Precio
							END							   
	FROM cat_productos p
	INNER JOIN cat_familias f on f.Clave = p.ClaveFamilia
	INNER JOIN cat_productos_precios PP ON PP.IdProducto = p.ProductoId AND
											PP.IdPrecio = 1
	LEFT JOIN  doc_precios_especiales PE ON PE.Id = @pPrecioEspecialId 
	LEFT JOIN doc_precios_especiales_detalle PED ON PED.PrecioEspeciaId = PE.Id AND
											PED.ProductoId = p.ProductoId 
	WHERE p.Estatus = 1 AND
	((p.Descripcion LIKE '%'+RTRIM(@pBuscar)+'%' OR @pBuscar = '') OR
	(f.Descripcion LIKE '%'+RTRIM(@pBuscar)+'%' OR @pBuscar = '')) AND
	(
		@pSoloConPrecioEspecial = 0	OR 
		(PED.Id IS NOT NULL AND @pSoloConPrecioEspecial = 1)
	) 
GO
/****** Object:  StoredProcedure [dbo].[p_doc_produccion_abierta_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[p_doc_produccion_abierta_sel]
@pSucursalId int,
@pProductoId int,
@pFecha	int
as

	SELECT * 
	FROM doc_produccion p
	WHERE p.SucursalId = @pSucursalId AND
	p.ProductoId = @pProductoId AND
	p.Activo = 1 AND
	p.FechaHoraFin IS NULL AND
	ISNULL(p.Completado,0) = 0
GO
/****** Object:  StoredProcedure [dbo].[p_doc_produccion_completar_por_solicitud]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_doc_produccion_completar_por_solicitud]
@pProduccionSolicitudId INT,
@pUsuarioId INT
AS

	declare @produccionId INT

	UPDATE doc_produccion
	SET EstatusProduccionId = 3,
		Completado = 1,
		FechaHoraFin = GETDATE()
	WHERE ProduccionSolicitudId = @pProduccionSolicitudId
	
	INSERT INTO doc_produccion_salida(ProduccionId,ProductoId,Cantidad,UnidadId,CreadoEl)
	SELECT PS.ProduccionId,PSD.ProductoId,SUM(PSA.Cantidad),MAX(PSA.UnidadId),GETDATE()
	FROM doc_produccion_solicitud PS
	INNER JOIN doc_produccion_solicitud_detalle PSD ON PSD.ProduccionSolicitudId = PS.ProduccionSolicitudId
	INNER JOIN doc_produccion_solicitud_aceptacion PSA ON PSA.ProduccionSolicitudDetalleId = PSD.Id 
	INNER JOIN doc_produccion P ON P.ProduccionSolicitudId = PS.ProduccionSolicitudId AND
								P.ProductoId = PSD.ProductoId
	WHERE PS.ProduccionSolicitudId = @pProduccionSolicitudId
	group by PS.ProduccionId,PSD.ProductoId


GO
/****** Object:  StoredProcedure [dbo].[p_doc_produccion_generar_por_solicitud]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_doc_produccion_generar_por_solicitud 12,1
CREATE PROC [dbo].[p_doc_produccion_generar_por_solicitud]
@pProduccionSolicitudId INT,
@pUsuarioId INT
AS

	declare @produccionId INT

	SELECT @produccionId = ISNULL(MAX(ProduccionId),0) 
	FROM doc_produccion 

	INSERT INTO doc_produccion(
	ProduccionId,	SucursalId,	FechaHoraInicio,	FechaHoraFin,	CreadoPor,	CreadoEl,
	Completado,		Activo,		EstatusProduccionId,ProductoId,		ProduccionSolicitudId)
	SELECT @produccionId + ROW_NUMBER() OVER(ORDER BY PS.ProduccionSolicitudId ASC) ,PS.ParaSucursalId, GETDATE(),			NULL,			@pUsuarioId,GETDATE(),
	0,				1,			2,					PSD.ProductoId,	@pProduccionSolicitudId		
	FROM doc_produccion_solicitud PS 
	INNER JOIN doc_produccion_solicitud_detalle PSD ON PSD.ProduccionSolicitudId = PS.ProduccionSolicitudId
	--INNER JOIN doc_produccion_solicitud_requerido PSR ON PSR.ProduccionSolicitudDetalleId = PSD.Id
	WHERE PS.ProduccionSolicitudId = @pProduccionSolicitudId
	GROUP BY PS.ProduccionSolicitudId,
	PSD.ProductoId,
	PS.ParaSucursalId
	
	INSERT INTO doc_produccion_entrada(ProduccionId,ProductoId,Cantidad,UnidadId,CreadoEl)
	SELECT P.ProduccionId,IR.ProductoRequeridoId,SUM(IR.Cantidad),MAX(IR.UnidadRequeridaId),GETDATE()
	FROM doc_produccion_solicitud PS
	INNER JOIN doc_produccion_solicitud_detalle PSD ON PSD.ProduccionSolicitudId = PS.ProduccionSolicitudId
	INNER JOIN doc_produccion_solicitud_requerido IR ON IR.ProduccionSolicitudDetalleId = PSD.Id
	inner join doc_produccion p on p.ProduccionSolicitudId = PS.ProduccionSolicitudId AND
								PSD.ProductoId = p.ProductoId
	WHERE PS.ProduccionSolicitudId = @pProduccionSolicitudId
	group by P.ProduccionId,IR.ProductoRequeridoId


GO
/****** Object:  StoredProcedure [dbo].[p_doc_produccion_solicitud_requerido_gen]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROC [dbo].[p_doc_produccion_solicitud_requerido_gen]
@pProduccionSolicitudId INT,
@pCreadoPor INT
AS
BEGIN


	DELETE [doc_produccion_solicitud_requerido]
	FROM [doc_produccion_solicitud_requerido] R
	INNER JOIN doc_produccion_solicitud_detalle SD ON SD.Id = R.ProduccionSolicitudDetalleId
	WHERE SD.ProduccionSolicitudId = @pProduccionSolicitudId

	INSERT INTO [doc_produccion_solicitud_requerido](
		ProduccionSolicitudDetalleId,		ProductoRequeridoId,		UnidadRequeridaId,
		Cantidad,							CreadoEl,							CreadoPor
	)
	SELECT SD.Id,							PB.ProductoBaseId,		  UnidadRequeridaId =PB.UnidadCocinaId,
		  CantidadRequerida = ISNULL(SD.Cantidad,0) * ISNULL(PB.Cantidad,0),GETDATE(),@pCreadoPor
	FROM doc_produccion_solicitud_detalle SD
	INNER JOIN cat_productos_base PB on PB.ProductoId = SD.ProductoId
	INNER JOIN cat_productos P ON P.ProductoId = SD.ProductoId
	WHERE SD.ProduccionSolicitudId = @pProduccionSolicitudId
END

GO
/****** Object:  StoredProcedure [dbo].[p_doc_produccion_venta_salida]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_doc_produccion_venta_salida 5,''
create proc [dbo].[p_doc_produccion_venta_salida]
@pVentaId INT,
@pError VARCHAR(100) OUT
AS
BEGIN

	SET @pError = ''
	DECLARE @MovimientoId INT,
		@MovimientoDetalleId INT
		
	BEGIN TRY

	BEGIN TRAN

	--oBTENER LA MATERIA PRIMA USADA EN LA VENTA
	SELECT 
		V.SucursalId,
		VD.ProductoId,
		VD.Cantidad,
		ProductoMateriaPrimaId = pb.ProductoBaseId,
		CantidadMateriaPrima = vd.Cantidad * pb.Cantidad,
		v.UsuarioCreacionId
	INTO #TMP_MOV_INV
	FROM doc_ventas v
	INNER JOIN doc_ventas_detalle vd on VD.VentaId = V.VentaId
	inner join cat_productos_base pb on pb.ProductoId = vd.ProductoId AND
								pb.GenerarSalidaVenta = 1
	WHERE v.VentaId = @pVentaId AND
	v.Activo = 1

	IF EXISTS (SELECT 1 FROM  #TMP_MOV_INV)
	BEGIN	

		SELECT @MovimientoId = ISNULL(MAX(MovimientoId),0) + 1
		FROM doc_inv_movimiento

		---GENERAR MOVIMIENTO INVENTARIO
		INSERT INTO doc_inv_movimiento(
				MovimientoId,	SucursalId,		FolioMovimiento,	TipoMovimientoId,		FechaMovimiento,
				HoraMovimiento,	Comentarios,	ImporteTotal,		Activo,					CreadoPor,
				CreadoEl,		Autorizado,		FechaAutoriza,		SucursalDestinoId,		AutorizadoPor,
				FechaCancelacion,ProductoCompraId,Consecutivo,		SucursalOrigenId,		VentaId,
				MovimientoRefId,Cancelado,		TipoMermaId
		)
		SELECT TOP 1 @MovimientoId, SucursalId, CAST(@MovimientoId AS VARCHAR),8 /*VENTA CAJA*/,dbo.fn_GetDateTimeServer(),
			CAST(dbo.fn_GetDateTimeServer() AS TIME),'Venta ID:' + cast(@pVentaId AS VARCHAR), 0, 1, UsuarioCreacionId,
			dbo.fn_GetDateTimeServer(),1,dbo.fn_GetDateTimeServer(),NULL,UsuarioCreacionId,
			NULL,NULL,CAST(@MovimientoId AS VARCHAR),SucursalId,@pVentaId,NULL,NULL,NULL
		FROM #TMP_MOV_INV

		SELECT @MovimientoDetalleId = ISNULL(MAX(MovimientoDetalleId),0) + 1
		FROM doc_inv_movimiento_detalle

		INSERT INTO doc_inv_movimiento_detalle(
		MovimientoDetalleId,		MovimientoId,		ProductoId,		Consecutivo,		Cantidad,
		PrecioUnitario,				Importe,			Disponible,		CreadoPor,			CreadoEl,
		CostoUltimaCompra,			CostoPromedio,		ValCostoUltimaCompra,				ValCostoPromedio,
		ValorMovimiento,			Flete,				Comisiones,		SubTotal,			PrecioNeto
		)
		SELECT @MovimientoDetalleId,@MovimientoId,		ProductoMateriaPrimaId, CAST(@MovimientoDetalleId AS VARCHAR), CantidadMateriaPrima,
		0,							0,					0,				UsuarioCreacionId,	DBO.fn_GetDateTimeServer(),
		0,							0,					0,				0,
		0,							0,					0,				0,					0
		FROM #TMP_MOV_INV

	END

	COMMIT TRAN


	END TRY
	BEGIN CATCH

		ROLLBACK TRAN
		SELECT @pError = ERROR_MESSAGE() + '.ERROR LINE:'+CAST(ERROR_LINE() AS VARCHAR)

	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[p_doc_productos_compra_cancelar]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Proc [dbo].[p_doc_productos_compra_cancelar]
@pProductoCompraId int,
@pUsuarioId int
as

	begin tran

	update doc_productos_compra
	set FechaCancelacion = getdate(),
	CanceladoPor = @pUsuarioId,
	Activo = 0
	where  ProductoCompraId = @pProductoCompraId and
	FechaCancelacion is null

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	update [doc_inv_movimiento]
	set Cancelado = 1,
	FechaCancelacion = GETDATE(),
	Activo = 0
	from [doc_inv_movimiento]
	where  ProductoCompraId = @pProductoCompraId 

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	commit tran
	fin:









GO
/****** Object:  StoredProcedure [dbo].[p_doc_productos_compra_detalle_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[p_doc_productos_compra_detalle_ins]
@pProductoCompraDetId	int,
@pProductoCompraId	int,
@pProductoId	int,
@pCantidad	decimal(14,2),
@pPrecioUnitario	money,
@pPorcImpuestos	decimal(5,2),
@pImpuestos	money,
@pPorcDescuentos	decimal(5,2),
@pDescuentos	money,
@pSubtotal	money,
@pTotal	money,
@pCreadoPor	int,
@pPrecioNeto money,
@pPrecioCompra money
AS

	SELECT @pProductoCompraDetId = ISNULL(MAX(ProductoCompraDetId),0)+ 1
	FROM doc_productos_compra_detalle

	insert INTO dbo.doc_productos_compra_detalle
	(
	    ProductoCompraDetId,
	    ProductoCompraId,
	    ProductoId,
	    Cantidad,
	    PrecioUnitario,
	    PorcImpuestos,
	    Impuestos,
	    PorcDescuentos,
	    Descuentos,
	    Subtotal,
	    Total,
	    CreadoEl,
	    CreadoPor,
		PrecioNeto,
		PrecioCompra
	)
	VALUES
	(   @pProductoCompraDetId,
	    @pProductoCompraId,
	    @pProductoId,
	    @pCantidad,
	    @pPrecioUnitario,
	    @pPorcImpuestos,
	    @pImpuestos,
	    @pPorcDescuentos,
	    @pDescuentos,
	    @pSubtotal,
	    @pTotal,
	    GETDATE(),
	    @pCreadoPor,     -- CreadoPor - int
		@pPrecioNeto,
		@pPrecioCompra
	    )





GO
/****** Object:  StoredProcedure [dbo].[p_doc_productos_compra_grd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_doc_productos_compra_grd 1, '20210101','20210801'
CREATE proc [dbo].[p_doc_productos_compra_grd]
@pSucursalId int,
@pDel DateTime ,
@pAl DateTime
as

	SELECT 
		pcd.ProductoCompraDetId,
		Sucursal = suc.NombreSucursal,
		pc.ProductoCompraId,
		pc.ProveedorId,
		Proveedor = prov.Nombre,
		RFC = prov.RFC,
	    pc.NumeroRemision,
		pc.FechaRegistro,
		TotalCompra = pc.Total,
		prod.Clave,
		prod.Descripcion,
		pcd.PrecioNeto,
		pcd.Cantidad,
		pcd.Subtotal,
		Impuestos = pcd.Total-pcd.Subtotal,
		TotalPartida=pcd.Total
		
	FROM doc_productos_compra pc
	INNER JOIN doc_productos_compra_detalle pcd  ON pcd.ProductoCompraId = pc.ProductoCompraId
	INNER JOIN cat_proveedores prov on prov.ProveedorId = pc.ProveedorId
	INNER JOIN cat_productos prod on prod.ProductoId = pcd.ProductoId
	INNER JOIN cat_sucursales suc on suc.Clave = pc.SucursalId
	WHERE pc.FechaRegistro BETWEEN @pDel AND @pAl and
	@pSucursalId in (0,pc.SucursalId) AND
	pc.Activo = 1
	ORDER BY prov.Nombre,pc.NumeroRemision
GO
/****** Object:  StoredProcedure [dbo].[p_doc_productos_compra_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_doc_productos_compra_ins]
@pProductoCompraId	int out,
@pProveedorId	int,
@pSucursalId int,
@pFechaRegistro	datetime,
@pNumeroRemision	varchar(50),
@pFechaRemision datetime,
@pDescuento	money,
@pSubtotal	money,
@pImpuestos	money,
@pTotal	MONEY,
@pCreadoPor	int,
@pPrecioConImpuestos bit,
@pFlete bit,
@pFleteFecha DateTime,
@pFleteRemision varchar(20),
@pFleteTotal money,
@pFleteProveedorId int,
@pComision bit,
@pComisionFecha DateTime,
@pComisionRemision varchar(20),
@pComisionTotal money,
@pComisionProveedorId int,
@pError varchar(250) out
AS

	begin try

	begin tran

	declare @fletePonderacion float,
		@comisionPonderacion float


	SELECT @pProductoCompraId = ISNULL(MAX(ProductoCompraId),0)+1
	FROM doc_productos_compra

	INSERT INTO doc_productos_compra(ProductoCompraId,	ProveedorId,	FechaRegistro,	NumeroRemision,		
	Descuento,		Subtotal,	Impuestos,		Total,	CreadoPor,	CreadoEl,	ModificadoPor,
	ModificadoEl,	Activo,		FechaRemision,	PrecioConImpuestos,	SucursalId)		
	VALUES(
		@pProductoCompraId,		@pProveedorId,		getdate(),		@pNumeroRemision,		
	@pDescuento,		@pSubtotal,		@pImpuestos,		@pTotal,	@pCreadoPor,	GETDATE(),	null,
	null,			1,			@pFechaRemision,@pPrecioConImpuestos,@pSucursalId
	)


	/****Fletes****/
	if(@pFlete = 1)
	begin
		insert into doc_productos_compra_cargos(ProductoCompraId,
			ProductoId,
			Remision,
			Fecha,
			ProveedorId,
			Total,
			CreadoPor)
		select @pProductoCompraId,-2/*Fletes*/,@pFleteRemision,@pFleteFecha,
		@pFleteProveedorId,@pFleteTotal,@pCreadoPor
	end
	if(@pComision = 1)
	begin
	/****Comisiones***/
	insert into doc_productos_compra_cargos(ProductoCompraId,
		ProductoId,
		Remision,
		Fecha,
		ProveedorId,
		Total,
		CreadoPor)
	select @pProductoCompraId,-3/*Comisiones*/,@pComisionRemision,@pComisionFecha,
	@pComisionProveedorId,@pComisionTotal,@pCreadoPor
	end

	

	commit tran
	end try
	begin catch
		rollback tran
		set @pError=error_message()

	end catch



GO
/****** Object:  StoredProcedure [dbo].[p_doc_productos_compra_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[p_doc_productos_compra_upd]
@pProductoCompraId	int out,
@pProveedorId	int,
@pSucursalId int,
@pFechaRegistro	datetime,
@pNumeroRemision	varchar(50),
@pFechaRemision datetime,
@pDescuento	money,
@pSubtotal	money,
@pImpuestos	money,
@pTotal	MONEY,
@pCreadoPor	int,
@pFlete bit,
@pFleteFecha DateTime,
@pFleteRemision varchar(20),
@pFleteTotal money,
@pFleteProveedorId int,
@pComision bit,
@pComisionFecha DateTime,
@pComisionRemision varchar(20),
@pComisionTotal money,
@pComisionProveedorId int,
@pError varchar(250) out
AS

	begin try
	declare @fletePonderacion float,
		@comisionPonderacion float
	begin tran

	UPDATE doc_productos_compra
	SET 	
	ProveedorId = @pProveedorId,		
	NumeroRemision = @pNumeroRemision,		
	Descuento = @pDescuento,		
	Subtotal = @pSubtotal,	
	Impuestos = @pImpuestos,		
	Total = @pTotal,		
	ModificadoPor = @pCreadoPor,
	ModificadoEl = getdate(),		
	FechaRemision = @pFechaRemision,
	SucursalId = @pSucursalId
	WHERE ProductoCompraId = @pProductoCompraId

	

	if(@pFlete = 0)
	begin 
		delete doc_productos_compra_cargos
		where ProductoCompraId = @pProductoCompraId and
		ProductoId = -2--Flete
	end
	else
	begin

		if not exists (
			select 1
			from doc_productos_compra_cargos
			where ProductoCompraId = @pProductoCompraId and
			ProductoId = -2--Fletes
		)
		begin
			/****Fletes****/
			insert into doc_productos_compra_cargos(ProductoCompraId,
				ProductoId,
				Remision,
				Fecha,
				ProveedorId,
				Total,
				CreadoPor)
			select @pProductoCompraId,-2/*Fletes*/,@pFleteRemision,@pFleteFecha,
			@pFleteProveedorId,@pFleteTotal,@pCreadoPor
		end
		else
			begin
				/***Fletes***/
				update doc_productos_compra_cargos
				set Remision = @pFleteRemision,
					 Fecha = @pFleteFecha,
					 ProveedorId = @pFleteProveedorId,
					 Total = @pFleteTotal
				where ProductoCompraId = @pProductoCompraId and
				ProductoId = -2--Fletes
			end
		
		
			
		
		
	end
	if(@pComision = 0)
	begin 
		delete doc_productos_compra_cargos
		where ProductoCompraId = @pProductoCompraId and
		ProductoId = -3--Comisiones
	end
	else
	begin

			if not exists (
			select 1
			from doc_productos_compra_cargos
			where ProductoCompraId = @pProductoCompraId and
			ProductoId = -3--Comisiones
			)
			begin

				insert into doc_productos_compra_cargos(ProductoCompraId,
					ProductoId,
					Remision,
					Fecha,
					ProveedorId,
					Total,
					CreadoPor)
				select @pProductoCompraId,-3/*Comisiones*/,@pComisionRemision,@pComisionFecha,
				@pComisionProveedorId,@pComisionTotal,@pCreadoPor
			end
			else
			begin
				/***Comisiones***/
				update doc_productos_compra_cargos
				set Remision = @pComisionRemision,
					 Fecha = @pComisionFecha,
					 ProveedorId = @pComisionProveedorId,
					 Total = @pComisionTotal
				where ProductoCompraId = @pProductoCompraId and
				ProductoId = -3--Comisiones
			end

	end

	
	

	commit tran

	end try
	begin catch
		rollback tran
		set @pError =ERROR_MESSAGE()
	end catch





GO
/****** Object:  StoredProcedure [dbo].[p_doc_productos_existencias_diario_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_doc_productos_existencias_diario_upd 3,1,''
CREATE PROC [dbo].[p_doc_productos_existencias_diario_upd]
@pSucursalId INT,
@pCreadoPor INT,
@pError VARCHAR(250) OUT
as


	SET @pError = ''

	BEGIN TRAN

	BEGIN TRY


		DECLARE @FechaExistenciaMov DATETIME


		--MARCAR MOVIMIENTOS DE INVENTARIO PARA YA NO TOMARSE EN CUENTA
		update doc_inv_movimiento
		set FechaCorteExistencia = [dbo].[fn_GetDateTimeServer]()
		where SucursalId = @pSucursalId AND
		FechaCorteExistencia IS NULL

		SELECT *
		INTO #TMP_EXISTENCIAS_SUCURSAL
		FROM cat_productos_existencias PE
		WHERE PE.SucursalId = @pSucursalId

		SET @FechaExistenciaMov = [dbo].[fn_GetDateTimeServer]()

		
		--ACTUALIZAR EXISTENCIAS QUE YA TENGAN REGISTRO DEL D�A

		UPDATE doc_productos_existencias_diario
		SET [Existencia] = TMP.ExistenciaTeorica,
			FechaCorteExistencia = @FechaExistenciaMov
		FROM doc_productos_existencias_diario PE
		INNER JOIN #TMP_EXISTENCIAS_SUCURSAL TMP ON TMP.ProductoId = PE.ProductoId AND
												TMP.SucursalId = PE.SucursalId AND
												CONVERT(VARCHAR,PE.FechaCorteExistencia,112) = CONVERT(VARCHAR,@FechaExistenciaMov,112)


		INSERT INTO doc_productos_existencias_diario(SucursalId,ProductoId,FechaCorteExistencia,Existencia,CreadoEl,CreadoPor)
		SELECT TMP.SucursalId,TMP.ProductoId,@FechaExistenciaMov,TMP.ExistenciaTeorica,GETDATE(),@pCreadoPor
		FROM #TMP_EXISTENCIAS_SUCURSAL TMP 
		WHERE NOT EXISTS (
			SELECT 1
			FROM doc_productos_existencias_diario S1
			WHERE S1.SucursalId = TMP.SucursalId AND
			S1.ProductoId = TMP.ProductoId AND
			CONVERT(VARCHAR,S1.FechaCorteExistencia,112) = CONVERT(VARCHAR,@FechaExistenciaMov,112)
		)

		COMMIT TRAN

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @pError = ERROR_MESSAGE()
	END CATCH
GO
/****** Object:  StoredProcedure [dbo].[p_doc_productos_max_min_grd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_doc_productos_max_min_grd 1,1
CREATE PROC [dbo].[p_doc_productos_max_min_grd]
@pSucursalId INT,
@pSoloAsignadasSucursal BIT=0
AS

	SELECT SucursalId = @pSucursalId,
		Sucursal = S.NombreSucursal,
		P.ProductoId,
		P.Clave,
		P.Descripcion,
		Maximo = ISNULL(PMM.Maximo,0),
		Minimo = ISNULL(PMM.Minimo,0)
	FROM cat_productos P
	INNER JOIN cat_sucursales S ON S.Clave = @pSucursalId
	LEFT JOIN doc_productos_max_min PMM ON PMM.ProductoId = P.ProductoId AND
											PMM.SucursalId = S.Clave
	LEFT JOIN cat_sucursales_productos SP ON SP.SucursalId = S.Clave AND
											SP.ProductoId = P.ProductoId
	WHERE (@pSoloAsignadasSucursal = 1 AND SP.ProductoId IS NOT NULL )
	OR @pSoloAsignadasSucursal = 0

	
GO
/****** Object:  StoredProcedure [dbo].[p_doc_productos_max_min_ins_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- p_doc_productos_max_min_grd 1,1
CREATE PROC [dbo].[p_doc_productos_max_min_ins_upd]
@pSucursalId INT,
@pProductoId INT,
@pMaximo DECIMAL(14,2),
@pMinimo DECIMAL(14,2)
AS

	IF NOT EXISTS (
		SELECT 1
		FROM doc_productos_max_min 
		WHERE ProductoId = @pProductoId AND
		SucursalId = @pSucursalId
	)
	BEGIN

		INSERT INTO doc_productos_max_min(
			SucursalId,ProductoId,Maximo,Minimo,CreadoEl
		)
		VALUES(@pSucursalId,@pProductoId,@pMaximo,@pMinimo,GETDATE())
	END
	ELSE
	BEGIN

		UPDATE doc_productos_max_min
		SET Maximo = @pMaximo,
		Minimo = @pMinimo
		WHERE ProductoId = @pProductoId AND
		SucursalId = @pSucursalId
	END

GO
/****** Object:  StoredProcedure [dbo].[p_doc_productos_max_min_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[p_doc_productos_max_min_sel]
@pSucursalId INT
AS

	SELECT CalveProducto = P.Clave,
		MM.ProductoId,
		MM.SucursalId,
		Disponible = ISNULL(PE.Disponible,0),
		Maximo = ISNULL(MM.Maximo,0),
		Minimo = ISNULL(MM.Minimo,0),
		Solicitar = ISNULL(MM.Minimo,0) - ISNULL(PE.Disponible,0),
		Producto = P.Descripcion
	FROM doc_productos_max_min MM
	INNER JOIN cat_productos P ON P.ProductoId = MM.ProductoId
	LEFT JOIN cat_productos_existencias PE ON PE.ProductoId = MM.ProductoId AND
									PE.SucursalId = MM.SucursalId AND
									ISNULL(MM.Minimo,0) > 0
	WHERE MM.SucursalId = @pSucursalId  AND
	ISNULL(MM.Minimo,0) - ISNULL(PE.Disponible,0) > 0
GO
/****** Object:  StoredProcedure [dbo].[p_doc_productos_sobrantes_registro_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_doc_productos_sobrantes_registro_sel]
@pSucursalId int,
@pFecha DateTime
AS
	SELECT Id,
		SucursalId,
		ProductoId,
		CantidadSobrante,
		CreadoEl,
		CreadoPor
	FROM doc_productos_sobrantes_registro
	WHERE SucursalId = @pSucursalId AND
	CONVERT(VARCHAR,CreadoEl,112) = CONVERT(VARCHAR,@pFecha,112)
GO
/****** Object:  StoredProcedure [dbo].[p_doc_promociones_cm_detalle]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[p_doc_promociones_cm_detalle]
@pPromocionCMDetId int out,
@pPromocionCMId int,
@pProductoId int,
@pCantidadCompraMinima decimal(10,2),
@pCantidadCobro decimal(10,2)
as

	if(isnull(@pPromocionCMDetId,0) = 0)
	begin

		select @pPromocionCMDetId = isnull(max(PromocionCMDetId),0) + 1
		from doc_promociones_cm_detalle

		insert into doc_promociones_cm_detalle(
			PromocionCMDetId,		PromocionCMId,		ProductoId,
			CantidadCompraMinima,	CantidadCobro,		CreadoEL
		)
		select @pPromocionCMDetId,	@pPromocionCMId,	@pProductoId,
		@pCantidadCompraMinima,	@pCantidadCobro,getdate()
	end
	Else
	Begin
		update doc_promociones_cm_detalle
		set ProductoId = @pProductoId,
			CantidadCompraMinima = @pCantidadCompraMinima,
			CantidadCobro = @pCantidadCobro
		where PromocionCMDetId = @pPromocionCMDetId
	End
GO
/****** Object:  StoredProcedure [dbo].[p_doc_promociones_cm_ins_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[p_doc_promociones_cm_ins_upd]
@pPromocionCMId int out,
@pSucursalId int,
@pNombrePromocion varchar(150),
@pFechaVigencia DateTime,
@pHoraVigencia time,
@pLunes bit,
@pMartes bit,
@pMiercoles bit,
@pJueves bit,
@pViernes  bit,
@pSabado bit,
@pDomingo bit,
@pCreadoPor int,
@pActivo bit
as


	if isnull(@pPromocionCMId,0) = 0
	begin
		select @pPromocionCMId = isnull(max(PromocionCMId),0) + 1
		from doc_promociones_cm

		insert into doc_promociones_cm(
			PromocionCMId,	SucursalId,		NombrePromocion,	FechaRegistro,
			FechaVigencia,	HoraVigencia,	Lunes,				Martes,			
			Miercoles,		Jueves,			Viernes,			Sabado,
			Domingo,		CreadoPor,		Activo
		)
		select @pPromocionCMId,	@pSucursalId,		@pNombrePromocion,	getdate(),
			@pFechaVigencia,	@pHoraVigencia,	@pLunes,				@pMartes,			
			@pMiercoles,		@pJueves,			@pViernes,			@pSabado,
			@pDomingo,		@pCreadoPor,		1
	end
	Else
	Begin
		update doc_promociones_cm
		set 
		NombrePromocion = @pNombrePromocion,		
		FechaVigencia = @pFechaVigencia,
		HoraVigencia = @pHoraVigencia,
		Lunes = @pLunes,
		Martes = @pMartes,
		Miercoles = @pMiercoles,
		Jueves = @pJueves,
		Viernes = @pViernes,
		Sabado = @pSabado,
		Domingo = @pDomingo,
		Activo = @pActivo
		where PromocionCMId = @pPromocionCMId
	End
GO
/****** Object:  StoredProcedure [dbo].[p_doc_promociones_detalle]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[p_doc_promociones_detalle]
@pPromocionDetalleId	int,
@pPromocionId	int,
@pLineaId	int,
@pFamiliaId	int,
@pSubfamilia	int,
@pProductoId	int
as


	select @pPromocionDetalleId = isnull(max(PromocionDetalleId),0) + 1
	from [doc_promociones_detalle]

	insert into [dbo].[doc_promociones_detalle](
		PromocionDetalleId,		PromocionId,		LineaId,		FamiliaId,	
		Subfamilia,				ProductoId,			CreadoEl
	)
	values(
		@pPromocionDetalleId,		@pPromocionId,		@pLineaId,		@pFamiliaId,	
		@pSubfamilia,				@pProductoId,		getdate()
	)





GO
/****** Object:  StoredProcedure [dbo].[p_doc_promociones_detalle_del]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[p_doc_promociones_detalle_del]
@pPromocionId int
as
	
		delete [doc_promociones_detalle]
		where promocionid = @pPromocionId





GO
/****** Object:  StoredProcedure [dbo].[p_doc_promociones_detalle_grd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Proc [dbo].[p_doc_promociones_detalle_grd]
@pPromocionId int
as

	select PromocionDetalleId,
			PromocionId,
			LineaId,
			Linea = isnull(l.Descripcion,'(Todas)'),
			FamiliaId,
			Familia =  isnull(F.Descripcion,'(Todas)'),
			SubfamiliaId = pd.Subfamilia,
			Subfamilia = isnull(sF.Descripcion,'(Todas)'),
			pd.ProductoId,
			Producto =isnull( pro.DescripcionCorta,'(Todas)'),
			CreadoEl
	from doc_promociones_detalle pd
	left join cat_lineas l on l.clave = pd.lineaId
	LEFT join cat_familias f on f.clave = pd.familiaiD
	LEFT JOIN CAT_SUBFAMILIAS sf on sf.clave = pd.Subfamilia
	left join cat_productos pro on pro.productoId = pd.ProductoId
	where promocionId = @pPromocionId





GO
/****** Object:  StoredProcedure [dbo].[p_doc_promociones_excepcion_del]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[p_doc_promociones_excepcion_del]
@pPromocionId int
as
	
		delete [doc_promociones_excepcion]
		where promocionid = @pPromocionId




GO
/****** Object:  StoredProcedure [dbo].[p_doc_promociones_excepcion_grd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create Proc [dbo].[p_doc_promociones_excepcion_grd]
@pPromocionId int
as

	select PromocionExcepcionId,
			PromocionId,
			LineaId,
			Linea = isnull(l.Descripcion,'(Todas)'),
			FamiliaId,
			Familia =  isnull(F.Descripcion,'(Todas)'),
			SubfamiliaId = pd.Subfamilia,
			Subfamilia = isnull(sF.Descripcion,'(Todas)'),
			pd.ProductoId,
			Producto =isnull( pro.DescripcionCorta,'(Todas)'),
			CreadoEl
	from doc_promociones_excepcion pd
	left join cat_lineas l on l.clave = pd.lineaId
	LEFT join cat_familias f on f.clave = pd.familiaiD
	LEFT JOIN CAT_SUBFAMILIAS sf on sf.clave = pd.Subfamilia
	left join cat_productos pro on pro.productoId = pd.ProductoId
	where promocionId = @pPromocionId




GO
/****** Object:  StoredProcedure [dbo].[p_doc_promociones_excepcion_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Proc [dbo].[p_doc_promociones_excepcion_ins]
@pPromocionDetalleId	int,
@pPromocionId	int,
@pLineaId	int,
@pFamiliaId	int,
@pSubfamilia	int,
@pProductoId	int
as


	select @pPromocionDetalleId = isnull(max(PromocionExcepcionId),0) + 1
	from [doc_promociones_excepcion]

	insert into [dbo].[doc_promociones_excepcion](
		PromocionExcepcionId,		PromocionId,		LineaId,		FamiliaId,	
		Subfamilia,				ProductoId,			CreadoEl
	)
	values(
		@pPromocionDetalleId,		@pPromocionId,		@pLineaId,		@pFamiliaId,	
		@pSubfamilia,				@pProductoId,		getdate()
	)




GO
/****** Object:  StoredProcedure [dbo].[p_doc_promociones_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[p_doc_promociones_ins]
@pPromocionId	int out,
@pPorcentajeDescuento	decimal(5,2),
@pFechaInicioVigencia	datetime,
@pFechaFinVigencia	datetime,
@pCreadoPor	int,
@pEmpresaId	int,
@pSucursalId	int,
@pNombrePromocion varchar(100),
@pLunes bit,
@pMartes bit,
@pMiercoles bit,
@pJueves bit,
@pViernes bit,
@pSabado bit,
@pDomingo bit,
@pPermanente bit
as

	select @pPromocionId = isnull(max(PromocionId),0) + 1
	from [doc_promociones]

	insert into [dbo].[doc_promociones](
		PromocionId,			FechaRegistro,		PorcentajeDescuento,		FechaInicioVigencia,
		FechaFinVigencia,		CreadoPor,			EmpresaId,					SucursalId,
		Activo,					NombrePromocion,	Lunes,
		Martes,					Miercoles,			Jueves,
		Viernes,				Sabado,				Domingo,					Permanente
	)
	values(
		@pPromocionId,			getdate(),			@pPorcentajeDescuento,		@pFechaInicioVigencia,
		@pFechaFinVigencia,		@pCreadoPor,		@pEmpresaId,				@pSucursalId,
		1,						@pNombrePromocion,	@pLunes,
		@pMartes,				@pMiercoles,		@pJueves,
		@pViernes,				@pSabado,			@pDomingo,					@pPermanente
	)





GO
/****** Object:  StoredProcedure [dbo].[p_doc_promociones_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[p_doc_promociones_upd]
@pPromocionId	int out,
@pPorcentajeDescuento	decimal(5,2),
@pFechaInicioVigencia	datetime,
@pFechaFinVigencia	datetime,
@pCreadoPor	int,
@pEmpresaId	int,
@pSucursalId	int,
@pNombrePromocion varchar(100),
@pLunes bit,
@pMartes bit,
@pMiercoles bit,
@pJueves bit,
@pViernes bit,
@pSabado bit,
@pDomingo bit,
@pActivo bit,
@pPermanente bit
as

	

	update [dbo].[doc_promociones]
	set 
		PorcentajeDescuento = @pPorcentajeDescuento,
		FechaInicioVigencia = @pFechaInicioVigencia,
		FechaFinVigencia = @pFechaFinVigencia,
		EmpresaId = @pEmpresaId,
		SucursalId = @pSucursalId,
		NombrePromocion = @pNombrePromocion,
		Lunes = @pLunes,
		Martes = @pMartes,
		Miercoles = @pMiercoles,
		Jueves = @pJueves,
		Viernes = @pViernes,
		Sabado = @pSabado,
		Domingo = @pDomingo,
		Activo = @pActivo,
		Permanente = @pPermanente
	where Promocionid = @pPromocionId







GO
/****** Object:  StoredProcedure [dbo].[p_doc_sesiones_punto_venta_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Proc [dbo].[p_doc_sesiones_punto_venta_ins]
@pSesionId	int out,
@pUsuarioId	int,
@pCajaId	int,
@pFechaInicio	datetime,
@pFechaUltimaConexion	datetime,
@pCorteAplicado	bit,
@pFechaCorte	datetime,
@pFinalizada	bit,
@pCorteCajaId	int
as

	if(isnull(@pSesionId,0) = 0)
	begin 

		select @pSesionId  =isnull(max(SesionId),0)+1
		from doc_sesiones_punto_venta



		insert into doc_sesiones_punto_venta(
			SesionId,UsuarioId,CajaId,FechaInicio,FechaUltimaConexion,
			CorteAplicado,FechaCorte,Finalizada,CorteCajaId
		)
		values(
			@pSesionId,@pUsuarioId,@pCajaId,getdate(),getdate(),
			@pCorteAplicado,@pFechaCorte,@pFinalizada,@pCorteCajaId
		)
	end
	else
	begin
		update doc_sesiones_punto_venta
		set FechaUltimaConexion = getdate()
		where sesionId = @pSesionId
	end
	



GO
/****** Object:  StoredProcedure [dbo].[p_doc_sobrantes_ajustes_inventario]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [p_doc_sobrantes_ajustes_inventario] 38,'20231222',163,''
CREATE PROC [dbo].[p_doc_sobrantes_ajustes_inventario]
@pSucursalId INT,
@pFecha DATETIME,
@pUsuarioId INT,
@pError VARCHAR(250) OUT
AS

	DECLARE @MovimientoId INT,
		@MovimientoDetalleId INT,
		@FolioMovimiento VARCHAR(200),
		@Id INT,
		@RegistroSobranteId INT,
		@UUID VARCHAR(300)

	SET @pError = ''

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	BEGIN TRY

	--BEGIN TRAN

	SELECT psc.ProductoSobranteId,Descripcion1=P1.Descripcion,PSC.ProductoConvertirId ,Descripcion2=p2.Descripcion,CantidadSobrante = SUM(ps.CantidadSobrante),
		TipoMovimientoInventario1 = CASE WHEN P1.Descripcion LIKE '%DESPERDICIO%' THEN 25 /*Desperdicio de Inventario*/ ELSE 6 /*Ajuste Por Salida*/ END,
		TipoMovimientoInventario2 = CASE WHEN PSC.Convertir = 1  THEN   5 /*Ajuste Por Entrada*/ END
	INTO #TMP_SOBRANTES_CONFIG
	FROM doc_productos_sobrantes_registro PS
	INNER JOIN doc_productos_sobrantes_config PSC ON PSC.ProductoSobranteId = PS.ProductoId 
	INNER JOIN cat_productos P1 ON P1.ProductoId = PSC.ProductoSobranteId
	INNER JOIN cat_productos P2 ON P2.ProductoId = PSC.ProductoConvertirId
	LEFT JOIN doc_productos_sobrantes_regitro_inventario PSI ON PSI.SobranteRegsitroId = PS.Id
	WHERE SucursalId = @pSucursalId AND
	PSI.Id IS NULL AND
	CONVERT(VARCHAR,PS.CreadoEl,112) = CONVERT(VARCHAR,@pFecha,112) AND
	ISNULL(PS.Cerrado,0) = 0
	GROUP BY psc.ProductoSobranteId,P1.Descripcion,PSC.ProductoConvertirId ,p2.Descripcion,PSC.Convertir

	SELECT @RegistroSobranteId = MIN(ProductoSobranteId)
	FROM #TMP_SOBRANTES_CONFIG PSR

	SET @UUID = NEWID()	


	/****DESPERDICIO DE INVENTARIO ENTRADA****/
	SELECT @MovimientoId = ISNULL(MAX(MovimientoId),0) + 1
	FROM doc_inv_movimiento
	
	

	SELECT @FolioMovimiento = count(*) + 1
	FROM doc_inv_movimiento
	WHERE TipoMovimientoId = 5 AND
	SucursalId = @pSucursalId

	
	INSERT INTO doc_inv_movimiento(
		MovimientoId,SucursalId,FolioMovimiento,TipoMovimientoId,FechaMovimiento,HoraMovimiento,
		Comentarios,ImporteTotal,Activo,CreadoPor,CreadoEl,
		Autorizado,FechaAutoriza,SucursalDestinoId,AutorizadoPor,FechaCancelacion,
		ProductoCompraId,Consecutivo,SucursalOrigenId,VentaId,MovimientoRefId,
		Cancelado,TipoMermaId
	)
	SELECT TOP 1 @MovimientoId,@pSucursalId,@FolioMovimiento,5 /*DESPERDICIO*/,dbo.fn_GetDateTimeServer(),dbo.fn_GetDateTimeServer(),
	'Movimiento Autom?tico registro sobrantes:' +@UUID ,0,1,1,dbo.fn_GetDateTimeServer(),
	1,dbo.fn_GetDateTimeServer(),NULL,1,NULL,
	NULL,@FolioMovimiento,NULL,NULL,NULL,NULL,NULL
	FROM #TMP_SOBRANTES_CONFIG
	WHERE Descripcion1 LIKE '%DESPERDICIO%'



	SELECT @MovimientoDetalleId = ISNULL(MAX(MovimientoDetalleId),0) + 1
	FROM doc_inv_movimiento_detalle

	INSERT INTO doc_inv_movimiento_detalle(	MovimientoDetalleId,MovimientoId,ProductoId,Consecutivo,Cantidad,PrecioUnitario,Importe,
	Disponible,CreadoPor,CreadoEl,CostoUltimaCompra,CostoPromedio,ValCostoUltimaCompra,ValCostoPromedio,ValorMovimiento,Flete,Comisiones,
	SubTotal,PrecioNeto
	)
	SELECT  ROW_NUMBER() OVER(ORDER BY ProductoSobranteId ASC) +@MovimientoDetalleId,@MovimientoId,ProductoSobranteId,ROW_NUMBER() OVER(ORDER BY ProductoSobranteId ASC),CantidadSobrante,0,0,
	0,1,dbo.fn_GetDateTimeServer(),0,0,0,0,0,0,0,0,0
	FROM #TMP_SOBRANTES_CONFIG
	WHERE Descripcion1  LIKE '%DESPERDICIO%'

	


	/****DESPERDICIO DE INVENTARIO SALIDA****/
	SELECT @MovimientoId = ISNULL(MAX(MovimientoId),0) + 1
	FROM doc_inv_movimiento

	SELECT @FolioMovimiento = count(*) + 1
	FROM doc_inv_movimiento
	WHERE TipoMovimientoId = 25 AND
	SucursalId = @pSucursalId

	INSERT INTO doc_inv_movimiento(
		MovimientoId,SucursalId,FolioMovimiento,TipoMovimientoId,FechaMovimiento,HoraMovimiento,
		Comentarios,ImporteTotal,Activo,CreadoPor,CreadoEl,
		Autorizado,FechaAutoriza,SucursalDestinoId,AutorizadoPor,FechaCancelacion,
		ProductoCompraId,Consecutivo,SucursalOrigenId,VentaId,MovimientoRefId,
		Cancelado,TipoMermaId
	)
	SELECT TOP 1 @MovimientoId,@pSucursalId,@FolioMovimiento,25 /*DESPERDICIO*/,dbo.fn_GetDateTimeServer(),dbo.fn_GetDateTimeServer(),
	'Movimiento Autom?tico registro sobrantes:' +@UUID,0,1,1,dbo.fn_GetDateTimeServer(),
	1,dbo.fn_GetDateTimeServer(),NULL,1,NULL,
	NULL,@FolioMovimiento,NULL,NULL,NULL,NULL,NULL
	FROM #TMP_SOBRANTES_CONFIG
	WHERE Descripcion1 LIKE '%DESPERDICIO%'


	SELECT @MovimientoDetalleId = ISNULL(MAX(MovimientoDetalleId),0) + 1
	FROM doc_inv_movimiento_detalle

	INSERT INTO doc_inv_movimiento_detalle(	MovimientoDetalleId,MovimientoId,ProductoId,Consecutivo,Cantidad,PrecioUnitario,Importe,
	Disponible,CreadoPor,CreadoEl,CostoUltimaCompra,CostoPromedio,ValCostoUltimaCompra,ValCostoPromedio,ValorMovimiento,Flete,Comisiones,
	SubTotal,PrecioNeto
	)
	SELECT  ROW_NUMBER() OVER(ORDER BY ProductoSobranteId ASC) +@MovimientoDetalleId,@MovimientoId,ProductoSobranteId,ROW_NUMBER() OVER(ORDER BY ProductoSobranteId ASC),CantidadSobrante,0,0,
	0,1,dbo.fn_GetDateTimeServer(),0,0,0,0,0,0,0,0,0
	FROM #TMP_SOBRANTES_CONFIG
	WHERE Descripcion1  LIKE '%DESPERDICIO%'

	/***********ENTRADA DE PRODUCTOS SOBRANTES ANTES DE CONVERTIRLO EN OTRO PRODUCTO**********************/
	
	SELECT @MovimientoId = ISNULL(MAX(MovimientoId),0) + 1
	FROM doc_inv_movimiento

	SELECT @FolioMovimiento = count(*) + 1
	FROM doc_inv_movimiento
	WHERE TipoMovimientoId = 5 AND
	SucursalId = @pSucursalId

	INSERT INTO doc_inv_movimiento(
		MovimientoId,SucursalId,FolioMovimiento,TipoMovimientoId,FechaMovimiento,HoraMovimiento,
		Comentarios,ImporteTotal,Activo,CreadoPor,CreadoEl,
		Autorizado,FechaAutoriza,SucursalDestinoId,AutorizadoPor,FechaCancelacion,
		ProductoCompraId,Consecutivo,SucursalOrigenId,VentaId,MovimientoRefId,
		Cancelado,TipoMermaId
	)
	SELECT TOP 1 @MovimientoId,@pSucursalId,@FolioMovimiento,5,dbo.fn_GetDateTimeServer(),dbo.fn_GetDateTimeServer(),
	'Movimiento Autom?tico registro sobrantes:' +@UUID,0,1,1,dbo.fn_GetDateTimeServer(),
	1,dbo.fn_GetDateTimeServer(),NULL,1,NULL,
	NULL,@FolioMovimiento,NULL,NULL,NULL,NULL,NULL
	FROM #TMP_SOBRANTES_CONFIG
	WHERE Descripcion1 NOT LIKE '%DESPERDICIO%' AND TipoMovimientoInventario1 IS NOT NULL

	
	SELECT @MovimientoDetalleId = ISNULL(MAX(MovimientoDetalleId),0) + 1
	FROM doc_inv_movimiento_detalle

	INSERT INTO doc_inv_movimiento_detalle(	MovimientoDetalleId,MovimientoId,ProductoId,Consecutivo,Cantidad,PrecioUnitario,Importe,
	Disponible,CreadoPor,CreadoEl,CostoUltimaCompra,CostoPromedio,ValCostoUltimaCompra,ValCostoPromedio,ValorMovimiento,Flete,Comisiones,
	SubTotal,PrecioNeto
	)
	SELECT  ROW_NUMBER() OVER(ORDER BY ProductoSobranteId ASC) +@MovimientoDetalleId,@MovimientoId,ProductoSobranteId,ROW_NUMBER() OVER(ORDER BY ProductoSobranteId ASC),CantidadSobrante,0,0,
	0,1,dbo.fn_GetDateTimeServer(),0,0,0,0,0,0,0,0,0
	FROM #TMP_SOBRANTES_CONFIG
	WHERE Descripcion1  NOT LIKE '%DESPERDICIO%' AND TipoMovimientoInventario1 IS NOT NULL AND CantidadSobrante <> 0

	


	/***********SALIDA DE PRODUCTOS SOBRANTES PARA CONVERTIRLO EN OTRO PRODUCTO**********************/
	
	SELECT @MovimientoId = ISNULL(MAX(MovimientoId),0) + 1
	FROM doc_inv_movimiento

	SELECT @FolioMovimiento = count(*) + 1
	FROM doc_inv_movimiento
	WHERE TipoMovimientoId = 6 AND
	SucursalId = @pSucursalId

	INSERT INTO doc_inv_movimiento(
		MovimientoId,SucursalId,FolioMovimiento,TipoMovimientoId,FechaMovimiento,HoraMovimiento,
		Comentarios,ImporteTotal,Activo,CreadoPor,CreadoEl,
		Autorizado,FechaAutoriza,SucursalDestinoId,AutorizadoPor,FechaCancelacion,
		ProductoCompraId,Consecutivo,SucursalOrigenId,VentaId,MovimientoRefId,
		Cancelado,TipoMermaId
	)
	SELECT TOP 1 @MovimientoId,@pSucursalId,@FolioMovimiento,TipoMovimientoInventario1 /*DESPERDICIO*/,dbo.fn_GetDateTimeServer(),dbo.fn_GetDateTimeServer(),
	'Movimiento Autom?tico registro sobrantes:' +@UUID,0,1,1,dbo.fn_GetDateTimeServer(),
	1,dbo.fn_GetDateTimeServer(),NULL,1,NULL,
	NULL,@FolioMovimiento,NULL,NULL,NULL,NULL,NULL
	FROM #TMP_SOBRANTES_CONFIG
	WHERE Descripcion1 NOT LIKE '%DESPERDICIO%' AND TipoMovimientoInventario1 IS NOT NULL

	
	SELECT @MovimientoDetalleId = ISNULL(MAX(MovimientoDetalleId),0) + 1
	FROM doc_inv_movimiento_detalle

	INSERT INTO doc_inv_movimiento_detalle(	MovimientoDetalleId,MovimientoId,ProductoId,Consecutivo,Cantidad,PrecioUnitario,Importe,
	Disponible,CreadoPor,CreadoEl,CostoUltimaCompra,CostoPromedio,ValCostoUltimaCompra,ValCostoPromedio,ValorMovimiento,Flete,Comisiones,
	SubTotal,PrecioNeto
	)
	SELECT  ROW_NUMBER() OVER(ORDER BY ProductoSobranteId ASC) +@MovimientoDetalleId,@MovimientoId,ProductoSobranteId,ROW_NUMBER() OVER(ORDER BY ProductoSobranteId ASC),CantidadSobrante,0,0,
	0,1,dbo.fn_GetDateTimeServer(),0,0,0,0,0,0,0,0,0
	FROM #TMP_SOBRANTES_CONFIG
	WHERE Descripcion1  NOT LIKE '%DESPERDICIO%' AND TipoMovimientoInventario1 IS NOT NULL AND CantidadSobrante <> 0

	
	/***********ENTRADA DE PRODUCTOS SOBRANTES CONVERTIDOS A UN NUEVO PRODUCTO**********************/
	SELECT @MovimientoId = ISNULL(MAX(MovimientoId),0) + 1
	FROM doc_inv_movimiento

	SELECT @FolioMovimiento = count(*) + 1
	FROM doc_inv_movimiento
	WHERE TipoMovimientoId = 5 AND
	SucursalId = @pSucursalId

	INSERT INTO doc_inv_movimiento(
		MovimientoId,SucursalId,FolioMovimiento,TipoMovimientoId,FechaMovimiento,HoraMovimiento,
		Comentarios,ImporteTotal,Activo,CreadoPor,CreadoEl,
		Autorizado,FechaAutoriza,SucursalDestinoId,AutorizadoPor,FechaCancelacion,
		ProductoCompraId,Consecutivo,SucursalOrigenId,VentaId,MovimientoRefId,
		Cancelado,TipoMermaId
	)
	SELECT TOP 1 @MovimientoId,@pSucursalId,@FolioMovimiento,TipoMovimientoInventario2 ,dbo.fn_GetDateTimeServer(),dbo.fn_GetDateTimeServer(),
	'Movimiento Autom?tico registro sobrantes:' +@UUID,0,1,1,dbo.fn_GetDateTimeServer(),
	1,dbo.fn_GetDateTimeServer(),NULL,1,NULL,
	NULL,@FolioMovimiento,NULL,NULL,NULL,NULL,NULL
	FROM #TMP_SOBRANTES_CONFIG
	WHERE Descripcion1 NOT LIKE '%DESPERDICIO%' AND TipoMovimientoInventario2 IS NOT NULL
	

	SELECT @MovimientoDetalleId = ISNULL(MAX(MovimientoDetalleId),0) + 1
	FROM doc_inv_movimiento_detalle

	INSERT INTO doc_inv_movimiento_detalle(	MovimientoDetalleId,MovimientoId,ProductoId,Consecutivo,Cantidad,PrecioUnitario,Importe,
	Disponible,CreadoPor,CreadoEl,CostoUltimaCompra,CostoPromedio,ValCostoUltimaCompra,ValCostoPromedio,ValorMovimiento,Flete,Comisiones,
	SubTotal,PrecioNeto
	)
	SELECT  ROW_NUMBER() OVER(ORDER BY ProductoSobranteId ASC) +@MovimientoDetalleId,@MovimientoId,ProductoConvertirId,ROW_NUMBER() OVER(ORDER BY ProductoSobranteId ASC),CantidadSobrante,0,0,
	0,1,dbo.fn_GetDateTimeServer(),0,0,0,0,0,0,0,0,0
	FROM #TMP_SOBRANTES_CONFIG
	WHERE Descripcion1  NOT LIKE '%DESPERDICIO%' AND TipoMovimientoInventario2 IS NOT NULL AND CantidadSobrante <> 0

	

	/***********AJUSTAR INVENTARIO DE PRODUCTOS DE MOSTRADOR******************/
	SELECT @Id = ISNULL(MAX(Id),0)
	FROM doc_inventario_captura

	INSERT INTO doc_inventario_captura(Id,		SucursalId,		ProductoId,		Cantidad,		CreadoPor,		CreadoEl,		Cerrado)
	SELECT  ROW_NUMBER() OVER(ORDER BY PSR.ProductoId ASC) + @Id,PSR.SucursalId,PSR.ProductoId,SUM(PSR.CantidadSobrante),@pUsuarioId,DBO.fn_GetDateTimeServer(),0
	FROM doc_productos_sobrantes_registro PSR
	INNER JOIN cat_productos P ON P.ProductoId = PSR.ProductoId AND
							P.ProdVtaBascula = 0
	WHERE PSR.SucursalId = @pSucursalId AND
	CONVERT(VARCHAR,PSR.CreadoEl,112) = CONVERT(VARCHAR,@pFecha,112)
	GROUP BY PSR.SucursalId, PSR.ProductoId

	

	/****DEJAR EN CERO PRODUCTOS******/
	SELECT @Id = isnull(max(id),0) 
	FROM doc_inventario_captura

	INSERT INTO doc_inventario_captura(
	Id,SucursalId,ProductoId,Cantidad,CreadoPor,CreadoEl,Cerrado
	)
	SELECT ROW_NUMBER() OVER(ORDER BY ProductoSobranteId ASC) + @Id,@pSucursalId, PSC.ProductoSobranteId,0,@pUsuarioId,dbo.fn_GetDateTimeServer(),0
	FROM doc_productos_sobrantes_config PSC	
	WHERE ISNULL(DejarEnCero,0) = 1


	EXEC p_inventario_cierre @pSucursalId,@pUsuarioId

	
	
	/*****CERRAR PRODUCTOS SOBRANTES******/
	update doc_productos_sobrantes_registro
	set Cerrado = 1,
		CerradoEl = dbo.fn_GetDateTimeServer(),
		CerradoPor = @pUsuarioId,
		CantidadInventario = isnull(pe.ExistenciaTeorica,0)
	FROM doc_productos_sobrantes_registro PS
	LEFT JOIN cat_productos_existencias PE ON PE.SucursalId = @pSucursalId AND
									PE.ProductoId = PS.ProductoId 								
	WHERE CONVERT(VARCHAR,PS.CreadoEl,112) <= CONVERT(VARCHAR,@pFecha,112) AND
	PS.SucursalId = @pSucursalId AND
	CerradoEl IS NULL

	/***************INSERTAR MOVIMIENTOS DE INVENTARIO RESULTANTES DE ESTE REGISTRO DE SOBRANTES********************/
	SELECT @Id = ISNULL(MAX(Id),0) 
	FROM doc_productos_sobrantes_regitro_inventario	

	INSERT INTO doc_productos_sobrantes_regitro_inventario(
	SobranteRegsitroId,MovimientoDetalleId,CreadoEl	)
	SELECT @RegistroSobranteId,IMD.MovimientoDetalleId,dbo.fn_GetDateTimeServer()
	FROM doc_inv_movimiento IM
	INNER JOIN  doc_inv_movimiento_detalle IMD ON IMD.MovimientoId = IM.MovimientoId AND
											CONVERT(VARCHAR,IM.CreadoEl,112) = CONVERT(VARCHAR,@pFecha,112) AND
											IM.Comentarios LIKE '%'+@UUID+'%'

								
	/********************AJUSTE DE Cantidad Final de inventario en proceso de sobrantes********/
	SELECT MovimientoDetalleId = MAX(md.MovimientoDetalleId),
		MD.ProductoId
	INTO #TMP_MOVIMIENTOS_DETALLE
	FROM doc_inv_movimiento_detalle MD 
	INNER JOIN doc_inv_movimiento M ON M.MovimientoId = MD.MovimientoId
	INNER JOIN doc_productos_sobrantes_registro PSR ON PSR.ProductoId = MD.ProductoId AND
											CONVERT(VARCHAR,PSR.CreadoEl,112) = CONVERT(VARCHAR,@pFecha,112)
	WHERE M.SucursalId = @pSucursalId and
	convert(VARCHAR,m.FechaMovimiento,112) = CONVERT(VARCHAR,@pFecha,112) AND
	MD.CreadoEl < DATEADD(MINUTE,-1,PSR.CerradoEl)
	GROUP BY MD.ProductoId
	
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

	UPDATE doc_productos_sobrantes_registro
	SET CantidadInventario = IMD.Disponible
	FROM doc_productos_sobrantes_registro PSR
	INNER JOIN #TMP_MOVIMIENTOS_DETALLE TMP ON TMP.ProductoId = PSR.ProductoId
	INNER JOIN doc_inv_movimiento_detalle IMD ON IMD.MovimientoDetalleId = TMP.MovimientoDetalleId AND
								IMD.ProductoId = PSR.ProductoId
	WHERE PSR.SucursalId = @pSucursalId AND
	CONVERT(VARCHAR,PSR.CreadoEl,112) = CONVERT(VARCHAR,@pFecha,112)

	/*************ELIMINAR TEMPORALES**********************/
	DROP TABLE #TMP_MOVIMIENTOS_DETALLE

	DROP TABLE #TMP_SOBRANTES_CONFIG

	--COMMIT TRAN

	END TRY
	BEGIN CATCH
		--ROLLBACK TRAN
		SET @pError = CAST(ERROR_LINE() AS VARCHAR) + ERROR_MESSAGE()
		PRINT @pError
	END CATCH


GO
/****** Object:  StoredProcedure [dbo].[p_doc_solicitud_produccion_requerido_grd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_doc_solicitud_produccion_requerido_grd 9
CREATE proc [dbo].[p_doc_solicitud_produccion_requerido_grd]
@pProduccionSolicitudId INT
AS

	SELECT ProductoId = ps.ProductoRequeridoId,
		Clave = p.clave,
		Producto = p.Descripcion,
		UnidadId = u.DescripcionCorta,
		Cantidad  = SUM(ps.Cantidad)
	FROM doc_produccion_solicitud_requerido ps
	INNER JOIN doc_produccion_solicitud_detalle pd on pd.Id = ps.ProduccionSolicitudDetalleId
	INNER JOIN cat_productos p on p.ProductoId = ps.ProductoRequeridoId
	INNER JOIN cat_unidadesmed u on u.Clave = ps.UnidadRequeridaId
	WHERE pd.ProduccionSolicitudId = @pProduccionSolicitudId 
	GROUP BY ps.ProductoRequeridoId,p.clave,p.Descripcion,u.DescripcionCorta

	
GO
/****** Object:  StoredProcedure [dbo].[p_doc_venta_fp_vale_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[p_doc_venta_fp_vale_ins]
@pId	int,
@pVentaId	int,
@pTipoValeId	int,
@pMonto	money,
@pDevolucionId	int
as


	select @pId = isnull(max(id),0) + 1
	from doc_ventas_formas_pago_vale

	insert into doc_ventas_formas_pago_vale(
		Id,		VentaId,		TipoValeId,		Monto,		DevolucionId,
		CreadoEl
	)
	values(
		@pId,		@pVentaId,		@pTipoValeId,		@pMonto,		@pDevolucionId,
		getdate())





GO
/****** Object:  StoredProcedure [dbo].[p_doc_ventas_cancelacion]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_doc_ventas_cancelacion 4,1,'PRUEBA WEB'
CREATE PROC [dbo].[p_doc_ventas_cancelacion]
@pVentaId INT,
@pUsuarioCancelaId INT,
@pMotivoCancelacion varchar(250)
AS


	if exists (
		select 1
		from doc_apartados
		where ventaId = @pVentaId and
		ventaId > 0
	)
	begin
		RAISERROR (15600,-1,-1, '*************NO ES POSIBLE CANCELAR TICKETS DE APARTADOS************');
		return
	end

	if exists (
		select 1
		from doc_corte_caja_ventas cc
		inner join  doc_ventas v on v.ventaId = cc.VentaId
		where v.VentaId = @pVentaId 
	)
	begin 
		RAISERROR (15600,-1,-1, '*************NO ES POSIBLE CANCELAR EL TICKET, YA EST� DENTRO DE UN CORTE************');
		return
	end

	if exists (
		select 1
		from  doc_ventas v 
		inner join doc_devoluciones dev on dev.VentaId = v.ventaid
		where v.VentaId = @pVentaId 
	)
	begin 
		RAISERROR (15600,-1,-1, '*************NO ES POSIBLE CANCELAR EL TICKET, TIENE UNA DEVOLUCI�N************');
		return
	end


	begin tran

	UPDATE dbo.doc_ventas
	SET Activo = 0,
		FechaCancelacion = GETDATE(),
		UsuarioCancelacionId = @pUsuarioCancelaId,
		MotivoCancelacion = @pMotivoCancelacion
	WHERE VentaId = @pVentaId

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	update doc_inv_movimiento 
	set FechaCancelacion = GETDATE(),
		Cancelado = 1
	from doc_inv_movimiento m
	inner join doc_ventas v on v.VentaId = m.VentaId
	where isnull(m.Cancelado,0) = 0 and
	v.VentaId = @pVentaId

	
	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	update doc_web_carrito
	set Pagado = 0,
		FechaPago = null
	where VentaId = @pVentaId

	
	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	commit tran
	fin:





GO
/****** Object:  StoredProcedure [dbo].[p_doc_ventas_rec]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_doc_ventas_rec 4,''
CREATE PROC [dbo].[p_doc_ventas_rec]
@pSucursalId int,
@pError varchar(250)='' out
as

	declare @ventaId_i int,
			@porcRecortado decimal(14,2),
			@montoMaximoRec decimal (14,2),
			@montoRec_i decimal(14,2)=0,
			@lastFolio int,
			@esPrimero bit=1
	SET @pError = ''

	create table #tmpVentasRec( ventaId int)

	SELECT @porcRecortado = ISNULL(MAX(PorcRec),0)
	FROM cat_configuracion

	SELECT DISTINCT v.*
	INTO #tmpVentas
	FROM doc_ventas v
	INNER JOIN doc_ventas_formas_pago vfp on vfp.VentaId = v.VentaId AND
									vfp.FormaPagoId in (1) AND
									vfp.FormaPagoId not in (2,3,4,5)
	WHERE v.SucursalId = @pSucursalId AND
	NOT EXISTS (
		SELECT 1
		FROM doc_corte_caja_ventas CCV WHERE CCV.VentaId = v.VentaId
	)

	select * from #tmpVentas

	
	SELECT @montoMaximoRec =  (SUM(TotalVenta) * (@porcRecortado / 100))
	FROM #tmpVentas
	WHERE Activo = 1	
	

	SELECT @ventaId_i = MAX(VentaId)
	from #tmpVentas
	WHERE Activo = 1



	WHILE @ventaId_i IS NOT NULL
	BEGIN
		
		

		SELECT @montoRec_i = ISNULL(@montoRec_i,0) + ISNULL(TotalVenta,0)
		FROM #tmpVentas
		WHERE VentaId =@ventaId_i 

		IF @montoRec_i <= @montoMaximoRec OR @esPrimero = 1
		BEGIN
			INSERT INTO #tmpVentasRec(ventaId)
			VALUES(@ventaId_i)

			SELECT @ventaId_i = MAX(VentaId)
			FROM #tmpVentas
			WHERE VentaId < @ventaId_i AND
			Activo = 1

		END
		ELSE
		BEGIN
			SET @ventaId_i= NULL
		END

		SET @esPrimero = 0
		
	END

	

	BEGIN TRY

	BEGIN TRAN

	update doc_pedidos_orden
	SET VentaId = NULL,
	Activo = 0
	FROM doc_pedidos_orden PO
	INNER JOIN #tmpVentasRec TMP ON TMP.ventaId = PO.VentaId


	--ELIMINAR INVENTARIO
	DELETE doc_inv_movimiento_detalle
	FROM doc_inv_movimiento_detalle MD
	INNER JOIN doc_inv_movimiento M ON M.MovimientoId = MD.MovimientoId
	INNER JOIN #tmpVentasRec TMP ON TMP.ventaId = M.VentaId

	DELETE doc_inv_movimiento
	FROM doc_inv_movimiento M
	INNER JOIN #tmpVentasRec TMP ON TMP.ventaId = M.VentaId

	--VENTAS PAGOS doc_ventas_pagos
	DELETE doc_ventas_pagos
	FROM doc_ventas_pagos VP
	INNER JOIN #tmpVentasRec TMP ON TMP.ventaId = VP.VentaId


	--doc_ventas_formas_pago
	DELETE doc_ventas_formas_pago
	FROM doc_ventas_formas_pago VFP
	INNER JOIN #tmpVentasRec TMP ON TMP.ventaId = VFP.VentaId

	--doc_ventas_formas_pago_vale
	DELETE doc_ventas_formas_pago_vale
	FROM doc_ventas_formas_pago_vale FPV 
	INNER JOIN #tmpVentasRec TMP ON TMP.VentaId = FPV.VentaId

	--doc_ventas_detalle
	DELETE doc_ventas_detalle
	FROM doc_ventas_detalle VD 
	INNER JOIN #tmpVentasRec TMP ON TMP.VentaId = VD.VentaId

	DELETE doc_ventas
	FROM doc_ventas V
	INNER JOIN #tmpVentasRec TMP ON TMP.VentaId = V.VentaId

	--Refoliar
	SELECT @lastFolio = isnull(MAX(Folio),0)
	FROM doc_ventas V
	WHERE V.VentaId < (SELECT MIN(VentaId) FROM #tmpVentas	) AND
	V.SucursalId = @pSucursalId

	SELECT @ventaId_i = MIN(V.VentaId)
	FROM #tmpVentas TMP
	INNER JOIN doc_ventas V ON V.VentaId = TMP.VentaId

	WHILE @ventaId_i IS NOT NULL
	BEGIN
		
		SET @lastFolio = @lastFolio + 1

		UPDATE doc_ventas
		SET Folio = CAST(@lastFolio AS VARCHAR)
		where VentaId = @ventaId_i

		SELECT @ventaId_i = MIN(V.VentaId)
		FROM #tmpVentas TMP
		INNER JOIN doc_ventas V ON V.VentaId = TMP.VentaId 
		WHERE V.VentaId > @ventaId_i
	END

	COMMIT TRAN

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @pError = 'ERROR p_doc_ventas_rec LINEA:'+ CAST(ERROR_LINE() AS VARCHAR) + ' ' +ERROR_MESSAGE()
	END CATCH
	
	

GO
/****** Object:  StoredProcedure [dbo].[p_doc_ventas_rec_sinc]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_doc_ventas_rec_sinc 1,''
CREATE proc [dbo].[p_doc_ventas_rec_sinc]
@pSucursalId int,
@pError varchar(250)='' out
as

--	ERPJalisco.dbo.doc_apartados: FK_apartados_ventas
--ERPJalisco.dbo.doc_corte_caja: FK_doc_corte_caja_doc_ventas
--ERPJalisco.dbo.doc_corte_caja: FK_doc_corte_caja_doc_ventas1
--ERPJalisco.dbo.doc_devoluciones: FK_doc_devoluciones_doc_ventas1
--ERPJalisco.dbo.doc_devoluciones_detalle: FK_doc_devoluciones_cat_productos
--ERPJalisco.dbo.doc_devoluciones_detalle: FK_doc_devoluciones_doc_ventas
--ERPJalisco.dbo.doc_inv_movimiento: FK__doc_inv_m__Venta__7226EDCC
--ERPJalisco.dbo.doc_inv_movimiento: FK__doc_inv_m__Venta__731B1205
--ERPJalisco.dbo.doc_pedidos_orden: FK_Pedidos_Ventas
--ERPJalisco.dbo.doc_reimpresion_ticket: FK_doc_reimpresion_ticket_doc_ventas
--ERPJalisco.dbo.doc_ventas_detalle: FK_doc_ventas_detalle_doc_ventas
--ERPJalisco.dbo.doc_ventas_formas_pago: FK_doc_ventas_formas_pago_doc_ventas
--ERPJalisco.dbo.doc_web_carrito: FK_Carrito_Ventas

	declare @aplica_rec bit,
		@devolucionId int,
		@devolucionDetalleId int,
		@pedidoOrdenId int,
		@pedidoOrdenDetalleId int,
		@pventaId int,
		@ventaDetalleId int,
		@ventaFPValeId int,
		@ComandaId int

	select @aplica_rec = TieneRec
	from cat_configuracion 

	
	--BEGIN TRAN
	BEGIN TRY  
		
		if(@aplica_rec = 1)
		begin

			delete cat_rec_configuracion_rangos

			insert into cat_rec_configuracion_rangos
			select Id,RangoInicial,RangoFinal,PorcDeclarar,CreadoEl
			from ERPTemp..cat_rec_configuracion_rangos

				insert into ERPTemp..cat_lineas(
			Clave,Descripcion,Estatus,Empresa,Sucursal
			)
			select Clave,Descripcion,Estatus,Empresa,Sucursal
			from cat_lineas a
			where not exists (
				select 1
				from ERPTemp..cat_lineas b
				where b.Clave = a.Clave
			)

		
			insert into ERPTemp..cat_familias(
			Clave,	Descripcion,		Estatus,	Empresa,
			Sucursal,ProductoPortadaId,	Orden
			)
			select Clave,	Descripcion,		Estatus,	Empresa,
			Sucursal,ProductoPortadaId,	Orden
			from cat_familias a
			where not exists (
				select 1
				from ERPTemp..cat_familias b
				where b.Clave = a.Clave
			)


			insert into ERPTemp..cat_subfamilias(
			Clave,Descripcion,Familia,Estatus,Empresa,Sucursal
			)
			select Clave,Descripcion,Familia,Estatus,Empresa,Sucursal
			from cat_subfamilias a
			where not exists (
				select 1
				from ERPTemp..cat_subfamilias b
				where b.Clave = a.Clave
			)

		

			--update doc_ventas
			--set rec = 1
			--from doc_ventas v
			--inner join doc_corte_caja_ventas cc on cc.VentaId = v.VentaId
			--where isnull(rec,0) = 0

			--Sincornizar productos
			insert into ERPTemp..cat_productos(
				ProductoId,		Clave,		Descripcion,	DescripcionCorta,		FechaAlta,		ClaveMarca,
				ClaveFamilia,	ClaveSubFamilia,ClaveLinea,	ClaveUnidadMedida,		ClaveInventariadoPor,ClaveVendidaPor,
				Estatus,		ProductoTerminado,Inventariable,MateriaPrima,		ProdParaVenta,	ProdVtaBascula,
				Seriado,		NumeroDecimales,PorcDescuentoEmpleado,ContenidoCaja,Empresa,		Sucursal,
				Foto,			ClaveAlmacen,ClaveAnden,	ClaveLote,				FechaCaducidad,	MinimoInventario,
				MaximoInventario,PorcUtilidad,Talla,		ParaSexo,				Color,			Color2,
				SobrePedido,	Especificaciones,			Liquidacion
			)
			select ProductoId,		Clave,		Descripcion,	DescripcionCorta,		FechaAlta,		ClaveMarca,
				ClaveFamilia,	ClaveSubFamilia,ClaveLinea,	ClaveUnidadMedida,		ClaveInventariadoPor,ClaveVendidaPor,
				Estatus,		ProductoTerminado,Inventariable,MateriaPrima,		ProdParaVenta,	ProdVtaBascula,
				Seriado,		NumeroDecimales,PorcDescuentoEmpleado,ContenidoCaja,Empresa,		Sucursal,
				Foto,			ClaveAlmacen,ClaveAnden,	ClaveLote,				FechaCaducidad,	MinimoInventario,
				MaximoInventario,PorcUtilidad,Talla,		ParaSexo,				Color,			Color2,
				SobrePedido,	Especificaciones,			Liquidacion
			from cat_productos a
			where not exists(
				select 1
				from ERPTemp..cat_productos b
				where b.ProductoId = a.ProductoId
			)
			

			select @pventaId = isnull(max(VentaId ),0)
			from ERPTemp..doc_ventas

			/***Crear relaci�n antes de sincronizar****/
			INSERT INTO doc_ventas_temp(
				VentaId,VentaTempId,CreadoEl
			)
			select v.VentaId, ROW_NUMBER() OVER(ORDER BY v.VentaId ASC) + @pventaId,GETDATE()
			from doc_ventas v
			where isnull(v.Rec,0) = 0
			order by v.VentaId asc

			

			--VENTAS
			insert into ERPTemp..doc_ventas(
				VentaId,		Folio,			Fecha,			ClienteId,		DescuentoVentaSiNo,			PorcDescuentoVenta,
				MontoDescuentoVenta,DescuentoEnPartidas,TotalDescuento,			Impuestos,					SubTotal,
				TotalVenta,TotalRecibido,		Cambio,			Activo,			UsuarioCreacionId,			FechaCreacion,
				UsuarioCancelacionId,FechaCancelacion,SucursalId,CajaId,		Serie,						MotivoCancelacion,
				Rec
			)
			select ROW_NUMBER() OVER(ORDER BY VentaId ASC) + @pventaId,Folio,			Fecha,			ClienteId,		DescuentoVentaSiNo,			PorcDescuentoVenta,
				MontoDescuentoVenta,DescuentoEnPartidas,TotalDescuento,			Impuestos,					SubTotal,
				TotalVenta,TotalRecibido,		Cambio,			Activo,			UsuarioCreacionId,			FechaCreacion,
				UsuarioCancelacionId,FechaCancelacion,SucursalId,CajaId,		Serie,						MotivoCancelacion,
				Rec
			from doc_ventas v
			where isnull(v.Rec,0) = 0

			--VENTAS DETALLE
			select @ventaDetalleId= isnull(max(VentaDetalleId ),0)
			from ERPTemp..doc_ventas_detalle

			insert into ERPTemp..doc_ventas_detalle(
				VentaDetalleId,		VentaId,		ProductoId,		Cantidad,		PrecioUnitario,
				PorcDescuneto,		Descuento,		Impuestos,		Total,			UsuarioCreacionId,
				FechaCreacion,		TasaIVA
			)
			select ROW_NUMBER() OVER(ORDER BY VentaDetalleId ASC)  + @ventaDetalleId,vtemp.VentaTempId,ProductoId,		Cantidad,		PrecioUnitario,
				PorcDescuneto,		Descuento,		Impuestos,		Total,			UsuarioCreacionId,
				FechaCreacion,		TasaIVA
			from doc_ventas_detalle vd 
			inner join doc_ventas_temp vtemp on vtemp.ventaId = vd.VentaId

			--VENTAS FORMAS DE PAGO
			INSERT INTO ERPTemp..[doc_ventas_formas_pago](
				FormaPagoId,VentaId,Cantidad,FechaCreacion,UsuarioCreacionId,digitoVerificador
			)
			SELECT FormaPagoId,vtemp.VentaTempId,Cantidad,FechaCreacion,UsuarioCreacionId,digitoVerificador
			FROM [doc_ventas_formas_pago] FP
			inner join doc_ventas_temp vtemp on vtemp.ventaId = FP.VentaId
			where not exists (
				select 1
				from  ERPTemp..[doc_ventas_formas_pago] st
				where st.FormaPagoId = FP.FormaPagoId and
				VentaId = vtemp.VentaTempId
			)
			

			--VENTAS FORMAS PAGO VALE

			select @ventaFPValeId = isnull(max(Id),0)
			from ERPTemp..[doc_ventas_formas_pago_vale]

			INSERT INTO ERPTemp..[doc_ventas_formas_pago_vale](
				Id,VentaId,TipoValeId,Monto,DevolucionId,CreadoEl
			)
			select ROW_NUMBER() OVER(ORDER BY Id ASC) + @ventaFPValeId,VentaTempId,TipoValeId,Monto,DevolucionId,A.CreadoEl
			from [doc_ventas_formas_pago_vale] a
			inner join doc_ventas_temp vtemp on vtemp.ventaId = a.VentaId


			--DEVOLUCIONES
			select @devolucionId = isnull(max(devolucionId),0)
			from ERPTemp..doc_devoluciones


			insert into ERPTemp..doc_devoluciones(
				DevolucionId,	VentaId,			Total,	CreadoEl,
				CreadoPor,		TipoDevolucionId,	FechaVencimiento
			)
			select DevolucionId + @devolucionId,	dev.VentaId,			Total,	CreadoEl,
				CreadoPor,		TipoDevolucionId,	FechaVencimiento
			from doc_devoluciones dev
			inner join doc_ventas  v on v.VentaId = dev.VentaId
			where isnull(v.Rec,0) = 0
			order by DevolucionId

			--Sincornizar Devoluciones Detalle
			select @devolucionDetalleId = isnull(max(DevolucionDetId),0)
			from ERPTemp..doc_devoluciones_Detalle


			insert into ERPTemp..doc_devoluciones_Detalle(DevolucionDetId,DevolucionId,VentaId,ProductoId,Cantidad,
			Total,CreadoEl,CreadoPor)
			select ROW_NUMBER() OVER(ORDER BY DevolucionDetId ASC) + @devolucionDetalleId,dev.DevolucionId + @devolucionId,dev.VentaId,
			dd.ProductoId,dd.Cantidad,dd.Total,GETDATE(),dd.CreadoPor
			from doc_devoluciones dev
			inner join doc_ventas  v on v.VentaId = dev.VentaId
			inner join doc_devoluciones_detalle dd on dd.DevolucionId = dev.DevolucionId
			where isnull(v.Rec,0) = 0
			order by DevolucionDetId asc

			insert into ERPTemp..cat_rest_mesas(
				MesaId,SucursalId,Nombre,Descripcion,Activo,CreadoEl,
				CreadoPor,ModificadoEl,ModificadoPor
			)
			select MesaId,SucursalId,Nombre,Descripcion,Activo,CreadoEl,
				CreadoPor,ModificadoEl,ModificadoPor
			from cat_rest_mesas a
			where not exists (
				select 1
				from ERPTemp..cat_rest_mesas b
				where  a.MesaId = b.MesaId
			)

			insert into ERPTemp..cat_rest_comandas(
				ComandaId,SucursalId,Folio,Disponible,CreadoPor,CreadoEl
			)
			select ComandaId,SucursalId,Folio,Disponible,CreadoPor,CreadoEl
			from cat_rest_comandas a
			where not exists (
				select 1
				from ERPTemp..cat_rest_comandas b
				where a.ComandaId = b.ComandaId
			)


			--SINCRONIZAR 
			select @pedidoOrdenId = isnull(max(PedidoId),0)
			from ERPTemp..doc_pedidos_orden

			insert into  ERPTemp..doc_pedidos_orden(
				PedidoId,SucursalId,ComandaId,PorcDescuento,Subtotal,Descuento,Impuestos,Total,
				ClienteId,MotivoCancelacion,Activo,CreadoEl,CreadoPor,Personas,FechaApertura,FechaCierre,
				VentaId,Cancelada,FechaCancelacion,CanceladoPor
			)
			select dev.PedidoId + @pedidoOrdenId,dev.SucursalId,dev.ComandaId,dev.PorcDescuento,dev.Subtotal,dev.Descuento,
			dev.Impuestos,dev.Total,dev.ClienteId,dev.MotivoCancelacion,dev.Activo,dev.CreadoEl,
			dev.CreadoPor,dev.Personas,dev.FechaApertura,dev.FechaCierre,dev.VentaId,dev.Cancelada,
			dev.FechaCancelacion,dev.CanceladoPor
			from doc_pedidos_orden dev
			inner join doc_ventas v on v.VentaId = dev.VentaId
			where isnull(v.Rec,0) = 0
			order by dev.PedidoId asc

			select @pedidoOrdenDetalleId = isnull(max(PedidoDetalleId),0)
			from ERPTemp..doc_pedidos_orden_detalle


			insert into  ERPTemp..doc_pedidos_orden_detalle(
				PedidoDetalleId,PedidoId,ProductoId,Cantidad,PrecioUnitario,
				PorcDescuento,Descuento,Impuestos,Notas,Total,
				CreadoPor,CreadoEl,TasaIVA,Impreso,ComandaId,
				Parallevar,Cancelado
			)
			select ROW_NUMBER() OVER(ORDER BY PedidoDetalleId ASC) + @pedidoOrdenDetalleId,dev.PedidoId + @pedidoOrdenId,pod.ProductoId,pod.Cantidad,
				pod.PrecioUnitario,	pod.PorcDescuento,pod.Descuento,pod.Impuestos,pod.Notas,pod.Total,
				pod.CreadoPor,pod.CreadoEl,pod.TasaIVA,pod.Impreso,pod.ComandaId,
				Parallevar,Cancelado
			from doc_pedidos_orden dev
			inner join doc_ventas v on v.VentaId = dev.VentaId
			inner join doc_pedidos_orden_detalle pod on pod.PedidoId = dev.PedidoId
			where isnull(v.Rec,0) = 0
			order by dev.PedidoId asc

			insert into ERPTemp..[doc_pedidos_orden_mesa](
				PedidoOrdenId,MesaId,CreadoEl
			)
			select pm.PedidoOrdenId +  @pedidoOrdenId,pm.MesaId,pm.CreadoEl
			from [doc_pedidos_orden_mesa] pm
			inner join doc_pedidos_orden dev on dev.PedidoId = pm.PedidoOrdenId
			inner join doc_ventas v on v.VentaId = dev.VentaId
			where isnull(v.Rec,0) = 0
			order by dev.PedidoId asc


			insert into ERPTemp..[doc_pedidos_orden_mesero](
				PedidoOrdenId,EmpleadoId,CreadoEl
			)
			select pom.PedidoOrdenId + @pedidoOrdenId,pom.EmpleadoId,pom.CreadoEl
			from [doc_pedidos_orden_mesero] pom 
			inner join doc_pedidos_orden dev on dev.PedidoId = pom.PedidoOrdenId
			inner join doc_ventas v on v.VentaId = dev.VentaId
			where isnull(v.Rec,0) = 0
			order by dev.PedidoId asc


			

		end

		--ROLLBACK TRAN
	END TRY  
	BEGIN CATCH  
		--ROLLBACK TRAN
		set @pError = 'Ocurrió un error al sincronizar tablas' + ERROR_MESSAGE()
	END CATCH;  

GO
/****** Object:  StoredProcedure [dbo].[p_doc_web_carrito_detalle_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[p_doc_web_carrito_detalle_ins]
@pId int,
@pIdDetalle	int out,
@puUID	varchar(50),
@pProductoId	int,
@pCantidad	decimal(10,2),
@pDescripcion	varchar(250),
@pPrecioUnitario	money,
@pImporte	money,
@pCargoDetalleId int
as

	begin Tran

	declare @impuestos money=0,
			@porcImpuestos decimal(5,2)=0,
			@precioUnitario money,
			@subtotal money=0


	select @porcImpuestos = isnull(sum(isnull(Porcentaje,0)),0)
	from cat_productos_impuestos p
	inner join cat_impuestos i on i.Clave = p.ImpuestoId
	where ProductoId = @pProductoId

	if(isnull(@pCargoDetalleId,0) =0)
	begin

		select @pPrecioUnitario = pp.Precio
		from cat_productos p
		inner join cat_productos_precios pp on pp.IdProducto = p.ProductoId
		where p.ProductoId = @pProductoId and
		pp.IdPrecio = 1--venta
	end
	set @pImporte = @pPrecioUnitario * @pCantidad


	if(@porcImpuestos > 0)
	begin
		set @impuestos = @pImporte / (1+(@porcImpuestos/100))
	end

	set @subtotal = @pImporte-@impuestos



	

	select @pIdDetalle = isnull(max(IdDetalle),0) + 1
	from doc_web_carrito_detalle

	insert into [dbo].[doc_web_carrito_detalle](
		IdDetalle,		uUID,			ProductoId,		Cantidad,
		Descripcion,	PrecioUnitario,	Importe,		CreadoEl,
		Impuestos,		Subtotal,Id,CargoDetalleId
	)
	values(
		@pIdDetalle,	@puUID,			@pProductoId,	@pCantidad,
		@pDescripcion,	@pPrecioUnitario,@pImporte,		getdate(),
		@Impuestos,		@Subtotal,@pId,@pCargoDetalleId
	)

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	--Actualizar totales
	update doc_web_carrito
	set Total = (select sum(importe) from [doc_web_carrito_detalle] where uUID = @puUID),
		SubTotal = (select sum(Subtotal) from [doc_web_carrito_detalle] where uUID = @puUID),
		Impuestos = (select sum(Impuestos) from [doc_web_carrito_detalle] where uUID = @puUID)
	where uUID = @puUID


	if @@error <> 0
	begin
		rollback tran
		goto fin
	end


	commit tran

	fin:


GO
/****** Object:  StoredProcedure [dbo].[p_doc_web_carrito_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[p_doc_web_carrito_ins]
@puUID	varchar(50),
@pid	int out,
@pEmail	varchar(50),
@pTotal	money,
@pEnvioCalle	varchar(250),
@pEnvioColonia	varchar(100),
@pEnvioCiudad	varchar(70),
@pEnvioEstadoId	int,
@pEnvioCP	varchar(5),
@pEnvioPersonaRecibe	varchar(250),
@pEnvioTelefonoContacto	varchar(20),
@pClienteId int out,
@pFechaEstimadaEntrega DateTime

as

	set @pEnvioEstadoId = case when @pEnvioEstadoId = 0 then null else @pEnvioEstadoId end
	
	select @pid = case when isnull(max(id),0)  <= 100 then 1000 
					else isnull(max(id),0)  +1
					end
	from doc_web_carrito

	

	begin tran
	
	insert into [dbo].[doc_web_carrito](
		/*Id,*/
		uUID,						Email,		Total,			CreadoEl,
		EnvioCalle,	EnvioColonia,	EnvioCiudad,EnvioEstadoId,	EnvioCP,
		EnvioPersonaRecibe,EnvioTelefonoContacto,
		FechaEstimadaEntrega
	)
	values(
		/*@pid,*/
		@puUID,						@pEmail,		@pTotal,			getdate(),
		@pEnvioCalle,		@pEnvioColonia,			@pEnvioCiudad,		isnull(@pEnvioEstadoId,11),	@pEnvioCP,
		@pEnvioPersonaRecibe,@pEnvioTelefonoContacto,
		@pFechaEstimadaEntrega
	)

	set @pid = SCOPE_IDENTITY() 
	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	/****Generar un cliente*****/

	select @pClienteId = isnull(ClienteId,0)
	from cat_clientes_web
	where lower(rtrim(email)) = lower(rtrim(@pEmail))

	if @pClienteId = 0
	Begin
		/****Generar un id de cliente*******/

		select @pClienteId = isnull(max(ClienteId),0)+ 1
		from cat_clientes

		insert into cat_clientes(ClienteId,Nombre,Activo,Telefono )	
		values(@pClienteId,@pEmail,1,@pEnvioTelefonoContacto)

		if @@error <> 0
		begin
			rollback tran
			goto fin
		end

		insert into cat_clientes_web(ClienteId,Email,Password,CreadoEl)
		values(@pClienteId,@pEmail,'1234',getdate())

		if @@error <> 0
		begin
			rollback tran
			goto fin
		end

	End

	if @pClienteId > 0
	begin

		declare @ClienteDireccionId int

		select @ClienteDireccionId = isnull(ClienteDireccionId,0)
		from cat_clientes_direcciones 
		where ClienteId = @pClienteId and
		CodigoPostal = @pEnvioCP

		if(isnull(@ClienteDireccionId,0) = 0)
		begin
			select @ClienteDireccionId = isnull(max(ClienteDireccionId),0) +1

			from cat_clientes_direcciones
			--Generar Direcci�n
			insert into cat_clientes_direcciones(
				ClienteDireccionId,	ClienteId,	TipoDireccionId,	Calle,
				NumeroInterior,	NumeroExterior,	Colonia,			Ciudad,
				EstadoId,		PaisId,			CodigoPostal,		CreadoEl
			)
			select @ClienteDireccionId,@pClienteId,1,				@pEnvioCalle,
			'',					'',				@pEnvioColonia,		@pEnvioCiudad,
			isnull(@pEnvioEstadoId,11),	1,				@pEnvioCP,			getdate()
		end
		Else
		Begin

			update cat_clientes_direcciones
			set Calle = @pEnvioCalle,
				Colonia = @pEnvioColonia,
				Ciudad = @pEnvioCiudad,
				EstadoId = isnull(@pEnvioEstadoId,11),
				CodigoPostal = @pEnvioCP
			where ClienteDireccionId = @ClienteDireccionId
		End	


		
		if @@error <> 0
		begin
				rollback tran
				goto fin
		end
	end

	
	update [doc_web_carrito]
	set clienteId = @pClienteId
	where uUID = @puUID

	if @@error <> 0
	begin
			rollback tran
			goto fin
	end
	
	
	 
	/*from doc_web_carrito
	where uUID = @puUID*/

	commit tran


	fin:





GO
/****** Object:  StoredProcedure [dbo].[p_doc_web_carrito_pagar]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[p_doc_web_carrito_pagar]
@pSucursalId int,
@pId int,
@pTransactionRef varchar(30),
@pMontoPagado varchar(20),
@pFormaPagoId tinyint
as

	declare @FechaEstimadaEntrega datetime
	declare @diasPedido tinyint=0
	declare @diasAdicPedido tinyint=0

	select @FechaEstimadaEntrega = GETDATE();

	select @diasAdicPedido = DiasEntregaAdicSPedido,
			@diasPedido = DiasEntregaPedido
	from cat_web_configuracion
	where SucursalId = @pSucursalId

	set @FechaEstimadaEntrega = DATEADD(day,@diasPedido,@FechaEstimadaEntrega)

	if exists (
		select 1
		from doc_web_carrito_detalle d
		inner join cat_productos prod on prod.ProductoId = d.ProductoId
		inner join cat_productos_existencias pe on pe.ProductoId = prod.ProductoId and
											pe.SucursalId = @pSucursalId and
											pe.ExistenciaTeorica <= 0 
		where d.Id = @pId 
	)
	begin
		set @FechaEstimadaEntrega = DATEADD(day,@diasAdicPedido,@FechaEstimadaEntrega)
	end

	update doc_web_carrito
	set Pagado = 1,
		FechaPago = GETDATE(),
		TransactionRef = @pTransactionRef,
		MontoPaypal = @pMontoPagado,
		FechaEstimadaEntrega = @FechaEstimadaEntrega,
		FormaPagoId = @pFormaPagoId
	where id = @pId
GO
/****** Object:  StoredProcedure [dbo].[p_dov_ventas_rec]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[p_dov_ventas_rec]
@pSucursalId int,
@pError varchar(250)=''
as

		declare @aplica_rec bit,
			@porc_rec decimal(5,2),
			@fechaInicioRec datetime,
			@ventaIni int,@ventaFin int,
			@totalMaxRec money,
			@folio_new varchar(5),
			@serie_new varchar(5)


	

	create table #tmpVentasRec
	(
		VentaId int,
		Total money
	)

	select @aplica_rec = TieneRec,
		@porc_rec = PorcRec
	from cat_configuracion 
	

	if(
		isnull(@aplica_rec,0) = 1 and
		isnull(@porc_rec,0) > 0
	)
	begin

		BEGIN TRY

			

			BEGIN TRANSACTION


			--Sincornizar info con temp
			exec p_doc_ventas_rec_sinc @pSucursalId,@pError out

			select @fechaInicioRec = max(FechaCorte)
			from doc_corte_caja cc
			inner join  cat_cajas c on c.Clave = cc.CajaId
			where c.Sucursal = @pSucursalId

			select v.VentaId,v.TotalVenta, rec = cast(0 as bit),v.Activo,v.FechaCancelacion
			into #tmpVentasTot
			from doc_ventas v
			where SucursalId = @pSucursalId and
			v.FechaCreacion >= @fechaInicioRec and
			isnull(v.Rec,0) = 0

			select @totalMaxRec = sum(TotalVenta) * (@porc_rec / 100)
			from #tmpVentasRec
			where activo = 1 and
			fechacancelacion is null


			select @ventaFin = max(VentaId)
			from #tmpVentasTot

			while @ventaFin is not null
			begin
				declare @total_i money,
					@totalVenta_i money
			
				if exists(
					select 1
					from doc_ventas v
					inner join doc_ventas_formas_pago vfp on vfp.VentaId = v.VentaId and
																vfp.FormaPagoId = 1 --EFECTIVO
					left join doc_ventas_formas_pago vfp2 on vfp2.VentaId = v.VentaId and
																vfp2.FormaPagoId <> 1
					where v.VentaId = @ventaFin and
					v.Activo = 1 and
					v.FechaCancelacion is null and
					isnull(v.Impuestos,0) > 0 and
					vfp2.VentaId is null
				)
				begin

					select @total_i = isnull(sum(tmp.Total),0) 
					from #tmpVentasRec tmp
				

					select @totalVenta_i = isnull(TotalVenta,0)
					from #tmpVentasTot tmp2 
					where tmp2.VentaId = @ventaFin

					if((@total_i + @totalVenta_i) < @totalMaxRec)
					begin

						insert into #tmpVentasRec
						select @ventaFin,@totalVenta_i
					end
				
				end


				select @ventaFin = max(VentaId)
				from #tmpVentasTot
				where VentaId < @ventaFin

			end

			--Desligar las ventas a recortar del inventario
			update doc_inv_movimiento
			set VentaId = null
			from doc_inv_movimiento m
			inner join #tmpVentasRec tmp on tmp.VentaId = m.VentaId

			--MArcar las ventas como rec
			update doc_ventas
			set rec=1
			where isnull(rec,0)= 0

			--BORRAR DOC_VEN
			delete [doc_ventas_temp]
			from [doc_ventas_temp] a
			inner join #tmpVentasRec b on b.VentaId = a.VentaId
			where a.VentaId = @ventaFin

			delete [doc_ventas_formas_pago_vale]
			from [doc_ventas_formas_pago_vale] a
			inner join #tmpVentasRec b on b.VentaId = a.VentaId
			where a.VentaId = @ventaFin

			delete [doc_ventas_formas_pago]
			from [doc_ventas_formas_pago]  a
			inner join #tmpVentasRec b on b.VentaId = a.VentaId
			where a.VentaId = @ventaFin
			
			delete [doc_ventas_detalle]
			from [doc_ventas_detalle] a
			inner join #tmpVentasRec b on b.VentaId = a.VentaId

			delete [doc_ventas]
			from [doc_ventas] a
			inner join #tmpVentasRec b on b.VentaId = a.VentaId

			select @serie_new = Serie,
				@folio_new = Folio
			from doc_ventas
			where ventaId = (
				select min(VentaId)
				from #tmpVentasTot
			)

			select tmp1.VentaId,
			Folio = ROW_NUMBER() OVER(PARTITION BY tmp1.VentaId ORDER BY name ASC) + cast(@folio_new as int)
			into #tmpVentasFolios
			from #tmpVentasTot tmp1
			inner join doc_ventas v on v.VentaId = tmp1.VentaId

			update doc_ventas
			set Folio = f.Folio
			from doc_ventas v
			inner join #tmpVentasTot tmp1 on tmp1.VentaId = v.VentaId
			inner join #tmpVentasFolios f on f.VentaId = v.VentaId




			COMMIT

		END TRY  
		BEGIN CATCH  
			 ROLLBACK
			set @pError = 'Ocurrió un error al realizar rec tablas'
		END CATCH;  

	end
GO
/****** Object:  StoredProcedure [dbo].[p_dpc_gastos_pivot_rpt]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_dpc_gastos_pivot_rpt]
@pSucursalId INT,
@pDel DATETIME,
@pAl DATETIME
AS

	SELECT Sucursal = S.NombreSucursal
	FROM doc_gastos G
	INNER JOIN cat_sucursales S ON S.Clave = G.SucursalId
	WHERE G.SucursalId = @pSucursalId AND
	G.Activo = 1
GO
/****** Object:  StoredProcedure [dbo].[p_empleados_productos_descuentos_grd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_empleados_productos_descuentos_grd]
@pEmpleadoId INT
as

	SELECT 
			PD.Id,
			ClaveProducto = P.Clave,
			Producto = P.DescripcionCorta,
			MontoDescuento = PD.MontoDescuento,
			Precio = PP.Precio,
			PrecioDescuento = PP.Precio - ISNULL(PD.MontoDescuento,0),
			p.ProductoId
	FROM  doc_empleados_productos_descuentos PD
	INNER JOIN cat_productos P ON P.ProductoId = PD.ProductoId
	INNER JOIN cat_productos_precios PP ON PP.IdProducto = P.ProductoId AND
										PP.IdPrecio = 1--Publico en General
	--WHERE EmpleadoId = @pEmpleadoId 
GO
/****** Object:  StoredProcedure [dbo].[p_GetDateTimeServer]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[p_GetDateTimeServer]
as
	select FechaServidor=DATEADD(HOUR,2,getdate())





GO
/****** Object:  StoredProcedure [dbo].[p_InsertarVenta]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[p_InsertarVenta]
@pVentaId	BIGINT out,
@pFolio	varchar(20),
@pFecha	datetime,
@pClienteId	int,
@pDescuentoVentaSiNo	bit,
@pPorcDescuentoVenta	decimal(5,2),
@pMontoDescuentoVenta	money,
@pDescuentoEnPartidas	money,
@pTotalDescuento	money,
@pImpuestos	money,
@pSubTotal	money,
@pTotalVenta	money,
@pTotalRecibido MONEY,
@pCambio MONEY,
@pActivo	bit,
@pUsuarioCreacionId	int,
@pFechaCreacion	datetime,
@pUsuarioCancelacionId	int,
@pFechaCancelacion	datetime,
@pSucursalId int,
@pCajaId int,
@pPedidoId int,
@pFacturar BIT,
@pEmpleadoId INT=NULL
AS

 SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

	declare @serie varchar(5) = ''

	select @serie = isnull(Serie,'')
	from [dbo].[cat_configuracion_ticket_venta]
	where sucursalId = @pSucursalId


	

	select @pFolio = isnull(max(CAST(Folio AS int)),0) + 1
	from doc_ventas 
	where Serie = @serie

	
	SELECT @pVentaId = ISNULL(MAX(VentaId),0) + 1
	FROM [doc_ventas]
		

		INSERT INTO [dbo].[doc_ventas](
			VentaId,
			Folio,
			Fecha,
			ClienteId,
			DescuentoVentaSiNo,
			PorcDescuentoVenta,
			MontoDescuentoVenta,
			DescuentoEnPartidas,
			TotalDescuento,
			Impuestos,
			SubTotal,
			TotalVenta,
			TotalRecibido,
			Cambio,
			Activo,
			UsuarioCreacionId,
			FechaCreacion,
			UsuarioCancelacionId,
			FechaCancelacion,
			SucursalId,
			CajaId,
			Serie,
			Facturar,
			EmpleadoId
		)
		VALUES( @pVentaId,
			@pFolio,
			dbo.fn_GetDateTimeServer(),
			@pClienteId,
			@pDescuentoVentaSiNo,
			@pPorcDescuentoVenta,
			@pMontoDescuentoVenta,
			@pDescuentoEnPartidas,
			@pTotalDescuento,
			@pImpuestos,
			@pSubTotal,
			@pTotalVenta,
			@pTotalRecibido,
			@pCambio,
			@pActivo,
			@pUsuarioCreacionId,
			dbo.fn_GetDateTimeServer(),
			@pUsuarioCancelacionId,
			@pFechaCancelacion,
			@pSucursalId,
			@pCajaId,
			@serie,
			@pFacturar,
			@pEmpleadoId
			)



			update doc_pedidos_orden
			set VentaId = @pVentaId,
				Activo = 0
			where PedidoId = @pPedidoId






GO
/****** Object:  StoredProcedure [dbo].[p_InsertarVentaDetalle]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROC [dbo].[p_InsertarVentaDetalle]
@pVentaDetalleId bigint,
@pVentaId bigint,
@pProductoId int,
@pCantidad decimal(16,5) ,
@pDescripcion varchar(60),
@pPrecioUnitario money,
@pPorcDescuneto decimal(5,2),
@pDescuento money,
@pImpuestos money,
@pTotal money,
@pUsuarioCreacionId int,
@pFechaCreacion datetime,
@pTipoDescuentoId int,
@pPromocionCMId int,
@pCargoAdicionalId int,
@pCargoDetalleId int,
@pParaLlevar BIT,
@pParaMesa BIT
AS

	 SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

	declare @tasaIVA decimal(5,2),
			@subtotal money

	set @pPromocionCMId = case when @pPromocionCMId = 0 then null else @pPromocionCMId end

	---ASEGURARSE DE NO ENVIAR DECIMALES PARA PRODUCTOS QUE NO USEN BASCULA
	if EXISTS(
		SELECT 1
		FROM cat_productos P
		WHERE P.ProductoId = @pProductoId and
		ISNULL(P.ProdVtaBascula,0) = 0
	)
	BEGIN
		SET @pCantidad = CAST(@pCantidad AS INT)
		set @pTotal = CAST(@pCantidad AS INT) * @pPrecioUnitario
	END

	select @tasaIVA = sum(i.Porcentaje)
	from [dbo].[cat_productos_impuestos] p
	inner join cat_impuestos i on i.Clave = p.ImpuestoId
	where p.ProductoId = @pProductoId and
	i.Clave = 1

	if(isnull(@tasaIVA,0) > 0)
	begin 
		
		set @pImpuestos = @pTotal * (@tasaIVA/100)
		set @subtotal = @pTotal - @pImpuestos
		
	end





	SELECT @pVentaDetalleId = ISNULL(MAX(VentaDetalleId),0) + 1
	FROM doc_ventas_detalle

	

	INSERT INTO dbo.doc_ventas_detalle
	(
	    VentaDetalleId,
	    VentaId,
	    ProductoId,
	    Cantidad,
	    PrecioUnitario,
	    PorcDescuneto,
	    Descuento,
	    Impuestos,
	    Total,
	    UsuarioCreacionId,
	    FechaCreacion,
		TasaIVA,
		TipoDescuentoId,
		PromocionCMId,
		CargoAdicionalId,
		CargoDetalleId,
		Descripcion,
		ParaLlevar,
		ParaMesa
	)
	VALUES
	(	@pVentaDetalleId	,        -- VentaDetalleId - bigint
	    @pVentaId,        -- VentaId - bigint
	    @pProductoId,        -- ProductoId - int
	    @pCantidad,     -- Cantidad - decimal(14, 3)
	    @pPrecioUnitario,     -- PrecioUnitario - money
	    @pPorcDescuneto,     -- PorcDescuneto - decimal(5, 2)
	    @pDescuento,     -- Descuento - money
	    @pImpuestos,     -- Impuestos - money
	    @pTotal,     -- Total - money
	    @pUsuarioCreacionId,        -- UsuarioCreacionId - int
	    dbo.fn_GetDateTimeServer(), -- FechaCreacion - datetime
		@tasaIVA,
		case when @pTipoDescuentoId = 0 then null else @pTipoDescuentoId end,
		@pPromocionCMId,
		@pCargoAdicionalId,
		@pCargoDetalleId,
		@pDescripcion,
		@pParaLlevar,
		@pParaMesa
	    )


	

	update doc_ventas_detalle
	set Descuento = (PrecioUnitario * Cantidad) - Total
	where VentaDetalleId = @pVentaDetalleId

	
	

	update doc_ventas
	set TotalDescuento =(select sum(case when s1.ProductoId = 0 /*promociones*/ then (s1.Total*-1) else s1.Descuento end ) from doc_ventas_detalle s1 where s1.VentaId = @pVentaId )
	where ventaId = @pVentaId


	update doc_ventas
	set Impuestos =(select sum(s1.Impuestos) from doc_ventas_detalle s1 where s1.VentaId = @pVentaId )
	where ventaId = @pVentaId

	

	update doc_ventas
	set TotalVenta =(select sum(Total) from doc_ventas_detalle s1 where s1.VentaId = @pVentaId )
	where ventaId = @pVentaId

	

	update doc_ventas
	set SubTotal =TotalVenta - isnull(Impuestos,0)
	where ventaId = @pVentaId

	



	
	












GO
/****** Object:  StoredProcedure [dbo].[p_InsertarVentaFormaPago]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[p_InsertarVentaFormaPago]
@pFormaPagoId int,
@pVentaId bigint,
@pCantidad money,		
@pUsuarioCreacionId INT,
@pDigitoVerificador VARCHAR(20)
AS

	SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

	declare @cambio money

	select @cambio = isnull(cambio,0)
	from doc_ventas
	where  ventaid = @pVentaId

	if(@pformapagoid = 1)
		set @pCantidad = @pCantidad - @cambio

	INSERT INTO [dbo].[doc_ventas_formas_pago](
		FormaPagoId,
		VentaId,
		Cantidad,
		FechaCreacion,
		UsuarioCreacionId,
		digitoVerificador
	)
	VALUES(
	@pFormaPagoId,
		@pVentaId,
		@pCantidad,
		GETDATE(),
		@pUsuarioCreacionId,
		@pDigitoVerificador
	)






GO
/****** Object:  StoredProcedure [dbo].[p_inv_carga_inicia_cancel_inv]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[p_inv_carga_inicia_cancel_inv]
@pCargaInventarioId int
as


	begin tran

	update [dbo].[doc_inv_movimiento]
	set --Activo = 1,
		FechaCancelacion = getdate(),
		Cancelado = 1
	from [doc_inv_movimiento] mov
	inner join [doc_inv_movimiento_detalle] movD on movD.MovimientoId = mov.MovimientoId
	inner join [doc_inv_carga_inicial] ci on ci.ProductoId = movD.ProductoId and
											ci.SucursalId = mov.SucursalId 
	where ci.CargaInventarioId = @pCargaInventarioId and
	mov.TipoMovimientoId = 1 --CARGA INICIAL

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	delete [dbo].[doc_inv_carga_inicial]
	where CargaInventarioId = @pCargaInventarioId

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	commit tran

	fin:
											







GO
/****** Object:  StoredProcedure [dbo].[p_inv_carga_inicial_cancel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_inv_carga_inicial_cancel]
@pCargaInventarioId int
as

	delete [dbo].[doc_inv_carga_inicial]
	where CargaInventarioId = @pCargaInventarioId





GO
/****** Object:  StoredProcedure [dbo].[p_inv_carga_inicial_grd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_inv_carga_inicial_grd 1,1,2,0
CREATE Proc [dbo].[p_inv_carga_inicial_grd]
@pSucursaldId int,
@pFamiliaId int,
@pSubFamiliaId int,
@pVerListadoGeneral bit
as

	select 
		ci.CargaInventarioId,
		p.Clave,
		p.ProductoId,
		p.Descripcion,
		CostoPromedio = isnull(ci.CostoPromedio,0),
		UltimoCosto = isnull(ci.UltimoCosto,0),
		InventarioFisico = isnull(ci.Cantidad,0),
		TieneCargaInicial = cast(case when max(md.ProductoId) > 0 then 1 else 0 end as bit) 
	from [dbo].cat_productos p
	left join doc_inv_carga_inicial ci on ci.ProductoId = p.ProductoId and @pSucursaldId = ci.SucursalId
	left join doc_inv_movimiento m on m.SucursalId = @pSucursaldId and
							m.TipoMovimientoId = 1 and
							m.Autorizado = 1 and
							m.Activo = 1 --Carga Inicial
	left join doc_inv_movimiento_detalle md on md.MovimientoId  = m.MovimientoId and
									md.ProductoId = ci.ProductoId
										
	where p.ProductoId > 0 AND
	(
		(
			@pFamiliaId in( p.ClaveFamilia , 0)
			and @pSubFamiliaId in (p.ClaveSubFamilia ,0)
		)
		OR
		@pVerListadoGeneral = 1
	)
	GROUP BY ci.CargaInventarioId,
		p.Clave,
		p.ProductoId,
		p.Descripcion,
		ci.CostoPromedio,
		ci.UltimoCosto,
		ci.Cantidad
	
	

	






GO
/****** Object:  StoredProcedure [dbo].[p_inv_carga_inicial_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[p_inv_carga_inicial_ins]
@pCargaInventarioId	int out,
@pSucursalId	int,
@pProductoId	int,
@pCantidad	decimal,
@pCostoPromedio	money,
@pUltimoCosto	money,
@pCreadoPor	int
as

	select @pCargaInventarioId = isnull(max(CargaInventarioId),0) + 1
	from doc_inv_carga_inicial

	insert into doc_inv_carga_inicial(
		CargaInventarioId,SucursalId,ProductoId,Cantidad,CostoPromedio,
		UltimoCosto	,CreadoEl,CreadoPor
	)
	values(
		@pCargaInventarioId,@pSucursalId,@pProductoId,@pCantidad,@pCostoPromedio,
		@pUltimoCosto	,getdate(),@pCreadoPor
	)





GO
/****** Object:  StoredProcedure [dbo].[p_inv_carga_inicial_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[p_inv_carga_inicial_upd]
@pCargaInventarioId	int ,
@pSucursalId	int,
@pProductoId	int,
@pCantidad	decimal,
@pCostoPromedio	money,
@pUltimoCosto	money,
@pCreadoPor	int
as

	update doc_inv_carga_inicial
	set Cantidad = @pCantidad,
		CostoPromedio = @pCostoPromedio,
		UltimoCosto = @pUltimoCosto
	where CargaInventarioId = @pCargaInventarioId

	





GO
/****** Object:  StoredProcedure [dbo].[p_inv_genera_mov_cancel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[p_inv_genera_mov_cancel]
@pMovimientoId int
as

	declare @movimientoCancelId int,
			@sucursalId int,
			@consecutivo int,
			@tipoMovId int,
			@tipoMovCancel int,
			@movimientoDetalleId int,
			@consecutivoCancel int

	if not exists (
		select 1
		from doc_inv_movimiento 
		where MovimientoRefId =@pMovimientoId 
	)
	and exists (
		select 1
		from doc_inv_movimiento
		where MovimientoId = @pMovimientoId and
		FechaCancelacion is not null
	)
	begin
		

	select @movimientoCancelId= isnull(max(MovimientoId),0) + 1
	from doc_inv_movimiento

	select @sucursalId = SucursalId,
		@tipoMovId = TipoMovimientoId
	from doc_inv_movimiento
	where MovimientoId = @pMovimientoId

	
	select @consecutivo = isnull(max(Consecutivo),0) + 1
	from doc_inv_movimiento
	where SucursalId = @sucursalId and
	TipoMovimientoId = @tipoMovId

	select @tipoMovCancel = TipoMovimientoCancelacionId
	from cat_tipos_movimiento_inventario
	where TipoMovimientoInventarioId = @tipoMovId

	select @consecutivoCancel = Consecutivo
	from doc_inv_movimiento
	where MovimientoId = @pMovimientoId

	begin tran
	
	
	insert into doc_inv_movimiento(
		MovimientoId,	SucursalId,		FolioMovimiento,		TipoMovimientoId,
		FechaMovimiento,HoraMovimiento,	Comentarios,			ImporteTotal,
		Activo,			CreadoPor,		CreadoEl,				Autorizado,
		FechaAutoriza,	SucursalDestinoId,AutorizadoPor,		FechaCancelacion,
		ProductoCompraId,Consecutivo,	SucursalOrigenId,		VentaId,
		MovimientoRefId
	)
	select @movimientoCancelId,SucursalId,@consecutivo,		@tipoMovCancel,
	GETDATE(),			GETDATE(),		'Cancela Folio:'+cast(@consecutivoCancel as varchar),ImporteTotal,
	1,					CreadoPor,		GETDATE(),				1,	
	GETDATE(),			SucursalDestinoId,AutorizadoPor,		FechaCancelacion,
	ProductoCompraId,	@consecutivo,	SucursalOrigenId,		VentaId,
	@pMovimientoId
	from doc_inv_movimiento
	where MovimientoId = @pMovimientoId
	AND FechaCancelacion IS NOT NULL

	if @@ERROR <> 0
	begin
		rollback tran
		goto fin
	end

	select @movimientoDetalleId =isnull(max(MovimientoDetalleId),0) + 1
	from doc_inv_movimiento_detalle

	insert into doc_inv_movimiento_detalle(
		MovimientoDetalleId,MovimientoId,ProductoId,Consecutivo,Cantidad,
		PrecioUnitario,Importe,Disponible,CreadoPor,CreadoEl,
		CostoUltimaCompra,CostoPromedio,ValCostoUltimaCompra,ValCostoPromedio
	)
	select @movimientoDetalleId + ROW_NUMBER() OVER( ORDER BY MovimientoDetalleId ASC) ,
	@movimientoCancelId,ProductoId,Consecutivo,Cantidad,
	PrecioUnitario,Importe,Disponible,CreadoPor,CreadoEl,
	null,null,null,null
	from doc_inv_movimiento_detalle
	where MovimientoId = @pMovimientoId


	if @@ERROR <> 0
	begin
		rollback tran
		goto fin
	end

	commit tran

	fin:

	End

	





GO
/****** Object:  StoredProcedure [dbo].[p_inv_movimiento_autoriza]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE Proc [dbo].[p_inv_movimiento_autoriza]
@pMovimientoId int,
@pAutorizadoPor int
as

	update [dbo].[doc_inv_movimiento]
	set Autorizado = 1,
		AutorizadoPor = @pAutorizadoPor,
		FechaAutoriza = getdate(),
		Activo = 1
	where  MovimientoId = @pMovimientoId

	if exists(
		select 1
		from doc_inv_movimiento m
		where m.MovimientoId = @pMovimientoId and
		m.TipoMovimientoId = 7 --Entrada drecta
	)
	begin
		 exec p_Actualizar_CompraListaPrecios 0,@pMovimientoId,@pAutorizadoPor,''
	end




GO
/****** Object:  StoredProcedure [dbo].[p_inv_movimiento_detalle_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[p_inv_movimiento_detalle_ins]
@pMovimientoDetalleId	int out,
@pMovimientoId	int,
@pProductoId	int,
@pConsecutivo	smallint,
@pCantidad	decimal(14,3),
@pPrecioUnitario	money,
@pImporte	money,
@pDisponible	decimal(14,3),
@pCreadoPor	int,
@pCostoUltimaCompra money,
@pCostoPromedio money,
@pSubTotal money,
@pPrecioNeto money
as

	declare @ValCostoUltimaCompra money,
		   @ValCostoPromedio money

select @pMovimientoDetalleId = isnull(max(MovimientoDetalleId),0) + 1
from [doc_inv_movimiento_detalle]

select @pConsecutivo = isnull(max(Consecutivo),0)
from [doc_inv_movimiento_detalle]
where MovimientoId = @pMovimientoId

set @pImporte = @pCantidad * @pPrecioUnitario
set @ValCostoUltimaCompra = @pCantidad *isnull(@pCostoUltimaCompra,0)
set @ValCostoPromedio = @pCantidad * isnull(@pCostoPromedio,0)

INSERT INTO [dbo].[doc_inv_movimiento_detalle]
           ([MovimientoDetalleId]
           ,[MovimientoId]
           ,[ProductoId]
           ,[Consecutivo]
           ,[Cantidad]
           ,[PrecioUnitario]
           ,[Importe]
           ,[Disponible]
           ,[CreadoPor]
           ,[CreadoEl]
		   ,CostoUltimaCompra
			,CostoPromedio
			,ValCostoUltimaCompra
			,ValCostoPromedio
			,SubTotal
			,PrecioNeto)
     VALUES
           (@pMovimientoDetalleId,
           @pMovimientoId,
           @pProductoId, 
           @pConsecutivo, 
           @pCantidad, 
           @pPrecioUnitario, 
           @pImporte, 
           @pDisponible, 
           @pCreadoPor, 
           getdate() 
		   ,null
		   ,null
		   ,null
		   ,null
		   ,@pSubTotal
		   ,@pPrecioNeto)









GO
/****** Object:  StoredProcedure [dbo].[p_inv_movimiento_rpt]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_inv_movimiento_rpt 1
CREATE Proc [dbo].[p_inv_movimiento_rpt]
@pMovimientoId int
as

	declare @proveedor varchar(200)
	
	
	select @proveedor = prov.Nombre
	from doc_productos_compra pc
	inner join doc_inv_movimiento m on m.ProductoCompraId = pc.ProductoCompraId
	inner join cat_proveedores prov on  prov.ProveedorId = PC.ProveedorId
	where m.MovimientoId = @pMovimientoId 
	

	select SucursalOrigen = suc.NombreSucursal,
		SucursalDestino = sucDes.NombreSucursal,
		TipoMovimiento = TM.Descripcion,
		Folio = m.FolioMovimiento,
		FechaMovimiento = m.FechaMovimiento,
		FechaAfectaInv = m.FechaAutoriza,
		ProductoClave = PROD.Clave,
		Producto = cast(prod.Descripcion as varchar(26)),
		CantidadMov = md.Cantidad,
		PrecioUnitario = md.PrecioUnitario,
		RegistradoPor = usu.NombreUsuario,
		AutorizadoPor = usu2.NombreUsuario	,
		Proveedor = 	isnull(@proveedor,''),
		Remision = pc.NumeroRemision,
		IVAPartida = isnull(md.Importe,0) - isnull(md.SubTotal,0),
		SubTotalPartida = isnull(md.SubTotal,0),	
		TotalPartida =  isnull(md.Importe,0),
		Comentarios = ISNULL(merma.Tipo,'')+' '+ ISNULL(m.Comentarios,'')
	from doc_inv_movimiento m
	inner join doc_inv_movimiento_detalle md on md.MovimientoId = m.MovimientoId
	inner join cat_productos prod on prod.ProductoId = md.ProductoId
	inner join cat_sucursales suc on suc.Clave = isnull(m.SucursalOrigenId,m.SucursalId)
	inner join cat_tipos_movimiento_inventario tm on tm.TipoMovimientoInventarioId = m.TipoMovimientoId
	inner join cat_usuarios usu on usu.IdUsuario = m.CreadoPor
	inner join cat_usuarios usu2 on usu2.IdUsuario = M.AutorizadoPor
	left join cat_sucursales sucDes on sucDes.Clave = m.SucursalDestinoId
	left join doc_productos_compra pc on pc.ProductoCompraId = m.ProductoCompraId
	LEFT JOIN cat_tipos_mermas merma on merma.TipoMermaId = m.TipoMermaId
	where m.MovimientoId = @pMovimientoId










GO
/****** Object:  StoredProcedure [dbo].[p_inv_producto_kardex_grd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_inv_producto_kardex_grd 1,24393
CREATE Proc [dbo].[p_inv_producto_kardex_grd]
@pSucursalId int,
@pProductoId int
as	

	select FechaMov = m.FechaMovimiento,
		SucursalMov=suc.NombreSucursal,
		SucursalOrigen = sucO.NombreSucursal,
		SucursalDestino = sucD.NombreSucursal,
		FolioMov = m.FolioMovimiento,
		Movimiento = tipoMov.Descripcion,
		prod.clave,
		prod.DescripcionCorta,
		CantidadEntrada = ISNULL(case when tipoMov.EsEntrada = 1 then md.Cantidad else 0 end,0),
		CantidadSalida = ISNULL(case when tipoMov.EsEntrada = 0 then md.Cantidad else 0 end,0),
		Existencia = md.Disponible,
		CostoUltimaCompra,
		CostoPromedio,
		ValCostoUltimaCompra,
		ValCostoPromedio,
		m.Comentarios,
		ValorMovimiento	 = case when m.TipoMovimientoId in (2,7) then ValorMovimiento else null end	,
		OtrosCargos = isnull(md.Flete,0) + isnull(md.Comisiones,0)
	from doc_inv_movimiento m
	inner join doc_inv_movimiento_detalle md on md.MovimientoId = m.MovimientoId and
											md.ProductoId=@pProductoId
	inner join cat_tipos_movimiento_inventario tipoMov on tipoMov.TipoMovimientoInventarioId = m.TipoMovimientoId
	inner join cat_sucursales suc on suc.Clave = m.SucursalId
	inner join cat_productos prod on prod.ProductoId = md.ProductoId
	left join cat_sucursales sucO on sucO.Clave = m.SucursalOrigenId
	left join cat_sucursales sucD on sucD.Clave = m.SucursalDestinoId
	where m.SucursalId = @pSucursalId and
	(m.Activo = 1 OR m.Cancelado = 1) and
	m.Autorizado = 1
	order by md.MovimientoDetalleId DESC









GO
/****** Object:  StoredProcedure [dbo].[p_inventario_cierre]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- p_inventario_cierre 10,1
CREATE proc [dbo].[p_inventario_cierre]
@pSucursalId INT,
@pUsuarioId INT
AS
BEGIN

	DECLARE @MovimientoId INT,
		@Consecutivo INT,
		@MovimientoDetalleId INT

	SELECT IC.SucursalId,
			IC.ProductoId,
			Cantidad = SUM(IC.Cantidad)	
	INTO #TMP_INVENTARIO
	FROM doc_inventario_captura IC
	WHERE IC.SucursalId = @pSucursalId AND
	ISNULL(IC.Cerrado ,0)= 0
	GROUP BY IC.SucursalId,
	IC.ProductoId

	SELECT @MovimientoId = ISNULL(MAX(MovimientoId),0)+1
	from doc_inv_movimiento

	SELECT @Consecutivo =ISNULL(MAX(Consecutivo),0)+1
	from doc_inv_movimiento 
	WHERE TipoMovimientoId = 5--Ajuste por Entrada

	INSERT INTO doc_inv_movimiento(
	MovimientoId,	SucursalId,		FolioMovimiento,	TipoMovimientoId,
	FechaMovimiento,HoraMovimiento,	Comentarios,		ImporteTotal,
	Activo,			CreadoPor,		CreadoEl,			Autorizado,
	FechaAutoriza,	SucursalDestinoId,AutorizadoPor,	FechaCancelacion,
	ProductoCompraId,Consecutivo,	SucursalOrigenId,	VentaId,
	MovimientoRefId,Cancelado,TipoMermaId)

	SELECT @MovimientoId,@pSucursalId,CAST(@Consecutivo AS VARCHAR),5,
	dbo.fn_GetDateTimeServer(),		dbo.fn_GetDateTimeServer(),		'AJUSTE POR CIERRE DE INVENTARIO',0,
	1,				@pUsuarioId,	dbo.fn_GetDateTimeServer(),			1,
	dbo.fn_GetDateTimeServer(),		NULL,			@pUsuarioId,		NULL,
	NULL,			@Consecutivo,		NULL,			NULL,
	NULL,			NULL,		NULL
	

	SELECT @MovimientoDetalleId = ISNULL(MAX(MovimientoDetalleId),0)+1
	FROM doc_inv_movimiento_detalle

	INSERT INTO doc_inv_movimiento_detalle(
	MovimientoDetalleId,	MovimientoId,		ProductoId,		Consecutivo,
	Cantidad,				PrecioUnitario,		Importe,		Disponible,
	CreadoPor,				CreadoEl,			CostoUltimaCompra,CostoPromedio,	
	ValCostoUltimaCompra,	ValCostoPromedio,	ValorMovimiento, Flete,
	Comisiones,				SubTotal,			PrecioNeto
	)
	SELECT ROW_NUMBER() OVER(ORDER BY TMP.ProductoId ASC) +@MovimientoDetalleId,@MovimientoId,TMP.ProductoId,@Consecutivo,
	CASE WHEN ISNULL(PE.ExistenciaTeorica,0)  > 0 THEN ISNULL(PE.ExistenciaTeorica,0) * -1
		WHEN ISNULL(PE.ExistenciaTeorica,0)  < 0 THEN ISNULL(PE.ExistenciaTeorica,0)  * -1
	END,					0,					0,			
	CASE WHEN ISNULL(PE.ExistenciaTeorica,0)  > 0 THEN ISNULL(PE.ExistenciaTeorica,0) * -1
		WHEN ISNULL(PE.ExistenciaTeorica,0)  < 0 THEN ISNULL(PE.ExistenciaTeorica,0) 
	END,--
	@pUsuarioId,			dbo.fn_GetDateTimeServer(),			0,				0,
	0,						0,					0,				0,
	0,						0,					0
	FROM #TMP_INVENTARIO TMP
	LEFT JOIN cat_productos_existencias PE ON PE.ProductoId = TMP.ProductoId AND
									PE.SucursalId = @pSucursalId

	update doc_inv_movimiento
	SET Autorizado = 1,
		AutorizadoPor = @pUsuarioId,
		FechaAutoriza = dbo.fn_GetDateTimeServer(),
		FechaMovimiento = dbo.fn_GetDateTimeServer()
	where MovimientoId = @MovimientoId

	/*************************************************************************************************/
	SELECT @MovimientoId = ISNULL(MAX(MovimientoId),0)+1
	from doc_inv_movimiento

	SELECT @Consecutivo =ISNULL(MAX(Consecutivo),0)+1
	from doc_inv_movimiento 
	WHERE TipoMovimientoId = 5--Ajuste por Entrada

	INSERT INTO doc_inv_movimiento(
	MovimientoId,	SucursalId,		FolioMovimiento,	TipoMovimientoId,
	FechaMovimiento,HoraMovimiento,	Comentarios,		ImporteTotal,
	Activo,			CreadoPor,		CreadoEl,			Autorizado,
	FechaAutoriza,	SucursalDestinoId,AutorizadoPor,	FechaCancelacion,
	ProductoCompraId,Consecutivo,	SucursalOrigenId,	VentaId,
	MovimientoRefId,Cancelado,TipoMermaId)

	SELECT @MovimientoId,@pSucursalId,CAST(@Consecutivo AS VARCHAR),5,
	dbo.fn_GetDateTimeServer(),		dbo.fn_GetDateTimeServer(),		'AJUSTE POR CIERRE DE INVENTARIO',0,
	1,				@pUsuarioId,	dbo.fn_GetDateTimeServer(),			1,
	dbo.fn_GetDateTimeServer(),		NULL,			@pUsuarioId,		NULL,
	NULL,			@Consecutivo,		NULL,			NULL,
	NULL,			NULL,		NULL

	SELECT @MovimientoDetalleId = ISNULL(MAX(MovimientoDetalleId),0)+1
	FROM doc_inv_movimiento_detalle


	INSERT INTO doc_inv_movimiento_detalle(
	MovimientoDetalleId,	MovimientoId,		ProductoId,		Consecutivo,
	Cantidad,				PrecioUnitario,		Importe,		Disponible,
	CreadoPor,				CreadoEl,			CostoUltimaCompra,CostoPromedio,	
	ValCostoUltimaCompra,	ValCostoPromedio,	ValorMovimiento, Flete,
	Comisiones,				SubTotal,			PrecioNeto
	)
	SELECT ROW_NUMBER() OVER(ORDER BY TMP.ProductoId ASC) +@MovimientoDetalleId,@MovimientoId,TMP.ProductoId,@Consecutivo,
	ISNULL(TMP.Cantidad,0),					0,					0,			
	ISNULL(TMP.Cantidad,0),--
	@pUsuarioId,			dbo.fn_GetDateTimeServer(),			0,				0,
	0,						0,					0,				0,
	0,						0,					0
	FROM #TMP_INVENTARIO TMP
	LEFT JOIN cat_productos_existencias PE ON PE.ProductoId = TMP.ProductoId AND
									PE.SucursalId = @pSucursalId

	update doc_inv_movimiento
	SET Autorizado = 1,
		AutorizadoPor = @pUsuarioId,
		FechaAutoriza = dbo.fn_GetDateTimeServer(),
		FechaMovimiento = dbo.fn_GetDateTimeServer()
	where MovimientoId = @MovimientoId

	update doc_inventario_captura
	SET Cerrado = 1
	WHERE SucursalId = @pSucursalId AND
	Cerrado = 0

END
GO
/****** Object:  StoredProcedure [dbo].[p_producto_imagen_principal_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_producto_imagen_principal_upd]
@pProductoImagenId int
as

	declare @pProductoId int

	select @pProductoId = ProductoId
	from cat_productos_imagenes
	where ProductoImageId = @pProductoImagenId

	update cat_productos_imagenes
	set Principal = 0
	where ProductoId = @pProductoId

	update cat_productos_imagenes
	set Principal = 1
	where ProductoImageId = @pProductoImagenId



GO
/****** Object:  StoredProcedure [dbo].[p_producto_precio_especial_vigente]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROC [dbo].[p_producto_precio_especial_vigente]
@pProductoId INT,
@pSucursalId INT=0
AS

	SELECT PED.*
	FROM doc_precios_especiales_detalle PED
	INNER JOIN doc_precios_especiales PE ON PE.Id = PED.PrecioEspeciaId AND
								PE.FechaVigencia > GETDATE()
	WHERE PED.ProductoId = @pProductoId  AND
	PE.SucursalId = @pSucursalId

GO
/****** Object:  StoredProcedure [dbo].[p_producto_promocion_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- p_producto_promocion_sel 1,41,10,0
CREATE proc [dbo].[p_producto_promocion_sel]
@pSucursalId int,
@pProductoId int,
@pPedidoId int=0,
@pPedidoDetalleId int=0
as

	declare @diaSemena int

	select @diaSemena =datepart(weekday, getdate())	

	select PD.PromocionId,
		ProductoId = @pProductoId,
		p.PorcentajeDescuento
	into #tmpExcepciones
	from doc_promociones p
	inner join cat_productos pro on pro.ProductoId = @pProductoId and
									(
										(p.FechaInicioVigencia <= GETDATE() and
										p.FechaFinVigencia >= GETDATE())
										or
										P.Permanente = 1
									)
	inner join doc_promociones_excepcion pd on pd.PromocionId = p.PromocionId 	
	where p.SucursalId = @pSucursalId and
	p.Activo = 1 and
	(
		(p.Lunes = 1 and @diaSemena = 2) OR
		(p.Martes = 1 and @diaSemena = 3) OR
		(p.Miercoles = 1 and @diaSemena = 4) OR
		(p.Jueves = 1 and @diaSemena = 5) OR
		(p.Viernes = 1 and @diaSemena = 6) OR
		(p.Sabado = 1 and @diaSemena = 7) OR
		(p.Domingo = 1 and @diaSemena = 1) 
	) 
	AND (
		PD.ProductoId = PRO.ProductoId
		or(
			PD.ProductoId IS NULL and
			PD.LineaId = PRO.ClaveLinea AND
			PD.FamiliaId = PRO.ClaveFamilia AND
			PD.Subfamilia = PRO.ClaveSubFamilia
		)
		or(
			PD.ProductoId IS NULL and
			PD.LineaId =pro.ClaveLinea AND
			PD.FamiliaId = PRO.ClaveFamilia AND
			PD.Subfamilia IS NULL
		)
		or(
			PD.ProductoId IS NULL and
			PD.LineaId =pro.ClaveLinea AND
			PD.FamiliaId  is null AND
			PD.Subfamilia IS NULL
		)
		or(
			PD.ProductoId IS NULL and
			PD.LineaId is null AND
			PD.FamiliaId is null AND
			PD.Subfamilia is null
		)
	)
	
	


	select TOP 1 PD.PromocionId,
		ProductoId = @pProductoId,
		p.PorcentajeDescuento	,
		MontoDescuento = cast(0 as decimal(5,2)),
		PromocionCMId = cast(0 as decimal(5,2))
	into #tmpResult
	from doc_promociones p
	inner join cat_productos pro on pro.ProductoId = @pProductoId and
									(
										(p.FechaInicioVigencia <= GETDATE() and
										p.FechaFinVigencia >= GETDATE())
										or
										P.Permanente = 1
									)
	inner join doc_promociones_detalle pd on pd.PromocionId = p.PromocionId 
	--left join doc_promociones_excepcion pe on pe.ProductoId = p.PromocionId									
	where p.SucursalId = @pSucursalId and
	p.Activo = 1 and
	(
		(p.Lunes = 1 and @diaSemena = 2) OR
		(p.Martes = 1 and @diaSemena = 3) OR
		(p.Miercoles = 1 and @diaSemena = 4) OR
		(p.Jueves = 1 and @diaSemena = 5) OR
		(p.Viernes = 1 and @diaSemena = 6) OR
		(p.Sabado = 1 and @diaSemena = 7) OR
		(p.Domingo = 1 and @diaSemena = 1) 
	) 
	AND (
		PD.ProductoId = PRO.ProductoId
		or(
			PD.ProductoId IS NULL and
			PD.LineaId = PRO.ClaveLinea AND
			PD.FamiliaId = PRO.ClaveFamilia AND
			PD.Subfamilia = PRO.ClaveSubFamilia
		)
		or(
			PD.ProductoId IS NULL and
			PD.LineaId =pro.ClaveLinea AND
			PD.FamiliaId = PRO.ClaveFamilia AND
			PD.Subfamilia IS NULL
		)
		or(
			PD.ProductoId IS NULL and
			PD.LineaId =pro.ClaveLinea AND
			PD.FamiliaId  is null AND
			PD.Subfamilia IS NULL
		)
		or(
			PD.ProductoId IS NULL and
			PD.LineaId is null AND
			PD.FamiliaId is null AND
			PD.Subfamilia is null
		)
	)
	AND NOT EXISTS(
		SELECT 1
		FROM #tmpExcepciones st1
		where st1.PromocionId = PD.PromocionId
	)
	ORDER BY p.PorcentajeDescuento desc

	


		select Pedidod = po.PedidoId,
			pod.ProductoId,
			CantidadCompra = cast(sum(pod.Cantidad) as decimal(5,2)),
			CantidadPagarPromo =  (
									cast((cast((sum(pod.Cantidad)  / min(pd.CantidadCompraMinima)) as int) 
									* MAX(pd.CantidadCobro))  as decimal(5,2))
								) +
								(
									sum(pod.Cantidad) -
									(
										min(pd.CantidadCompraMinima) 
										*
										cast((sum(pod.Cantidad)  / min(pd.CantidadCompraMinima)) as int)
									)
								)				
								,
			PrecioUnitario = max(pod.PrecioUnitario),
			pd.PromocionCMId
		into #tmpPromocionesCM
		from doc_promociones_cm_detalle pd
		inner join doc_promociones_cm p on p.PromocionCMId = pd.PromocionCMId
		inner join doc_pedidos_orden po on po.PedidoId = @pPedidoId 
		inner join doc_pedidos_orden_detalle pod on pod.PedidoId = po.PedidoId and
											pod.ProductoId = pd.ProductoId and
											isnull(pod.PromocionCMId,0)= 0
		where pd.ProductoId = @pProductoId and
		p.Activo = 1 and				
		dateadd(minute,datepart(minute,p.HoraVigencia),
		dateadd(hour,datepart(hour,p.HoraVigencia),p.FechaVigencia))	 >= getdate() and
		(CASE 
											WHEN P.Lunes = 1 AND DATEPART(WEEKDAY,GETDATE()) = 2 THEN 1
											WHEN P.Martes = 1 AND DATEPART(WEEKDAY,GETDATE()) = 3 THEN 1
											WHEN P.MIercoles = 1 AND DATEPART(WEEKDAY,GETDATE()) = 4 THEN 1
											WHEN P.Jueves = 1  AND DATEPART(WEEKDAY,GETDATE()) = 5 THEN 1
											WHEN P.Viernes = 1 AND DATEPART(WEEKDAY,GETDATE()) = 6 THEN 1
											WHEN P.Sabado = 1 AND DATEPART(WEEKDAY,GETDATE()) = 7 THEN 1
											WHEN P.Domingo = 1 AND DATEPART(WEEKDAY,GETDATE()) = 1 THEN 1
											else 0
		END) = 1
		group by po.PedidoId,pod.ProductoId,pd.PromocionCMId

		
		
		if exists(
			select 1
			from #tmpPromocionesCM
			where isnull(CantidadPagarPromo,0) < isnull(CantidadCompra,0)
		)
		begin
			
			declare @totalOrig money,
					@totalPromo money,
					@descuento decimal(5,2),
					@totalDescuento money,
					@promocionCMId int

			select @totalOrig = CantidadCompra * PrecioUnitario,
					@totalPromo =CantidadPagarPromo *  PrecioUnitario,
					@promocionCMId = PromocionCMId
			from #tmpPromocionesCM

			

			select @descuento = cast(100 as decimal(5,2)) - ((@totalPromo *  cast(100 as decimal(5,2))) /@totalOrig)

			if(isnull(@totalPromo,0) > 0)
			begin
				select @totalDescuento = @totalOrig * (@descuento/ cast(100 as decimal(5,2)))
				from #tmpPromocionesCM

				delete #tmpResult

				insert into #tmpResult(PromocionId,ProductoId,PorcentajeDescuento,
				MontoDescuento,PromocionCMId)
				select 0,@pProductoId,@descuento,@totalDescuento,@promocionCMId
			end
			

		end
	
	
		select PromocionId,
			ProductoId ,
			PorcentajeDescuento	,
			MontoDescuento ,
			PromocionCMId
		from #tmpResult
	






GO
/****** Object:  StoredProcedure [dbo].[p_producto_ultima_compra]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_producto_ultima_compra 13
CREATE Proc [dbo].[p_producto_ultima_compra]
@pProductoId int
as

	declare @ProductoCompraDetId int,
		@precioUnitario money,
		@impuestos money,
		@porcImpuestos money,
		@movimientoId int

	--select top 1  @ProductoCompraDetId = ProductoCompraDetId
	--from doc_productos_compra_detalle pcd
	--inner join doc_productos_compra pc on pc.ProductoCompraId = pcd.ProductoCompraId
	--where pcd.ProductoId = @pProductoId and
	--pc.activo = 1
	--order by FechaRegistro desc

	--select @porcImpuestos = isnull(sum(i.Porcentaje),0)
	--from cat_productos_impuestos pi
	--inner join cat_impuestos i on i.Clave = pi.ImpuestoId
	--where ProductoId = @pProductoId


	--select PrecioUnitario = isnull(PrecioUnitario,0),
	--	Impuestos = isnull(
	--						PrecioUnitario -
	--						(
	--						PrecioUnitario / 
	--						(1+ (@porcImpuestos / 100))
	--						)
	--					,0),
	--	PrecioNeto = PrecioUnitario - isnull(
	--						PrecioUnitario -
	--						(
	--						PrecioUnitario / 
	--						(1+ (@porcImpuestos / 100))
	--						)
	--					,0)
	--from doc_productos_compra_detalle
	--where ProductoCompraDetId = @ProductoCompraDetId


	select top 1 @movimientoId = md.MovimientoDetalleId
	from doc_inv_movimiento m
	inner join doc_inv_movimiento_detalle md on md.MovimientoId = m.MovimientoId
	where md.ProductoId = @pProductoId and
	m.Activo = 1 and
	m.Autorizado = 1
	order by md.CreadoEl desc

	select @porcImpuestos = isnull(sum(i.Porcentaje),0)
	from cat_productos_impuestos pi
	inner join cat_impuestos i on i.Clave = pi.ImpuestoId
	where ProductoId = @pProductoId


	select PrecioUnitario = isnull(PrecioUnitario,0),
		Impuestos = isnull(
							PrecioUnitario -
							(
							PrecioUnitario / 
							(1+ (@porcImpuestos / 100))
							)
						,0),
		PrecioNeto = PrecioUnitario - isnull(
							PrecioUnitario -
							(
							PrecioUnitario / 
							(1+ (@porcImpuestos / 100))
							)
						,0)
	from doc_inv_movimiento_detalle
	where MovimientoDetalleId = @movimientoId
	








GO
/****** Object:  StoredProcedure [dbo].[p_productos_agrupados_upd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[p_productos_agrupados_upd]
@pProductoId int
as
	
	select pd2.ProductoId
	into #tmpProdutosRelacionados
	from cat_productos_agrupados_detalle pd
	INNER JOIN cat_productos_agrupados pa on pa.ProductoAgrupadoId = pd.ProductoAgrupadoId
	inner join cat_productos_agrupados_detalle pd2 on pd2.ProductoAgrupadoId = PA.ProductoAgrupadoId AND
											pd2.ProductoId <> @pProductoId
	where pd.ProductoId = @pProductoId

	select *
	into #tmpProducto
	from cat_productos 
	where ProductoId = @pProductoId

	select *
	into #tmpProductosPrecios
	from cat_productos_precios
	where IdProducto=@pProductoId
	

	--Generales
	--Revisar si es un producto agrupado
	update cat_productos
	set Descripcion = t2.Descripcion,
		DescripcionCorta=t2.DescripcionCorta,		
		ClaveMarca = t2.ClaveMarca,
		ClaveFamilia= t2.Clavefamilia,
		ClaveSubFamilia=t2.ClaveSubfamilia,
		ClaveLinea=t2.ClaveLinea,
		ClaveUnidadMedida=t2.ClaveUnidadMedida,
		ProductoTerminado=t2.ProductoTerminado,
		Inventariable=t2.Inventariable,
		MateriaPrima=t2.MateriaPrima,
		ProdParaVenta=t2.ProdParaVenta,
		ProdVtaBascula=t2.ProdVtaBascula,
		Seriado= t2.Seriado,
		NumeroDecimales= t2.NumeroDecimales,
		PorcDescuentoEmpleado=t2.PorcDescuentoEmpleado,
		ContenidoCaja=t2.ContenidoCaja,
		Empresa=t2.Empresa,
		Sucursal=t2.Sucursal,		
		ClaveAlmacen = t2.ClaveAlmacen,
		ClaveAnden=t2.ClaveAnden,
		ClaveLote=t2.ClaveLote,
		FechaCaducidad=t2.FechaCaducidad,
		MinimoInventario= t2.MinimoINventario,
		MaximoInventario= t2.MaximoInventario,
		PorcUtilidad=t2.PorcUtilidad,
		--Talla=t2.Talla,
		ParaSexo= t2.ParaSexo,
		Color=t2.Color,
		Color2=t2.Color2,
		SobrePedido= t2.SobrePedido,
		Especificaciones=t2.Especificaciones
	from cat_productos t1
	inner join #tmpProdutosRelacionados pr on pr.ProductoId = t1.ProductoId
	inner join #tmpProducto t2 on t2.ProductoId = @pProductoId

	--Precios
	UPDATE cat_productos_precios
	set 		
		PorcDescuento=tmp.PorcDescuento,
		MontoDescuento=tmp.MontoDescuento,
		Precio=tmp.Precio
	from cat_productos_precios pp
	inner join #tmpProdutosRelacionados pr on pr.ProductoId = pp.IdProducto 
	inner join #tmpProductosPrecios tmp on tmp.IdProducto = @pProductoId AND
										tmp.IdPrecio = pp.IdPrecio 
											
	
GO
/****** Object:  StoredProcedure [dbo].[p_productos_clonar]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_productos_clonar]
@pProductoId int,
@pProductoNuevoId int out
as

	declare @pIdProductoPrecio int,
		@pProductoImageId int

	select @pProductoNuevoId=isnull(max(ProductoId),0)+1
	from cat_productos

	begin tran

	insert into cat_productos(
		ProductoId,		Clave,		Descripcion,		DescripcionCorta,
		FechaAlta,		ClaveMarca,	ClaveFamilia,		ClaveSubFamilia,
		ClaveLinea,		ClaveUnidadMedida,ClaveInventariadoPor,ClaveVendidaPor,
		Estatus,		ProductoTerminado,Inventariable,MateriaPrima,
		ProdParaVenta,	ProdVtaBascula,Seriado,NumeroDecimales,
		PorcDescuentoEmpleado,	ContenidoCaja,	Empresa,	Sucursal,
		Foto,			ClaveAlmacen,	ClaveAnden,		ClaveLote,
		FechaCaducidad,	MinimoInventario,MaximoInventario,PorcUtilidad,
		Talla,			ParaSexo,	Color,				Color2,
		SobrePedido,		Especificaciones
	)
	select @pProductoNuevoId,@pProductoNuevoId,		Descripcion,		DescripcionCorta,
		FechaAlta,		ClaveMarca,	ClaveFamilia,		ClaveSubFamilia,
		ClaveLinea,		ClaveUnidadMedida,ClaveInventariadoPor,ClaveVendidaPor,
		Estatus,		ProductoTerminado,Inventariable,MateriaPrima,
		ProdParaVenta,	ProdVtaBascula,Seriado,NumeroDecimales,
		PorcDescuentoEmpleado,	ContenidoCaja,	Empresa,	Sucursal,
		Foto,			ClaveAlmacen,	ClaveAnden,		ClaveLote,
		FechaCaducidad,	MinimoInventario,MaximoInventario,PorcUtilidad,
		Talla,			ParaSexo,	Color,				Color2,
		SobrePedido,		Especificaciones
	from cat_productos
	where ProductoId = @pProductoId

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end
	
	--Insertar Precios
	select @pIdProductoPrecio = isnull(max(IdProductoPrecio),0) 
	from cat_productos_precios

	insert into cat_productos_precios(
		IdProductoPrecio,IdProducto,IdPrecio,PorcDescuento,
		MontoDescuento,Precio
	)
	select ROW_NUMBER() OVER(ORDER BY IdPrecio ASC) + @pIdProductoPrecio,@pProductoNuevoId,IdPrecio,PorcDescuento,
	MontoDescuento,Precio
	from cat_productos_precios
	where IdProducto = @pProductoId

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	--EXISTENCIAS
	insert into cat_productos_existencias(
			ProductoId,		SucursalId,		ExistenciaTeorica,		CostoUltimaCompra,
			CostoPromedio,	ValCostoUltimaCompra,ValCostoPromedio,	ModificadoEl,
			CreadoEl
		)
		select @pProductoNuevoId,clave,isnull(0,0),0,
		0,0,0,getdate(),
		getdate()
		from cat_sucursales
		where estatus =1 

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	--IMAGENES
	--select @pProductoImageId =isnull(max(ProductoImageId),0)
	--from cat_productos_imagenes
	


	--insert into cat_productos_imagenes(
	--	ProductoImageId,	ProductoId,		FileName,		CreadoEl,
	--	FileByte,			Principal,		Miniatura
	--)
	--select ROW_NUMBER() OVER(ORDER BY ProductoImageId ASC) + @pProductoImageId,				@pProductoNuevoId,	FileName,	GETDATE(),
	--FileByte,				Principal,		Miniatura
	--from cat_productos_imagenes
	--where ProductoId = @pProductoId


	--if @@error <> 0
	--begin
	--	rollback tran
	--	goto fin
	--end

	commit tran

	fin:
GO
/****** Object:  StoredProcedure [dbo].[p_productos_compra_inv]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE Proc [dbo].[p_productos_compra_inv]
@pProductoCompraId int,
@pSucursalId int,
@pCreadoPor int
as


	declare @pMovimientoId int,
			@pMovimientoDetId int,
			@consecutivo int,
			@sucursalId int,
			@fletePonderacion float,
			@comisionPonderacion float,
			@pFleteTotal float,
			@pComisionTotal float,
			@totMovs float


	



	select @pMovimientoId = isnull(max(MovimientoId),0) + 1
	from [doc_inv_movimiento]

	select @sucursalId = @pSucursalId
	--from [doc_inv_movimiento]
	--where ProductoCompraId = @pProductoCompraId

	select @consecutivo = @pProductoCompraId-- isnull(max(Consecutivo ),0) + 1
	--from [doc_inv_movimiento]
	--where SucursalId = @sucursalId and
	--TipoMovimientoId = 2

	select @pMovimientoDetId = isnull(max(MovimientoDetalleId),0) + 1
	from [doc_inv_movimiento_detalle]

	begin tran

	/***ACTUALIZAR FLETE Y COMISION PODENRADO**/
	select @pFleteTotal = isnull(Total,0)
	from doc_productos_compra_cargos 
	where ProductoCompraId = @pProductoCompraId and ProductoId = -2

	select @pComisionTotal =isnull(Total,0)
	from doc_productos_compra_cargos 
	where ProductoCompraId = @pProductoCompraId and ProductoId = -3

	select @totMovs = count(distinct ProductoCompraDetId)
	from doc_productos_compra_detalle
	where ProductoCompraId = @pProductoCompraId

	

	set @fletePonderacion = @pFleteTotal / @totMovs
	set @comisionPonderacion = @pComisionTotal / @totMovs

	--declare @error varchar(50)
	--set @error = cast( @pFleteTotal as varchar)
	--RAISERROR (15600,-1,-1, @error);  

	UPDATE doc_productos_compra_detalle
	SET Flete = isnull(@fletePonderacion,0) ,
	Comisiones = isnull(@comisionPonderacion,0)
	where ProductoCompraId = @pProductoCompraId

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	insert into [dbo].[doc_inv_movimiento](
		MovimientoId,SucursalId,FolioMovimiento,TipoMovimientoId,FechaMovimiento,
		HoraMovimiento,Comentarios,ImporteTotal,Activo,CreadoPor,CreadoEl,
		Autorizado,FechaAutoriza,AutorizadoPor,ProductoCompraId,Consecutivo
	)
	select @pMovimientoId,SucursalId,@consecutivo,2,getdate(),
	cast(getdate() as time),'',Total,1,@pCreadoPor,getdate(),
	1,getdate(),@pCreadoPor,@pProductoCompraId,@consecutivo
	from [dbo].[doc_productos_compra]
	where ProductoCompraId = @pProductoCompraId

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	insert into [dbo].[doc_inv_movimiento_detalle](
		MovimientoDetalleId,MovimientoId,ProductoId,Consecutivo,Cantidad,
		PrecioUnitario,Importe,Disponible,CreadoPor,CreadoEl,Flete,Comisiones,SubTotal,PrecioNeto
	)
	select @pMovimientoDetId + ROW_NUMBER() OVER(ORDER BY ProductoId ASC),@pMovimientoId,ProductoId,ROW_NUMBER() OVER(ORDER BY ProductoId ASC),Cantidad,
	PrecioUnitario,Total,Cantidad,@pCreadoPor,GETDATE(),Flete,Comisiones,Subtotal,PrecioNeto
	from [dbo].[doc_productos_compra_detalle]
	where ProductoCompraId = @pProductoCompraId

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	commit tran

	fin:



	

	









GO
/****** Object:  StoredProcedure [dbo].[p_productos_existencia_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_productos_existencia_sel 1,0,0,0,0,1
CREATE Proc [dbo].[p_productos_existencia_sel]
@pSucursal int,
@pLineaId int,
@pFamiliaId int,
@pSubfamiliaId int,
@pProductoId int,
@pSoloConExistencias bit
as
	/**********Obtener existencias de todas las sucursales************/
	select PE.SucursalId,
	PE.ProductoId,
	P.ClaveLinea,
	ClaveFamilia=isnull(P.ClaveFamilia,0),
	ClaveSubFamilia=isnull(P.ClaveSubFamilia,0),
	PE.ExistenciaTeorica,
	Apartado = isnull(PE.Apartado,0),
	Disponible = isnull(PE.Disponible,0)
	INTO #tmpExistencias
	from cat_productos_existencias PE
	INNER JOIN cat_productos p on p.ProductoId = pe.ProductoId
	where @pLineaId in (0,isnull(p.ClaveLinea,0)) and
	@pFamiliaId in (0,isnull(p.ClaveFamilia,0)) and
	@pSubfamiliaId in (0,isnull(p.ClaveSubFamilia,0)) and
	@pProductoId in (0,isnull(p.ProductoId,0))

	select tmp.SucursalId,
		  tmp.ClaveLinea,
		  Linea = l.Descripcion,
		  tmp.ClaveFamilia,
		  Familia = f.Descripcion,
		  tmp.ClaveSubFamilia,
		  SubFamilia = sf.Descripcion,
		  tmp.ProductoId,
		  ClaveProducto = p.clave,
		  Producto = p.Descripcion,
		  ExistenciaSucursal = tmp.ExistenciaTeorica,
		  ExistenciaTotal = (select sum(s1.ExistenciaTeorica)  from #tmpExistencias s1 where s1.ProductoId = p.ProductoId),
		  p.Clave,
		  tmp.ExistenciaTeorica,
		  p.Descripcion,
		  SUC.NombreSucursal,
		  tmp.Apartado,
		  tmp.Disponible
	from #tmpExistencias tmp
	INNER JOIN cat_productos P ON P.ProductoId = tmp.ProductoId and p.Inventariable = 1
	inner join cat_sucursales suc on suc.Clave = tmp.SucursalId
	left JOIN cat_familias f on f.Clave = p.ClaveFamilia
	left join cat_subfamilias sf on sf.Clave = p.ClaveSubFamilia
	left join cat_lineas l on l.Clave = p.ClaveLinea
	where tmp.SucursalId = @pSucursal and
	(
		(
			tmp.ExistenciaTeorica <> 0
			and @pSoloConExistencias = 1
		)
		OR
		(
			@pSoloConExistencias = 0
		)
	)
	














GO
/****** Object:  StoredProcedure [dbo].[p_productos_imagenes_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_productos_imagenes_sel]
@pProductoId int
as
	select ProductoImageId,
			ProductoId,
			FileName,
			Principal
	from cat_productos_imagenes
	where ProductoId = @pProductoId
GO
/****** Object:  StoredProcedure [dbo].[p_productos_importacion]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Proc [dbo].[p_productos_importacion]
@pEmpresa int,
@pSucursalId int,
@pLinea varchar(100),
@pFamilia varchar(100),
@pClaveProducto varchar(50),
@pDescripcionCorta varchar(250),
@pDescripcionLarga varchar(500),
@pPrecio money,
@pExistencias decimal(6,2),
@pCostoPromedio float,
@pInsertado bit out,
@pIVA int,
@pUnidad varchar(100),
@pMarca varchar(100),
@pSubfamilia varchar(100),
@pTalla varchar(5),
@pParaSexo varchar(1),
@pColor varchar(10),
@pColor2 varchar(10),
@pSobrePedido bit,
@pCreadoPor int,
@uuid uniqueidentifier,
@pMateriaPrima bit,
@pProdParaVenta bit,
@pUnidadLicencia varchar(1),
@pCantidadLlicencia smallint,
@pVersion varchar(20),
@pCostoUltimaCompra float,
@pProductoActivo bit,
@pProductoTerminado bit,
@pProductoInventariable bit,
@pProductoBascula bit,
@pProductoSeriado bit,
@pUnidadInventario varchar(100),
@pUnidadVenta varchar(100),
@pMinimoInventario float,
@pMaximoInventario float,
@pCantidadProductoCaja float,
@pCodigoBarras varchar(25),
@pError varchar(250) out
as
BEGIN

	declare @familiaId int,
			@lineaId int,
			@subfamiliaId int,
			@productoId int,
			@marcaId int,
			@unidadId int,
			 @movimiento int,
			@folio int,
			@movimientoDetalle int,
			@unidadInventario int,
			@unidadVenta int,
			@lastMovId int

	SET @pError = ''
	BEGIN TRY

	BEGIN TRAN

	/*COSTO PROMEDIO Y PRECIO ULT COMPRA SOLO SE ACTUALIZARÁN PARA MATRIZ, SI ES SUCURSAL SE TOMARÁ LO DE MATRIZ*/
	if(@pSucursalId <> 1)
	BEGIN

		set @pCostoPromedio = 0
		set @pCostoUltimaCompra = 0

		select  @lastMovId = md.MovimientoDetalleId
		from doc_inv_movimiento_detalle md
		inner join doc_inv_movimiento m on m.MovimientoId = md.MovimientoId
		where md.ProductoId = @productoId and m.SucursalId = 1

		select  @pCostoPromedio = isnull(CostoPromedio,0),
				 @pCostoUltimaCompra = isnull(CostoUltimaCompra,0)
		from doc_inv_movimiento_detalle md
		inner join doc_inv_movimiento m on m.MovimientoId = md.MovimientoId 
		where md.ProductoId = @productoId AND 
		md.MovimientoDetalleId = @lastMovId
	END

	if(isnull(@pCodigoBarras,'') = '')
	BEGIN
		SET @pCodigoBarras = @pClaveProducto
	END

	SET @pInsertado = 0

	select @lineaId = Clave
	from cat_lineas f
	where rtrim(f.Descripcion) = rtrim(@pLinea)

	select @familiaId = Clave
	from cat_familias f
	where rtrim(f.Descripcion) = rtrim(@pFamilia)

	select @subfamiliaid = Clave
	from cat_subfamilias f
	where UPPER(rtrim(f.Descripcion)) = UPPER(rtrim(@pSubFamilia))

	SELECT @productoId = ProductoId
	from cat_productos
	where RTRIM(Clave) = RTRIM(@pClaveProducto)

	SELECT @marcaId = Clave
	from cat_marcas
	where upper(RTRIM(Descripcion)) = upper(RTRIM(@pMarca))

	SELECT @unidadId = Clave
	from cat_unidadesmed
	where upper(RTRIM(Descripcion)) = upper(RTRIM(@pUnidad))

	SELECT @unidadInventario = Clave
	from cat_unidadesmed
	where upper(RTRIM(Descripcion)) = upper(RTRIM(@pUnidadInventario))

	SELECT @unidadVenta = Clave
	from cat_unidadesmed
	where upper(RTRIM(Descripcion)) = upper(RTRIM(@pUnidadVenta))
	
	

	if(
		isnull(@lineaId,0) = 0
	)
	begin 
		select @lineaId = isnull(max(Clave),0) +1
		from cat_lineas

		insert into cat_lineas(Empresa,Sucursal,Clave,Descripcion,Estatus)
		select @pEmpresa,@pSucursalId, @lineaId,@pLinea,1
	end

	

	if(
		isnull(@familiaId,0) = 0
	)
	begin 
		select @familiaId = isnull(max(Clave),0) +1
		from cat_familias
		select @pEmpresa,@pSucursalId,@familiaId,@pFamilia,1
		insert into cat_familias(Empresa,Sucursal,Clave,Descripcion,Estatus)
		select @pEmpresa,1,@familiaId,@pFamilia,1

		
	end


	if(
		isnull(@subfamiliaId,0) = 0
	)
	begin 

		
		select @subfamiliaId = isnull(max(Clave),0) +1
		from cat_subfamilias

				insert into cat_subfamilias(Clave,Descripcion,Familia,Estatus,
		Empresa,Sucursal)
		select @subfamiliaId,@pSubfamilia,@familiaiD,1,
		@pEmpresa,1
	end

	


	if(
		isnull(@marcaId,0) = 0
	)
	begin 
		select @marcaId = isnull(max(Clave),0) +1
		from cat_marcas

		insert into cat_marcas(Clave,Descripcion,Estatus,Empresa,Sucursal)
		select @marcaId,@pMarca,1,1,1
	end

	

	if(
		isnull(@unidadId,0) = 0
	)
	begin 
		select @unidadId = isnull(max(Clave),0) +1
		from cat_unidadesmed

		insert into cat_unidadesmed(
			Clave,		Descripcion,	DescripcionCorta,Decimales,
			Estatus,	Empresa,		Sucursal,		IdCodigoSAT
		)
		select @unidadId,@pUnidad,@pUnidad,0,
		1,@pEmpresa,1,null
	end

	if(
		isnull(@unidadInventario,0) = 0
	)
	begin 
		select @unidadInventario = isnull(max(Clave),0) +1
		from cat_unidadesmed

		insert into cat_unidadesmed(
			Clave,		Descripcion,	DescripcionCorta,Decimales,
			Estatus,	Empresa,		Sucursal,		IdCodigoSAT
		)
		select @unidadInventario,@pUnidadInventario,@pUnidadInventario,0,
		1,@pEmpresa,1,null
	end

	
	if(
		isnull(@unidadVenta,0) = 0
	)
	begin 
		select @unidadVenta = isnull(max(Clave),0) +1
		from cat_unidadesmed

		insert into cat_unidadesmed(
			Clave,		Descripcion,	DescripcionCorta,Decimales,
			Estatus,	Empresa,		Sucursal,		IdCodigoSAT
		)
		select @unidadVenta,@pUnidadVenta,@pUnidadVenta,0,
		1,@pEmpresa,1,null
	end

	

	
	--Si el producto no existe
	if(ISNULL(@productoId,0) = 0 and isnull(@pClaveProducto,'') != '')
	begin

		SELECT @productoId = isnull(max(ProductoId),0)+1
		FROM cat_productos

		insert into cat_productos(
		Empresa,			Sucursal,
			ProductoId,		ClaveLinea,		ClaveFamilia,		Descripcion,
			DescripcionCorta,Estatus,		Clave,				NumeroDecimales,
			PorcDescuentoEmpleado,ContenidoCaja,ProductoTerminado,Inventariable,
			MateriaPrima,	ProdParaVenta,	ProdVtaBascula,		Seriado,
			FechaAlta	,	ClaveMarca,		ClaveSubfamilia,
			--
			Talla,			ParaSexo,		Color,				Color2,
			SobrePedido,	ClaveUnidadMedida,ClaveInventariadoPor,ClaveVendidaPor,
			Version,		MaximoInventario, MinimoInventario, CodigoBarras
			)
		select 
			@pEmpresa,@pSucursalId,
			@productoId,@lineaId,@familiaId,@pDescripcionLarga,
			@pDescripcionCorta,@pProductoActivo,@pClaveProducto,				0,
			0,				@pCantidadProductoCaja,				isnull(@pProductoTerminado,0),					isnull(@pProductoInventariable,0),
			@pMateriaPrima,	@pProdParaVenta,@pProductoBascula,					@pProductoSeriado,
			GETDATE(),		@marcaId,		@subfamiliaId,
			@pTalla,		@pParaSexo,		@pColor,			@pColor2,
			@pSobrePedido,	@unidadId,		@unidadInventario, @unidadVenta,
			@pVersion,		@pMaximoInventario,	@pMinimoInventario,@pCodigoBarras

		if isnull(@pUnidadLicencia ,'')<> ''
		begin

			insert into cat_productos_licencias(ProductoId,TiempoLicencia,UnidadLicencia,CreadoEl)
			select @productoId,@pCantidadLlicencia,@pUnidadLicencia,getdate()
		end
		

		declare @IdProductoPrecio int

		select @IdProductoPrecio = isnull(max(IdProductoPrecio),0) + 1
		from cat_productos_precios

		--
		insert into cat_productos_precios(
			IdProductoPrecio,IdProducto,IdPrecio,
			PorcDescuento,MontoDescuento,Precio)
		select @IdProductoPrecio + IdPrecio,@productoId,
		IdPrecio,0,0, case when IdPrecio = 1 then @pPrecio else 0 end
		from cat_precios

		

		insert into cat_productos_existencias(
			ProductoId,		SucursalId,		ExistenciaTeorica,		CostoUltimaCompra,
			CostoPromedio,	ValCostoUltimaCompra,ValCostoPromedio,	ModificadoEl,
			CreadoEl,		CostoPromedioInicial
		)
		select @productoId,@pSucursalId,isnull(@pExistencias,0),isnull(@pCostoUltimaCompra,0),
		isnull(@pCostoPromedio,0),0,0,getdate(),
		getdate(),			isnull(@pCostoPromedio,0)		
		
		
		

		/**********Insertar carga inicial***********/
		declare @cargainventarioId int

		if not exists(
			select 1
			from [doc_inv_carga_inicial]
			where productoId = @productoId and
			SucursalId = @pSucursalId
		)
		begin
				select @cargainventarioId = isnull(max(cargainventarioId),0)+1
				from [doc_inv_carga_inicial]

				insert into [doc_inv_carga_inicial](
					CargaInventarioId,	SucursalId,		ProductoId,		Cantidad,
					CostoPromedio,		UltimoCosto,		CreadoEl,	CreadoPor
				)
				select @cargainventarioId,@pSucursalId,	@productoId,	@pExistencias,
				isnull(@pCostoPromedio,0),		isnull(@pCostoUltimaCompra,0),			getdate(),		@pCreadoPor

		
				/***Insertar movimiento de inventario*****/
		
				select @movimiento = isnull(max(MovimientoId),0) + 1
				from [dbo].[doc_inv_movimiento]

				select @folio = isnull(max(Consecutivo),0) + 1
				from [dbo].[doc_inv_movimiento]
				where TipoMovimientoId = 1 --CargaInicial


				insert into [dbo].[doc_inv_movimiento](
					MovimientoId,	SucursalId,		FolioMovimiento,	TipoMovimientoId,
					FechaMovimiento,HoraMovimiento,	Comentarios,		ImporteTotal,
					Activo,			CreadoPor,		CreadoEl,			Autorizado,
					FechaAutoriza,	SucursalDestinoId,AutorizadoPor,	FechaCancelacion,
					ProductoCompraId,Consecutivo,	SucursalOrigenId,	VentaId,
					MovimientoRefId,Cancelado
				)
				select @movimiento,@pSucursalId,cast(@folio as varchar),	1,
				getdate(),			getdate(),		'Importaci�n Productos Excel',isnull(@pPrecio,0)*isnull(@pExistencias,0),
				1,					@pCreadoPor,	getdate(),			1,
				getdate(),			null,			@pCreadoPor,		null,
				null,				@folio,			null,				null,
				null,				null



				select @movimientoDetalle = isnull(max(MovimientoDetalleId),0) +1
				from [doc_inv_movimiento_detalle]

				insert into [dbo].[doc_inv_movimiento_detalle](
					MovimientoDetalleId,	MovimientoId,	ProductoId,		Consecutivo,
					Cantidad,				PrecioUnitario,	Importe,		Disponible,
					CreadoPor,				CreadoEl,		CostoUltimaCompra,CostoPromedio,
					ValCostoUltimaCompra,	ValCostoPromedio,ValorMovimiento
				)
				select @movimientoDetalle,	@movimiento,	@productoId,	1,
					isnull(@pExistencias,0),isnull(@pPrecio,0),isnull(@pPrecio,0)*isnull(@pExistencias,0),isnull(@pExistencias,0),
					@pCreadoPor,			GETDATE(),		isnull(@pCostoUltimaCompra,0),isnull(@pCostoPromedio,0),
					isnull(@pCostoUltimaCompra,0) * @pExistencias,isnull(@pCostoPromedio,0) * @pExistencias,				isnull(@pCostoPromedio,0) * @pExistencias
			
		
				
		End

		



		if @pIVA > 0
		begin
			declare @ProductoImpuestoId int

			select @ProductoImpuestoId = isnull(max(ProductoImpuestoId),0)+1
			from cat_productos_impuestos

			insert into cat_productos_impuestos(
				ProductoImpuestoId,ProductoId,ImpuestoId
			)
			select @ProductoImpuestoId,@productoId,1 --IVA

			
			
		end

		
		--Guardar Bitacora
		insert into doc_productos_importacion_bitacora(
			UUID,		ProductoId,		TipoMovimientoInventarioId,		Cantidad,
			CreadoEl,	CreadoPor
		)
		select @uuid,	@productoId,	1,								@pExistencias,
		GETDATE(),		@pCreadoPor


		SET @pInsertado = 1

	end
	--si el producto no existe
	else
	begin

		/*Generar el movimiento de inventario solo si tiene existencias en 0 para la sucursal*/
		if not exists (
			select 1 
			from cat_productos_existencias
			where ProductoId = @productoId and
			SucursalId = @pSucursalId and
			isnull(ExistenciaTeorica,0) > 0
		)
		AND @productoId > 0		
		BEGIN

			if not exists (
				select 1
				from cat_productos_existencias
				where ProductoId = @productoId and
				SucursalId = @pSucursalId
			)
			BEGIN
				INSERT INTO cat_productos_existencias(
					ProductoId,SucursalId,ExistenciaTeorica,CostoUltimaCompra,
					CostoPromedio,ValCostoUltimaCompra,ValCostoPromedio,ModificadoEl,
					CreadoEl,Apartado,Disponible,CostoPromedioInicial
				)
				select @productoId,@pSucursalId,0,0,
				0,0,0,getdate(),
				getdate(),0,0,0
			END


			if(isnull(@pExistencias,0) > 0)
			BEGIN
			
			--generar entrada directa
			/***Insertar movimiento de inventario*****/
		
			select @movimiento = isnull(max(MovimientoId),0) + 1
			from [dbo].[doc_inv_movimiento]

			select @folio = isnull(max(Consecutivo),0) + 1
			from [dbo].[doc_inv_movimiento]
			where TipoMovimientoId = 7 --Entrada Directa


			insert into [dbo].[doc_inv_movimiento](
				MovimientoId,	SucursalId,		FolioMovimiento,	TipoMovimientoId,
				FechaMovimiento,HoraMovimiento,	Comentarios,		ImporteTotal,
				Activo,			CreadoPor,		CreadoEl,			Autorizado,
				FechaAutoriza,	SucursalDestinoId,AutorizadoPor,	FechaCancelacion,
				ProductoCompraId,Consecutivo,	SucursalOrigenId,	VentaId,
				MovimientoRefId,Cancelado
			)
			select @movimiento,@pSucursalId,cast(@folio as varchar),	7,
			getdate(),			getdate(),		'Importación Productos Excel',isnull(@pPrecio,0)*isnull(@pExistencias,0),
			1,					@pCreadoPor,	getdate(),			1,
			getdate(),			null,			@pCreadoPor,		null,
			null,				isnull(@folio,'1'),			null,				null,
			null,				null

			select @movimientoDetalle = isnull(max(MovimientoDetalleId),0) +1
			from [doc_inv_movimiento_detalle]

			insert into [dbo].[doc_inv_movimiento_detalle](
				MovimientoDetalleId,	MovimientoId,	ProductoId,		Consecutivo,
				Cantidad,				PrecioUnitario,	Importe,		Disponible,
				CreadoPor,				CreadoEl,		CostoUltimaCompra,CostoPromedio,
				ValCostoUltimaCompra,	ValCostoPromedio,ValorMovimiento
			)
			select @movimientoDetalle,	@movimiento,	@productoId,	1,
				isnull(@pExistencias,0),isnull(@pPrecio,0),isnull(@pPrecio,0)*isnull(@pExistencias,0),isnull(@pExistencias,0),
				@pCreadoPor,			GETDATE(),		isnull(@pCostoUltimaCompra,0),			isnull(@pCostoPromedio,0),
				isnull(@pCostoUltimaCompra,0) * isnull(@pExistencias,0),						0,				0

			END
			
		END	
		--Guardar Bitacora
		insert into doc_productos_importacion_bitacora(
			UUID,		ProductoId,		TipoMovimientoInventarioId,		Cantidad,
			CreadoEl,	CreadoPor
		)
		select @uuid,	@productoId,	7,								@pExistencias,
		GETDATE(),		@pCreadoPor


	end

	COMMIT TRAN
	
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @pError = isnull(@pError,'') + ERROR_MESSAGE() +  ' Line '+CAST(ERROR_LINE() AS VARCHAR) + ERROR_PROCEDURE()
	END CATCH


END













GO
/****** Object:  StoredProcedure [dbo].[p_productos_importacion_bitacora_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_productos_importacion_bitacora_sel]
as

	select UUID,
		  Fecha = convert(varchar,CreadoEl,103),
		  Producto = sum(cantidad)
	from [dbo].[doc_productos_importacion_bitacora]
	group by UUID,convert(varchar,CreadoEl,103)
	order by convert(varchar,CreadoEl,103) desc
GO
/****** Object:  StoredProcedure [dbo].[p_productos_importacion_validar]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_productos_importacion_validar 1,1,''
create proc [dbo].[p_productos_importacion_validar]
@pSucursald int,
@pProductoId int
as

	declare @respuesta as bit

	if exists (select 1
	from doc_inv_movimiento m
	inner join doc_inv_movimiento_detalle md on md.MovimientoId = m.MovimientoId
	where SucursalId = @pSucursald and
	md.ProductoId = @pProductoId and
	m.Activo = 1 and
	m.TipoMovimientoId in (1,7) and
	convert(varchar,m.FechaMovimiento,112) = convert(varchar,GETDATE(),112))
	begin
		set @respuesta = 1
	end
	Else
	Begin
		set @respuesta = 0
		
	End

	select Respuesta = @respuesta

	
GO
/****** Object:  StoredProcedure [dbo].[p_productos_precio_grd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_productos_precio_grd 1
CREATE PROC [dbo].[p_productos_precio_grd]
@pIdProducto int
as

	select pp.IdProductoPrecio,
		   p.IdPrecio,
		   p.Descripcion,
		   pp.PorcDescuento,
		   pp.MontoDescuento,
		   pp.Precio
	from [cat_precios] p
	left join cat_productos_precios pp on pp.IdProducto = @pIdProducto and
									pp.IdPrecio = p.IdPrecio





GO
/****** Object:  StoredProcedure [dbo].[p_productos_sobrantes_grd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_productos_sobrantes_grd 48,'20231211'
CREATE PROC [dbo].[p_productos_sobrantes_grd]
@SucursalId INT,
@Fecha DATETIME
AS
BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

IF NOT EXISTS (
	SELECT 1
	FROM cat_sucursales_productos 
	where SucursalId = @SucursalId and
	ProductoId = 45
) AND
EXISTS(
	SELECT 1
	FROM cat_sucursales_productos 
	where SucursalId = @SucursalId 
)
BEGIN
	INSERT INTO cat_sucursales_productos (
	SucursalId,ProductoId,CreadoEl	)
	values(@SucursalId,45,GETDATE())
END

DECLARE @ExcluirBascula BIT=0,
	@SoloProductosGranel BIT=0

CREATE TABLE #TMP_EXCLUIR_CLAVES( Clave VARCHAR(200))

INSERT INTO #TMP_EXCLUIR_CLAVES(Clave)
SELECT PS.Valor
FROM sis_preferencias_sucursales PS
INNER JOIN sis_preferencias P ON P.Id = PS.PreferenciaId
WHERE P.Preferencia IN( 'MAIZ-SACO-CLAVE', 'MASECA-SACO-CLAVE') AND
PS.SucursalId = @SucursalId
UNION
SELECT PS.Valor
FROM sis_preferencias_empresa PS
INNER JOIN sis_preferencias P ON P.Id = PS.PreferenciaId
WHERE P.Preferencia IN( 'MAIZ-SACO-CLAVE', 'MASECA-SACO-CLAVE') 


SELECT  @SoloProductosGranel = dbo.fnPreferenciaAplicaSiNo('SOB-SoloProdBascula',@SucursalId)


/********EXCLUIR BASCULA*******************/

SELECT @ExcluirBascula = CASE WHEN PS.PreferenciaId IS NOT NULL THEN 1 ELSE 0  END
FROM sis_preferencias_sucursales PS
INNER JOIN sis_preferencias P ON P.Id = PS.PreferenciaId AND
						P.Preferencia = 'SOBRANTE-QuitarBasculaEnCaptura'
WHERE SucursalId = @SucursalId 

IF ISNULL(@ExcluirBascula,0) = 0
BEGIN
	SELECT @ExcluirBascula = CASE WHEN PS.PreferenciaId IS NOT NULL THEN 1 ELSE 0  END
	FROM sis_preferencias_empresa PS
	INNER JOIN sis_preferencias P ON P.Id = PS.PreferenciaId AND
							P.Preferencia = 'SOBRANTE-QuitarBasculaEnCaptura'
	INNER JOIN cat_sucursales S ON S.Clave = @SucursalId
	INNER JOIN cat_empresas E ON E.Clave = S.Empresa 
END

SELECT PSR.ProductoId,
		PSR.SucursalId,
		CantidadSobrante = cast(SUM(PSR.CantidadSobrante) as decimal(14,3)),
		PSR.Cerrado
INTO #TMP_ProdcutoSobrante
FROM doc_productos_sobrantes_registro PSR
WHERE PSR.SucursalId = @SucursalId AND
CONVERT(VARCHAR,PSR.CreadoEl,112) = CONVERT(VARCHAR,@Fecha,112)
GROUP BY PSR.ProductoId,
		PSR.SucursalId,
		PSR.Cerrado

INSERT INTO #TMP_ProdcutoSobrante(ProductoId,SucursalId,CantidadSobrante,Cerrado)
SELECT psc.ProductoSobranteId,@SucursalId,0,0
FROM doc_productos_sobrantes_config PSC 
INNER JOIN cat_sucursales S ON S.Empresa = PSC.EmpresaId AND
							S.Clave = @SucursalId
AND NOT EXISTS (
	SELECT 1
	FROM #TMP_ProdcutoSobrante S1
	WHERE S1.ProductoId = PSC.ProductoSobranteId
)


		
SELECT 
	p.ProductoId,
	P.Clave,
	P.Descripcion,
	Existencia = ISNULL(MAX(PE.ExistenciaTeorica),0),
	Fecha = @Fecha,
	CantidadSobrante = ISNULL(PSR.CantidadSobrante,0),
	RequiereBascula =CAST( CASE WHEN @ExcluirBascula = 1 THEN 0 ELSE P.ProdVtaBascula END AS bit)

FROM cat_productos P
left JOIN cat_productos_existencias PE ON PE.ProductoId = P.ProductoId AND PE.SucursalId = @SucursalId
LEFT JOIN doc_inv_movimiento_detalle IMD ON IMD.ProductoId = P.ProductoId
LEFT JOIN doc_inv_movimiento IM ON IM.MovimientoId = IMD.MovimientoId AND
								CONVERT(VARCHAR,IM.FechaMovimiento,112) = CONVERT(VARCHAR,@Fecha,112)
LEFT JOIN #TMP_ProdcutoSobrante PSR ON PSR.ProductoId = P.ProductoId AND
												PSR.SucursalId = @SucursalId 
LEFT JOIN doc_productos_sobrantes_config PSC  ON PSC.ProductoSobranteId = P.ProductoId
WHERE (
			(
					PE.SucursalId = @SucursalId  AND
					(
						(IM.MovimientoId IS NOT NULL OR ISNULL(PE.ExistenciaTeorica,0) > 0) OR
						PSC.ProductoSobranteId IS NOT NULL	

					) 
			) 
			OR
			(
				PSR.SucursalId =@SucursalId 
			)
)
AND ISNULL(PSR.Cerrado,0) = 0
AND P.Descripcion NOT LIKE '%FRIA%'
AND P.CLAVE NOT IN (SELECT Clave FROM #TMP_EXCLUIR_CLAVES)
AND ((@SoloProductosGranel = 1 AND P.ProdVtaBascula = 1) OR  @SoloProductosGranel = 0)

GROUP BY 
	P.ProductoId,
	P.Clave,
	P.Descripcion,
	PSR.CantidadSobrante,
	 P.ProdVtaBascula,
	 P.Orden
ORDER BY P.ProdVtaBascula DESC,P.ORDEN ,P.Descripcion

DROP TABLE #TMP_ProdcutoSobrante


SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

END
GO
/****** Object:  StoredProcedure [dbo].[p_punto_venta_validar_sesion]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_punto_venta_validar_sesion 2,1,'',0
CREATE proc [dbo].[p_punto_venta_validar_sesion]
@pUsuarioId int,
@pCajaId int,
@pError varchar(250) out,
@pSesionId int out
as	

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

		declare @usuarioActivo varchar(100)='',
				@essupervisor bit = 0
		set @pError = ''
		set @pSesionId = 0


		select @essupervisor = EsSupervisor
		from cat_usuarios 
		where IdUsuario = @pUsuarioId

		
		select @usuarioActivo = ua.NombreUsuario
		from doc_sesiones_punto_venta  s
		inner join cat_usuarios u on u.IdUsuario = @pUsuarioId and u.Activo = 1 and
									isnull(u.EsSupervisor,0) =0
									
		inner join cat_usuarios ua on ua.IdUsuario = s.UsuarioId and
								ua.IdUsuario <> @pUsuarioId
		where s.CajaId = @pCajaId and
		s.Finalizada = 0
	
		--if exists(
		--	select 1
		--	from doc_ventas v 
		--	--inner join doc_corte_caja_ventas ccv on ccv.VentaId = v.VentaId 
		--	where v.CajaId = @pCajaId and
		--	UsuarioCreacionId <> @pUsuarioId and
		--	not exists(
		--		select 1
		--		from doc_corte_caja_ventas cvv where cvv.VentaId = v.VentaId
		--	)
		--)AND
		--@essupervisor = 0
		--BEGIN
			
		--	select TOP 1 @pError= @pError + 'Existen un corte pendiente por otro usuario: ' + ISNULL(U.NombreUsuario,'')
		--	from doc_ventas v 
		--	INNER JOIN cat_usuarios U ON U.IdUsuario = v.UsuarioCreacionId
		--	where v.CajaId = @pCajaId and
		--	UsuarioCreacionId <> @pUsuarioId and
		--	not exists(
		--		select 1
		--		from doc_corte_caja_ventas cvv where cvv.VentaId = v.VentaId
		--	)
		--END
		
		if @pError = ''
		begin 
			select @pSesionId = s.SesionId
			from doc_sesiones_punto_venta  s		
			inner join cat_usuarios ua on ua.IdUsuario = s.UsuarioId
			where s.CajaId = @pCajaId and
			s.Finalizada = 0 and			
			ua.IdUsuario = @pUsuarioId
		end


	
GO
/****** Object:  StoredProcedure [dbo].[p_pv_cargos_adicionales_grd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_pv_cargos_adicionales_grd 1
create proc [dbo].[p_pv_cargos_adicionales_grd]
@pSucursalId int
as

	select
		a.CargoAdicionalId,
		a.Descripcion,
		Detalle = case when isnull(b.PorcentajeVenta,0) > 0 then cast(isnull(b.PorcentajeVenta,0) as varchar)+' % '
						when isnull(b.MontoFijo,0) > 0 then '$' + cast(isnull(b.MontoFijo,0) as varchar)
				end,
		Seleccion = cast(0 as bit)
	from cat_cargos_adicionales a
	inner join doc_cargo_adicional_config b on b.CargoAdicionalId = a.CargoAdicionalId
	where b.SucursalId = @pSucursalId and
	b.Activo = 1 
	
GO
/****** Object:  StoredProcedure [dbo].[p_retiro_automatico_SiNo]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
DW 20230602
Procedimiento almacenado que verifica si es necesario avisar al cajero que es necesario realizar un retiro 
*/

-- p_retiro_automatico_SiNo 4,3
CREATE PROC [dbo].[p_retiro_automatico_SiNo]
@pSucursalId INT,
@pCajaId INT
AS

	DECLARE @TotalVentas MONEY,
		@TotalRetiros MONEY,
		@CantidadRetiro MONEY

	IF(
		DBO.fnPreferenciaAplicaSiNo('PV-RetiroAutomatico',@pSucursalId) = 1
	)
	BEGIN

		
		SELECT @CantidadRetiro = CAST(ISNULL(dbo.fnGetPreferenciaValor('PV-RetiroAutomatico',@pSucursalId),'0') AS MONEY)
		

		IF(@CantidadRetiro > 0)
		BEGIN

			SELECT @TotalVentas = ISNULL(SUM(vfp.Cantidad),0)
			FROM doc_ventas V
			INNER JOIN doc_ventas_formas_pago VFP ON VFP.VentaId = v.VentaId AND
												VFP.FormaPagoId = 1 AND --EFECTIVO AND
												V.CajaId = @pCajaId AND
												V.Activo = 1
			WHERE CAST(V.Fecha AS DATE) = CAST(GETDATE() AS DATE) 

			SELECT @TotalRetiros = ISNULL(SUM(R.MontoRetiro),0)
			FROM doc_retiros R
			WHERE R.CajaId = @pCajaId AND
			CAST(R.FechaRetiro AS DATE) = CAST(getdate() AS DATE)

			
			IF((@TotalVentas - @TotalRetiros)>@CantidadRetiro)
			BEGIN
				SELECT AplicaSiNo = CAST(1 AS BIT),
				CantidadDisponibleRetiro = @TotalVentas - @TotalRetiros
			END
			ELSE
			BEGIN
				SELECT AplicaSiNo = CAST(0 AS BIT),
				CantidadDisponibleRetiro = @TotalVentas - @TotalRetiros
			END

		END
		ELSE
		BEGIN
			SELECT AplicaSiNo = CAST(0 AS BIT),
			CantidadDisponibleRetiro = 0
		END

	END
	ELSE
	BEGIN
		SELECT AplicaSiNo = 0,
			CantidadDisponibleRetiro = 0
	END


	
	
GO
/****** Object:  StoredProcedure [dbo].[p_rh_empleado_cliente_gen]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[p_rh_empleado_cliente_gen]
@pEmpleadoId int
as

	declare @clienteId int

	if not exists (
		select 1
		from cat_clientes
		where empleadoId = @pEmpleadoId
	)
	begin

		select @clienteId = isnull(max(ClienteId),0) +1
		from cat_clientes

		insert into cat_clientes(ClienteId,ApellidoPaterno,ApellidoMaterno,Nombre,
		Activo,EmpleadoId)
		select @clienteId,'','',Nombre,1,NumEmpleado
		from rh_empleados e
		where e.NumEmpleado = @pEmpleadoId

	end


	
GO
/****** Object:  StoredProcedure [dbo].[p_rh_empleado_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[p_rh_empleado_sel]
@pUsuarioId INT
AS

	SELECT RH.*
	FROM rh_empleados RH
	INNER JOIN cat_usuarios U ON U.IdEmpleado = RH.NumEmpleado
	WHERE U.IdUsuario = @pUsuarioId
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_apartado_ticket]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_rpt_apartado_ticket 1,2
CREATE Proc [dbo].[p_rpt_apartado_ticket]
@pApartadoId int,
@pApartadoPagoId int
as

	select Folio = a.ApartadoId,
			FechaApartado = A.CreadoEl,
			PagoRealizado = p.Importe,
			FechaPago = p.FechaPago,
			TotalApartado,
			Saldo,
			Empresa = e.NombreComercial,
			Sucursal = s.NombreSucursal,
			a.FechaLimite,
			ExpedidoEn = RTRIM(s.Calle) + ' '+
						RTRIM(s.NoExt) + ' '+
						RTRIM(s.NoInt) + ' '+
						RTRIM(s.Colonia) + ' '+
						RTRIM(s.Ciudad) + ' '+
						RTRIM(s.Estado),
			a.ClienteId,
			Cliente = cli.Nombre,
			--------
			ClaveProducto = PROD.Clave,
			Producto = prod.Descripcion,
			Cantidad = pProd.Cantidad,
			Importe = pProd.Total,
			TextoCabecera1 = ISNULL(TextoCabecera1,''),
			TextoCabecera2 = ISNULL(TextoCabecera2,''),
			TextoPie = ISNULL(TextoPie,''),
			AnticipoAbono = case when p.Anticipo = 1 then 'APARTADO INICIAL' else 'ABONO APARTADO' end,
			Serie = isnull(confA.Serie,''),
			Atendio = rh.Nombre

	from doc_apartados a
	inner join cat_sucursales s on s.Clave = a.SucursalId
	inner join cat_clientes cli on cli.ClienteId = A.ClienteId
	inner join cat_empresas e on e.Clave = s.Empresa
	inner join doc_apartados_pagos p on p.ApartadoId = a.ApartadoId and
									p.ApartadoPagoId = @pApartadoPagoId
	inner join doc_apartados_productos pProd on pProd.ApartadoId = A.ApartadoId
	inner join cat_productos prod on prod.ProductoId = pProd.ProductoId
	inner join cat_usuarios usu on usu.IdUsuario = p.CreadoPor
	inner join rh_empleados rh on rh.NumEmpleado = usu.IdEmpleado
	LEFT JOIN cat_configuracion_ticket_apartado confA on confA.SucursalId = a.SucursalId
	where a.ApartadoId = @pApartadoId






GO
/****** Object:  StoredProcedure [dbo].[p_rpt_apartados]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_rpt_apartados 1,0,'20180601','20180801',1
CREATE proc [dbo].[p_rpt_apartados]
@pSucursalId int,
@pCliente int,
@pDel datetime,
@pAl datetime,
@pSoloVencido bit
as

	select 
		Del = @pDel,
		Al = @pAl,
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		Cliente = a.ClienteId,
		Nombre = c.Nombre,
		FechaApartado = a.CreadoEl,
		a.FechaLimite,
		Folio = a.ApartadoId,
		Clave = max(p.Clave),
		SaldoPorVencer30 = (
			select isnull(sum(s1.Saldo),0)
			from doc_apartados s1
			where s1.ApartadoId = a.ApartadoId and
			DATEDIFF ( day , getdate() , a.FechaLimite ) <= 30 and
			a.FechaLimite > getdate()
		),
		SaldoVencido30 = (
			select isnull(sum(s1.Saldo),0)
			from doc_apartados s1
			where s1.ApartadoId = a.ApartadoId and
			DATEDIFF ( day , getdate() , a.FechaLimite ) >= 30 and
			a.FechaLimite < getdate()
		),
		SaldoTotal = a.Saldo,
		Telefono = isnull(c.Telefono,c.Telefono2)
	from doc_apartados a
	inner join doc_apartados_productos ap on ap.Apartadoid = a.ApartadoId
	inner join cat_clientes c on c.Clienteid = a.ClienteId
	inner join cat_productos p on p.Productoid = ap.ProductoId
	inner join cat_sucursales suc on suc.Clave = a.SucursalId
	inner join cat_empresas emp on emp.clave = suc.Empresa
	
	where a.SucursalId = @pSucursalId and
	(
		(
			convert(varchar,a.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112)  and 
			@pSoloVencido = 0
		)
		OR
		(a.FechaLimite < getdate() and @pSoloVencido = 1 )
	)
	and
	a.Activo = 1 and
	a.saldo > 0 and
	@pCliente in (0,a.ClienteId)
	group by  a.ClienteId,
		 c.Nombre,
		 a.CreadoEl,
		 a.ApartadoId,
		 a.FechaLimite,
		 a.Saldo,
		 emp.NombreComercial,suc.NombreSucursal,
		 c.Telefono,
		 c.Telefono2

	order by a.ClienteId,a.CreadoEl
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_bascula_bitacora]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******IMPORTANTE!!!!!
TODAS LAS MODIFICACIONES A ESTE SP REPLICARLAS EN EL SP p_corte_caja_inventario_generacion, en la sección de PESO INTELIGENTE

************/

-- p_rpt_bascula_bitacora '20221229','20221229',10,0
CREATE proc [dbo].[p_rpt_bascula_bitacora]
@pFechaIni DateTime,
@pFechaFin DateTime,
@pSucursalId int,
@pUsuarioId INT=0
as
BEGIN


	CREATE TABLE #TMP_RESULT(
		Id INT,
		BasculaId INT,
		Sucursal VARCHAR(250),
		Cantidad DECIMAL(14,2),
		Fecha DATETIME,
		TipoMovimiento VARCHAR(250),
		ClaveProducto VARCHAR(100),
		Producto VARCHAR(500)
	)

	/********************INDEFINIDOS*******************/    
	 SELECT     
	  ID= IDENTITY(INT,1,1),    
	  ProductoId = NULL,    
	  Clave = NULL,    
	  DescripcionCorta = 'INDEFINIDO',    
	  BB.Cantidad,    
	  TipoBasculaBitacoraId= CASE WHEN BB.TipoBasculaBitacoraId IS NULL THEN 0 ELSE BB.TipoBasculaBitacoraId  END ,    
	  Tipo = ISNULL(TBB.Nombre,'INDEFINIDO'),    
	  BB.Fecha,    
	  Hora = DATEPART(HH,BB.Fecha),    
	  Minuto = DATEPART(MM, BB.Fecha),    
	  Segundo = 0   ,
	  BB.BasculaId,
		BitacoraId = BB.Id
	 INTO #TMP_DATOS    
	 FROM doc_basculas_bitacora BB    
	 INNER join cat_tipos_bascula_bitacora TBB ON TBB.TipoBasculaBitacoraId = BB.TipoBasculaBitacoraId      
	 WHERE CONVERT(VARCHAR,Fecha,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND    
	 BB.ProductoId IS NULL AND    
	 TBB.TipoBasculaBitacoraId = 4   AND
	 BB.VentaId IS NULL
	 ORDER BY BB.Fecha     


	 /********************TORTILLA/MASA VENTA*****************r**/    
 
	  INSERT INTO  #TMP_DATOS(ProductoId,Clave,DescripcionCorta,Cantidad,TipoBasculaBitacoraId,Tipo,Fecha,Hora,Minuto,Segundo,BasculaId,BitacoraId)    
	 SELECT     
      
	  ProductoId = P.ProductoId,    
	  Clave = ISNULL(P.Clave,''),    
	  DescripcionCorta = ISNULL(p.DescripcionCorta,'INDEFINIDO'),    
	  BB.Cantidad,    
	  TipoBasculaBitacoraId= CASE WHEN BB.TipoBasculaBitacoraId IS NULL THEN 0 ELSE BB.TipoBasculaBitacoraId  END ,    
	  Tipo = ISNULL(TBB.Nombre,'INDEFINIDO'),    
	  BB.Fecha,    
	  Hora = DATEPART(HH,BB.Fecha),    
	  Minuto = DATEPART(MM, BB.Fecha),    
	  Segundo = DATEPART(SECOND,BB.Fecha)    ,
	  BB.BasculaId,
	  BB.Id
     
	 FROM doc_basculas_bitacora BB    
	 INNER JOIN cat_productos P ON P.ProductoId = BB.ProductoId    
	 INNER join cat_tipos_bascula_bitacora TBB ON TBB.TipoBasculaBitacoraId = BB.TipoBasculaBitacoraId    
	 INNER JOIN doc_ventas V ON V.VentaId = BB.VentaId AND V.ClienteId IS NULL 
	 WHERE CONVERT(VARCHAR,BB.Fecha,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND    
	 --BB.SucursalId = @pSucursalId AND    
	 P.productoid IN (1,2) AND    
	 BB.TipoBasculaBitacoraId  = 1 AND--VENTA MOSTRADOR    
	 BB.VentaId IS NOT NULL 
 
	 group by P.Clave,P.ProductoId,p.DescripcionCorta,BB.Fecha,BB.Cantidad,BB.TipoBasculaBitacoraId,TBB.Nombre     , BB.BasculaId  , BB.Id
	 ORDER BY BB.Fecha    


	  /********************TORTILLA/MASA VENTA PEDIDO PAGADOS*****************r**/    
 
	   INSERT INTO  #TMP_DATOS(ProductoId,Clave,DescripcionCorta,Cantidad,TipoBasculaBitacoraId,Tipo,Fecha,Hora,Minuto,Segundo,BasculaId,BitacoraId)    
	 SELECT     
      
	  ProductoId = P.ProductoId,    
	  Clave = ISNULL(P.Clave,''),    
	  DescripcionCorta = ISNULL(p.DescripcionCorta,'INDEFINIDO'),    
	  BB.Cantidad,    
	  TipoBasculaBitacoraId= CASE WHEN BB.TipoBasculaBitacoraId IS NULL THEN 0 ELSE BB.TipoBasculaBitacoraId  END ,    
	  Tipo = ISNULL('VENTA MAYOREO PAGADO','INDEFINIDO'),    
	  BB.Fecha,    
	  Hora = DATEPART(HH,BB.Fecha),    
	  Minuto = DATEPART(MM, BB.Fecha),    
	  Segundo = DATEPART(SECOND,BB.Fecha)   ,
     BB.BasculaId,
	  BB.Id
	 FROM doc_basculas_bitacora BB    
	 INNER JOIN cat_productos P ON P.ProductoId = BB.ProductoId    
	 INNER join cat_tipos_bascula_bitacora TBB ON TBB.TipoBasculaBitacoraId = BB.TipoBasculaBitacoraId    
	 INNER JOIN doc_ventas V ON V.VentaId = BB.VentaId AND V.ClienteId IS NOT NULL 
	 WHERE CONVERT(VARCHAR,BB.Fecha,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND    
	 --BB.SucursalId = @pSucursalId AND    
	 P.productoid IN (1,2) AND    
	 BB.TipoBasculaBitacoraId  = 1 AND--VENTA MOSTRADOR    
	 BB.VentaId IS NOT NULL 
 
	 group by P.Clave,P.ProductoId,p.DescripcionCorta,BB.Fecha,BB.Cantidad,BB.TipoBasculaBitacoraId,TBB.Nombre   , BB.BasculaId    , BB.Id
	 ORDER BY BB.Fecha    
    
    
    
	 /********************TORTILLA/MASA PRECIO EMPLEADO*****************r**/    
	 INSERT INTO  #TMP_DATOS(ProductoId,Clave,DescripcionCorta,Cantidad,TipoBasculaBitacoraId,Tipo,Fecha,Hora,Minuto,Segundo,BasculaId,BitacoraId)    
	 SELECT     
      
	  ProductoId = P.ProductoId,    
	  Clave = ISNULL(P.Clave,''),    
	  DescripcionCorta = ISNULL(p.DescripcionCorta,'INDEFINIDO'),    
	  BB.Cantidad,    
	  TipoBasculaBitacoraId= CASE WHEN BB.TipoBasculaBitacoraId IS NULL THEN 0 ELSE BB.TipoBasculaBitacoraId  END ,    
	  Tipo = ISNULL(TBB.Nombre,'INDEFINIDO'),    
	  BB.Fecha,    
	  Hora = DATEPART(HH,BB.Fecha),    
	  Minuto = DATEPART(MM, BB.Fecha),    
	  Segundo = DATEPART(SECOND,BB.Fecha)    ,
     BB.BasculaId,
	  BB.Id
	 FROM doc_basculas_bitacora BB    
	 INNER JOIN cat_productos P ON P.ProductoId = BB.ProductoId    
	 INNER join cat_tipos_bascula_bitacora TBB ON TBB.TipoBasculaBitacoraId = BB.TipoBasculaBitacoraId    
   
	 WHERE CONVERT(VARCHAR,BB.Fecha,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND    
	 --BB.SucursalId = @pSucursalId AND    
	 P.productoid IN (1,2) AND    
	 BB.TipoBasculaBitacoraId  = 14 --PRECIO EMPLEADO    
	 group by P.Clave,P.ProductoId,p.DescripcionCorta,BB.Fecha,BB.Cantidad,BB.TipoBasculaBitacoraId,TBB.Nombre  , BB.BasculaId , BB.Id    
	 ORDER BY BB.Fecha    
    
    
    
	 /********************TORTILLA/MASA POR PAGAR*****************r**/    
	 INSERT INTO  #TMP_DATOS(ProductoId,Clave,DescripcionCorta,Cantidad,TipoBasculaBitacoraId,Tipo,Fecha,Hora,Minuto,Segundo,BasculaId,BitacoraId)    
	 SELECT     
      
	  ProductoId = P.ProductoId,    
	  Clave = ISNULL(P.Clave,''),    
	  DescripcionCorta = ISNULL(p.DescripcionCorta,'INDEFINIDO'),    
	  BB.Cantidad,    
	  TipoBasculaBitacoraId= CASE WHEN BB.TipoBasculaBitacoraId IS NULL THEN 0 ELSE BB.TipoBasculaBitacoraId  END ,    
	  Tipo = ISNULL('PEDIDO MAYOREO POR PAGAR','INDEFINIDO'),    
	  VD.CreadoEl,    
	  Hora = DATEPART(HH,VD.CreadoEl),    
	  Minuto = DATEPART(MM, VD.CreadoEl),    
	  Segundo = DATEPART(SECOND,VD.CreadoEl)  ,  
     BB.BasculaId,
	  BB.Id
	 FROM doc_basculas_bitacora BB    
	 INNER JOIN cat_productos P ON P.ProductoId = BB.ProductoId    
	 INNER join cat_tipos_bascula_bitacora TBB ON TBB.TipoBasculaBitacoraId = BB.TipoBasculaBitacoraId    
	 INNER JOIN doc_pedidos_orden_detalle VD ON VD.ProductoId = BB.ProductoId AND    
			 CONVERT(VARCHAR,VD.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND    
			 VD.Cantidad = BB.Cantidad     
	 WHERE CONVERT(VARCHAR,Fecha,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND    
	 --BB.SucursalId = @pSucursalId AND    
	 P.productoid IN (1,2) AND    
	 BB.TipoBasculaBitacoraId  = 15 --PRECIO EMPLEADO    
	 group by P.Clave,P.ProductoId,p.DescripcionCorta,VD.CreadoEl,BB.Cantidad,BB.TipoBasculaBitacoraId,TBB.Nombre  , BB.BasculaId  , BB.Id
	 ORDER BY VD.CreadoEl 
	 

	   --FILTRO DUPLICADOS
     
		 SELECT     
		  ID = MAX(ID),    
		  ProductoId,    
		  --Cantidad = MAX(Cantidad),    
		  TipoBasculaBitacoraId,    
		  --Fecha = MAX(Fecha),    
		  Tipo,    
		  Hora,    
		  Minuto,    
		  Segundo    
		 INTO #TMP_FILTRO_MOVS    
		 FROM #TMP_DATOS    
		 WHERE ISNULL(ProductoId,0) = 0    
		 GROUP BY ProductoId,Hora, Minuto,Segundo,TipoBasculaBitacoraId,Tipo    
     
    
    
		 INSERT INTO #TMP_FILTRO_MOVS    
		 SELECT     
		  ID = MAX(ID),    
		  ProductoId,      
		  TipoBasculaBitacoraId,      
		  Tipo,    
		  Hora,    
		  Minuto,    
		  0    
     
		 FROM #TMP_DATOS    
		 WHERE ISNULL(ProductoId,0) > 0    
		 GROUP BY ProductoId,Hora, Minuto,TipoBasculaBitacoraId,Tipo,ID    
	 


	 SELECT R.Id,
		R.BasculaId,
		Bascula = B.Alias,
		Sucursal = S.NombreSucursal,
		Cantidad = R.Cantidad,
		Fecha = R.Fecha,
		TipoMovimiento = UPPER(R.Tipo),
		ClaveProducto = P.Clave,
		Producto = P.Descripcion,
		r.BitacoraId
	 FROM #TMP_DATOS R
	 INNER JOIN #TMP_FILTRO_MOVS F ON F.ID = R.ID
	 INNER JOIN cat_basculas B ON B.BasculaId = R.BasculaId
	 INNER JOIN cat_sucursales S ON S.Clave = @pSucursalId
	 LEFT JOIN cat_productos P ON P.ProductoId = R.ProductoId
	

END

GO
/****** Object:  StoredProcedure [dbo].[p_rpt_clientes_apartados]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_clientes_apartados 1
create proc [dbo].[p_rpt_clientes_apartados]
@pSucursalId int
as

	select 
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		c.ClienteId,
		c.Nombre,
		Telefono = isnull(c.Telefono,c.Telefono2),
		FechaApartado = max(a.CreadoEl),
		FechaVencimiento = max(a.FechaLimite),
		Producto = max(p.Clave),
		Saldo = max(a.Saldo),
		a.Apartadoid
		
	from cat_clientes c
	inner join cat_sucursales suc on suc.Clave = @pSucursalId
	inner join cat_empresas emp on emp.clave = suc.Empresa
	left join doc_apartados a on a.ClienteId = c.ClienteId and
								a.Activo = 1 and
								a.Saldo > 0  and
								a.SucursalId = @pSucursalId
	left join doc_apartados_productos ap on ap.ApartadoId = a.ApartadoId 
	left join cat_productos p on p.ProductoId = ap.ProductoId
	group by c.ClienteId,c.Nombre,c.Telefono,c.Telefono2,a.ApartadoId,emp.NombreComercial,suc.NombreSucursal
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_Comanda]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- [p_rpt_Comanda] 39,0,1,''
CREATE proc [dbo].[p_rpt_Comanda]
@pPedidoId int,
@pComandaId int,
@pMarcarImpresos bit,
@pNotas varchar(250)
as

	select Fecha = GETDATE(),
		Folio = ISNULL(TP.Folio,'') + ISNULL(p.Folio,''),
		Cantidad = pd.Cantidad ,
		Descripcion = pd.Descripcion + dbo.fnGetComandaAdicionales(pd.PedidoDetalleId) + CASE WHEN ISNULL(Pd.Parallevar,0) = 1 THEN '(LL)' ELSE '(M)' END,
		pd.Parallevar,
		Mesas = dbo.fnGetComandaMesas(@pPedidoId),
		Para = '',/*case when isnull(pd.Parallevar,0) = 1 then 'PARA LLEVAR' 
				when isnull(pd.Parallevar,0) = 0 then 'PARA MESA' 
				end*/
		Notas = ISNULL(@pNotas,'') + ISNULL(p.Notas,''),
		Recibe = p.Para,
		Mesero = u.NombreUsuario
	from doc_pedidos_orden p
	inner join doc_pedidos_orden_detalle pd on pd.PedidoId = p.PedidoId
	LEFT join cat_rest_comandas com on com.ComandaId = pd.ComandaId
	inner join cat_productos prod on prod.ProductoId = pd.ProductoId
	INNER join cat_usuarios u on u.IdUsuario = p.CreadoPor
	LEFT JOIN	cat_tipos_pedido TP ON TP.TipoPedidoId = p.TipoPedidoId
	where p.PedidoId = @pPedidoId and isnull(Impreso,0) = 0
	and isnull(pd.Cancelado,0) = 0 
	and prod.productoId > 0
	--and
	--@pComandaId in (pd.ComandaId ,0 )
	order by cast(pd.Parallevar as int) ASC,pd.CreadoEl

	if(@pMarcarImpresos = 1)
	begin

		update doc_pedidos_orden_detalle
		set Impreso = 1		
		where PedidoId = @pPedidoId and
		isnull(Impreso,0) = 0

	end


	--update doc_pedidos_orden
	--set Total = (select isnull(sum(Total),0) from doc_pedidos_orden_detalle where PedidoId = @pPedidoId),
	--	Impuestos = (select isnull(sum(Impuestos),0) from doc_pedidos_orden_detalle where PedidoId = @pPedidoId)
	--where PedidoId = @pPedidoId

	--update doc_pedidos_orden
	--set Subtotal = Total-isnull(Impuestos,0)
	--where PedidoId = @pPedidoId

GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_apartados]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[p_rpt_corte_caja_apartados]
@pCorteCajaId int
as

	select Folio = a.ApartadoId,
		a.TotalApartado 
	from doc_apartados a
	inner join doc_corte_caja cc on cc.CorteCajaId = @pCorteCajaId 
	where a.CreadoEl between cc.FechaApertura and cc.FechaCorte and
	cc.CreadoPor = a.CreadoPor



GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_apartados_det]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_corte_caja_apartados_det 7
CREATE PROC [dbo].[p_rpt_corte_caja_apartados_det]
@pCorteCajaId int
as

	--Anticipos
	select Pagos = count(distinct a.ApartadoPagoId),
			TipoPago = 'Anticipo',
			Total = isnull(sum(a.Importe),0)
	from doc_apartados_pagos a
	inner join doc_corte_caja cc on cc.CorteCajaId = @pCorteCajaId 
	where a.FechaPago between cc.FechaApertura and cc.FechaCorte and
	cc.CreadoPor = a.CreadoPor and
	a.anticipo = 1
	having count(distinct a.ApartadoPagoId) > 0

	union

	select Pagos = count(distinct a.ApartadoPagoId),
			TipoPago = 'Abono',
			Total = sum(a.Importe)
	from doc_apartados_pagos a
	inner join doc_corte_caja cc on cc.CorteCajaId = @pCorteCajaId 
	where a.FechaPago between cc.FechaApertura and cc.FechaCorte and
	cc.CreadoPor = a.CreadoPor and
	a.anticipo = 0
	having count(distinct a.ApartadoPagoId) > 0




GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_apartados_det_previo]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_corte_caja_apartados_det 7
create PROC [dbo].[p_rpt_corte_caja_apartados_det_previo]
@pCorteCajaId int
as

	--Anticipos
	select Pagos = count(distinct a.ApartadoPagoId),
			TipoPago = 'Anticipo',
			Total = isnull(sum(a.Importe),0)
	from doc_apartados_pagos a
	inner join doc_corte_caja_previo cc on cc.CorteCajaId = @pCorteCajaId 
	where a.FechaPago between cc.FechaApertura and cc.FechaCorte and
	cc.CreadoPor = a.CreadoPor and
	a.anticipo = 1
	having count(distinct a.ApartadoPagoId) > 0

	union

	select Pagos = count(distinct a.ApartadoPagoId),
			TipoPago = 'Abono',
			Total = sum(a.Importe)
	from doc_apartados_pagos a
	inner join doc_corte_caja_previo cc on cc.CorteCajaId = @pCorteCajaId 
	where a.FechaPago between cc.FechaApertura and cc.FechaCorte and
	cc.CreadoPor = a.CreadoPor and
	a.anticipo = 0
	having count(distinct a.ApartadoPagoId) > 0




GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_apartados_previo]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_rpt_corte_caja_apartados_previo]
@pCorteCajaId int
as

	select Folio = a.ApartadoId,
		a.TotalApartado 
	from doc_apartados a
	inner join doc_corte_caja_previo cc on cc.CorteCajaId = @pCorteCajaId 
	where a.CreadoEl between cc.FechaApertura and cc.FechaCorte and
	cc.CreadoPor = a.CreadoPor



GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_cajero]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- p_rpt_corte_caja_cajero 4,'20221031',9
CREATE PROC [dbo].[p_rpt_corte_caja_cajero]
@pSucursalId INT,
@pFecha DateTime,
@pCajaId INT
AS

	DECLARE @montoVentasTelefono MONEY,
		@corteCajaId INT,
		@retiros MONEY,
		@gastos MONEY

	SELECT @montoVentasTelefono = SUM(V.TotalVenta)
	FROM doc_pedidos_orden PO
	INNER JOIN doc_ventas V ON V.VentaId = PO.VentaId
	WHERE PO.Activo = 1 AND
	CONVERT(VARCHAR,V.Fecha,112) = CONVERT(VARCHAR,@pFecha,112) AND
	PO.SucursalId = @pSucursalId AND
	PO.TipoPedidoId = 2 AND--Pedido Telefono
	V.CajaId = @pCajaId

	SELECT @corteCajaId = MAX(CorteCajaId)
	FROM doc_corte_caja
	where CajaId = @pCajaId AND
	CONVERT(VARCHAR,FechaCorte,112) = CONVERT(VARCHAR,@pFecha,112)
	
	SELECT @retiros = SUM(MontoRetiro)
	from doc_retiros
	WHERE SucursalId = @pSucursalId AND
	CajaId = @pCajaId  AND
	CONVERT(VARCHAR,FechaRetiro,112) = CONVERT(VARCHAR,@pFecha,112)

	
	

	SELECT	
			CC.CorteCajaId,
			Caja = C.Descripcion,
			CC.TotalCorte,
			CC.FechaCorte,
			HoraCorte = CONVERT(varchar,CC.FechaCorte,108),
			U.NombreUsuario,
			Efectivo = ISNULL(SUM(CFP.Total),0),
			OtrasFP = ISNULL(SUM(CFP2.Total),0),
			FondoInicial = ISNULL(FI.Total,0),
			Gastos = ISNULL(G.Gastos,0),
			Retiros = ISNULL(@retiros,0),
			TotalGlobal = ISNULL(MAX(CFP.Total),0) + ISNULL(SUM(CFP2.Total),0)  + ISNULL(FI.Total,0) -
						ISNULL(G.Gastos,0) -ISNULL(@retiros,0),
			Ingresado = ISNULL(SUM(CCD.Total),0),
			Faltante = CASE WHEN ISNULL(MAX(CFP.Total),0) + ISNULL(SUM(CFP2.Total),0)  + ISNULL(FI.Total,0) -
						ISNULL(G.Gastos,0) -ISNULL(@retiros,0) - ISNULL(SUM(CCD.Total),0) <= 0 THEN 0
						ELSE 
						ISNULL(MAX(CFP.Total),0) + ISNULL(SUM(CFP2.Total),0)  + ISNULL(FI.Total,0) -
						ISNULL(G.Gastos,0) -ISNULL(@retiros,0) - ISNULL(SUM(CCD.Total),0)
						END,
			Excedente = CASE WHEN ISNULL(MAX(CFP.Total),0) + ISNULL(SUM(CFP2.Total),0)  + ISNULL(FI.Total,0) -
						ISNULL(G.Gastos,0) -ISNULL(@retiros,0) - ISNULL(SUM(CCD.Total),0) >= 0 THEN 0
						ELSE 
						ISNULL(MAX(CFP.Total),0) + ISNULL(SUM(CFP2.Total),0)  + ISNULL(FI.Total,0) -
						ISNULL(G.Gastos,0) -ISNULL(@retiros,0) - ISNULL(SUM(CCD.Total),0)
						END,
			VentasTelefono = ISNULL(@montoVentasTelefono,0),
			Denominacion = CAST(0 AS money),
			DenominacionValor = CAST(0 AS money),
			DenominacionCantidad = CAST(0 AS money)
	into #tmpResult
	FROM cat_sucursales SUC
	INNER JOIN cat_cajas C on C.Sucursal = SUC.Clave
	INNER JOIN doc_corte_caja CC ON CC.CajaId = C.Clave AND
							CONVERT(VARCHAR,CC.FechaCorte,112) = CONVERT(VARCHAR,@pFecha,112) and
							CC.CajaId = @pCajaId
	INNER JOIN cat_usuarios U ON U.IdUsuario = CC.CreadoPor
	INNER JOIN doc_corte_caja_fp CFP ON CFP.CorteCajaId = CC.CorteCajaId AND
										CFP.FormaPagoId = 1--EFECTIVO
	LEFT JOIN doc_declaracion_fondo_inicial FI ON FI.CorteCajaId = CC.CorteCajaId
	--LEFT JOIN doc_corte_caja_denominaciones ccdeno on ccdeno.CorteCajaId = CC.CorteCajaId
	--LEFT JOIN cat_denominaciones deno on deno.Clave = ccdeno.DenominacionId
	LEFT JOIN doc_corte_caja_denominaciones CCD ON CCD.CorteCajaId = CC.CorteCajaId
	LEFT JOIN doc_corte_caja_egresos G ON G.CorteCajaId = CC.CorteCajaId
	LEFT JOIN doc_corte_caja_fp CFP2 ON CFP2.CorteCajaId = CC.CorteCajaId AND
										CFP2.FormaPagoId <> 1--OTRAS
	
	WHERE SUC.Clave = @pSucursalId and
	CC.CorteCajaId = @corteCajaId
	GROUP BY CC.CorteCajaId, 
			C.Descripcion,
			CC.TotalCorte,
			U.NombreUsuario,
			FI.Total,
			G.Gastos,
			CC.FechaCorte

	SELECT TMP.CorteCajaId,
			Caja ,
			TotalCorte,
			FechaCorte,
			HoraCorte ,
			NombreUsuario,
			Efectivo ,
			OtrasFP ,
			FondoInicial ,
			Gastos ,
			Retiros ,
			TotalGlobal ,
			Ingresado ,
			Faltante ,
			Excedente ,
			VentasTelefono,
			Denominacion = deno.Descripcion,
			DenominacionValor = CAST(ccDeno.Total AS MONEY),
			DenominacionCantidad = CAST(ccDeno.Cantidad AS MONEY)
	FROM #tmpResult TMP
	LEFT JOIN doc_corte_caja_denominaciones ccDeno on ccDeno.CorteCajaId = TMP.CorteCajaId
	LEFT JOIN cat_denominaciones deno on deno.Clave = ccDeno.DenominacionId


GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_cancelaciones]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_corte_caja_cancelaciones 8
CREATE Proc [dbo].[p_rpt_corte_caja_cancelaciones]
@pCorteCajaId int
as

	select Folio = v.VentaId,
		FechaCancelacion = v.FechaCancelacion,
		v.TotalVenta
	from doc_ventas v
	inner join doc_corte_caja cc on cc.CorteCajaId = @pCorteCajaId and
							v.FechaCancelacion
							between cc.FechaApertura and cc.FechaCorte and
							cc.CreadoPor = v.UsuarioCreacionId
	where v.Activo = 0  and
	v.CajaId = cc.CajaId



	
	





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_cancelaciones_previo]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_corte_caja_cancelaciones 8
create Proc [dbo].[p_rpt_corte_caja_cancelaciones_previo]
@pCorteCajaId int
as

	select Folio = v.VentaId,
		FechaCancelacion = v.FechaCancelacion,
		v.TotalVenta
	from doc_ventas v
	inner join doc_corte_caja_previo cc on cc.CorteCajaId = @pCorteCajaId and
							v.FechaCancelacion
							between cc.FechaApertura and cc.FechaCorte and
							cc.CreadoPor = v.UsuarioCreacionId
	where v.Activo = 0  and
	v.CajaId = cc.CajaId



	
	





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_denom]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_corte_caja_denom 1
Create proc [dbo].[p_rpt_corte_caja_denom]
@pCorteCajaId int
as

	select Denominacion=d.Descripcion,
		Cantidad = cd.Cantidad,
		Total = cd.Total
	from doc_corte_caja_denominaciones cd
	inner join doc_corte_caja cc on cc.CorteCajaId = cd.CorteCajaId
	INNER JOIN cat_denominaciones d on d.Clave = cd.DenominacionId
	where cc.CorteCajaId = @pCorteCajaId





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_denom_previo]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_corte_caja_denom 1
create proc [dbo].[p_rpt_corte_caja_denom_previo]
@pCorteCajaId int
as

	select Denominacion=d.Descripcion,
		Cantidad = cd.Cantidad,
		Total = cd.Total
	from doc_corte_caja_denominaciones_previo cd
	inner join doc_corte_caja_previo cc on cc.CorteCajaId = cd.CorteCajaId
	INNER JOIN cat_denominaciones d on d.Clave = cd.DenominacionId
	where cc.CorteCajaId = @pCorteCajaId





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_descuentos]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_corte_caja_descuentos 1
CREATE proc [dbo].[p_rpt_corte_caja_descuentos]
@pCorteCaja int
as

	select v.Folio,
			Descuento = v.DescuentoEnPartidas
	from doc_corte_caja cc
	inner join doc_ventas v on v.VentaId between cc.VentaIniId and cc.VentaFinId and
				v.Activo = 1 and
				isnull(v.DescuentoEnPartidas,0) > 0 AND
				v.UsuarioCreacionId = cc.CreadoPor
	where cc.CorteCajaId = @pCorteCaja
	order by v.Folio

	





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_descuentos_previo]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_corte_caja_descuentos 1
create proc [dbo].[p_rpt_corte_caja_descuentos_previo]
@pCorteCaja int
as

	select v.Folio,
			Descuento = v.DescuentoEnPartidas
	from doc_corte_caja_previo cc
	inner join doc_ventas v on v.VentaId between cc.VentaIniId and cc.VentaFinId and
				v.Activo = 1 and
				isnull(v.DescuentoEnPartidas,0) > 0 AND
				v.UsuarioCreacionId = cc.CreadoPor
	where cc.CorteCajaId = @pCorteCaja
	order by v.Folio

	





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_detallado]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- [p_rpt_corte_caja_detallado] 1,1,'20180723','20180724'
CREATE Proc [dbo].[p_rpt_corte_caja_detallado]
@pSucursal int,
@pCajaId int,
@pDel DateTime,
@pAl DateTime
as

	declare @gastos money,
		@retiros money,
		@efectivoApartado money,
		@tarjetaApartado money

    --gastos
	select cc.CorteCajaId,total1 = isnull(sum(g.Monto),0)
	into #tmpGastos
	from doc_corte_caja cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join doc_gastos g on g.CajaId = cc.cajaId and
							g.CreadoEl between FechaApertura and FechaCorte
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId

	

	--retiros
	select cc.CorteCajaId,total1 = isnull(sum(g.MontoRetiro),0)
	into #tmpRetiros
	from doc_corte_caja cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join doc_retiros g on g.CajaId = cc.cajaId and
							g.FechaRetiro between FechaApertura and FechaCorte
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId

	--Efectivo Apartado
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpEfectivoApartado
	from doc_corte_caja cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp_apartado] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid = 1 --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId

	--Tarjeta Apartado
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpTarjetasApartado
	from doc_corte_caja cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp_apartado] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid in (2,3) --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId


	--Efectivo Venta
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpEfectivoVenta
	from doc_corte_caja cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid = 1 --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId


	--Tarjeta Apartado
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpTarjetasVenta
	from doc_corte_caja cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid in (2,3) --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId

	---vales
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpValesVenta
	from doc_corte_caja cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid in (5) --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId




	select 
		Dia = convert(varchar,FechaApertura,112) ,
		Del = @pDel,
		Al = @pAl,
		Caja = caja.Descripcion,
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		Folio = cc.CorteCajaId,
		FechaApertura = FechaApertura,
		FechaCierre = cc.FechaCorte,
		--Ventas
		EfectivoVenta = isnull(ev.Total1,0),
		TarjetaVenta = isnull(tv.Total1,0),		
		TotalVenta =isnull(ev.Total1,0)+isnull(tv.Total1,0) ,
		--Apartados
		EfectivoApartado = isnull(ea.Total1,0),
		TarjetaApartado = isnull(ta.Total1,0),		
		TotalApartado =isnull(ea.Total1,0)+isnull(ta.Total1,0) ,
		--
		Gastos = isnull(g.total1,0),
		Vales = isnull(vv.total1,0),
		Cancelaciones = (
			select isnull(sum(sv.TotalVenta),0)
			from doc_ventas sv
			where sv.CajaId = cc.CajaId and
			sv.FechaCancelacion is not null and
			sv.FechaCancelacion between cc.FechaApertura and cc.FechaCorte
		),
		Retiros = isnull(r.total1,0),
		Devoluciones = (
			select isnull(sum(sdev.Total),0)
			from doc_devoluciones sdev
			inner join doc_ventas sv on sv.VentaId = sdev.VentaId
			where sv.CajaId = cc.CajaId and
			sv.Fecha between cc.FechaApertura and cc.FechaCorte
			
		),
		TotalIngreso = isnull(ev.Total1,0)+isnull(tv.Total1,0)+
						isnull(ea.Total1,0)+isnull(ta.Total1,0),
		TotalGral = isnull(ev.Total1,0)+isnull(tv.Total1,0)+
						isnull(ea.Total1,0)+isnull(ta.Total1,0)-
						 isnull(g.total1,0),
		TotalCorte = isnull(ev.Total1,0) +
					 isnull(tv.Total1,0) +
					 isnull(ea.Total1,0) +
					 isnull(ta.Total1,0) +
					 isnull(vv.total1,0) -
					 isnull(g.total1,0) -
					(
						select isnull(sum(sv.TotalVenta),0)
						from doc_ventas sv
						where sv.CajaId = cc.CajaId and
						sv.FechaCancelacion is not null and
						sv.FechaCancelacion between cc.FechaApertura and cc.FechaCorte
					) -
					isnull(r.total1,0) -
					(
						select isnull(sum(sdev.Total),0)
						from doc_devoluciones sdev
						inner join doc_ventas sv on sv.VentaId = sdev.VentaId
						where sv.CajaId = cc.CajaId and
						sv.Fecha between cc.FechaApertura and cc.FechaCorte
			
					),
		Vendedor = u.NombreUsuario
	from doc_corte_caja cc
	--inner join doc_corte_caja_fp ccfp on ccfp.CorteCajaId = cc.CorteCajaId
	inner join cat_cajas caja on caja.Clave = cc.CajaId
	inner join cat_sucursales suc on suc.Clave = caja.Sucursal
	inner join cat_empresas emp on emp.Clave = suc.Empresa
	inner join cat_usuarios u 
				on u.IdUsuario = (
					select isnull(min(sv.UsuarioCreacionId),cc.CreadoPor)
					from doc_ventas sv
					where sv.VentaId between cc.VentaIniId and cc.VentaFinId
					)
	left join #tmpRetiros r on r.CorteCajaId = cc.CorteCajaId
	left join #tmpGastos g on g.CorteCajaId = cc.CorteCajaId
	left join doc_corte_caja_fp_apartado ccapartado on ccapartado.CorteCajaId  = cc.CorteCajaId
	left join #tmpEfectivoApartado ea on ea.CorteCajaId = cc.CorteCajaId
	left join #tmpTarjetasApartado ta on ta.CorteCajaId = cc.CorteCajaId
	left join #tmpEfectivoVenta ev on ev.CorteCajaId = cc.CorteCajaId
	left join #tmpTarjetasVenta tv on tv.CorteCajaId = cc.CorteCajaId
	left join #tmpValesVenta vv on vv.CorteCajaId = cc.CorteCajaId

	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	@pCajaId in (cc.CajaId ,0)
	group by  cc.CorteCajaId,
		 FechaApertura,
		 cc.FechaCorte,
		 cc.CajaId,
		 cc.TotalCorte,
		 emp.NombreComercial,
		suc.NombreSucursal,
		caja.Descripcion,
		u.NombreUsuario,
		r.total1,
		g.total1,
		ea.total1,
		ta.total1,
		ev.total1,
		tv.total1,
		vv.total1
	


GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_detallado_previo]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- [p_rpt_corte_caja_detallado] 1,1,'20180723','20180724'
create Proc [dbo].[p_rpt_corte_caja_detallado_previo]
@pSucursal int,
@pCajaId int,
@pDel DateTime,
@pAl DateTime
as

	declare @gastos money,
		@retiros money,
		@efectivoApartado money,
		@tarjetaApartado money

    --gastos
	select cc.CorteCajaId,total1 = isnull(sum(g.Monto),0)
	into #tmpGastos
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join doc_gastos g on g.CajaId = cc.cajaId and
							g.CreadoEl between FechaApertura and FechaCorte
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId

	

	--retiros
	select cc.CorteCajaId,total1 = isnull(sum(g.MontoRetiro),0)
	into #tmpRetiros
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join doc_retiros g on g.CajaId = cc.cajaId and
							g.FechaRetiro between FechaApertura and FechaCorte
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId

	--Efectivo Apartado
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpEfectivoApartado
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp_apartado] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid = 1 --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId

	--Tarjeta Apartado
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpTarjetasApartado
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp_apartado] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid in (2,3) --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId


	--Efectivo Venta
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpEfectivoVenta
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid = 1 --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId


	--Tarjeta Apartado
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpTarjetasVenta
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid in (2,3) --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId

	---vales
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpValesVenta
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid in (5) --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId




	select 
		Dia = convert(varchar,FechaApertura,112) ,
		Del = @pDel,
		Al = @pAl,
		Caja = caja.Descripcion,
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		Folio = cc.CorteCajaId,
		FechaApertura = FechaApertura,
		FechaCierre = cc.FechaCorte,
		--Ventas
		EfectivoVenta = isnull(ev.Total1,0),
		TarjetaVenta = isnull(tv.Total1,0),		
		TotalVenta =isnull(ev.Total1,0)+isnull(tv.Total1,0) ,
		--Apartados
		EfectivoApartado = isnull(ea.Total1,0),
		TarjetaApartado = isnull(ta.Total1,0),		
		TotalApartado =isnull(ea.Total1,0)+isnull(ta.Total1,0) ,
		--
		Gastos = isnull(g.total1,0),
		Vales = isnull(vv.total1,0),
		Cancelaciones = (
			select isnull(sum(sv.TotalVenta),0)
			from doc_ventas sv
			where sv.CajaId = cc.CajaId and
			sv.FechaCancelacion is not null and
			sv.FechaCancelacion between cc.FechaApertura and cc.FechaCorte
		),
		Retiros = isnull(r.total1,0),
		Devoluciones = (
			select isnull(sum(sdev.Total),0)
			from doc_devoluciones sdev
			inner join doc_ventas sv on sv.VentaId = sdev.VentaId
			where sv.CajaId = cc.CajaId and
			sv.Fecha between cc.FechaApertura and cc.FechaCorte
			
		),
		TotalIngreso = isnull(ev.Total1,0)+isnull(tv.Total1,0)+
						isnull(ea.Total1,0)+isnull(ta.Total1,0),
		TotalGral = isnull(ev.Total1,0)+isnull(tv.Total1,0)+
						isnull(ea.Total1,0)+isnull(ta.Total1,0)-
						 isnull(g.total1,0),
		TotalCorte = isnull(ev.Total1,0) +
					 isnull(tv.Total1,0) +
					 isnull(ea.Total1,0) +
					 isnull(ta.Total1,0) +
					 isnull(vv.total1,0) -
					 isnull(g.total1,0) -
					(
						select isnull(sum(sv.TotalVenta),0)
						from doc_ventas sv
						where sv.CajaId = cc.CajaId and
						sv.FechaCancelacion is not null and
						sv.FechaCancelacion between cc.FechaApertura and cc.FechaCorte
					) -
					isnull(r.total1,0) -
					(
						select isnull(sum(sdev.Total),0)
						from doc_devoluciones sdev
						inner join doc_ventas sv on sv.VentaId = sdev.VentaId
						where sv.CajaId = cc.CajaId and
						sv.Fecha between cc.FechaApertura and cc.FechaCorte
			
					),
		Vendedor = u.NombreUsuario
	from doc_corte_caja_previo cc
	--inner join doc_corte_caja_fp ccfp on ccfp.CorteCajaId = cc.CorteCajaId
	inner join cat_cajas caja on caja.Clave = cc.CajaId
	inner join cat_sucursales suc on suc.Clave = caja.Sucursal
	inner join cat_empresas emp on emp.Clave = suc.Empresa
	inner join cat_usuarios u 
				on u.IdUsuario = (
					select isnull(min(sv.UsuarioCreacionId),cc.CreadoPor)
					from doc_ventas sv
					where sv.VentaId between cc.VentaIniId and cc.VentaFinId
					)
	left join #tmpRetiros r on r.CorteCajaId = cc.CorteCajaId
	left join #tmpGastos g on g.CorteCajaId = cc.CorteCajaId
	left join doc_corte_caja_fp_apartado_previo ccapartado on ccapartado.CorteCajaId  = cc.CorteCajaId
	left join #tmpEfectivoApartado ea on ea.CorteCajaId = cc.CorteCajaId
	left join #tmpTarjetasApartado ta on ta.CorteCajaId = cc.CorteCajaId
	left join #tmpEfectivoVenta ev on ev.CorteCajaId = cc.CorteCajaId
	left join #tmpTarjetasVenta tv on tv.CorteCajaId = cc.CorteCajaId
	left join #tmpValesVenta vv on vv.CorteCajaId = cc.CorteCajaId

	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	@pCajaId in (cc.CajaId ,0)
	group by  cc.CorteCajaId,
		 FechaApertura,
		 cc.FechaCorte,
		 cc.CajaId,
		 cc.TotalCorte,
		 emp.NombreComercial,
		suc.NombreSucursal,
		caja.Descripcion,
		u.NombreUsuario,
		r.total1,
		g.total1,
		ea.total1,
		ta.total1,
		ev.total1,
		tv.total1,
		vv.total1
	


GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_devoluciones]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[p_rpt_corte_caja_devoluciones]
@pCorteCajaId int
as
	select FolioDevolucion=	dev.DevolucionId,
			FolioVenta = v.Folio,
			MontoDevolucion = dev.Total
	from doc_corte_caja cc
	INNER JOIN doc_devoluciones DEV ON 
				DEV.CreadoEl 
				between cc.FechaApertura and cc.FechaCorte 
	inner join doc_ventas v on v.VentaId = dev.VentaId
	where cc.CorteCajaId = @pCorteCajaId AND
	cc.CreadoPor = dev.CreadoPor





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_devoluciones_previo]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[p_rpt_corte_caja_devoluciones_previo]
@pCorteCajaId int
as
	select FolioDevolucion=	dev.DevolucionId,
			FolioVenta = v.Folio,
			MontoDevolucion = dev.Total
	from doc_corte_caja_previo cc
	INNER JOIN doc_devoluciones DEV ON 
				DEV.CreadoEl 
				between cc.FechaApertura and cc.FechaCorte 
	inner join doc_ventas v on v.VentaId = dev.VentaId
	where cc.CorteCajaId = @pCorteCajaId AND
	cc.CreadoPor = dev.CreadoPor





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_enc]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- [p_rpt_corte_caja_enc] 49
CREATE Proc [dbo].[p_rpt_corte_caja_enc]
@pCorteCajaId int
as

	declare @egresos money,
			@apartados money,
			@vales money,
			@cajaId int,
			@efectivo money,
			@tarjetas money,
			@fondoFinal money

	select @egresos = isnull(Gastos,0)
	from [dbo].[doc_corte_caja_egresos]
	where CorteCajaId = @pCorteCajaId

	
	select @apartados = sum(a.Importe)
	from doc_apartados_pagos a
	inner join doc_corte_caja cc on cc.CorteCajaId = @pCorteCajaId 
	where a.FechaPago between cc.FechaApertura and cc.FechaCorte and
	cc.CreadoPor = a.CreadoPor


	select @vales = isnull(sum(monto),0)
	from doc_ventas_formas_pago_vale fpv
	inner join doc_ventas v on v.ventaId = fpv.VentaId
	inner join doc_corte_caja cc on cc.cortecajaid = @pCorteCajaId
	where v.cajaid = @cajaId and
	fpv.CreadoEl between cc.FechaApertura and cc.FechaCorte and
	cc.cajaId = v.cajaId

	/***Efectivo de ventas y apartados*****/
	select @efectivo = SUM(VD.Total)
	FROM doc_ventas_detalle VD
	INNER JOIN doc_corte_caja_ventas CCV ON CCV.CorteId = @pCorteCajaId AND
								CCV.VentaId = VD.VentaId
	INNER JOIN doc_ventas_formas_pago VFP ON VFP.VentaId = CCV.VentaId AND VFP.FormaPagoId = 1
	INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId AND V.FechaCancelacion IS NULL
	
	select @tarjetas = SUM(VD.Total)
	FROM doc_ventas_detalle VD
	INNER JOIN doc_corte_caja_ventas CCV ON CCV.CorteId = @pCorteCajaId AND
								CCV.VentaId = VD.VentaId
	INNER JOIN doc_ventas_formas_pago VFP ON VFP.VentaId = CCV.VentaId AND VFP.FormaPagoId <> 1
	INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId AND V.FechaCancelacion IS NULL
	
	SELECT @fondoFinal = ISNULL(SUM(Total),0)
	from doc_corte_caja_denominaciones
	where CorteCajaId = @pCorteCajaId

	select
			suc.NombreSucursal,
			Direccion = RTRIM(ISNULL(suc.Calle,'')) + ' '+
						RTRIM(ISNULL(suc.NoExt ,'')) + ' ' +
						RTRIM(ISNULL(suc.NoInt,'')) +' '+
						RTRIM(ISNULL(suc.Colonia, '')) + ' '+
						RTRIM(ISNULL(suc.Ciudad,'')) +','+
						RTRIM(ISNULL(suc.Estado,'')) +','+
						RTRIM(ISNULL(suc.Pais,'')),
			RFC = emp.RFC,
			NombreEmpresa = NombreComercial,
			Apertura = cc.FechaApertura,
			Corte = cc.FechaCorte,
			FolioIni = isnull(VentaIniId,0),
			FolioFin=isnull(VentaFinId,0),
			Usuario = rh.Nombre,
			Caja = caj.Descripcion,
			CC.TotalCorte,
			Egresos = @egresos,
			FolioVenta =isnull(v.Ventaid,0),
			TotalVenta = isnull(@efectivo,0)+isnull(@tarjetas,0),--case when v.activo = 0 then 0 else  isnull(v.TotalVenta,0) end,
			TotalNV = case when isnull(v.activo,0) = 0 then 0 else V.TotalVenta end,
			cc.CorteCajaId,
			Estatus = case when v.activo = 0 then 'C' else '' END,
			TotalApartado = isnull(@apartados,0),
			TotalGeneral =ISNULL(fi.Total,0) + isnull(@efectivo,0)+isnull(@tarjetas,0)-isnull(@egresos,0),
			Efectivo = @efectivo,
			Tarjetas=@tarjetas,
			FondoInicial = ISNULL(fi.Total,0),
			FondoFinal = @fondoFinal
		from doc_corte_caja cc
		inner join cat_cajas caj on cc.CajaId = caj.Clave
		inner join cat_sucursales suc on suc.Clave = caj.Sucursal
		inner join cat_empresas emp on emp.Clave = suc.Empresa	
		inner join cat_usuarios usu on usu.IdUsuario = CreadoPor
		inner join rh_empleados rh on rh.NumEmpleado = usu.IdEmpleado
		LEFT join doc_ventas v on v.VentaId between VentaIniId and VentaFinId AND
									cc.CorteCajaId = @pCorteCajaId and
									v.SucursalId = suc.Clave and
									V.VentaId NOT IN(
										SELECT ap.VentaId
										FROM doc_apartados ap
										where isnull(ap.VentaId,0) > 0
									)	
		LEFT JOIN doc_declaracion_fondo_inicial fi on fi.CorteCajaId = cc.CorteCajaId AND
											fi.CajaId = caj.Clave AND
											fi.SucursalId = caj.Sucursal
												
		where cc.CorteCajaId = @pCorteCajaId
		



	








GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_enc_previo]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- [p_rpt_corte_caja_enc] 2
create Proc [dbo].[p_rpt_corte_caja_enc_previo]
@pCorteCajaId int
as

	declare @egresos money,
			@apartados money,
			@vales money,
			@cajaId int,
			@efectivo money,
			@tarjetas money

	select @egresos = isnull(Gastos,0)
	from [dbo].[doc_corte_caja_egresos_previo]
	where CorteCajaId = @pCorteCajaId

	
	select @apartados = sum(a.Importe)
	from doc_apartados_pagos a
	inner join doc_corte_caja_previo cc on cc.CorteCajaId = @pCorteCajaId 
	where a.FechaPago between cc.FechaApertura and cc.FechaCorte and
	cc.CreadoPor = a.CreadoPor


	select @vales = isnull(sum(monto),0)
	from doc_ventas_formas_pago_vale fpv
	inner join doc_ventas v on v.ventaId = fpv.VentaId
	inner join doc_corte_caja_previo cc on cc.cortecajaid = @pCorteCajaId
	where v.cajaid = @cajaId and
	fpv.CreadoEl between cc.FechaApertura and cc.FechaCorte and
	cc.cajaId = v.cajaId

	/***Efectivo de ventas y apartados*****/
	select @efectivo = isnull(sum(ccfp.Total),0) + isnull(sum(ccfp2.Total),0)
	from doc_corte_caja_previo cc
	left join [dbo].[doc_corte_caja_fp_previo] ccfp on ccfp.CorteCajaid = cc.CorteCajaId and
									ccfp.FormaPagoId = 1
	left join [dbo].[doc_corte_caja_fp_apartado_previo] ccfp2 on ccfp2.CorteCajaid = cc.CorteCajaId and
									ccfp2.FormaPagoId = 1
	where cc.CorteCajaId = @pCorteCajaId


	select @tarjetas = isnull(sum(ccfp.Total),0) + isnull(sum(ccfp2.Total),0)
	from doc_corte_caja_previo cc
	left join [dbo].[doc_corte_caja_fp_previo] ccfp on ccfp.CorteCajaid = cc.CorteCajaId and
									ccfp.FormaPagoId in(2,3)
	left join [dbo].[doc_corte_caja_fp_apartado_previo] ccfp2 on ccfp2.CorteCajaid = cc.CorteCajaId and
									ccfp2.FormaPagoId in(2,3)
	where cc.CorteCajaId = @pCorteCajaId
	
	

	select
			suc.NombreSucursal,
			Direccion = RTRIM(ISNULL(suc.Calle,'')) + ' '+
						RTRIM(ISNULL(suc.NoExt ,'')) + ' ' +
						RTRIM(ISNULL(suc.NoInt,'')) +' '+
						RTRIM(ISNULL(suc.Colonia, '')) + ' '+
						RTRIM(ISNULL(suc.Ciudad,'')) +','+
						RTRIM(ISNULL(suc.Estado,'')) +','+
						RTRIM(ISNULL(suc.Pais,'')),
			RFC = emp.RFC,
			NombreEmpresa = NombreComercial,
			Apertura = cc.FechaApertura,
			Corte = cc.FechaCorte,
			FolioIni = isnull(VentaIniId,0),
			FolioFin=isnull(VentaFinId,0),
			Usuario = rh.Nombre,
			Caja = caj.Descripcion,
			CC.TotalCorte,
			Egresos = @egresos,
			FolioVenta =isnull(v.Ventaid,0),
			TotalVenta = isnull(@efectivo,0)+isnull(@tarjetas,0),--case when v.activo = 0 then 0 else  isnull(v.TotalVenta,0) end,
			TotalNV = case when isnull(v.activo,0) = 0 then 0 else V.TotalVenta end,
			cc.CorteCajaId,
			Estatus = case when v.activo = 0 then 'C' else '' END,
			TotalApartado = isnull(@apartados,0),
			TotalGeneral =isnull(@efectivo,0)+isnull(@tarjetas,0)-isnull(@egresos,0),
			Efectivo = @efectivo,
			Tarjetas=@tarjetas
		from doc_corte_caja_previo cc
		inner join cat_cajas caj on cc.CajaId = caj.Clave
		inner join cat_sucursales suc on suc.Clave = caj.Sucursal
		inner join cat_empresas emp on emp.Clave = suc.Empresa	
		inner join cat_usuarios usu on usu.IdUsuario = CreadoPor
		inner join rh_empleados rh on rh.NumEmpleado = usu.IdEmpleado
		LEFT join doc_ventas v on v.VentaId between VentaIniId and VentaFinId AND
									V.VentaId NOT IN(
										SELECT ap.VentaId
										FROM doc_apartados ap
										where isnull(ap.VentaId,0) > 0
									)								
		where cc.CorteCajaId = @pCorteCajaId
		



	






GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_enc_rec]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[p_rpt_corte_caja_enc_rec]
@pCorteCajaId int
as

	exec ERPTemp..p_rpt_corte_caja_enc @pCorteCajaId
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_fp]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_fp]    Script Date: 06/07/2022 06:50:32 p. m. ******/
-- p_rpt_corte_caja_fp 46
CREATE proc [dbo].[p_rpt_corte_caja_fp]
@pCorteCajaId int
as


		SELECT VFP.FormaPagoId,
			FormaPago = fp.Descripcion,
			Monto = SUM(V.TotalVenta)
		FROM doc_corte_caja_ventas CCV
		INNER JOIN  doc_ventas V ON V.VentaId = CCV.VentaId 
		INNER JOIN doc_ventas_formas_pago VFP ON VFP.VentaId = V.VentaId
		inner join cat_formas_pago  fp on fp.FormaPagoId = VFP.FormaPagoId
		WHERE CCV.CorteId = @pCorteCajaId AND
		V.FechaCancelacion IS NULL AND
		ISNULL(V.Activo,0)=1
		GROUP BY VFP.FormaPagoId,
			 fp.Descripcion





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_fp_previo]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_corte_caja_fp 1
create proc [dbo].[p_rpt_corte_caja_fp_previo]
@pCorteCajaId int
as

	select fp.FormaPagoId,
		FormaPago =fp.Descripcion,
		Monto = sum(cc.Total)
	from doc_corte_caja_fp_previo cc
	inner join cat_formas_pago  fp on fp.FormaPagoId = cc.FormaPagoId
	where CorteCajaId = @pCorteCajaId
	group by fp.FormaPagoId,
		fp.Descripcion





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_gastos]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_rpt_corte_caja_gastos 1
CREATE proc [dbo].[p_rpt_corte_caja_gastos]
@pCorteCajaId int
as

	select FolioGasto = g.GastoId,
			Fecha = g.CreadoEl,
		   g.Monto,
		   CentroCosto = cc.Descripcion,
		   Concepto = con.Descripcion
	from doc_gastos g
	inner join doc_corte_caja c on c.CorteCajaId = @pCorteCajaId
	inner join cat_centro_costos cc on cc.Clave = g.CentroCostoId
	inner join cat_gastos con on con.Clave = g.GastoConceptoId
	where g.CreadoEl
	 between c.FechaApertura and c.FechaCorte and
	g.Activo = 1 and
	g.CajaId = c.CajaId AND
	g.CreadoPor = c.CreadoPor

	





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_gastos_previo]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_corte_caja_gastos 1
create proc [dbo].[p_rpt_corte_caja_gastos_previo]
@pCorteCajaId int
as

	select FolioGasto = g.GastoId,
			Fecha = g.CreadoEl,
		   g.Monto,
		   CentroCosto = cc.Descripcion,
		   Concepto = con.Descripcion
	from doc_gastos g
	inner join doc_corte_caja_previo c on c.CorteCajaId = @pCorteCajaId
	inner join cat_centro_costos cc on cc.Clave = g.CentroCostoId
	inner join cat_gastos con on con.Clave = g.GastoConceptoId
	where g.CreadoEl
	 between c.FechaApertura and c.FechaCorte and
	g.Activo = 1 and
	g.CajaId = c.CajaId AND
	g.CreadoPor = c.CreadoPor

	





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_general]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- p_rpt_corte_caja_general 4,'20230614'
CREATE PROC [dbo].[p_rpt_corte_caja_general]
@pSucursalId INT,
@pFecha DateTime
AS

	DECLARE @montoVentasTelefono MONEY,
		@efectivo MONEY,
		@tdebito MONEY,
		@tcredito MONEY,
		@otros MONEY,
		@retiros MONEy

	SELECT @efectivo = ISNULL(SUM(VFP.Cantidad),0)
	FROM doc_ventas_formas_pago VFP
	INNER JOIN doc_ventas V ON V.VentaId = VFP.VentaId AND VFP.FormaPagoId IN(1) AND
							V.Activo = 1 AND
							V.FechaCancelacion IS NULL
	WHERE CONVERT(VARCHAR,V.Fecha,112) = CONVERT(VARCHAR,@pFecha,112)  AND
	V.SucursalId = @pSucursalId

	SELECT @tdebito = ISNULL(SUM(VFP.Cantidad),0)
	FROM doc_ventas_formas_pago VFP
	INNER JOIN doc_ventas V ON V.VentaId = VFP.VentaId AND VFP.FormaPagoId IN(3) AND
							V.Activo = 1 AND
							V.FechaCancelacion IS NULL
	WHERE CONVERT(VARCHAR,V.Fecha,112) = CONVERT(VARCHAR,@pFecha,112)  AND
	V.SucursalId = @pSucursalId

	SELECT @tcredito = ISNULL(SUM(VFP.Cantidad),0)
	FROM doc_ventas_formas_pago VFP
	INNER JOIN doc_ventas V ON V.VentaId = VFP.VentaId AND VFP.FormaPagoId IN(2) AND
							V.Activo = 1 AND
							V.FechaCancelacion IS NULL
	WHERE CONVERT(VARCHAR,V.Fecha,112) = CONVERT(VARCHAR,@pFecha,112)  AND
	V.SucursalId = @pSucursalId

	SELECT @otros = ISNULL(SUM(VFP.Cantidad),0)
	FROM doc_ventas_formas_pago VFP
	INNER JOIN doc_ventas V ON V.VentaId = VFP.VentaId AND VFP.FormaPagoId NOT IN(1,2,3) AND
							V.Activo = 1 AND
							V.FechaCancelacion IS NULL
	WHERE CONVERT(VARCHAR,V.Fecha,112) = CONVERT(VARCHAR,@pFecha,112) AND
	V.SucursalId = @pSucursalId

	

	SELECT @montoVentasTelefono = SUM(V.TotalVenta)
	FROM doc_pedidos_orden PO
	INNER JOIN doc_ventas V ON V.VentaId = PO.VentaId
	WHERE PO.Activo = 1 AND
	CONVERT(VARCHAR,V.Fecha,112) = CONVERT(VARCHAR,@pFecha,112) AND
	PO.SucursalId = @pSucursalId AND
	PO.TipoPedidoId = 2--Pedido Telefono

	SELECT CC.CorteCajaId,
		
		MontoRetiro = SUM(R.MontoRetiro)
	INTO #TMP_RETIROS
	FROM doc_retiros R
	INNER JOIN doc_corte_caja CC ON CC.CajaId = R.CajaId AND
							convert(varchar,CC.FechaCorte,112) = convert(varchar,@pFecha,112) 		AND
							CAST(R.FechaRetiro AS DATE) BETWEEN convert(varchar,@pFecha,112)  AND convert(varchar,@pFecha,112) 
							
	GROUP BY CC.CorteCajaId

	SELECT 
		CC.CorteCajaId,
		TotalGlobal = SUM(CC.Total),
		Gastos = MAX(CCE.Gastos),
		Retiro = ISNULL(MAX(R.MontoRetiro),0),
		FondoInicial  = ISNULL(MAX(FI.Total),0)

	INTO #TMP_TOTAL_GLOBAL
	FROM doc_corte_caja_fp CC
	INNER JOIN doc_corte_caja C ON C.CorteCajaId = CC.CorteCajaId 
	INNER JOIN cat_cajas CAJA ON C.CajaId = C.CajaId AND
						CAJA.Sucursal = @pSucursalId AND
						CAST(C.FechaCorte AS DATE) = CAST(@pFecha AS DATE)
	INNER JOIN doc_corte_caja_egresos CCE ON CCE.CorteCajaId = CC.CorteCajaId
	INNER JOIN doc_declaracion_fondo_inicial FI ON FI.CorteCajaId = CC.CorteCajaId
	LEFT JOIN #TMP_RETIROS R ON R.CorteCajaId = C.CorteCajaId
	GROUP BY CC.CorteCajaId

	SELECT	
			CC.CorteCajaId,
			Caja = C.Descripcion,
			CC.TotalCorte,
			CC.FechaCorte,
			HoraCorte = CONVERT(varchar,CC.FechaCorte,108),
			U.NombreUsuario,
			Efectivo = ISNULL(MAX(CFP.Total),0),
			OtrasFP = ISNULL(SUM(CFP2.Total),0),
			FondoInicial = ISNULL(FI.Total,0),
			Gastos = ISNULL(G.Gastos,0),
			Retiros = ISNULL(
								MAX(R.MontoRetiro)
								,0),
			TotalGlobal =MAX(TG.TotalGlobal)  + MAX(tg.FondoInicial) - MAX(TG.Gastos),
			Ingresado = ISNULL(SUM(CCD.Total),0),
			Faltante = CASE WHEN MAX(TG.TotalGlobal)  + MAX(tg.FondoInicial) - MAX(TG.Gastos) - MAX(TG.Retiro)- ISNULL(SUM(CCD.Total),0) < 0 
								then  MAX(TG.TotalGlobal)  + MAX(tg.FondoInicial) - MAX(TG.Gastos) - MAX(TG.Retiro)- ISNULL(SUM(CCD.Total),0) 
							    ELSE 0
						END,
			Excedente = CASE WHEN MAX(TG.TotalGlobal)  + MAX(tg.FondoInicial) - MAX(TG.Gastos) - MAX(TG.Retiro)- ISNULL(SUM(CCD.Total),0) > 0 
								then  MAX(TG.TotalGlobal)  + MAX(tg.FondoInicial) - MAX(TG.Gastos) - MAX(TG.Retiro)- ISNULL(SUM(CCD.Total),0) 
							    ELSE 0
						END,
			VentasTelefono = ISNULL(@montoVentasTelefono,0),
			FPEfectivo = @efectivo,
			FPTCredito = @tcredito,
			FPTDebito = @tdebito,
			FPOtros = @otros
	FROM cat_sucursales SUC
	INNER JOIN cat_cajas C on C.Sucursal = SUC.Clave
	INNER JOIN doc_corte_caja CC ON CC.CajaId = C.Clave AND
							CONVERT(VARCHAR,CC.FechaCorte,112) = CONVERT(VARCHAR,@pFecha,112)
	INNER JOIN cat_usuarios U ON U.IdUsuario = CC.CreadoPor
	INNER JOIN doc_corte_caja_fp CFP ON CFP.CorteCajaId = CC.CorteCajaId AND
										CFP.FormaPagoId = 1--EFECTIVO 
	INNER JOIN doc_declaracion_fondo_inicial FI ON FI.CorteCajaId = CC.CorteCajaId
	LEFT JOIN doc_corte_caja_denominaciones CCD ON CCD.CorteCajaId = CC.CorteCajaId
	LEFT JOIN doc_corte_caja_egresos G ON G.CorteCajaId = CC.CorteCajaId
	LEFT JOIN doc_corte_caja_fp CFP2 ON CFP2.CorteCajaId = CC.CorteCajaId AND
										CFP2.FormaPagoId <> 1--OTRAS
	LEFT JOIN #TMP_RETIROS R ON R.CorteCajaId = CC.CorteCajaId
	LEFT JOIN #TMP_TOTAL_GLOBAL TG ON TG.TotalGlobal = TG.TotalGlobal
	WHERE SUC.Clave = @pSucursalId
	GROUP BY CC.CorteCajaId, 
			C.Descripcion,
			CC.TotalCorte,
			U.NombreUsuario,
			FI.Total,
			G.Gastos,
			CC.FechaCorte

GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_pedidos_pagos]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_corte_caja_pedidos_pagos 3,'20221220'
CREATE PROC [dbo].[p_rpt_corte_caja_pedidos_pagos]
@pSucursalId INT,
@pFecha DATETIME
AS

	SELECT 
		Cliente = CLI.Nombre,
		P.FechaPago, 
		P.Monto,
		PedidoFolio = po.Folio
	FROM doc_pagos P
	INNER JOIN doc_cargos C ON C.CargoId = P.CargoId AND
							C.SucursalId = @pSucursalId
	INNER JOIN doc_pedidos_orden PO ON PO.CargoId = C.CargoId
	left JOIN cat_clientes CLI ON CLI.ClienteId = C.ClienteId
	WHERE CONVERT(VARCHAR,p.FechaPago,112) = CONVERT(VARCHAR,@pFecha,112)

	
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_producto]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_corte_caja_producto 0,'20220922','20220922',5
CREATE PROC [dbo].[p_rpt_corte_caja_producto]
@pSucursalId INT,
@pDel DATETIME,
@pAl DATETIME,
@pUsuarioId INT=0
AS


	
	--EXISTENCIAS
	SELECT imd.ProductoId,
		MinId = MIN(IMD.MovimientoDetalleId),
		MaxId = MAX(IMD.MovimientoDetalleId)
	INTO #TMP_EXISTENCIAS
	FROM doc_inv_movimiento_detalle IMD
	INNER JOIN doc_inv_movimiento IM on IM.MovimientoId = IMD.MovimientoId and im.Activo = 1 AND
					@pSucursalId IN(0, IM.SucursalId)
	WHERE CONVERT(VARCHAR,IM.FechaMovimiento,112) BETWEEN CONVERT(VARCHAR,@pDel,112) AND CONVERT(VARCHAR,@pAl,112) 
	GROUP BY imd.ProductoId
	
	SELECT 
		Id =ROW_NUMBER() OVER(ORDER BY P.ProductoId ASC) ,
		CajaId = 1,
		Caja = 'caja',
		P.ProductoId,
		Producto = P.Descripcion,
		ExistenciaInicial = ISNULL(IMD.Disponible,0),
		ExistenciaFinal = ISNULL(FMD.Disponible,0),
		CantidadVenta = ISNULL(SUM(vd.Cantidad),0),
		ImporteVenta = ISNULL(SUM(Vd.Total),0)
	FROM doc_ventas_detalle vd 
	INNER JOIN doc_ventas v on v.VentaId = vd.VentaId
	INNER JOIN cat_cajas C ON C.Clave = v.CajaId
	INNER JOIN cat_productos P ON P.ProductoId = vd.ProductoId
	INNER JOIN dbo.fnUsuarioSucursales(@pUsuarioId) US ON US.SucursalId = v.SucursalId
	LEFT JOIN #TMP_EXISTENCIAS TMP ON TMP.ProductoId = vd.ProductoId
	LEFT JOIN doc_inv_movimiento_detalle IMD ON IMD.MovimientoDetalleId = TMP.MinId
	LEFT JOIN doc_inv_movimiento_detalle FMD ON FMD.MovimientoDetalleId = TMP.MaxId
	WHERE CONVERT(VARCHAR,vd.FechaCreacion,112) BETWEEN CONVERT(VARCHAR,@pDel,112) AND CONVERT(VARCHAR,@pAl,112) AND
	V.Activo = 1 and
	@pSucursalId in (v.SucursalId,0)
	GROUP BY 
		P.ProductoId,
		P.Descripcion,
		IMD.Disponible,
		FMD.Disponible
	order by ISNULL(SUM(Vd.Total),0)DESC,P.ProductoId

	

	
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_resumido]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_corte_caja_resumido 1,1,'20180723','20180724'
CREATE Proc [dbo].[p_rpt_corte_caja_resumido]
@pSucursal int,
@pCajaId int,
@pDel DateTime,
@pAl DateTime
as

	declare @gastos money,
		@retiros money
	
	select cc.CorteCajaId,total1 = isnull(sum(g.Monto),0)
	into #tmpGastos
	from doc_corte_caja cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join doc_gastos g on g.CajaId = cc.cajaId and
							g.CreadoEl between FechaApertura and FechaCorte
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId


	select cc.CorteCajaId,total1 = isnull(sum(g.MontoRetiro),0)
	into #tmpRetiros
	from doc_corte_caja cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join doc_retiros g on g.CajaId = cc.cajaId and
							g.FechaRetiro between FechaApertura and FechaCorte
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId



	select Efectivo = sum(case when fp.FormaPagoId = 1 then fp.Total else 0 end),
	Tarjeta=sum(case when fp.FormaPagoId in( 2,3) then fp.Total else 0 end),
	Vales = sum(case when fp.FormaPagoId in( 5) then fp.Total else 0 end),
	Total = sum(case when fp.FormaPagoId = 1 then fp.Total else 0 end) +
			sum(case when fp.FormaPagoId in( 2,3) then fp.Total else 0 end) +
			sum(case when fp.FormaPagoId in( 5) then fp.Total else 0 end),
	cc.CorteCajaId
	into #tmpApartadosFP
	from [doc_corte_caja_fp_apartado] fp
	inner join doc_corte_caja cc on cc.CorteCajaId = fp.CorteCajaId
	inner join cat_cajas  c on c.clave = cc.CajaId
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId,fp.FormaPagoId


	select 
		Del = @pDel,
		Al = @pAl,
		Caja = caja.Descripcion,
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		Folio = cc.CorteCajaId,
		Fecha = cast(FechaApertura as date),
		FechaApertura = FechaApertura,
		FechaCierre = cc.FechaCorte,
		Efectivo = sum(case when ccfp.FormaPagoId = 1 then ccfp.Total else 0 end) +
					isnull(afp.Efectivo,0),
		Tarjeta = sum(case when ccfp.FormaPagoId in( 2,3) then ccfp.Total else 0 end)+
				isnull(afp.Tarjeta,0),
		Vales = sum(case when ccfp.FormaPagoId in( 5) then ccfp.Total else 0 end) +
				isnull(afp.Vales,0),
		Total =sum(case when ccfp.FormaPagoId in (1,2,3,5) then ccfp.Total else 0 end)+
			isnull(afp.Total,0) ,
		Gastos = isnull(g.total1,0),--isnull(sum(g.Monto),0),
		Cancelaciones = (
			select isnull(sum(sv.TotalVenta),0)
			from doc_ventas sv
			where sv.CajaId = cc.CajaId and
			sv.FechaCancelacion is not null and
			sv.FechaCancelacion between cc.FechaApertura and cc.FechaCorte
		),
		Retiros = isnull(r.total1,0),--isnull(sum(ret.MontoRetiro),0),
		Devoluciones = (
			select isnull(sum(sdev.Total),0)
			from doc_devoluciones sdev
			inner join doc_ventas sv on sv.VentaId = sdev.VentaId
			where sv.CajaId = cc.CajaId and
			sv.Fecha between cc.FechaApertura and cc.FechaCorte
			
		),
		TotalCorte = sum(case when ccfp.FormaPagoId in (1,2,3,5) then ccfp.Total else 0 end)+
			 isnull(afp.Total,0)
			-
			isnull(g.total1,0)-
			--(
			--	select isnull(sum(sv.TotalVenta),0)
			--	from doc_ventas sv
			--	where sv.CajaId = cc.CajaId and
			--	sv.FechaCancelacion is not null and
			--	sv.FechaCancelacion between cc.FechaApertura and cc.FechaCorte
			--) -
			isnull(r.total1,0)-
			(
			select isnull(sum(sdev.Total),0)
			from doc_devoluciones sdev
			inner join doc_ventas sv on sv.VentaId = sdev.VentaId
			where sv.CajaId = cc.CajaId and
			sv.Fecha between cc.FechaApertura and cc.FechaCorte
			
		),
		Vendedor = u.NombreUsuario
	from doc_corte_caja cc
	inner join doc_corte_caja_fp ccfp on ccfp.CorteCajaId = cc.CorteCajaId
	inner join cat_cajas caja on caja.Clave = cc.CajaId
	inner join cat_sucursales suc on suc.Clave = caja.Sucursal
	inner join cat_empresas emp on emp.Clave = suc.Empresa
	inner join cat_usuarios u on u.IdUsuario = cc.CreadoPor
	left join #tmpRetiros r on r.CorteCajaId = cc.CorteCajaId
	left join #tmpGastos g on g.CorteCajaId = cc.CorteCajaId
	left join #tmpApartadosFP afp on afp.CorteCajaId = cc.CorteCajaId
	

	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	@pCajaId in (cc.CajaId ,0)
	group by  cc.CorteCajaId,
		 FechaApertura,
		 cc.FechaCorte,
		 cc.CajaId,
		 cc.TotalCorte,
		 emp.NombreComercial,
		suc.NombreSucursal,
		caja.Descripcion,
		u.NombreUsuario,
		r.total1,
		g.total1,
		afp.Efectivo,
		afp.Tarjeta,
		afp.Vales,
		afp.Total
	


GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_resumido_previo]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_rpt_corte_caja_resumido 1,1,'20180723','20180724'
create Proc [dbo].[p_rpt_corte_caja_resumido_previo]
@pSucursal int,
@pCajaId int,
@pDel DateTime,
@pAl DateTime
as

	declare @gastos money,
		@retiros money
	
	select cc.CorteCajaId,total1 = isnull(sum(g.Monto),0)
	into #tmpGastos
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join doc_gastos g on g.CajaId = cc.cajaId and
							g.CreadoEl between FechaApertura and FechaCorte
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId


	select cc.CorteCajaId,total1 = isnull(sum(g.MontoRetiro),0)
	into #tmpRetiros
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join doc_retiros g on g.CajaId = cc.cajaId and
							g.FechaRetiro between FechaApertura and FechaCorte
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId



	select Efectivo = sum(case when fp.FormaPagoId = 1 then fp.Total else 0 end),
	Tarjeta=sum(case when fp.FormaPagoId in( 2,3) then fp.Total else 0 end),
	Vales = sum(case when fp.FormaPagoId in( 5) then fp.Total else 0 end),
	Total = sum(case when fp.FormaPagoId = 1 then fp.Total else 0 end) +
			sum(case when fp.FormaPagoId in( 2,3) then fp.Total else 0 end) +
			sum(case when fp.FormaPagoId in( 5) then fp.Total else 0 end),
	cc.CorteCajaId
	into #tmpApartadosFP
	from [doc_corte_caja_fp_apartado_previo] fp
	inner join doc_corte_caja_previo cc on cc.CorteCajaId = fp.CorteCajaId
	inner join cat_cajas  c on c.clave = cc.CajaId
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId,fp.FormaPagoId


	select 
		Del = @pDel,
		Al = @pAl,
		Caja = caja.Descripcion,
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		Folio = cc.CorteCajaId,
		Fecha = cast(FechaApertura as date),
		FechaApertura = FechaApertura,
		FechaCierre = cc.FechaCorte,
		Efectivo = sum(case when ccfp.FormaPagoId = 1 then ccfp.Total else 0 end) +
					isnull(afp.Efectivo,0),
		Tarjeta = sum(case when ccfp.FormaPagoId in( 2,3) then ccfp.Total else 0 end)+
				isnull(afp.Tarjeta,0),
		Vales = sum(case when ccfp.FormaPagoId in( 5) then ccfp.Total else 0 end) +
				isnull(afp.Vales,0),
		Total =sum(case when ccfp.FormaPagoId in (1,2,3,5) then ccfp.Total else 0 end)+
			isnull(afp.Total,0) ,
		Gastos = isnull(g.total1,0),--isnull(sum(g.Monto),0),
		Cancelaciones = (
			select isnull(sum(sv.TotalVenta),0)
			from doc_ventas sv
			where sv.CajaId = cc.CajaId and
			sv.FechaCancelacion is not null and
			sv.FechaCancelacion between cc.FechaApertura and cc.FechaCorte
		),
		Retiros = isnull(r.total1,0),--isnull(sum(ret.MontoRetiro),0),
		Devoluciones = (
			select isnull(sum(sdev.Total),0)
			from doc_devoluciones sdev
			inner join doc_ventas sv on sv.VentaId = sdev.VentaId
			where sv.CajaId = cc.CajaId and
			sv.Fecha between cc.FechaApertura and cc.FechaCorte
			
		),
		TotalCorte = sum(case when ccfp.FormaPagoId in (1,2,3,5) then ccfp.Total else 0 end)+
			 isnull(afp.Total,0)
			-
			isnull(g.total1,0)-
			(
				select isnull(sum(sv.TotalVenta),0)
				from doc_ventas sv
				where sv.CajaId = cc.CajaId and
				sv.FechaCancelacion is not null and
				sv.FechaCancelacion between cc.FechaApertura and cc.FechaCorte
			) -
			isnull(r.total1,0)-
			(
			select isnull(sum(sdev.Total),0)
			from doc_devoluciones sdev
			inner join doc_ventas sv on sv.VentaId = sdev.VentaId
			where sv.CajaId = cc.CajaId and
			sv.Fecha between cc.FechaApertura and cc.FechaCorte
			
		),
		Vendedor = u.NombreUsuario
	from doc_corte_caja_previo cc
	inner join doc_corte_caja_fp_previo ccfp on ccfp.CorteCajaId = cc.CorteCajaId
	inner join cat_cajas caja on caja.Clave = cc.CajaId
	inner join cat_sucursales suc on suc.Clave = caja.Sucursal
	inner join cat_empresas emp on emp.Clave = suc.Empresa
	inner join cat_usuarios u on u.IdUsuario = cc.CreadoPor
	left join #tmpRetiros r on r.CorteCajaId = cc.CorteCajaId
	left join #tmpGastos g on g.CorteCajaId = cc.CorteCajaId
	left join #tmpApartadosFP afp on afp.CorteCajaId = cc.CorteCajaId
	

	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	@pCajaId in (cc.CajaId ,0)
	group by  cc.CorteCajaId,
		 FechaApertura,
		 cc.FechaCorte,
		 cc.CajaId,
		 cc.TotalCorte,
		 emp.NombreComercial,
		suc.NombreSucursal,
		caja.Descripcion,
		u.NombreUsuario,
		r.total1,
		g.total1,
		afp.Efectivo,
		afp.Tarjeta,
		afp.Vales,
		afp.Total
	


GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_retiros]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_corte_caja_retiros 1
CREATE Proc [dbo].[p_rpt_corte_caja_retiros]
@pCorteCajaId int
as

	select Folio=ret.RetiroId,
		Monto=ret.MontoRetiro,
		Fecha=ret.FechaRetiro
	from doc_corte_caja cc	
	inner join doc_retiros ret on ret.CajaId = cc.CajaId and
								ret.FechaRetiro
								between cc.FechaApertura
								 and cc.FechaCorte and
								 ret.CreadoPor = cc.CreadoPor
	
	where cc.CorteCajaId = @pCorteCajaId






GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_retiros_previo]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_rpt_corte_caja_retiros 1
create Proc [dbo].[p_rpt_corte_caja_retiros_previo]
@pCorteCajaId int
as

	select Folio=ret.RetiroId,
		Monto=ret.MontoRetiro,
		Fecha=ret.FechaRetiro
	from doc_corte_caja_previo cc	
	inner join doc_retiros ret on ret.CajaId = cc.CajaId and
								ret.FechaRetiro
								between cc.FechaApertura
								 and cc.FechaCorte and
								 ret.CreadoPor = cc.CreadoPor
	
	where cc.CorteCajaId = @pCorteCajaId






GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_tpv_digito]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_corte_caja_tpv_digito 2
create proc [dbo].[p_rpt_corte_caja_tpv_digito]
@pCorteCajaId int
as

	select Folio = v.Serie + v.Folio,
		Importe = vfp.Cantidad,
		Digito = digitoVerificador
	from [dbo].[doc_corte_caja_ventas] ccv
	inner join [dbo].[doc_ventas_formas_pago] vfp on vfp.VentaId = ccv.VentaId
	inner join doc_ventas v on v.VentaId = vfp.VentaID
	where ccv.CorteId = @pCorteCajaId and
	vfp.FormaPagoId in (2,3)

	union


	select Folio = cast(v.ApartadoId as varchar),
		Importe = vfp.Cantidad,
		Digito = digitoVerificador
	from [dbo].[doc_corte_caja_apartados_pagos] ccv
	inner join [dbo].[doc_apartados_formas_pago] vfp on vfp.ApartadoPagoId = ccv.ApartadoPagoId
	inner join doc_apartados_pagos ap on  ap.ApartadoPagoId = ccv.ApartadoPagoId
	inner join [dbo].[doc_apartados] v on v.ApartadoId = ap.ApartadoId
	where ccv.CorteCajaId = @pCorteCajaId and
	vfp.FormaPagoId in (2,3)
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_tpv_digito_previo]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_corte_caja_tpv_digito 2
create proc [dbo].[p_rpt_corte_caja_tpv_digito_previo]
@pCorteCajaId int
as

	select Folio = v.Serie + v.Folio,
		Importe = vfp.Cantidad,
		Digito = digitoVerificador
	from [dbo].[doc_corte_caja_ventas_previo] ccv
	inner join [dbo].[doc_ventas_formas_pago] vfp on vfp.VentaId = ccv.VentaId
	inner join doc_ventas v on v.VentaId = vfp.VentaID
	where ccv.CorteId = @pCorteCajaId and
	vfp.FormaPagoId in (2,3)

	union


	select Folio = cast(v.ApartadoId as varchar),
		Importe = vfp.Cantidad,
		Digito = digitoVerificador
	from [dbo].[doc_corte_caja_apartados_pagos_previo] ccv
	inner join [dbo].[doc_apartados_formas_pago] vfp on vfp.ApartadoPagoId = ccv.ApartadoPagoId
	inner join doc_apartados_pagos ap on  ap.ApartadoPagoId = ccv.ApartadoPagoId
	inner join [dbo].[doc_apartados] v on v.ApartadoId = ap.ApartadoId
	where ccv.CorteCajaId = @pCorteCajaId and
	vfp.FormaPagoId in (2,3)

GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_vales]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_rpt_corte_caja_vales]
@pCorteCaja int
as

	select Folio = isnull(v.Serie,'') + cast(v.VentaId as varchar),
		   MontoTicket = v.TotalVenta,
		   FolioVale = vale.DevolucionId,
		   MontoVale = dev.Total
	from doc_ventas v
	inner join doc_corte_caja cc on cc.CorteCajaId = @pCorteCaja and
							v.Fecha between cc.FechaApertura and cc.FechaCorte
	inner join [dbo].[doc_ventas_formas_pago_vale] vale on vale.VentaId = v.VentaId 
	inner join doc_devoluciones  dev on dev.DevolucionId = vale.DevolucionId
						

GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_vales_previo]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[p_rpt_corte_caja_vales_previo]
@pCorteCaja int
as

	select Folio = isnull(v.Serie,'') + cast(v.VentaId as varchar),
		   MontoTicket = v.TotalVenta,
		   FolioVale = vale.DevolucionId,
		   MontoVale = dev.Total
	from doc_ventas v
	inner join doc_corte_caja_previo cc on cc.CorteCajaId = @pCorteCaja and
							v.Fecha between cc.FechaApertura and cc.FechaCorte
	inner join [dbo].[doc_ventas_formas_pago_vale] vale on vale.VentaId = v.VentaId 
	inner join doc_devoluciones  dev on dev.DevolucionId = vale.DevolucionId
						

GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_venta_por_producto]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_corte_caja_venta_por_producto 1,22
CREATE PROC [dbo].[p_rpt_corte_caja_venta_por_producto]
@EmpresaId INT,
@pCorteCajaId INT
AS

	declare @ValorPreferencia VARCHAR(500),
			@UsarOtros BIT=0
	

	SELECT @ValorPreferencia = ISNULL(pe.Valor,'')
	FROM sis_preferencias_empresa PE
	INNER JOIN sis_preferencias P ON P.Id = PE.PreferenciaId AND P.Preferencia = 'CorteCajaSubReporteVentasProd'
	WHERE PE.EmpresaId = @EmpresaId

	

	SELECT splitdata
	INTO #TMP_IdProdcutos
	FROM [dbo].[fnSplitString](@ValorPreferencia,',')

	

	IF NOT EXISTS (SELECT 1 FROM #TMP_IdProdcutos) SET @UsarOtros = 0 ELSE SET @UsarOtros = 1
	
	--INSERTAR PRODUCTOS QUE EST�N EN PREFERENCIA
	SELECT CC.CorteCajaId,
		P.Clave,
		Producto = P.Descripcion,
		Total = SUM(VD.Total)
	INTO #TMP_RESULT
	FROM doc_corte_caja CC
	INNER JOIN doc_corte_caja_ventas CCV ON CCV.CorteId = CC.CorteCajaId
	INNER JOIN doc_ventas V ON V.VentaId = CCV.VentaId AND V.FechaCancelacion IS NULL
	INNER JOIN doc_ventas_detalle VD ON VD.VentaId = V.VentaId
	INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId	
	INNER JOIN #TMP_IdProdcutos TMP ON TMP.splitdata = P.ProductoId
	WHERE CC.CorteCajaId = @pCorteCajaId  
	GROUP BY CC.CorteCajaId,
		P.Clave,
		P.Descripcion

		

	IF (@UsarOtros = 0)
	BEGIN
		INSERT INTO #TMP_RESULT
		SELECT CC.CorteCajaId,
			P.Clave,
			Producto = P.Descripcion,
			Total = SUM(VD.Total)		
		FROM doc_corte_caja CC
		INNER JOIN doc_corte_caja_ventas CCV ON CCV.CorteId = CC.CorteCajaId
		INNER JOIN doc_ventas V ON V.VentaId = CCV.VentaId AND V.FechaCancelacion IS NULL
		INNER JOIN doc_ventas_detalle VD ON VD.VentaId = V.VentaId
		INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId		
		WHERE CC.CorteCajaId = @pCorteCajaId  
		GROUP BY CC.CorteCajaId,
			P.Clave,
			P.Descripcion
	END
	ELSE
	BEGIN
		INSERT INTO #TMP_RESULT
		SELECT CC.CorteCajaId,
			Clave = 'OTROS',
			Producto = 'OTROS',
			Total = SUM(VD.Total)		
		FROM doc_corte_caja CC
		INNER JOIN doc_corte_caja_ventas CCV ON CCV.CorteId = CC.CorteCajaId
		INNER JOIN doc_ventas V ON V.VentaId = CCV.VentaId AND V.FechaCancelacion IS NULL
		INNER JOIN doc_ventas_detalle VD ON VD.VentaId = V.VentaId
		INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId			
		WHERE CC.CorteCajaId = @pCorteCajaId   AND
		P.ProductoId NOT IN(
			SELECT splitdata
			FROM #TMP_IdProdcutos
		)
		GROUP BY CC.CorteCajaId
			
	END


	SELECT *
	FROM #TMP_RESULT





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_productos_existencias]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_corte_productos_existencias 1,1
CREATE proc [dbo].[p_rpt_corte_productos_existencias]
@pCorteCajaId int,
@pSoloConExistencia bit
as

	declare @sucursalid int

	select @sucursalid = c.Sucursal
	from doc_corte_caja cc
	inner join cat_cajas c on c.Clave = cc.CajaId
	where CorteCajaId = @pCorteCajaId

	select p.Clave,
			Descripcion = substring(p.Descripcion,1,30),
			pe.ExistenciaTeorica
	from cat_productos_existencias pe
	inner join cat_productos p on p.ProductoId = pe.ProductoId
	where pe.SucursalId = @sucursalid and
	(
		(isnull(pe.ExistenciaTeorica,0) <> 0 AND @pSoloConExistencia = 1) 
		or
		@pSoloConExistencia = 0
	)
	ORDER BY P.ClaveFamilia,P.ClaveSubFamilia, p.Descripcion
	





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_productos_existencias_previo]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_corte_productos_existencias 1,1
create proc [dbo].[p_rpt_corte_productos_existencias_previo]
@pCorteCajaId int,
@pSoloConExistencia bit
as

	declare @sucursalid int

	select @sucursalid = c.Sucursal
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.CajaId
	where CorteCajaId = @pCorteCajaId

	select p.Clave,
			Descripcion = substring(p.Descripcion,1,30),
			pe.ExistenciaTeorica
	from cat_productos_existencias pe
	inner join cat_productos p on p.ProductoId = pe.ProductoId
	where pe.SucursalId = @sucursalid and
	(
		(isnull(pe.ExistenciaTeorica,0) <> 0 AND @pSoloConExistencia = 1) 
		or
		@pSoloConExistencia = 0
	)
	ORDER BY P.ClaveFamilia,P.ClaveSubFamilia, p.Descripcion
	





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_reimpresiones]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_corte_reimpresiones 1
Create proc [dbo].[p_rpt_corte_reimpresiones]
@pCorteCajaId int
as

	select  g.ReimpresionTicketId,
			Folio = conf.Serie + CAST( g.ventaid AS varchar),
			FechaReimpresion = g.CreadoEl,
			ReimpresoPor = e.Nombre
	from doc_reimpresion_ticket g
	inner join doc_corte_caja c on c.CorteCajaId = @pCorteCajaId	
	inner join cat_cajas caj on caj.Clave = c.CajaId
	inner join cat_usuarios usu on usu.IdUsuario = g.CreadoPor
	inner join rh_empleados e on e.NumEmpleado = usu.IdEmpleado
	INNER JOIN cat_configuracion_ticket_venta conf on conf.SucursalId=caj.Sucursal
	where g.CreadoEl
	between c.FechaApertura and c.FechaCorte and	
	g.CajaId = c.CajaId AND
	g.CreadoPor = c.CreadoPor

	




GO
/****** Object:  StoredProcedure [dbo].[p_rpt_cuenta]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_cuenta 1
CREATE proc [dbo].[p_rpt_cuenta]
@pPedidoId int
as

	declare @meseroId int

	select @meseroId = EmpleadoId
	from doc_pedidos_orden_mesero
	where PedidoOrdenId = @pPedidoId

	select 
		Folio = p.PedidoId,
		e.NombreComercial,
		Cantidad = pd.Cantidad,
		Descripcion = pr.DescripcionCorta,
		PrecioUnitario = pd.PrecioUnitario,
		Importe = pd.Total,
		Mesa = dbo.fnGetComandaMesas(p.PedidoId) + ' ' + isnull(p.Para,''),
		Mesero = cast(empleado.NumEmpleado as varchar(50)),
		Total = (select sum(Total) from doc_pedidos_orden_detalle where pedidoid= @pPedidoId)
		
	from doc_pedidos_orden p
	inner join doc_pedidos_orden_detalle pd on pd.PedidoId = p.PedidoId
	inner join cat_sucursales suc on suc.Clave = p.SucursalId
	inner join cat_empresas e on e.Clave = suc.Empresa
	inner join cat_productos pr on pr.ProductoId = pd.ProductoId
	inner join rh_empleados empleado on empleado.NumEmpleado = @meseroId
	
	where p.PedidoId = @pPedidoId and isnull(pd.Cancelado,0) = 0
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_cuentas_resumen]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_cuentas_resumen 2,'20231214','20231214',0,0,0,1
CREATE PROC [dbo].[p_rpt_cuentas_resumen]
@pSucursalId INT,
@pDel DATETIME,
@pAl DATETIME,
@pMaizInventario DECIMAL(14,3)=0,
@pMasecaInventario DECIMAL(14,3)=0,
@pTotalRepartoRecuperacion DECIMAL(14,3)=0,
@pUsuarioId INT
AS

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	DECLARE @PrecioSacoMaiz MONEY=0,
			@PrecioSacoMaseca MONEY=0,
			@PrecioTortilla MONEY = 0,
			@RecuperacionTotal MONEY=0,
			@Gastos MONEY=0,
			@UtilidadSucursal DECIMAL(14,3),
			@UtilidadEmpresa DECIMAL(14,3)


	CREATE TABLE #TMP_RESULT
	(
		Id INT IDENTITY(1,1),
		Sucursal VARCHAR(200),
		MaizSacosEntrada DECIMAL(14,3) default 0,
		MasecaSacosEntrada DECIMAL(14,3) default 0,
		MaizInvFinal  DECIMAL(14,3) default 0,
		MasecaInvFinal  DECIMAL(14,3) default 0,
		MaizSacosPagar DECIMAL(14,3) default 0,
		MasecaSacosPagar DECIMAL(14,3) default 0,
		MaizSacoRendimiento DECIMAL(14,3) default 0,
		MasecaSacoRendimiento DECIMAL(14,3) default 0,
		MaizSacoRendimientoTortilla DECIMAL(14,3) default 0,
		MasecaSacoRendimientoTortilla DECIMAL(14,3) default 0,
		TortillaPrecioKilo MONEY default 0,--Precio por Kilo
		MaizTotalProduccion MONEY default 0,--Total Prod. Maiz y maseca
		MasecaTotalProduccion MONEY default 0, --Total Prod. Maiz y maseca
		TortillaVentaTotal MONEY default 0, --Total venta tortilla
		RepartoRecuperacionTotal MONEY default 0,--Recuperacion 2 Pesos Vtas reparto
		TortillaVentaTotal2 MONEY default 0, --Total venta tortilla
		PagosMaseca MONEY default 0,--Pagos a Maseca
		PagosMaiz MONEY default 0,--Consumo de Maiz
		Gastos MONEY default 0,
		Utilidad MONEY default 0,
		Utilidad60 MONEY default 0,
		ConsumoMaiz MONEY default 0,
		TotalPago MONEY default 0,
		Utilidad40 MONEY default 0,
		MaizSacoCosto MONEY default 0,
		MasecaSacoCosto MONEY default 0
		
	)

	SELECT @UtilidadSucursal = CAST(ISNULL([dbo].[fnGetPreferenciaValor]('UtilidadSucursal',@pSucursalId),0) AS DECIMAL(14,2));
	SET @UtilidadEmpresa = 100 - @UtilidadSucursal;


	SELECT @PrecioSacoMaiz = MAX(PP.Precio)
	FROM cat_productos P
	INNER JOIN cat_productos_precios PP ON PP.IdProducto = P.ProductoId
	WHERE P.Clave = 'MP001'

	SELECT @PrecioSacoMaseca = MAX(PP.Precio)
	FROM cat_productos P
	INNER JOIN cat_productos_precios PP ON PP.IdProducto = P.ProductoId
	WHERE P.Clave = 'MP002'


	--SUCURSAL
	INSERT INTO #TMP_RESULT(Sucursal)
	SELECT NombreSucursal
	FROM cat_sucursales S
	INNER JOIN cat_usuarios_sucursales US  ON US.UsuarioId = @pUsuarioId AND
										US.SucursalId = S.Clave
	where Clave = @pSucursalId

	UPDATE #TMP_RESULT
	SET MaizSacoCosto = @PrecioSacoMaiz,
	MasecaSacoCosto = @PrecioSacoMaseca

	--*************SACOS ENTRADA****************
	SELECT	MaizSacos = ISNULL(SUM(T1.MaizSacos),0) ,
		MasecaSacos = ISNULL(SUM(T1.MasecaSacos),0),
		SucursalId = T1.SucursalId
	INTO #TMP_MAIZ_MASECA_ENTRADA
	FROM doc_maiz_maseca_entrada T1
	WHERE SucursalId = @pSucursalId AND
	CAST(T1.Fecha AS DATE) BETWEEN  CAST(@pDel AS DATE) AND CAST(@pAl AS DATE)
	GROUP BY T1.SucursalId

	UPDATE #TMP_RESULT
	SET MaizSacosEntrada = MaizSacos,
		MasecaSacosEntrada = MasecaSacos
	FROM #TMP_RESULT TMP
	INNER JOIN #TMP_MAIZ_MASECA_ENTRADA TMP2 ON TMP2.SucursalId = @pSucursalId

	--*******************MAIZ/MASECA INV FINAL***********************
	UPDATE #TMP_RESULT
	SET MaizInvFinal = @pMaizInventario,
		MasecaInvFinal = @pMasecaInventario

	--****************Sacos Maiz/maseca a pagar**********************
	UPDATE #TMP_RESULT
	SET MaizSacosPagar = MaizSacosEntrada - MaizInvFinal  ,
		MasecaSacosPagar = MasecaSacosEntrada - MasecaInvFinal

	--***************Rendimineto por saco*************************
	UPDATE  #TMP_RESULT
	SET MaizSacoRendimiento = CAST(isnull(PS.Valor,0) AS DECIMAL(14,2))
	FROM #TMP_RESULT TMP
	INNER JOIN sis_preferencias_sucursales PS ON PS.SucursalId = @pSucursalId
	INNER JOIN sis_preferencias P ON P.Id = PS.PreferenciaId AND
								P.Preferencia IN ('PROD-EquivalenciaMaizSacoTortillaKg')

	UPDATE  #TMP_RESULT
	SET MasecaSacoRendimiento = CAST(isnull(PS.Valor,0) AS DECIMAL(14,2))
	FROM #TMP_RESULT TMP
	INNER JOIN sis_preferencias_sucursales PS ON PS.SucursalId = @pSucursalId
	INNER JOIN sis_preferencias P ON P.Id = PS.PreferenciaId AND
								P.Preferencia IN ('PROD-EquivalenciaMasecaSacoTortillaKg')

	--***************Rend. Kilos tortilla****************
	UPDATE #TMP_RESULT
	SET MaizSacoRendimientoTortilla = MaizSacoRendimiento * MaizSacosPagar,
		MasecaSacoRendimientoTortilla = MasecaSacoRendimiento * MasecaSacosPagar

	--*****************Precio por Kilo*****************************
	UPDATE #TMP_RESULT
	SET TortillaPrecioKilo = (SELECT ISNULL(MAX(S1.PrecioUnitario),0) FROM doc_ventas_detalle S1 WHERE S1.ProductoId = 1 AND CAST(S1.FechaCreacion AS DATE) BETWEEN CAST(@pDel AS DATE) AND  CAST(@pAl AS DATE) )


	--**********Total Prod. Maiz y maseca***************
	update  #TMP_RESULT
	SET MaizTotalProduccion = TortillaPrecioKilo * MaizSacoRendimientoTortilla,
		MasecaTotalProduccion = TortillaPrecioKilo * MasecaSacoRendimientoTortilla

	--***********Total venta tortilla*************
	UPDATE #TMP_RESULT
	SET TortillaVentaTotal = MaizTotalProduccion + MasecaTotalProduccion

	--************Recuperacion 2 Pesos Vtas reparto****************	
	SELECT @RecuperacionTotal = ISNULL(SUM(VD.Cantidad),0) * 2
	FROM DOC_VENTAS_DETALLE VD 
	INNER JOIN DOC_VENTAS V ON V.VentaId = VD.VentaId AND
								V.Activo = 1 AND
								V.SucursalId = @pSucursalId AND
								CAST(V.FechaCreacion AS DATE) BETWEEN CAST(@pDel AS DATE) and CAST(@pAl AS DATE) AND
								VD.ProductoId IN (1,2)
	INNER JOIN DOC_PEDIDOS_ORDEN PO  ON PO.VentaId = V.VentaId
	
	UPDATE #TMP_RESULT
	SET RepartoRecuperacionTotaL = CASE  WHEN @pTotalRepartoRecuperacion > 0 THEN @pTotalRepartoRecuperacion ELSE  @RecuperacionTotal END

	--*************Total venta tortilla***************
	UPDATE #TMP_RESULT
	SET TortillaVentaTotal2 = TortillaVentaTotal - RepartoRecuperacionTotaL


	--Pagos a Maseca
	UPDATE #TMP_RESULT
	SET PagosMaseca = MasecaSacosPagar * @PrecioSacoMaseca,
		PagosMaiz = MaizSacosPagar * @PrecioSacoMaiz


	--Gatos en general
	SELECT @Gastos = ISNULL(SUM(G.Monto),0)
	FROM doc_gastos G
	INNER JOIN cat_gastos_deducibles GD ON GD.GastoConceptoId = G.GastoConceptoId
	WHERE G.SucursalId = @pSucursalId AND
	G.Activo = 1 AND
	CAST(G.CreadoEl AS DATE) BETWEEN CAST(@pDel AS DATE) AND CAST(@pAl AS DATE)

	UPDATE #TMP_RESULT
	SET Gastos = @Gastos

	--Utilidad Tortilleria
	UPDATE #TMP_RESULT
	SET Utilidad = CASE WHEN ( TortillaVentaTotal2 - PagosMaiz - PagosMaseca - Gastos) < 0 THEN 0 ELSE ( TortillaVentaTotal2 - PagosMaiz - PagosMaseca - Gastos) END

	--Utilidad Tortilleria
	UPDATE #TMP_RESULT
	SET Utilidad60 =Utilidad * (@UtilidadEmpresa/100)

	--Utilidad Tortilleria
	UPDATE #TMP_RESULT
	SET ConsumoMaiz = PagosMaiz

	--Total a paga a Don Juan
	UPDATE #TMP_RESULT
	SET TotalPago = PagosMaiz + Utilidad60


	--Utilidad Encargado 40%
	UPDATE #TMP_RESULT
	SET Utilidad40 = Utilidad * (@UtilidadSucursal/100)

	SELECT * FROM #TMP_RESULT
	
	
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_devolucion]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_devolucion 2
CREATE Proc [dbo].[p_rpt_devolucion]
@pDevolucionId int
as

	select 
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		Total = d.Total,
		v.VentaId,
		FechaRegistro = d.CreadoEl,
		RegistradoPor = e.Nombre,
		D.DevolucionId,
		d.FechaVencimiento,
		TipoDevolucion = td.Descripcion
	from doc_devoluciones d
	inner join doc_ventas v on v.VentaId = d.VentaId
	inner join cat_sucursales suc on suc.Clave = v.SucursalId
	inner join cat_empresas emp on emp.Clave = suc.Empresa
	inner join cat_usuarios us on us.IdUsuario = d.CreadoPor
	inner join rh_empleados e  on e.NumEmpleado = us.IdEmpleado
	inner join cat_tipos_devolucion td on td.TipoDevolucionId = d.TipoDevolucionId
	where d.DevolucionId = @pDevolucionId

	





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_estado_cuenta_detalle]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_estado_cuenta_detalle 1,'all','20210101','20220228'
CREATE proc [dbo].[p_rpt_estado_cuenta_detalle]
@pSucursalId INT,
@pTipo varchar(50),
@pDel DATETIME,
@pAl DATETIME,
@pUsuarioId INT=0
AS

	--GASTOS
	SELECT Fecha = PC.FechaRegistro,
			Sucursal = SUC.NombreSucursal,
		   Movimiento = 'Compras a Proveedores',
		   DetalleMovimiento = 'Proveedor:'+ISNULL(PROV.Nombre,''),
		   Total = (PC.Total) * -1,
		   CargoAbono=CAST(0 AS BIT),
		   Tipo = 'Cargo'
	FROM doc_productos_compra PC
	INNER JOIN doc_inv_movimiento I ON I.ProductoCompraId = PC.ProductoCompraId
	INNER JOIN cat_proveedores PROV ON PROV.ProveedorId = PC.ProveedorId
	INNER JOIN cat_sucursales SUC ON SUC.Clave = PC.SucursalId
	INNER JOIN dbo.fnUsuarioSucursales(@pUsuarioId) US ON US.SucursalId = PC.SucursalId
	WHERE PC.Activo = 1 AND
	I.Activo = 1	AND
	@pSucursalId IN(	PC.SucursalId,0) AND
	CONVERT(VARCHAR,PC.FechaRegistro,112) BETWEEN CONVERT(VARCHAR,@pDel,112) AND CONVERT(VARCHAR,@pAl,112)
	AND @pTipo IN ('ALL','GAS')

	UNION

	SELECT G.CreadoEl,
			Sucursal = SUC.NombreSucursal,
			Movimiento='Gastos Caja Chica',
			DetalleMovimiento = G.Obervaciones,
			Total = G.Monto * -1,
			CargoAbono=CAST(0 AS BIT),
			Tipo = 'Cargo'
	FROM doc_gastos G
	INNER JOIN cat_sucursales SUC ON SUC.Clave = G.SucursalId
	INNER JOIN dbo.fnUsuarioSucursales(@pUsuarioId) US ON US.SucursalId = G.SucursalId
	WHERE G.Activo = 1 AND
	@pSucursalId IN(G.SucursalId,0)AND
	CONVERT(VARCHAR,G.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pDel,112) AND CONVERT(VARCHAR,@pAl,112)
	AND @pTipo IN ('ALL','GAS')

	UNION 

	--VENTAS

	SELECT
		V.Fecha,
		SucursalId = SUC.NombreSucursal,
		Movimiento='Venta',
		DetalleMovimiento = ISNULL(V.Serie,'') + ISNULL(V.Folio,''),
		Total = V.TotalVenta,
			CargoAbono=CAST(1 AS bit),
			Tipo = 'Abono'
	FROM doc_ventas V
	INNER JOIN cat_sucursales SUC ON SUC.Clave = V.SucursalId
	INNER JOIN dbo.fnUsuarioSucursales(@pUsuarioId) US ON US.SucursalId = V.SucursalId
	WHERE V.Activo = 1 AND
	@pSucursalId IN(v.SucursalId,0)AND
	CONVERT(VARCHAR,V.Fecha,112) BETWEEN CONVERT(VARCHAR,@pDel,112) AND CONVERT(VARCHAR,@pAl,112)
	AND @pTipo IN ('ALL','VEN')
	order by 1 desc
	
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_existencias_agrupado]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_existencias_agrupado 1,0,0,0,1,0,0,0
create proc [dbo].[p_rpt_existencias_agrupado]
@pSucursalId int,
@pLinea int,
@pFamilia int,
@pSubFamilia int,
@pLineaAgrupado bit,
@pFamiliaAgrupado bit,
@pSubfamiliaAgrupado bit,
@pSoloConExistencia bit
as

	select pe.ProductoId,
			pe.ExistenciaTeorica,
			p.ClaveLinea,
			p.ClaveFamilia,
			p.ClaveSubFamilia,
			Sucursal = suc.NombreSucursal
	INTO #tmpExistencias
	from cat_productos_existencias pe
	inner join cat_productos p  on  p.ProductoId = pe.ProductoId
	inner join cat_sucursales suc on suc.Clave = @pSucursalId
	where
	@pLinea in (0,p.ClaveLinea) and
	@pFamilia in(0,p.ClaveFamilia) and
	@pSubFamilia in (0,p.ClaveSubFamilia)  and
	pe.SucursalId = @pSucursalId AND
	(
		(PE.ExistenciaTeorica <> 0 AND @pSoloConExistencia = 1)
		or
		@pSoloConExistencia = 0
	)
	

	if(
		@pLineaAgrupado = 1
	)
	begin
		select Clave = linea.Clave,
				Tipo = 'Línea',
				Descripcion = linea.Descripcion,
				Existencia = Sum(tmp.ExistenciaTeorica),
				Sucursal = MAX(TMP.Sucursal)
		FROM #tmpExistencias tmp
		inner join cat_lineas linea on linea.Clave = tmp.ClaveLinea
		group by linea.Clave,linea.Descripcion
	end

	if(
		@pFamiliaAgrupado = 1
	)
	begin
		select Clave = linea.Clave,
				Tipo = 'Familia',
				Descripcion = linea.Descripcion,
				Existencia = Sum(tmp.ExistenciaTeorica),
				Sucursal = MAX(TMP.Sucursal)
		FROM #tmpExistencias tmp
		inner join cat_familias linea on linea.Clave = tmp.ClaveFamilia
		group by linea.Clave,linea.Descripcion
	end

	if(
		@pSubFamiliaAgrupado = 1
	)
	begin
		select Clave = linea.Clave,
				Tipo = 'Subfamilia',
				Descripcion = linea.Descripcion,
				Existencia = Sum(tmp.ExistenciaTeorica),
				Sucursal = MAX(TMP.Sucursal)
		FROM #tmpExistencias tmp
		inner join cat_subfamilias linea on linea.Clave = tmp.ClaveFamilia
		group by linea.Clave,linea.Descripcion
	end


GO
/****** Object:  StoredProcedure [dbo].[p_rpt_gasto_ticket]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_gasto_ticket 1
Create Proc [dbo].[p_rpt_gasto_ticket]
@pGastoId int
as

	select Empresa = NombreComercial,
		Sucursal = suc.NombreSucursal,
		g.Obervaciones,
		g.Monto,
		CentroCosto = cc.Descripcion,
		Concepto = con.Descripcion,
		RegistradoPor = empl.Nombre,
		Fecha = convert(varchar,getdate(),103)
	from doc_gastos g
	inner join cat_sucursales suc on suc.Clave = g.SucursalId
	inner join cat_empresas emp on emp.Clave = suc.Empresa
	inner join [dbo].[cat_centro_costos] cc on cc.Clave = g.CentroCostoId
	inner join [dbo].[cat_gastos] con on con.Clave = g.GastoConceptoId
	inner join [dbo].[cat_usuarios] usu on usu.IdUsuario = g.CreadoPor
	inner join [dbo].[rh_empleados] empl on empl.NumEmpleado = usu.IdEmpleado
	where g.gastoId = @pGastoId





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_gramos_favor_contra]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- p_rpt_gramos_favor_contra 2,'20221005','20221005'
CREATE PROC [dbo].[p_rpt_gramos_favor_contra]
@pSucursalId INT,
@pDel DATETIME,
@pAl DATETIME
AS

--GRAMOS A FAVOR
SELECT 	
	VD.VentaDetalleId,
	S.NombreSucursal,
	GramosFavorContra = Cantidad - Total/PrecioUnitario,
	Producto = P.DescripcionCorta,
	FolioVenta = V.Serie + V.Folio,
	Importe = VD.PrecioUnitario * (Cantidad - Total/PrecioUnitario)
FROM doc_ventas_detalle VD
INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId AND v.Activo = 1
INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId AND p.ProdVtaBascula = 1
INNER JOIN cat_sucursales S ON S.Clave = V.SucursalId
WHERE (PrecioUnitario * Cantidad) <> Total AND
PrecioUnitario > 0 AND
@pSucursalId IN (S.Clave,0 )  AND
CONVERT(VARCHAR,V.FechaCreacion,112) BETWEEN CONVERT(VARCHAR,@pDel,112) AND CONVERT(VARCHAR,@pAl,112)

UNION 

--GRAMOS EN CONTRA

SELECT 	
	VD.VentaDetalleId,
	S.NombreSucursal,
	GramosFavorContra = (Total % 1) - 1,
	Producto = P.DescripcionCorta,
	FolioVenta = V.Serie + V.Folio,
	Importe = VD.PrecioUnitario * ((Total % 1) - 1)
FROM doc_ventas_detalle VD
INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId and v.Activo = 1
INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId AND p.ProdVtaBascula = 1
INNER JOIN cat_sucursales S ON S.Clave = V.SucursalId
WHERE (Cantidad % 1 BETWEEN .875 AND .999  AND VD.Total = VD.PrecioUnitario) AND
PrecioUnitario > 0 AND
@pSucursalId IN (S.Clave,0 )  AND
CONVERT(VARCHAR,V.FechaCreacion,112) BETWEEN CONVERT(VARCHAR,@pDel,112) AND CONVERT(VARCHAR,@pAl,112)

GO
/****** Object:  StoredProcedure [dbo].[p_rpt_gramos_favor_contra_agrupado]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- p_rpt_gramos_favor_contra_agrupado 9,'20221019','20221019'
CREATE PROC [dbo].[p_rpt_gramos_favor_contra_agrupado]
@pSucursalId INT,
@pDel DATETIME,
@pAl DATETIME
AS

	CREATE TABLE #TMP_RESULT(
		Tipo VARCHAR(100),
		VentaDetalleId INT,
		NombreSucursal VARCHAR(500),
		GramosFavorContra FLOAT,
		Producto VARCHAR(500),
		FolioVenta VARCHAR(100),
		Importe MONEY
	)


	INSERT INTO #TMP_RESULT
	--GRAMOS A FAVOR
	SELECT 	
		'GRAMOS A FAVOR',
		VD.VentaDetalleId,
		S.NombreSucursal,
		GramosFavorContra = Cantidad - Total/PrecioUnitario,
		Producto = P.DescripcionCorta,
		FolioVenta = V.Serie + V.Folio,
		Importe = VD.PrecioUnitario * (Cantidad - Total/PrecioUnitario)
	FROM doc_ventas_detalle VD
	INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId AND v.Activo = 1 AND
														@pSucursalId IN (v.SucursalId,0 ) 
	INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId AND p.ProdVtaBascula = 1
	INNER JOIN cat_sucursales S ON S.Clave = V.SucursalId
	WHERE (PrecioUnitario * Cantidad) <> Total AND
	PrecioUnitario > 0 AND
	CONVERT(VARCHAR,V.FechaCreacion,112) BETWEEN CONVERT(VARCHAR,@pDel,112) AND CONVERT(VARCHAR,@pAl,112)

	UNION 

	--GRAMOS EN CONTRA

	SELECT 	
		'GRAMOS EN CONTRA',
		VD.VentaDetalleId,
		S.NombreSucursal,
		GramosFavorContra = (Total % 1) - 1,
		Producto = P.DescripcionCorta,
		FolioVenta = V.Serie + V.Folio,
		Importe = VD.PrecioUnitario * ((Total % 1) - 1)
	FROM doc_ventas_detalle VD
	INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId and v.Activo = 1 AND @pSucursalId IN (V.SucursalId,0 )  
	INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId AND p.ProdVtaBascula = 1
	INNER JOIN cat_sucursales S ON S.Clave = V.SucursalId
	WHERE (Cantidad % 1 BETWEEN .875 AND .999  AND VD.Total = VD.PrecioUnitario) AND
	PrecioUnitario > 0 AND	
	CONVERT(VARCHAR,V.FechaCreacion,112) BETWEEN CONVERT(VARCHAR,@pDel,112) AND CONVERT(VARCHAR,@pAl,112)

	SELECT Tipo,
		Total = SUM(Importe)
	FROM #TMP_RESULT
	GROUP BY Tipo

GO
/****** Object:  StoredProcedure [dbo].[p_rpt_inventario_producto]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- p_rpt_inventario_producto 1,'20210927','20211003'
CREATE proc [dbo].[p_rpt_inventario_producto]
@pSucursalId INT,
@pDel DATETIME,
@pAl DATETIME
as
BEGIN	

	


	DECLARE @TituloReporte varchar(250),
		@Sucursal varchar(250)
	
	SET @TituloReporte = 'INVENTARIO DEL '+CONVERT(VARCHAR,@pDel,103) + ' AL '+CONVERT(VARCHAR,@pAl,103)

	SELECT @Sucursal = NombreSucursal
	FROM cat_sucursales
	where Clave = @pSucursalId

	SELECT imd.* ,i.TipoMovimientoId,tm.EsEntrada,SucursalId = i.SucursalId
	INTO #tmpMovimientosinventario
	FROM doc_inv_movimiento i
	INNER JOIN doc_inv_movimiento_detalle imd on imd.MovimientoId = i.MovimientoId
	INNER JOIN cat_tipos_movimiento_inventario tm on tm.TipoMovimientoInventarioId = i.TipoMovimientoId 
	WHERE CONVERT(VARCHAR,i.FechaMovimiento,112) BETWEEN CONVERT(VARCHAR,@pDel,112) AND CONVERT(VARCHAR,@pAl,112) AND
	i.Activo = 1 AND @pSucursalId IN (0,i.SucursalId) AND i.SucursalId is not null

	

	SELECT p.ProductoId, 
			ExistenciaInicial = MAX(ISNULL(imd.Disponible,0))
	into #tmpExistenciaInicial
	FROM cat_Productos p
	INNER JOIN doc_inv_movimiento_detalle imd on imd.ProductoId = p.ProductoId 
	INNER JOIN doc_inv_movimiento m on m.MovimientoId = imd.MovimientoId AND
								m.MovimientoId = (
													SELECT top 1 sm.MovimientoId
													FROM doc_inv_movimiento sm 
													INNER JOIN doc_inv_movimiento_detalle smd on smd.MovimientoId = sm.MovimientoId 
													WHERE smd.ProductoId = p.ProductoId  AND 
													CONVERT(VARCHAR,sm.FechaMovimiento,112) < CONVERT(VARCHAR,@pDel,112) AND
													sm.Activo = 1 AND
													sm.SucursalId = @pSucursalId
 
													ORDER BY sm.FechaMovimiento  DESC
												)
	INNER JOIN cat_tipos_movimiento_inventario tm on tm.TipoMovimientoInventarioId = m.TipoMovimientoId 
	WHERE m.SucursalId = @pSucursalId
	GROUP BY p.ProductoId


	

	SELECT ProductoId,
		MinMovimientoDetalleId = MIN(i.MovimientoDetalleId),
		MaxMovimientoDetalleId = MAX(i.MovimientoDetalleId)
	INTO #tmpMovimientoMaxMin
	FROM #tmpMovimientosinventario i	 
	group by ProductoId

	

	SELECT 
			
			ProductoId = p.ProductoId,
			TituloReporte = @TituloReporte,
			Sucursal = ISNULL(@Sucursal,'TODAS') ,
			ClaveProducto = p.Clave,
			Producto = p.Descripcion,
			InvInicial = ISNULL(ei.ExistenciaInicial,0),
			Compras =CAST(0 as decimal(14,3)),
			SalidasTraspasos = CAST(0 as  decimal(14,3)),
			InvFinal = CAST(0 as  decimal(14,3))
	INTO #tmpResult
	FROM  cat_productos p 
	LEFT JOIN #tmpMovimientoMaxMin MinM on MinM.ProductoId = p.ProductoId 
	LEFT JOIN #tmpMovimientosinventario II ON II.MovimientoDetalleId = MinM.MinMovimientoDetalleId	
	LEFT JOIN #tmpExistenciaInicial ei on ei.ProductoId = p.ProductoId
	GROUP BY   p.ProductoId,p.Clave, p.Descripcion,II.Disponible,ei.ExistenciaInicial
	ORDER BY p.Descripcion,p.Clave

	update #tmpResult
	set Compras = (SELECT ISNULL(SUM( TMP.Cantidad),0) FROM #tmpMovimientosinventario TMP WHERE TMP.ProductoId = r.ProductoId AND TMP.EsEntrada = 1),
		SalidasTraspasos = (SELECT ISNULL(SUM( TMP.Cantidad),0) FROM #tmpMovimientosinventario TMP WHERE TMP.ProductoId = r.ProductoId AND TMP.EsEntrada = 0)
	from #tmpResult r

	update #tmpResult
	set InvFinal = ISNULL(InvInicial,0) + ISNULL(Compras,0) - ISNULL(SalidasTraspasos,0)
	from #tmpResult r

	

	SELECT Id = CAST(ROW_NUMBER() OVER(ORDER BY Producto ASC) AS INT),*
	FROM #tmpResult
	ORDER BY Producto
	
	



END

GO
/****** Object:  StoredProcedure [dbo].[p_rpt_inventario_valuado]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_inventario_valuado 1,'20210927','20211003'
CREATE proc [dbo].[p_rpt_inventario_valuado]
@pSucursalId INT,
@pDel DATETIME,
@pAl DATETIME
as
BEGIN	

	DECLARE @TituloReporte varchar(250),
	@Sucursal varchar(250)

	
	

	SET @TituloReporte = 'INVENTARIO DEL '+CONVERT(VARCHAR,@pDel,103) + ' AL '+CONVERT(VARCHAR,@pAl,103)

	SELECT @Sucursal = NombreSucursal
	FROM cat_sucursales
	where Clave = @pSucursalId

	SELECT imd.* ,i.TipoMovimientoId,tm.EsEntrada,SucursalId = @pSucursalId
	INTO #tmpMovimientosinventario
	FROM doc_inv_movimiento i
	INNER JOIN doc_inv_movimiento_detalle imd on imd.MovimientoId = i.MovimientoId
	INNER JOIN cat_tipos_movimiento_inventario tm on tm.TipoMovimientoInventarioId = i.TipoMovimientoId 
	WHERE CONVERT(VARCHAR,i.FechaMovimiento,112) BETWEEN CONVERT(VARCHAR,@pDel,112) AND CONVERT(VARCHAR,@pAl,112) AND
	i.Activo = 1 AND @pSucursalId IN (0,i.SucursalId)

	


	
	SELECT p.ProductoId, 
			ExistenciaInicial = MAX(ISNULL(imd.Disponible,0))
	into #tmpExistenciaInicial
	FROM cat_Productos p
	INNER JOIN doc_inv_movimiento_detalle imd on imd.ProductoId = p.ProductoId 
	INNER JOIN doc_inv_movimiento m on m.MovimientoId = imd.MovimientoId AND
								m.MovimientoId = (
													SELECT top 1 sm.MovimientoId
													FROM doc_inv_movimiento sm 
													INNER JOIN doc_inv_movimiento_detalle smd on smd.MovimientoId = sm.MovimientoId 
													WHERE smd.ProductoId = p.ProductoId  AND 
													CONVERT(VARCHAR,sm.FechaMovimiento,112) < CONVERT(VARCHAR,@pDel,112) AND
													sm.Activo = 1 AND
													sm.SucursalId = @pSucursalId 
													ORDER BY sm.FechaMovimiento  DESC
												)
	INNER JOIN cat_tipos_movimiento_inventario tm on tm.TipoMovimientoInventarioId = m.TipoMovimientoId 
	WHERE m.SucursalId = @pSucursalId
	GROUP BY p.ProductoId



	SELECT i.ProductoId,
		MinMovimientoDetalleId = MIN(i.MovimientoDetalleId),
		MaxMovimientoDetalleId = MAX(i.MovimientoDetalleId),
		MaxCostoPromedio = max(pe.CostoUltimaCompra)
	INTO #tmpMovimientoMaxMin
	FROM #tmpMovimientosinventario i	
	INNER JOIN cat_productos_existencias pe on pe.ProductoId = i.ProductoId and pe.SucursalId = 1 --MATRIZ O ALMAC�N GENERAL
	group by I.ProductoId

	SELECT 
			
			TituloReporte = @TituloReporte,
			Sucursal = ISNULL(@Sucursal,'TODAS') ,
			ClaveProducto = p.Clave,
			Producto = p.Descripcion,
			InvInicial = CAST(ISNULL(ei.ExistenciaInicial,0) * ISNULL(MAX(pe.CostoUltimaCompra),0) as decimal(14,3)),
			Compras = CAST(0 as decimal(14,3)),
			SalidasTraspasos = CAST(0 as decimal(14,3)),
			InvFinal = CAST(0 as decimal(14,3)),
			p.ProductoId,
			MaxCostoPromedio = ISNULL(MAX(pe.CostoUltimaCompra),0)
	INTO #tmpResult
	FROM  cat_productos p 
	LEFT JOIN #tmpMovimientosinventario I on p.ProductoId = I.ProductoId	
	LEFT JOIN #tmpMovimientoMaxMin MinM on MinM.ProductoId = P.ProductoId 
	LEFT JOIN #tmpMovimientosinventario II ON II.MovimientoDetalleId = MinM.MinMovimientoDetalleId	
	LEFT JOIN #tmpExistenciaInicial ei on ei.ProductoId = P.ProductoId
	left JOIN cat_productos_existencias pe on pe.ProductoId = p.ProductoId and pe.SucursalId = 1 --MATRIZ O ALMAC�N GENERAL
	GROUP BY  p.Clave, p.Descripcion,II.Disponible,MinM.MaxCostoPromedio,p.ProductoId,ei.ExistenciaInicial

	ORDER BY p.Descripcion,p.Clave

	update #tmpResult
	set Compras = (SELECT ISNULL(SUM( ISNULL(TMP.Cantidad,0) ),0) FROM #tmpMovimientosinventario TMP WHERE TMP.ProductoId = r.ProductoId AND TMP.EsEntrada = 1) * ISNULL(r.MaxCostoPromedio,0),
		SalidasTraspasos = (SELECT ISNULL(SUM( ISNULL(TMP.Cantidad,0) ),0) FROM #tmpMovimientosinventario TMP WHERE TMP.ProductoId = r.ProductoId AND TMP.EsEntrada = 0)* ISNULL(r.MaxCostoPromedio,0)
	from #tmpResult r

	update #tmpResult
	set InvFinal = ISNULL(InvInicial,0) + ISNULL(Compras,0) - ISNULL(SalidasTraspasos,0)
	from #tmpResult r

	SELECT 
			Id = CAST(ROW_NUMBER() OVER(ORDER BY Producto ASC) AS INT),*
	FROM #tmpResult
	ORDER BY Producto



END


GO
/****** Object:  StoredProcedure [dbo].[p_rpt_maiz_maseca_sacos]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_maiz_maseca_sacos 31
CREATE PROC [dbo].[p_rpt_maiz_maseca_sacos]
@pSucursalId INT
AS

	SELECT MM.Id,
			S.NombreSucursal,
			MM.SucursalId,
			MM.Fecha,
			MM.MaizSacos,
			MM.MasecaSacos,
			MM.TortillaMaizRendimiento,
			MM.TortillaMasecaRendimiento,
			MM.TortillaTotalRendimiento,
			MM.CreadoEl,
			MM.CreadoPor,
			MM.ModificadoEl,
			MM.ModificadoPor
	FROM doc_maiz_maseca_rendimiento MM
	INNER JOIN cat_sucursales S ON S.Clave = MM.SucursalId
	WHERE MM.SucursalId = @pSucursalId
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_materia_prima_consumo_venta]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[p_rpt_materia_prima_consumo_venta]
@pSucursalId INT,
@pDel DATETIME='20220801',
@pAl DATETIME='20220815'
AS


	SELECT 
			ID = CAST(ROW_NUMBER() OVER(ORDER BY P.Descripcion ASC)  AS INT),
			Insumo = P.Descripcion,
			ProductoVenta = p2.Descripcion,
			CantidadInsumo = SUM(VD.Cantidad * PB.Cantidad),
			CantidadProductoVenta = SUM(VD.Cantidad)
	FROM cat_productos_base PB
	INNER JOIN doc_ventas_detalle VD ON VD.ProductoId = PB.ProductoId
	INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId AND V.Activo = 1
	INNER JOIN cat_productos P ON P.ProductoId = PB.ProductoBaseId
	INNER JOIN cat_productos P2 ON P2.ProductoId = PB.ProductoId
	WHERE V.SucursalId = @pSucursalId AND
	CONVERT(VARCHAR,V.Fecha,112) BETWEEN CONVERT(VARCHAR,@pDel,112) AND CONVERT(VARCHAR,@pAl,112)
	GROUP BY P.Descripcion,p2.Descripcion
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_movimiento_cancela_inv]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create Proc [dbo].[p_rpt_movimiento_cancela_inv]
@pMovimientoId int,
@pProductoCompraId int
as

	declare @proveedor varchar(200)
	
	
	select @proveedor = prov.Nombre
	from doc_productos_compra pc
	inner join doc_inv_movimiento m on m.ProductoCompraId = pc.ProductoCompraId
	inner join cat_proveedores prov on  prov.ProveedorId = PC.ProveedorId
	where m.MovimientoId = @pMovimientoId OR m.ProductoCompraId = @pProductoCompraId
	

	select SucursalOrigen = suc.NombreSucursal,
		SucursalDestino = sucDes.NombreSucursal,
		TipoMovimiento = TM.Descripcion,
		Folio = m.FolioMovimiento,
		FechaMovimiento = m.FechaCancelacion,
		FechaAfectaInv = m.FechaAutoriza,
		ProductoClave = PROD.Clave,
		Producto = cast(prod.Descripcion as varchar(26)),
		CantidadMov = md.Cantidad,
		PrecioUnitario = md.PrecioUnitario,
		RegistradoPor = usu.NombreUsuario,
		AutorizadoPor = usu2.NombreUsuario	,
		Proveedor = 	isnull(@proveedor,''),
		Remision = pc.NumeroRemision
	from doc_inv_movimiento m
	inner join doc_inv_movimiento_detalle md on md.MovimientoId = m.MovimientoId
	inner join cat_productos prod on prod.ProductoId = md.ProductoId
	inner join cat_sucursales suc on suc.Clave = isnull(m.SucursalOrigenId,m.SucursalId)
	inner join cat_tipos_movimiento_inventario tm on tm.TipoMovimientoInventarioId = m.TipoMovimientoId
	inner join cat_usuarios usu on usu.IdUsuario = m.CreadoPor
	inner join cat_usuarios usu2 on usu2.IdUsuario = M.AutorizadoPor
	left join cat_sucursales sucDes on sucDes.Clave = m.SucursalDestinoId
	left join doc_productos_compra pc on pc.ProductoCompraId = m.ProductoCompraId
	
	where (m.MovimientoId = @pMovimientoId OR m.ProductoCompraId = @pProductoCompraId) AND
	m.Cancelado = 1









GO
/****** Object:  StoredProcedure [dbo].[p_rpt_notas_venta_detalle]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_rpt_notas_venta_detalle 1,1,'20180101','20180701'
CREATE PROC [dbo].[p_rpt_notas_venta_detalle]
@pSucursalId int,
@pCajaId int,
@pDel DateTime,
@pAl  DateTime
as

	select 
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		Del = @pDel,
		Al = @pAl,
		Folio = 'NV'+cast(v.VentaId as varchar),
		Fecha = v.Fecha,
		Caja = caja.Descripcion,
		Clave = prod.Clave,
		Producto = prod.DescripcionCorta,
		Precio = vd.PrecioUnitario,
		Cantidad = vd.cantidad,
		Total = case when v.FechaCancelacion is null then  vd.Total + vd.Descuento
					else 0
				End,
		Descuento = case when v.FechaCancelacion is null then vd.Descuento 
					else 0
				End,
		Importe =case when v.FechaCancelacion is null then vd.Total 
					else 0
				End ,
		Cajero = rh.Nombre,
		v.VentaId,
		Estatus = case when v.FechaCancelacion is null then '' 
					else 'C'
				End
	from doc_ventas v
	inner join doc_ventas_detalle vd on vd.VentaId = v.VentaId
	inner join cat_productos prod on prod.ProductoId = vd.ProductoId
	inner join cat_sucursales suc on suc.Clave = v.SucursalId
	inner join cat_cajas caja on caja.Clave = v.CajaId
	inner join cat_empresas emp on emp.Clave = suc.Empresa
	inner join cat_usuarios usu on usu.IdUsuario = v.UsuarioCreacionId
	inner join rh_empleados rh on rh.NumEmpleado = usu.IdEmpleado
	where v.SucursalId = @pSucursalId and
	@pCajaId  in (0,v.CajaId) and
	CONVERT(VARCHAR,v.Fecha,112)  between CONVERT(VARCHAR,@pDel,112) and CONVERT(VARCHAR,@pAl,112) --and
	--v.FechaCancelacion is null
	order by v.VentaId


GO
/****** Object:  StoredProcedure [dbo].[p_rpt_notas_venta_resumido]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_notas_venta_resumido 1,1,'20180101','20180801'
CREATE proc [dbo].[p_rpt_notas_venta_resumido]
@pSucursalId int,
@pCajaId int,
@pMesaId int,
@pDel DateTime,
@pAl  DateTime
as

	select 
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		Del = @pDel,
		Al = @pAl,
		Folio = 'NV'+cast(v.VentaId as varchar),
		Fecha = cast(v.Fecha as date),
		Caja = caja.Descripcion,
		Mesa = [dbo].[fnGetComandaMesas](po.PedidoId),
		Total = case when v.FechaCancelacion is null then v.TotalVenta + v.TotalDescuento else 0 end,
		Descuento =case when v.FechaCancelacion is null then v.TotalDescuento else 0 end,
		Importe = case when v.FechaCancelacion is null then v.TotalVenta else 0 end,
		Cajero = rh.Nombre,
		Estatus = case when v.FechaCancelacion is not null then 'C' else '' END
	from doc_ventas v
	inner join cat_sucursales suc on suc.Clave = v.SucursalId
	inner join cat_cajas caja on caja.Clave = v.CajaId
	inner join cat_empresas emp on emp.Clave = suc.Empresa
	inner join cat_usuarios usu on usu.IdUsuario = v.UsuarioCreacionId
	inner join rh_empleados rh on rh.NumEmpleado = usu.IdEmpleado
	left join doc_pedidos_orden po on po.VentaId = v.VentaId 
	left join doc_pedidos_orden_mesa pom on pom.PedidoOrdenId = po.PedidoId 
									
	
	where v.SucursalId = @pSucursalId and
	@pCajaId  in (0,v.CajaId) and
	CONVERT(VARCHAR,v.Fecha,112)  between CONVERT(VARCHAR,@pDel,112) and CONVERT(VARCHAR,@pAl,112) --and
	and (
										(@pMesaId  > 0 and pom.MesaId = @pMesaId)
										OR
										@pMesaId = 0
									)
	group by emp.NombreComercial,
		 suc.NombreSucursal,
		
		cast(v.VentaId as varchar),
		 cast(v.Fecha as date),
		 caja.Descripcion,
		 [dbo].[fnGetComandaMesas](po.PedidoId),
		 case when v.FechaCancelacion is null then v.TotalVenta + v.TotalDescuento else 0 end,
		case when v.FechaCancelacion is null then v.TotalDescuento else 0 end,
		case when v.FechaCancelacion is null then v.TotalVenta else 0 end,
		 rh.Nombre,
		 case when v.FechaCancelacion is not null then 'C' else '' END,
		 v.VentaId
	order by v.VentaId





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_pedido_orden_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- p_rpt_pedido_orden_sel 1858
CREATE PROC [dbo].[p_rpt_pedido_orden_sel]
@pPedidoId INT
AS

	SELECT PO.PedidoId,
		Folio = 'P'+PO.Folio,
		Cliente = C.Nombre,
		Direccion = ISNULL(C.Calle,'') +' '+ isnull(C.NumeroExt,'') +' '+ 
				ISNULL(C.NumeroInt,'') +' '+ ISNULL(C.Colonia,'') + ISNULL(C.Telefono,'') + '' + ISNULL(C.Telefono2,'') + ' '+
				ISNULL(CONVERT(VARCHAR,POP.FechaProgramada,103),'') + ' '+ ISNULL(CAST(POP.HoraProgramada AS VARCHAR(5)),''),
		FechaPedido = PO.FechaApertura,		
		ClaveProducto = P.Clave,
		Producto = P.DescripcionCorta,
		Cantidad = POD.Cantidad,
		Precio = POD.PrecioUnitario,
		Total = POD.Total,
		Devolucion = POD.CantidadDevolucion,
		FechaProgramada = POP.FechaProgramada,
		HoraProgramada = POP.HoraProgramada,
		SucursalProduccion = S.NombreSucursal,
		Estado = CASE WHEN ISNULL(PO.Cancelada,0) = 1 THEN 'CANCELADO'
					WHEN PO.VentaId IS Not NULL THEN 'PAGADO'
					WHEN ISNULL(PO.Cancelada,0) = 0 AND PO.VentaId IS NULL THEN 'POR PAGAR' 
				END
	FROM doc_pedidos_orden PO
	INNER JOIN doc_pedidos_orden_detalle POD ON POD.PedidoId = PO.PedidoId
	INNER JOIN cat_clientes C ON C.ClienteId = PO.ClienteId
	INNER JOIN cat_productos P ON P.ProductoId = POD.ProductoId
	LEFT JOIN doc_pedidos_orden_programacion POP ON POP.PedidoId = PO.PedidoId
	LEFT JOIN cat_sucursales S ON S.Clave = PO.SucursalId
	WHERE PO.PedidoId = @pPedidoId

GO
/****** Object:  StoredProcedure [dbo].[p_rpt_pedido_pago_ticket]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_pedido_pago_ticket 1,16
CREATE proc [dbo].[p_rpt_pedido_pago_ticket]
@pPagoId int,
@pPedidoId int
as

	select Folio = po.PedidoId,
			FechaApartado = po.CreadoEl,
			PagoRealizado =P.Monto,
			FechaPago = p.FechaPago,
			TotalApartado = c.Total,
			Saldo = cast(c.Saldo as money),
			Empresa = e.NombreComercial,
			Sucursal = s.NombreSucursal,
			FechaLimite = pro.FechaProgramada,
			ExpedidoEn = RTRIM(s.Calle) + ' '+
						RTRIM(s.NoExt) + ' '+
						RTRIM(s.NoInt) + ' '+
						RTRIM(s.Colonia) + ' '+
						RTRIM(s.Ciudad) + ' '+
						RTRIM(s.Estado),
			po.ClienteId,
			Cliente = cli.Nombre,
			--------
			ClaveProducto = PROD.Clave,
			Producto = prod.Descripcion,
			Cantidad = pProd.Cantidad,
			Importe = pProd.Total,
			TextoCabecera1 = ISNULL(TextoCabecera1,''),
			TextoCabecera2 = ISNULL(TextoCabecera2,''),
			TextoPie = ISNULL(TextoPie,''),
			AnticipoAbono = 'ANTICIPO',
			Serie = isnull(confA.Serie,'P'),
			Atendio = rh.Nombre,
			Politica = isnull(POL.Politica,'')
	from doc_pagos p
	INNER join doc_cargos c on c.CargoId = p.CargoId
	inner join doc_pedidos_orden po on po.PedidoId = @pPedidoId and
								po.CargoId = c.CargoId	
	inner join doc_pedidos_orden_detalle pprod on pprod.PedidoId = po.PedidoId
	inner join cat_sucursales s on s.Clave = po.SucursalId
	inner join cat_empresas e on e.Clave = s.Empresa
	inner join cat_clientes cli on cli.ClienteId = po.ClienteId
	inner join cat_productos prod on prod.ProductoId = pprod.ProductoId
	inner join cat_usuarios usu on usu.IdUsuario = p.CreadoPor
	inner join rh_empleados rh on rh.NumEmpleado = usu.IdEmpleado
	left join doc_pedidos_orden_programacion pro on pro.PedidoId = po.PedidoId
	left join cat_configuracion conf on conf.PedidoPoliticaId = conf.PedidoPoliticaId
	LEFT JOIN cat_configuracion_ticket_apartado confA on confA.SucursalId = po.SucursalId
	LEFT JOIN cat_politicas pol on pol.PoliticaId = conf.PedidoPoliticaId
	where p.PagoId = @pPagoId

GO
/****** Object:  StoredProcedure [dbo].[p_rpt_produccion_molino]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_rpt_produccion_molino]
@pSucursalId INT,
@pDel DATETIME,
@pAl DATETIME
as

	SELECT P.ProduccionId,
		ClaveProductoTerminado = PROD.Clave,
		Formula = PROD.DescripcionCorta,
		Tipo = 'Insumo',
		ProductoDetalle = PRODE.DescripcionCorta,
		Cantidad = SUM(PE.Cantidad),
		Unidad = U.DescripcionCorta,
		CreadoEl = P.CreadoEl,
		Inicio = P.FechaHoraInicio,
		Fin = P.FechaHoraFin
	FROM doc_produccion P
	INNER JOIN doc_produccion_entrada PE ON PE.ProduccionId = P.ProduccionId
	INNER JOIN cat_productos PROD ON PROD.ProductoId = p.ProductoId
	INNER JOIN  cat_productos PRODE ON PRODE.ProductoId = PE.ProductoId
	inner join cat_unidadesmed U ON U.Clave = PE.UnidadId
	GROUP BY  P.ProduccionId,
		PROD.Clave,
		PROD.DescripcionCorta,		
		PRODE.DescripcionCorta,
		U.DescripcionCorta,
		P.CreadoEl,
		P.FechaHoraInicio,
		P.FechaHoraFin
	
	UNION
	
	SELECT P.ProduccionId,
		ClaveProductoTerminado = PROD.Clave,
		Formula = PROD.DescripcionCorta,
		Tipo = 'Producto Terminado',
		ProductoDetalle = PRODE.DescripcionCorta,
		Cantidad = SUM(PE.Cantidad),
		Unidad = U.DescripcionCorta,
		CreadoEl = P.CreadoEl,
		Inicio = P.FechaHoraInicio,
		Fin = P.FechaHoraFin
	FROM doc_produccion P
	INNER JOIN doc_produccion_salida PE ON PE.ProduccionId = P.ProduccionId
	INNER JOIN cat_productos PROD ON PROD.ProductoId = p.ProductoId
	INNER JOIN  cat_productos PRODE ON PRODE.ProductoId = PE.ProductoId
	inner join cat_unidadesmed U ON U.Clave = PE.UnidadId
	
	GROUP BY  P.ProduccionId,
		PROD.Clave,
		PROD.DescripcionCorta,		
		PRODE.DescripcionCorta,
		U.DescripcionCorta,
		P.CreadoEl,
		P.FechaHoraInicio,
		P.FechaHoraFin
	



GO
/****** Object:  StoredProcedure [dbo].[p_rpt_produccion_rendimiento]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- p_rpt_produccion_rendimiento 1,'20220301','20220428'
CREATE PROC [dbo].[p_rpt_produccion_rendimiento]
@pSucursalId INT,
@pDel DATETIME,
@pAl DATETIME
AS

	DECLARE @IndicadorProduccionEstimada DECIMAL(10,2),
			@IndicadorGlobalProduccionEstimada DECIMAL(10,2)

	--venta tortilla
	SELECT Cantidad = SUM(VD.Cantidad)
	into #tmpVentaTortilla
	FROM doc_ventas V
	INNER JOIN doc_ventas_detalle VD ON VD.VentaId = V.VentaId
	INNER JOIN cat_productos p on p.ProductoId = VD.ProductoId AND
									UPPER(p.Descripcion) = 'TORTILLA'
	WHERE V.Activo = 1 AND
	v.FechaCancelacion IS NULL AND
	@pSucursalId IN (0,V.SucursalId) AND
	CONVERT(VARCHAR,V.Fecha,112) BETWEEN CONVERT(VARCHAR,@pDel,112) and CONVERT(VARCHAR,@pAl,112)
	


	--PRODUCTOS PRODUCCI�N
	SELECT 
		  
		   ProductoTerminadoId=P.ProductoId,
		   ProductoTerminado = isnull(P.DescripcionCorta,P.Descripcion),
		   ProductoMateriaPrimaId = MP.ProductoId,
		   ProductoMateriaPrima = MP.DescripcionCorta,
		   Unidad = UNID.DescripcionCorta,
		   CantidadRealInsumo = ISNULL(SUM(PE.Cantidad),0),		  
		   CantidadEstimadaInsumo = ISNULL(max(PB.Cantidad),0) * ISNULL(SUM(PS.Cantidad),0),		   
		   CantidadRealProductoTerminado = ISNULL(SUM(PS.Cantidad),0),
		   CantidadEstimadaProductoTerminado = CAST(0 AS DECIMAL(14,2)),
		   IndicadorRendimiento = CAST(0 AS DECIMAL(14,2)),
		   IndicadorGlobalRendimiento = CAST(0 AS DECIMAL(14,2)),
		   IndicadorProduccionEstimada = CAST(0 AS DECIMAL(14,2)),
		   IndicadorGlobalProduccionEstimada = CAST(0 AS DECIMAL(14,2))
	INTO #tmpResult
	FROM doc_produccion prod	
	INNER JOIN cat_productos P ON P.ProductoId = prod.ProductoId
	INNER JOIN cat_productos_base PB ON PB.ProductoId = P.ProductoId 
	INNER JOIN cat_productos MP ON MP.ProductoId = PB.ProductoBaseId
	INNER JOIN cat_unidadesmed UNID ON UNID.Clave = PB.UnidadCocinaId
	LEFT JOIN doc_produccion_entrada PE ON PE.ProduccionId = prod.ProduccionId AND 
											PE.ProductoId = MP.ProductoId
	LEFT JOIN doc_produccion_salida PS ON PS.ProduccionId = prod.ProduccionId AND
										PS.ProductoId = P.ProductoId
	WHERE prod.Completado = 1 AND
	@pSucursalId IN (0,prod.SucursalId) AND
	CONVERT(VARCHAR,prod.FechaHoraFin,112) BETWEEN CONVERT(VARCHAR,@pDel,112) and CONVERT(VARCHAR,@pAl,112)
	GROUP BY P.ProductoId,
	P.DescripcionCorta,
	P.Descripcion,
	MP.ProductoId,
	MP.DescripcionCorta,
	UNID.DescripcionCorta

	--UNION
	
	----TORTILLA
	--SELECT 
	--	   ProductoTerminadoId=P.ProductoId,
	--	   ProductoTerminado = isnull(P.DescripcionCorta,P.Descripcion),
	--	   ProductoMateriaPrimaId = MP.ProductoId,
	--	   ProductoMateriaPrima = MP.DescripcionCorta,
	--	   Unidad = UNID.DescripcionCorta,
	--	   CantidadRealInsumo = isnull(SUM(IMD.Cantidad),0),		  
	--	   CantidadEstimadaInsumo = isnull(max(PB.Cantidad),0) *MAX(Vt.Cantidad),
	--	   CantidadRealProductoTerminado = MAX(vt.Cantidad),
	--	   CantidadEstimadaProductoTerminado = CAST(0 AS DECIMAL(14,2)),
	--	   IndicadorRendimiento = CAST(0 AS DECIMAL(14,2)),
	--	   IndicadorGlobalRendimiento = CAST(0 AS DECIMAL(14,2)),
	--	   IndicadorProduccionEstimada = CAST(0 AS DECIMAL(14,2)),
	--	   IndicadorGlobalProduccionEstimada = CAST(0 AS DECIMAL(14,2))
	--FROM cat_productos P
	--INNER JOIN cat_productos_base PB ON PB.ProductoId = P.ProductoId 
	--INNER JOIN cat_productos MP ON MP.ProductoId = PB.ProductoBaseId
	--INNER JOIN cat_unidadesmed UNID ON UNID.Clave = PB.UnidadCocinaId
	--INNER JOIN doc_inv_movimiento IM ON IM.Activo = 1 AND
	--								IM.TipoMovimientoId = 22-- Producto Terminado
	--INNER JOIN doc_inv_movimiento_detalle IMD on IMD.MovimientoId = IM.MovimientoId AND
	--								IMD.ProductoId = PB.ProductoBaseId
	--INNER JOIN #tmpVentaTortilla vt on vt.Cantidad = vt.Cantidad
	--where UPPER(P.DescripcionCorta) = 'TORTILLA' AND
	--CONVERT(VARCHAR,IM.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pDel,112) AND CONVERT(VARCHAR,@pAl,112)
	--group by P.ProductoId,
	--P.DescripcionCorta,
	--MP.ProductoId,
	--MP.DescripcionCorta,
	--UNID.DescripcionCorta,
	--P.Descripcion

	UPDATE #tmpResult
	SET IndicadorRendimiento = CASE WHEN CantidadEstimadaInsumo > 0
									THEN 
										(
											(
													(CantidadRealInsumo * 100) / CantidadEstimadaInsumo
											)-100
										)/100
									ELSE 0
								END

	

	UPDATE #tmpResult
	SET IndicadorGlobalRendimiento = (SELECT SUM(IndicadorRendimiento)/COUNT(*) from #tmpResult)

	--CANTIDAD ESTIMADA PRODUCTO TERMINADO
	--Update #tmpResult
	SELECT CantidadEstimadaProductoTerminado = max(CantidadRealInsumo) / MAX(PB.Cantidad),T.ProductoTerminadoId
	INTO #TMPCantidadEstimada
	FROM #tmpResult T
	INNER JOIN cat_productos_base PB ON PB.ProductoId = T.ProductoTerminadoId AND
								PB.ProductoMateriaPrimaId = (SELECT MIN(ProductoMateriaPrimaId) FROM cat_productos_base S1 WHERE S1.ProductoId = PB.ProductoId)
	WHERE T.ProductoMateriaPrimaId = PB.ProductoBaseId
	GROUP BY T.ProductoTerminadoId

	UPDATE #tmpResult
	SET CantidadEstimadaProductoTerminado = T2.CantidadEstimadaProductoTerminado
	FROM #tmpResult T1
	INNER JOIN #TMPCantidadEstimada T2 ON T2.ProductoTerminadoId = T1.ProductoTerminadoId

	
	SELECT ProductoTerminadoId , 
			IndicadorProduccionEstimada =
										CASE WHEN  MAX(CantidadRealInsumo) > 0 THEN
											(
												(
													(MAX(CantidadEstimadaInsumo)*100) / MAX(CantidadRealInsumo)
												)-100
										  )/100
										  ELSE 0
										END
	INTO #TMPIndicadorProduccionEstimada
	FROM #tmpResult TMP
	GROUP BY ProductoTerminadoId

	UPDATE #tmpResult
	SET IndicadorProduccionEstimada = TMPI.IndicadorProduccionEstimada + 1
	FROM #tmpResult TMP
	INNER JOIN #TMPIndicadorProduccionEstimada TMPI ON TMPI.ProductoTerminadoId = TMP.ProductoTerminadoId

	SELECT @IndicadorGlobalProduccionEstimada  = SUM(IndicadorProduccionEstimada)/COUNT(*)
	FROM #tmpResult TMP
	

	UPDATE #tmpResult
	SET IndicadorGlobalProduccionEstimada = @IndicadorGlobalProduccionEstimada

	SELECT distinct * FROM #tmpResult

GO
/****** Object:  StoredProcedure [dbo].[p_rpt_productos_existencias]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[p_rpt_productos_existencias]
@pSucursalId int,
@pClaveLinea int,
@pClaveFamilia int,
@pClaveSubfamilia int,
@pSoloConExistencia bit,
@pFechaHasta DateTime=null,
@pClaveIni	varchar(100)=null,
@pClaveFin varchar(100)=null
as

	CREATE TABLE #tmpExistencias
	(
		Clave		varchar(100),
		ProductoId int,
		SucursalId int,
		ExistenciaTeorica Decimal(14,2)
	)

	IF(@pFechaHasta IS NULL)
	BEGIN

		INSERT INTO #tmpExistencias(Clave,ProductoId,SucursalId,ExistenciaTeorica)
		SELECT p.Clave, pe.ProductoId,pe.SucursalId,pe.ExistenciaTeorica
		FROM cat_productos_existencias pe
		INNER JOIN cat_productos p on p.ProductoId = pe.ProductoId
		WHERE pe.SucursalId = @pSucursalId
	END
	ELSE
	BEGIN
		INSERT INTO #tmpExistencias(Clave,ProductoId,SucursalId,ExistenciaTeorica)
		SELECT p.Clave, MD.ProductoId,M.SucursalId,MD.Disponible
		FROM doc_inv_movimiento M
		INNER JOIN doc_inv_movimiento_detalle MD on MD.MovimientoId = M.MovimientoId
		INNER JOIN cat_productos p on p.ProductoId = MD.ProductoId
		where M.SucursalId = @pSucursalId AND
		MD.MovimientoDetalleId = (
									SELECT MAX(MD2.MovimientoDetalleId) 
									FROM doc_inv_movimiento_detalle MD2 
									INNER JOIN doc_inv_movimiento M2 ON M2.MovimientoId = MD2.MovimientoId
									WHERE M2.SucursalId = M.SucursalId AND
									MD2.ProductoId = MD.ProductoId AND M2.Activo = 1 
									AND CONVERT(VARCHAR,M2.FechaMovimiento,112) <= CONVERT(VARCHAR,@pFechaHasta,112)
								)
		
	END

	SET @pFechaHasta = CASE WHEN @pFechaHasta IS NULL THEN GETDATE() ELSE @pFechaHasta END
	
	select 
			p.ClaveLinea,
			ClaveFamilia=cast(cast(p.claveLinea as varchar) + cast(p.ClaveFamilia as varchar) as int),
			ClaveSubFamilia=cast(cast(p.claveLinea as varchar) + cast(p.ClaveFamilia as varchar) + cast(p.ClaveSubFamilia as varchar) as int),
			Linea = l.Descripcion,
			Familia = f.Descripcion,
			Subfamilia = sf.Descripcion,
			p.Clave,
			Descripcion = p.Clave+'-'+p.Descripcion,
			p.DescripcionCorta,
			pe.ExistenciaTeorica,
			Sucursal = suc.NombreSucursal,
			PrecioVenta = pp.Precio,
			FechaHasta = @pFechaHasta
	from #tmpExistencias pe
	inner join cat_productos p on p.ProductoId = pe.ProductoId and p.Inventariable = 1 AND
									p.ProductoId > 0
	inner join cat_productos_precios pp on pp.IdProducto = p.ProductoId and pp.IdPrecio = 1
	inner join cat_lineas l on l.Clave = p.ClaveLinea
	inner join cat_familias f on f.Clave = p.ClaveFamilia
	inner join cat_subfamilias sf on sf.Clave = p.ClaveSubFamilia
	INNER JOIN cat_sucursales suc on suc.Clave = pe.SucursalId
	where pe.SucursalId = @pSucursalId and
	(
		(isnull(pe.ExistenciaTeorica,0) <> 0 AND @pSoloConExistencia = 1) 
		or
		@pSoloConExistencia = 0
	)and @pClaveLinea in(0,p.ClaveLinea) and
	@pClaveFamilia in(0,p.ClaveFamilia) and
	@pClaveSubfamilia in(0,p.ClaveSubFamilia) AND
	(
		(p.Clave BETWEEN @pClaveIni AND @pClaveFin AND ISNULL(@pClaveIni,'') <> '' AND ISNULL(@pClaveFin,'') <> '') OR
		(ISNULL(@pClaveIni,'') = '' AND ISNULL(@pClaveFin,'') = '')
	)
	
	ORDER BY p.ClaveLinea,P.ClaveFamilia,P.ClaveSubFamilia, p.Descripcion
	







GO
/****** Object:  StoredProcedure [dbo].[p_rpt_productos_existencias_valuo]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- [p_rpt_productos_existencias_valuo] 1,0,0,0,0,60
CREATE proc [dbo].[p_rpt_productos_existencias_valuo]
@pSucursalId int,
@pClaveLinea int,
@pClaveFamilia int,
@pClaveSubfamilia int,
@pSoloConExistencia bit,
@pDescuento decimal(10,2)
as

	select 
			p.ClaveLinea,
			ClaveFamilia=cast(cast(p.claveLinea as varchar) + cast(p.ClaveFamilia as varchar) as int),
			ClaveSubFamilia=cast(cast(p.claveLinea as varchar) + cast(p.ClaveFamilia as varchar) + cast(p.ClaveSubFamilia as varchar) as int),
			Linea = l.Descripcion,
			Familia = f.Descripcion,
			Subfamilia = sf.Descripcion,
			p.Clave,
			Descripcion = p.Clave+'-'+p.Descripcion,
			ExistenciaTeorica = pe.Disponible,
			Sucursal = suc.NombreSucursal,
			PrecioVenta = isnull(pe.CostoUltimaCompra,0),
			ExistenciaValuada = isnull(pe.CostoUltimaCompra,0) * isnull(pe.Disponible,0),
			Descuento = @pDescuento,
			PrecioConDescuento =  isnull(pe.CostoPromedio,0),
			ExistenciaDescValuada = isnull(pe.CostoPromedio,0)* isnull(pe.Disponible,0)
	from cat_productos_existencias pe
	inner join cat_productos p on p.ProductoId = pe.ProductoId
	inner join cat_productos_precios pp on pp.IdProducto = p.ProductoId and pp.IdPrecio = 1
											
	inner join cat_lineas l on l.Clave = p.ClaveLinea
	inner join cat_familias f on f.Clave = p.ClaveFamilia
	inner join cat_subfamilias sf on sf.Clave = p.ClaveSubFamilia
	INNER JOIN cat_sucursales suc on suc.Clave = pe.SucursalId
	where pe.SucursalId = @pSucursalId and
	(
		(isnull(pe.ExistenciaTeorica,0) <> 0 AND @pSoloConExistencia = 1) 
		or
		@pSoloConExistencia = 0
	)and @pClaveLinea in(0,p.ClaveLinea) and
	@pClaveFamilia in(0,p.ClaveFamilia) and
	@pClaveSubfamilia in(0,p.ClaveSubFamilia)
	
	ORDER BY p.ClaveLinea,P.ClaveFamilia,P.ClaveSubFamilia, p.Descripcion
	







GO
/****** Object:  StoredProcedure [dbo].[p_rpt_productos_importacion]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec p_rpt_productos_importacion '41129728-6e9b-4040-a092-a6da356794b6' 
create proc [dbo].[p_rpt_productos_importacion]
@pUUID uniqueidentifier
as

	select UUID,
		p.Clave,
		p.Descripcion,
		b.Cantidad,
		Movimiento = mov.Descripcion,
		Fecha = convert(varchar,b.CreadoEl,103)
	from doc_productos_importacion_bitacora  b
	inner join cat_tipos_movimiento_inventario mov on mov.TipoMovimientoInventarioId = b.TipoMovimientoInventarioId
	inner join cat_productos p on p.ProductoId = b.productoId
	where UUID  = @pUUID
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_productos_vendidos]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_productos_vendidos 1,0,0,'20180601','20180730'
create proc [dbo].[p_rpt_productos_vendidos]
@pSucursalId int,
@pCajaId int,
@pCajeroId int,
@pDel DateTime,
@pAl DateTime
as


	select 
		Del = @pDel,
		Al = @pAl,
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		Linea = l.Descripcion,
		Familia = f.Descripcion,
		Subfamilia = sf.Descripcion,
		p.ProductoId,
		p.Clave,
		Producto = p.Descripcion,
		Cantidad = SUM(vd.Cantidad)
	into #tmpResult
	from doc_ventas v
	inner join doc_ventas_detalle vd on vd.VentaId = v.VentaId
	inner join cat_cajas c on c.clave = v.cajaId
	inner join cat_productos p on p.ProductoId = vd.ProductoId
	inner join cat_lineas l on l.clave = p.ClaveLinea
	inner join cat_familias f on f.clave = p.ClaveFamilia
	inner join cat_subfamilias sf on sf.Clave = p.ClaveSubFamilia
	inner join cat_sucursales suc on suc.clave = v.SucursalId
	inner join cat_empresas emp on emp.clave = suc.empresa
	where @pCajaId in (0,v.cajaId) and
	@pCajeroId in (0,v.UsuarioCreacionId) and
	c.Sucursal = @pSucursalId and
	convert(varchar,v.Fecha,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	v.FechaCancelacion is null
	group by  l.Descripcion,
		f.Descripcion,
		sf.Descripcion,
		p.Descripcion,
		p.ProductoId,
		p.Clave,
		suc.NombreSucursal,
		emp.NombreComercial
	--order by SUM(vd.Cantidad) desc

	insert into #tmpResult
	select 
		Del = @pDel,
		Al = @pAl,
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		Linea = l.Descripcion,
		Familia = f.Descripcion,
		Subfamilia = sf.Descripcion,
		p.ProductoId,
		p.Clave,
		Producto = p.Descripcion,
		Cantidad = SUM(vd.Cantidad)
	from doc_apartados v
	inner join doc_apartados_productos vd on vd.ApartadoId = v.ApartadoId
	inner join cat_cajas c on c.clave = v.cajaId
	inner join cat_productos p on p.ProductoId = vd.ProductoId
	inner join cat_lineas l on l.clave = p.ClaveLinea
	inner join cat_familias f on f.clave = p.ClaveFamilia
	inner join cat_subfamilias sf on sf.Clave = p.ClaveSubFamilia
	inner join cat_sucursales suc on suc.clave = v.SucursalId
	inner join cat_empresas emp on emp.clave = suc.empresa
	where @pCajaId in (0,v.cajaId) and
	@pCajeroId in (0,v.CreadoPor) and
	c.Sucursal = @pSucursalId and
	v.activo = 1 and
	v.saldo = 0 and
	convert(varchar,v.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) 
	
	group by  l.Descripcion,
		f.Descripcion,
		sf.Descripcion,
		p.Descripcion,
		p.ProductoId,
		p.Clave,
		suc.NombreSucursal,
		emp.NombreComercial
	order by SUM(vd.Cantidad) desc


	select Del,
		Al,
		Empresa ,
		Sucursal,
		Linea ,
		Familia ,
		Subfamilia ,
		ProductoId,
		Clave,
		Producto ,
		Cantidad = sum(Cantidad)
	from #tmpResult
	group by 
	Del,
		Al,
		Empresa ,
		Sucursal,
		Linea ,
		Familia ,
		Subfamilia ,
		ProductoId,
		Clave,
		Producto
	order by sum(Cantidad) desc


	
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_retiro_ticket]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_retiro_ticket 1
Create Proc [dbo].[p_rpt_retiro_ticket]
@pRetiroId int
as

	SELECT r.RetiroId,
		r.FEchaRetiro,
		r.MontoRetiro,
		Usuario = e.Nombre,
		em.RFC,
		Direccion =  ISNULL(suc.Calle,'') + ' '+
						ISNULL(suc.NoExt ,'') + ' ' +
						ISNULL(suc.NoInt,'') +' '+
						ISNULL(suc.Colonia, '') + ' '+
						ISNULL(suc.Ciudad,'') +','+
						ISNULL(suc.Estado,'') +','+
						ISNULL(suc.Pais,''),
		suc.NombreSucursal,
		FECHA = CONVERT(VARCHAR,r.FEchaRetiro,103),
		HORA = CONVERT(VARCHAR,r.FEchaRetiro,108),
		r.Observaciones

	FROM DOC_RETIROS r
	inner join cat_usuarios u on u.IdUsuario = r.CreadoPor
	inner join rh_empleados e on e.NumEmpleado = u.IdEmpleado
	inner join cat_empresas em on em.clave = 1
	inner join cat_sucursales suc on suc.Clave = r.SucursalId
	where r.retiroId=@pRetiroId





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_salidas_analitico]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- p_rpt_salidas_analitico 4,'20230601','20230623'
CREATE proc [dbo].[p_rpt_salidas_analitico]
@pSucursalId INT,
@pDel DATETIME,
@pAl DATETIME
as
BEGIN	

	DECLARE @TituloReporte varchar(250)

	

	SET @TituloReporte = 'SALIDAS DE INVENTARIO DEL DIA '+CONVERT(VARCHAR,@pDel,103) + ' AL '+CONVERT(VARCHAR,@pAl,103)

	SELECT imd.* ,i.TipoMovimientoId,tm.EsEntrada,SucursalId = i.SucursalId,i.FechaMovimiento,SucursalDestinoId = i.SucursalDestinoId
	INTO #tmpMovimientosinventario
	FROM doc_inv_movimiento i
	INNER JOIN doc_inv_movimiento_detalle imd on imd.MovimientoId = i.MovimientoId
	INNER JOIN cat_tipos_movimiento_inventario tm on tm.TipoMovimientoInventarioId = i.TipoMovimientoId 
	WHERE CONVERT(VARCHAR,i.FechaMovimiento,112) BETWEEN CONVERT(VARCHAR,@pDel,112) AND CONVERT(VARCHAR,@pAl,112) AND
	i.Activo = 1 AND @pSucursalId IN (0,i.SucursalId) AND
	tm.EsEntrada = 0

	
	SELECT ProductoId,
		MinMovimientoDetalleId = MIN(i.MovimientoDetalleId),
		MaxMovimientoDetalleId = MAX(i.MovimientoDetalleId),
		MaxCostoPromedio = MAX(i.CostoPromedio)
	INTO #tmpMovimientoMaxMin
	FROM #tmpMovimientosinventario i	 
	group by ProductoId


	

	SELECT 
			Id = CAST(ROW_NUMBER() OVER(ORDER BY S.NombreSucursal ASC) AS INT),
			TituloReporte = @TituloReporte,
			SucursalOrigen = ISNULL(S.NombreSucursal,'TODAS') ,
			SucursalDestino = ISNULL(SD.NombreSucursal,''),
			ClaveProducto = p.Clave,
			Producto = p.Descripcion,
			FechaMovimiento = cast( CONVERT(Varchar,I.FechaMovimiento,112) as date),
			Cantidad = SUM(I.Cantidad)
	FROM #tmpMovimientosinventario I
	INNER JOIN cat_productos p on p.ProductoId = I.ProductoId
	INNER JOIN #tmpMovimientoMaxMin MinM on MinM.ProductoId = I.ProductoId 
	
	INNER JOIN cat_sucursales S ON I.SucursalId = S.Clave
	LEFT JOIN cat_sucursales SD ON I.SucursalDestinoId = SD.Clave
	GROUP BY  p.Clave, p.Descripcion,S.NombreSucursal,SD.NombreSucursal,CONVERT(varchar,I.FechaMovimiento,112)
	ORDER BY S.NombreSucursal,SD.NombreSucursal,p.Descripcion,CONVERT(varchar,I.FechaMovimiento,112)



END

GO
/****** Object:  StoredProcedure [dbo].[p_rpt_salidas_sintetico]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_salidas_sintetico 0,'20210901','20211001'
CREATE proc [dbo].[p_rpt_salidas_sintetico]
@pSucursalId INT,
@pDel DATETIME,
@pAl DATETIME
as
BEGIN	

	DECLARE @TituloReporte varchar(250)

	SET @TituloReporte = 'SALIDAS DE INVENTARIO DEL DIA '+CONVERT(VARCHAR,@pDel,103) + ' AL '+CONVERT(VARCHAR,@pAl,103)

	SELECT imd.* ,i.TipoMovimientoId,tm.EsEntrada,SucursalId = i.SucursalId,i.FechaMovimiento,SucursalDestinoId = i.SucursalDestinoId
	INTO #tmpMovimientosinventario
	FROM doc_inv_movimiento i
	INNER JOIN doc_inv_movimiento_detalle imd on imd.MovimientoId = i.MovimientoId
	INNER JOIN cat_tipos_movimiento_inventario tm on tm.TipoMovimientoInventarioId = i.TipoMovimientoId 
	WHERE CONVERT(VARCHAR,i.FechaMovimiento,112) BETWEEN CONVERT(VARCHAR,@pDel,112) AND CONVERT(VARCHAR,@pAl,112) AND
	i.Activo = 1 AND @pSucursalId IN (0,i.SucursalId) AND
	tm.EsEntrada = 0

	SELECT ProductoId,
		MinMovimientoDetalleId = MIN(i.MovimientoDetalleId),
		MaxMovimientoDetalleId = MAX(i.MovimientoDetalleId),
		MaxCostoPromedio = MAX(i.CostoPromedio)
	INTO #tmpMovimientoMaxMin
	FROM #tmpMovimientosinventario i	 
	group by ProductoId

	SELECT 
			Id = CAST(ROW_NUMBER() OVER(ORDER BY S.NombreSucursal ASC) AS INT),
			TituloReporte = @TituloReporte,
			SucursalOrigen = ISNULL(S.NombreSucursal,'TODAS') ,
			SucursalDestino = ISNULL(SD.NombreSucursal,''),
			ClaveProducto = p.Clave,
			Producto = p.Descripcion,			
			Cantidad = SUM(I.Cantidad)
	FROM #tmpMovimientosinventario I
	INNER JOIN cat_productos p on p.ProductoId = I.ProductoId
	INNER JOIN #tmpMovimientoMaxMin MinM on MinM.ProductoId = I.ProductoId 
	
	INNER JOIN cat_sucursales S ON I.SucursalId = S.Clave
	LEFT JOIN cat_sucursales SD ON I.SucursalDestinoId = SD.Clave
	GROUP BY  p.Clave, p.Descripcion,S.NombreSucursal,SD.NombreSucursal
	ORDER BY S.NombreSucursal,SD.NombreSucursal,p.Descripcion,p.Clave



END
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_sucursal_mov_dia]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_sucursal_mov_dia 0,'20230918','20231028',1
CREATE proc [dbo].[p_rpt_sucursal_mov_dia]
@pSucursalId INT,
@pDel DATETIME,
@pAl DATETIME,
@pUsuarioId INT,
@pTipo INT=1 --1 AGRUPAR POR DIA, 2 AGRUPAR SOLO POR SUCURSAL
AS

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	CREATE TABLE #TMP_RESULT(
		Id INT IDENTITY(1,1),
		Fecha DATETIME,
		SucursalId INT,
		Sucursal VARCHAR(250),
		VentasMostradorTortilla MONEY,
		VentasMostradorMasa	MONEY,
		TotalVentaMostradorTortillaMasa MONEY NULL, --
		VentasRepartoTortilla MONEY,
		VentasRepartoMasa  MONEY,
		TotalRepartoMasaTortilla MONEY NULL,
		TotalGlobalMostradorRepartoTortillaMasa MONEY NULL,
		VentasMostradorOtros MONEY,		
		TotalGlobalVenta MONEY NULL,
		KilosVentaMostradorTortilla DECIMAL(14,3) NULL,--
		KilosVentaMostradorMasa DECIMAL(14,3) NULL,--
		KilosRepartoTortilla DECIMAL(14,3) NULL,--
		KilosRepartoMasa DECIMAL(14,3) NULL,--
		TotalKilosVentaRepartoTortilla DECIMAL(14,3) NULL,
		TotalKilosVentaRepartoMasa DECIMAL(14,3) NULL,
		DevolucionRepartoKilosTortilla DECIMAL(14,3) NULL,
		DevolucionRepartoKilosMasa  DECIMAL(14,3) NULL,
		TotalDevolucionesRepato DECIMAL(14,3) NULL,
		SobranteKilosTortilla DECIMAL(14,3) NULL,	
		SobranteKilosMasa DECIMAL(14,3) NULL,		
		Gastos		MONEY,
		GastosAdmon MONEY NULL,
		Retiros		MONEY,
		RetirosCorte MONEY,
		RetirosTotal MONEY,
		Maiz		DECIMAL(14,3),
		Maseca		DECIMAL(14,3),
		VentaTortillaFria MONEY NULL,
		KilosTortillaFria MONEY NULL,
		MaizEntrada	DECIMAL(14,3) NULL,
		MasecaEntrada DECIMAL(14,3) NULL
	)



	INSERT INTO #TMP_RESULT(Fecha,SucursalId,Sucursal,VentasMostradorTortilla,VentasMostradorMasa,VentasMostradorOtros,
	VentasRepartoTortilla,VentasRepartoMasa,Gastos,Retiros,RetirosCorte,RetirosTotal,Maiz,Maseca)
	SELECT CAST(DATEADD(DAY,number,@pDel) AS DATE), S.Clave,S.NombreSucursal,0,0,0,0,0,
	0,0,0,0,0,0
	FROM master..spt_values D
	INNER JOIN cat_sucursales S ON @pSucursalId IN (0,S.Clave)
	INNER JOIN cat_usuarios_sucursales US ON US.UsuarioId = @pUsuarioId AND
										US.SucursalId = S.Clave
	WHERE D.type = 'P'
	AND DATEADD(DAY,number,@pDel) <= @pAl

	--VENTAS MOSTRADOR
	SELECT V.SucursalId,
		Fecha = CAST(V.Fecha AS date),
		VentasMostradorTortilla = SUM(CASE WHEN VD.ProductoId = 1 THEN VD.Total ELSE 0 END),
		VentasMostradorMasa = SUM(CASE WHEN VD.ProductoId = 2 THEN VD.Total ELSE 0 END),
		VentasMostradorOtros = SUM(CASE WHEN VD.ProductoId NOT IN (1,2) THEN VD.Total ELSE 0 END),
		KilosVentaMostradorTortilla = SUM(CASE WHEN VD.ProductoId = 1 THEN VD.Cantidad ELSE 0 END),--
		KilosVentaMostradorMasa = SUM(CASE WHEN VD.ProductoId = 2 THEN VD.Cantidad ELSE 0 END),
		VentaTortillaFria = SUM(CASE WHEN VD.ProductoId IN(38,39) THEN VD.Total ELSE 0 END), --TORTILLA FRIA
		KilosTortillaFria = SUM(CASE WHEN VD.ProductoId IN(38) THEN VD.Cantidad 
									WHEN VD.ProductoId IN(39) THEN VD.Cantidad /2 --TORTILLA FRIA 1/2
								ELSE 0 END) --TORTILLA FRIA KG
	INTO #TMP_VENTAS_MOSTRADOR
	FROM doc_ventas_detalle VD
	INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId AND 
							CAST(V.Fecha AS date) BETWEEN CAST(@pDel AS date) AND CAST(@pAl AS date)
	WHERE V.Activo = 1  and
	V.ClienteId IS NULL
	GROUP BY V.SucursalId,CAST(V.Fecha AS date)
	ORDER BY V.SucursalId,CAST(V.Fecha AS date)


	--repartos
	SELECT V.SucursalId,
		Fecha = CAST(V.Fecha AS date),
		VentasRepartoTortilla = SUM(CASE WHEN VD.ProductoId = 1 THEN VD.Total ELSE 0 END),
		--VentasMostradorMasa = SUM(CASE WHEN VD.ProductoId = 2 THEN VD.Total ELSE 0 END),
		VentasRepartoMasa = SUM(CASE WHEN VD.ProductoId = 2 THEN VD.Total ELSE 0 END),
		KilosRepartoTortilla = SUM(CASE WHEN VD.ProductoId = 1 THEN VD.Cantidad ELSE 0 END),--
		KilosRepartoMasa= SUM(CASE WHEN VD.ProductoId = 2 THEN VD.Cantidad ELSE 0 END)
	INTO #TMP_VENTAS_REPARTOS
	FROM doc_ventas_detalle VD
	INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId AND
						CAST(V.Fecha AS DATE) BETWEEN CAST(@pDel AS DATE) AND CAST(@pAl AS DATE)
	WHERE V.Activo = 1  and
	V.ClienteId IS NOT NULL AND
	@pSucursalId IN(0,V.SucursalId)
	GROUP BY V.SucursalId,CAST(V.Fecha AS date)
	ORDER BY V.SucursalId,CAST(V.Fecha AS date)

	


	--Gastos
	SELECT 
		Fecha = CAST(G.CreadoEl AS date),
		G.SucursalId,		
		Gastos = SUM(G.Monto)
	INTO #TMP_GASTOS
	FROM doc_gastos G
	WHERE @pSucursalId IN (0, G.SucursalId ) AND
	G.Activo = 1  AND
	G.CajaId IS NOT NULL
	GROUP BY  CAST(G.CreadoEl AS date),G.SucursalId
	ORDER BY G.SucursalId,CAST(G.CreadoEl AS date)


	--Gastos
	SELECT 
		Fecha = CAST(G.CreadoEl AS date),
		G.SucursalId,		
		Gastos = SUM(G.Monto)
	INTO #TMP_GASTOS_ADMON
	FROM doc_gastos G
	WHERE @pSucursalId IN (0, G.SucursalId ) AND
	G.Activo = 1  AND
	G.CajaId IS NULL
	GROUP BY  CAST(G.CreadoEl AS date),G.SucursalId
	ORDER BY G.SucursalId,CAST(G.CreadoEl AS date)

	--Retiros
	SELECT R.SucursalId,
		Fecha = Cast(R.FechaRetiro as date),
		Retiros = SUM(R.MontoRetiro)
	INTO #TMP_RETIROS
	FROM doc_retiros R
	WHERE @pSucursalId IN (0,R.SucursalId) AND
	CAST(R.FechaRetiro AS date) BETWEEN CAST(@pDel AS date) AND CAST(@pAl AS date)
	GROUP BY R.SucursalId, cast(R.FechaRetiro as date)

	--Retiro Final
	SELECT SucursalId = C.Sucursal,
		Fecha = cast(CC.CreadoEl as date), 
		Retiros = SUM(CCD.Total)
	INTO #TMP_RETIROS_CC
	FROM doc_corte_caja_denominaciones CCD
	INNER JOIN doc_corte_caja CC ON CC.CorteCajaId = CCD.CorteCajaId AND 
									CAST(CC.CreadoEl AS date) BETWEEN CAST(@pDel AS date) AND CAST(@pAl AS date)
	INNER JOIN cat_cajas C ON C.Clave = CC.CajaId AND @pSucursalId IN (0,C.Sucursal)
	GROUP BY C.Sucursal, cast(CC.CreadoEl as date)


	--REPARTO DEVOLUCIONES
	SELECT
		SucursalId = PO.SucursalId,
		Fecha = CAST(PO.CreadoEl AS DATE),
		DevolucionTortilla = SUM(CASE WHEN POD.ProductoId = 1 THEN POD.CantidadDevolucion ELSE 0 END),
		DevolucionMasa = SUM(CASE WHEN POD.ProductoId = 2 THEN POD.CantidadDevolucion ELSE 0 END),
		TotalRepartoDevolucion = SUM(POD.CantidadDevolucion * POD.PrecioUnitario)
	INTO #TMP_REPARTOS_DEVS
	FROM doc_pedidos_orden_detalle POD 
	INNER JOIN doc_pedidos_orden PO ON PO.PedidoId = POD.PedidoId
	INNER JOIN doc_ventas V ON V.VentaId = PO.VentaId AND
							@pSucursalId IN (V.SucursalId,0) AND
							CAST(PO.CreadoEl AS DATE) BETWEEN CAST(@pDel AS DATE) AND CAST(@pAl AS DATE) and							
							V.FechaCancelacion IS NULL
	GROUP BY PO.SucursalId,CAST(PO.CreadoEl AS DATE)

	--SOBRANTES TORTILLA
	SELECT PS.SucursalId,
		Fecha = CAST(PS.CreadoEl AS DATE) ,
		KilosSobrante = ISNULL(SUM(PS.CantidadSobrante),0)
	INTO #TMP_SOBRANTE_TORTILLA
	FROM doc_productos_sobrantes_registro PS 
	WHERE PS.ProductoId = 1	
	GROUP BY PS.SucursalId,CAST(PS.CreadoEl AS DATE) 

	--SOBRANTES MASA
	SELECT PS.SucursalId,
		Fecha = CAST(PS.CreadoEl AS DATE) ,
		KilosSobrante = ISNULL(SUM(PS.CantidadSobrante),0)
	INTO #TMP_SOBRANTE_MASA
	FROM doc_productos_sobrantes_registro PS 
	INNER JOIN cat_productos P ON P.ProductoId = PS.ProductoId
	WHERE P.Descripcion LIKE '%MASA%'
	GROUP BY PS.SucursalId,CAST(PS.CreadoEl AS DATE) 


	--ACTUALIZAR TEMPORAL VENTAS MOSTRADOR
	UPDATE #TMP_RESULT
	SET VentasMostradorTortilla = ISNULL(VM.VentasMostradorTortilla,0),
		VentasMostradorMasa = ISNULL(VM.VentasMostradorMasa,0),
		VentasMostradorOtros = ISNULL(VM.VentasMostradorOtros,0),
		KilosVentaMostradorTortilla =  ISNULL(VM.KilosVentaMostradorTortilla,0),
		KilosVentaMostradorMasa = ISNULL(VM.KilosVentaMostradorMasa,0),
		VentaTortillaFria = ISNULL(VM.VentaTortillaFria,0),
		KilosTortillaFria = ISNULL(VM.KilosTortillaFria,0)
	FROM #TMP_RESULT T1
	INNER JOIN #TMP_VENTAS_MOSTRADOR VM ON VM.SucursalId = T1.SucursalId AND
										CAST(VM.Fecha AS date) = CAST(T1.Fecha AS date)

	--ACTUALIZAR TEMPORAL REPARTOS
	UPDATE #TMP_RESULT
	SET VentasRepartoTortilla  = ISNULL(VM.VentasRepartoTortilla,0),
		VentasRepartoMasa = ISNULL(VM.VentasRepartoMasa,0),
		KilosRepartoTortilla = ISNULL(VM.KilosRepartoTortilla,0),
		KilosRepartoMasa =  ISNULL(VM.KilosRepartoMasa,0)
	FROM #TMP_RESULT T1
	INNER JOIN #TMP_VENTAS_REPARTOS VM ON VM.SucursalId = T1.SucursalId AND
										CAST(VM.Fecha AS date) = CAST(T1.Fecha AS date)

	--ACTUALIZAR TEMPORAL DEVS REPARTO
	UPDATE #TMP_RESULT
	SET DevolucionRepartoKilosMasa = ISNULL(D.DevolucionMasa,0),
		DevolucionRepartoKilosTortilla = ISNULL(D.DevolucionTortilla,0),
		TotalDevolucionesRepato = ISNULL(TotalRepartoDevolucion,0)
	FROM #TMP_RESULT T1
	LEFT JOIN #TMP_REPARTOS_DEVS D ON D.SucursalId = T1.SucursalId AND
									D.Fecha = T1.Fecha	

	--ACTUALIZAR TEMPORAL SOBRANTE TORTILLA
	UPDATE #TMP_RESULT
	SET SobranteKilosTortilla = ISNULL(S.KilosSobrante,0)
	FROM #TMP_RESULT T
	LEFT JOIN #TMP_SOBRANTE_TORTILLA S ON S.SucursalId = T.SucursalId AND
											S.Fecha = T.Fecha

	--ACTUALIZAR TEMPORAL SOBRANTE MASA
	UPDATE #TMP_RESULT
	SET SobranteKilosMasa = ISNULL(S.KilosSobrante,0)
	FROM #TMP_RESULT T
	LEFT JOIN #TMP_SOBRANTE_MASA S ON S.SucursalId = T.SucursalId AND
											S.Fecha = T.Fecha


	--ACTUALIZAR GASTOS
	UPDATE #TMP_RESULT
	SET Gastos = G.Gastos
	FROM #TMP_RESULT T1
	INNER JOIN #TMP_GASTOS G ON G.SucursalId = T1.SucursalId AND
										CAST(G.Fecha AS date) = CAST(T1.Fecha AS date)

	--ACTUALIZAR GASTOS
	UPDATE #TMP_RESULT
	SET GastosAdmon = ISNULL(G.Gastos,0) 
	FROM #TMP_RESULT T1
	INNER JOIN #TMP_GASTOS_ADMON G ON G.SucursalId = T1.SucursalId AND
										CAST(G.Fecha AS date) = CAST(T1.Fecha AS date)

	--ACTUALIZAR RETIROS
	UPDATE #TMP_RESULT
	SET Retiros =R.Retiros
	FROM #TMP_RESULT T1
	INNER JOIN #TMP_RETIROS R ON R.SucursalId = T1.SucursalId AND
										CAST(R.Fecha AS date) = CAST(T1.Fecha AS date)

	--ACTUALIZAR RETIROS CORTE
	UPDATE #TMP_RESULT
	SET RetirosCorte = R.Retiros
	FROM #TMP_RESULT T1
	INNER JOIN #TMP_RETIROS_CC R ON R.SucursalId = T1.SucursalId AND
										CAST(R.Fecha AS date) = CAST(T1.Fecha AS date)

	--ACTUALIZAR RETIROS TOTAL
	UPDATE #TMP_RESULT
	SET RetirosTotal = Retiros + RetirosCorte

	--ACTUALZIAR CONSUMO MAIZ  MASECA
	
	UPDATE #TMP_RESULT
	SET Maiz = M.MaizSacos,
		Maseca = m.MasecaSacos
	FROM #TMP_RESULT T1
	INNER JOIN doc_maiz_maseca_rendimiento M ON M.SucursalId = T1.SucursalId AND
											CAST(M.CreadoEl AS DATE) = cast(T1.Fecha as date)

	--ACTUALIZAR ENTRADA MAIZ MASECA
	UPDATE #TMP_RESULT
	SET MaizEntrada = (SELECT ISNULL(SUM(s1.MaizSacos),0) FROM doc_maiz_maseca_entrada S1 WHERE S1.SucursalId = T1.SucursalId AND CAST(T1.Fecha AS DATE) = CAST(S1.Fecha AS DATE) AND S1.Activo = 1),
		MasecaEntrada =  (SELECT ISNULL(SUM(s1.MasecaSacos),0) FROM doc_maiz_maseca_entrada S1 WHERE S1.SucursalId = T1.SucursalId AND CAST(T1.Fecha AS DATE) = CAST(S1.Fecha AS DATE) AND S1.Activo = 1)
	FROM #TMP_RESULT T1 

	UPDATE #TMP_RESULT
	SET TotalVentaMostradorTortillaMasa = ISNULL(VentasMostradorTortilla,0) + ISNULL(VentasMostradorMasa,0),
		TotalRepartoMasaTortilla = ISNULL(VentasRepartoTortilla,0) + ISNULL(VentasRepartoMasa,0),
		TotalGlobalMostradorRepartoTortillaMasa = ISNULL(VentasMostradorTortilla,0) + ISNULL(VentasMostradorMasa,0) + ISNULL(VentasRepartoTortilla,0) + ISNULL(VentasRepartoMasa,0)

	/*
	TotalKilosVentaRepartoTortilla DECIMAL(14,3) NULL,
		TotalKilosVentaRepartoMasa DECIMAL(14,3) NULL,
	*/
	UPDATE #TMP_RESULT
	SET TotalGlobalVenta = ISNULL(TotalGlobalMostradorRepartoTortillaMasa,0) + ISNULL(VentasMostradorOtros,0),
	TotalKilosVentaRepartoTortilla = ISNULL(KilosVentaMostradorTortilla,0) + ISNULL(KilosRepartoTortilla,0),
	TotalKilosVentaRepartoMasa = ISNULL(KilosVentaMostradorMasa,0) + ISNULL(KilosRepartoMasa,0)


	IF(@pTipo = 2)
	BEGIN
		SELECT Id,
		   Fecha,
		   T.SucursalId,
		   Sucursal,
		   ISNULL(VentasMostradorTortilla, 0) AS VentasMostradorTortilla,
		   ISNULL(VentasMostradorMasa, 0) AS VentasMostradorMasa,
		   ISNULL(TotalVentaMostradorTortillaMasa, 0) AS TotalVentaMostradorTortillaMasa,
		   ISNULL(VentasRepartoTortilla, 0) AS VentasRepartoTortilla,
		   ISNULL(VentasRepartoMasa, 0) AS VentasRepartoMasa,
		   ISNULL(TotalRepartoMasaTortilla, 0) AS TotalRepartoMasaTortilla,
		   ISNULL(TotalGlobalMostradorRepartoTortillaMasa, 0) AS TotalGlobalMostradorRepartoTortillaMasa,
		   ISNULL(VentasMostradorOtros, 0) AS VentasMostradorOtros,
		   ISNULL(TotalGlobalVenta, 0) AS TotalGlobalVenta,
		   ISNULL(KilosVentaMostradorTortilla, 0) AS KilosVentaMostradorTortilla,
		   ISNULL(KilosVentaMostradorMasa, 0) AS KilosVentaMostradorMasa,
		   ISNULL(KilosRepartoTortilla, 0) AS KilosRepartoTortilla,
		   ISNULL(KilosRepartoMasa, 0) AS KilosRepartoMasa,
		   ISNULL(TotalKilosVentaRepartoTortilla, 0) AS TotalKilosVentaRepartoTortilla,
		   ISNULL(TotalKilosVentaRepartoMasa, 0) AS TotalKilosVentaRepartoMasa,
		   ISNULL(DevolucionRepartoKilosTortilla, 0) AS DevolucionRepartoKilosTortilla,
		   ISNULL(DevolucionRepartoKilosMasa, 0) AS DevolucionRepartoKilosMasa,
		   ISNULL(TotalDevolucionesRepato, 0) AS TotalDevolucionesRepato,
		   ISNULL(SobranteKilosTortilla, 0) AS SobranteKilosTortilla,
		   ISNULL(SobranteKilosMasa, 0) AS SobranteKilosMasa,
		   ISNULL(VentaTortillaFria, 0) AS VentaTortillaFria,
			ISNULL(kilosTortillaFria, 0) AS KilosTortillaFria,
		   Gastos,
		   ISNULL(GastosAdmon, 0) AS GastosAdmon,
		   Retiros,
		   RetirosCorte,
		   RetirosTotal=Retiros,
		   Maiz,
		   Maseca,
		   MaizEntrada,
		   MasecaEntrada
		FROM #TMP_RESULT T
		INNER JOIN cat_usuarios_sucursales US ON US.UsuarioId = @pUsuarioId AND
											US.SucursalId = T.SucursalId
		ORDER BY Fecha, Sucursal
	END

	IF(@pTipo = 1)
	BEGIN

		--INSERT INTO #TMP_RESULT(Fecha ,		SucursalId ,		Sucursal,		VentasMostradorTortilla ,
		--VentasMostradorMasa	,		TotalVentaMostradorTortillaMasa, 		VentasRepartoTortilla ,		VentasRepartoMasa  ,		TotalRepartoMasaTortilla ,
		--TotalGlobalMostradorRepartoTortillaMasa ,		VentasMostradorOtros ,				TotalGlobalVenta ,		KilosVentaMostradorTortilla ,		KilosVentaMostradorMasa,
		--KilosRepartoTortilla ,		KilosRepartoMasa,		TotalKilosVentaRepartoTortilla ,		TotalKilosVentaRepartoMasa ,		DevolucionRepartoKilosTortilla ,
		--DevolucionRepartoKilosMasa  ,		TotalDevolucionesRepato ,		SobranteKilosTortilla ,			SobranteKilosMasa,			Gastos		,
		--GastosAdmon ,		Retiros		,		RetirosCorte ,		RetirosTotal ,		Maiz		,
		--Maseca		,		VentaTortillaFria ,		KilosTortillaFria)
		
		
		
		
		SELECT Id=0,	Fecha=GETDATE() ,		SucursalId = -1 ,		Sucursal = 'TOTAL GLOBAL',		
		VentasMostradorTortilla = SUM(VentasMostradorTortilla) ,
		VentasMostradorMasa =SUM(VentasMostradorMasa)	,		
		TotalVentaMostradorTortillaMasa = SUM(TotalVentaMostradorTortillaMasa), 		
		VentasRepartoTortilla =SUM(VentasRepartoTortilla),		
		VentasRepartoMasa =SUM(VentasRepartoMasa)  ,		
		TotalRepartoMasaTortilla = SUM(TotalRepartoMasaTortilla) ,
		TotalGlobalMostradorRepartoTortillaMasa =SUM(TotalGlobalMostradorRepartoTortillaMasa),		
		VentasMostradorOtros =SUM(VentasMostradorOtros),				
		TotalGlobalVenta =SUM(TotalGlobalVenta),		
		KilosVentaMostradorTortilla =SUM(KilosVentaMostradorTortilla),		
		KilosVentaMostradorMasa=SUM(KilosVentaMostradorMasa),
		KilosRepartoTortilla =SUM(KilosRepartoTortilla),		
		KilosRepartoMasa=SUM(KilosRepartoMasa),		
		TotalKilosVentaRepartoTortilla =SUM(TotalKilosVentaRepartoTortilla),		
		TotalKilosVentaRepartoMasa=SUM(TotalKilosVentaRepartoMasa) ,		
		DevolucionRepartoKilosTortilla =SUM(DevolucionRepartoKilosTortilla),
		DevolucionRepartoKilosMasa =SUM(DevolucionRepartoKilosMasa) ,		
		TotalDevolucionesRepato =SUM(TotalDevolucionesRepato),		
		SobranteKilosTortilla =SUM(SobranteKilosTortilla),			
		SobranteKilosMasa=SUM(SobranteKilosMasa),	
		VentaTortillaFria=SUM(VentaTortillaFria) ,		
		KilosTortillaFria = SUM(KilosTortillaFria),
		Gastos	=ISNULL(SUM(Gastos),0)	,
		GastosAdmon =ISNULL(SUM(GastosAdmon),0),			
		Retiros	=SUM(Retiros)	,	
		RetirosCorte=SUM(RetirosCorte) ,		
		RetirosTotal =Sum(Retiros),	
		Maiz=SUM(Maiz)		,
		Maseca=SUM(Maseca),
		MaizEntrada = SUM(MaizEntrada),
		MasecaEntrada = SUM(MasecaEntrada)
		FROM  #TMP_RESULT T
		
		UNION

		SELECT Id = MAX(Id),
		   Fecha = MAX(Fecha),
		   T.SucursalId,
		   Sucursal,
		  SUM(ISNULL(VentasMostradorTortilla, 0)) AS VentasMostradorTortilla,
		   SUM(ISNULL(VentasMostradorMasa, 0)) AS VentasMostradorMasa,
		   SUM(ISNULL(TotalVentaMostradorTortillaMasa, 0)) AS TotalVentaMostradorTortillaMasa,
		   SUM(ISNULL(VentasRepartoTortilla, 0)) AS VentasRepartoTortilla,
		   SUM(ISNULL(VentasRepartoMasa, 0)) AS VentasRepartoMasa,
		   SUM(ISNULL(TotalRepartoMasaTortilla, 0)) AS TotalRepartoMasaTortilla,
		   SUM(ISNULL(TotalGlobalMostradorRepartoTortillaMasa, 0)) AS TotalGlobalMostradorRepartoTortillaMasa,
		   SUM(ISNULL(VentasMostradorOtros, 0)) AS VentasMostradorOtros,
		   SUM(ISNULL(TotalGlobalVenta, 0)) AS TotalGlobalVenta,
		   SUM(ISNULL(KilosVentaMostradorTortilla, 0)) AS KilosVentaMostradorTortilla,
		   SUM(ISNULL(KilosVentaMostradorMasa, 0)) AS KilosVentaMostradorMasa,
		   SUM(ISNULL(KilosRepartoTortilla, 0)) AS KilosRepartoTortilla,
		   SUM(ISNULL(KilosRepartoMasa, 0)) AS KilosRepartoMasa,
		   SUM(ISNULL(TotalKilosVentaRepartoTortilla, 0)) AS TotalKilosVentaRepartoTortilla,
		   SUM(ISNULL(TotalKilosVentaRepartoMasa, 0)) AS TotalKilosVentaRepartoMasa,
		   SUM(ISNULL(DevolucionRepartoKilosTortilla, 0)) AS DevolucionRepartoKilosTortilla,
		   SUM(ISNULL(DevolucionRepartoKilosMasa, 0)) AS DevolucionRepartoKilosMasa,
		   SUM(ISNULL(TotalDevolucionesRepato, 0)) AS TotalDevolucionesRepato,
		   SUM(ISNULL(SobranteKilosTortilla, 0)) AS SobranteKilosTortilla,
		   SUM(ISNULL(SobranteKilosMasa, 0)) AS SobranteKilosMasa,
		   SUM(ISNULL(VentaTortillaFria, 0)) AS VentaTortillaFria,
			SUM(ISNULL(kilosTortillaFria, 0)) AS KilosTortillaFria,
		   SUM(Gastos) AS Gastos,
		   SUM(ISNULL(GastosAdmon, 0)) AS GastosAdmon,
		   SUM(Retiros) AS Retiros,
		   SUM(RetirosCorte) AS RetirosCorte,
		   SUM(CASE WHEN T.SucursalId > 0 then Retiros ELSE 0 END) AS RetirosTotal,
		   SUM(Maiz) AS Maiz,
		   SUM(Maseca) AS Maseca,
		   SUM(MaizEntrada) AS MaizEntrada,
		   SUM(MasecaEntrada) AS MasecaEntrada
		FROM #TMP_RESULT T
		INNER JOIN cat_usuarios_sucursales US ON US.UsuarioId = @pUsuarioId AND
											(US.SucursalId = T.SucursalId)
		GROUP BY T.SucursalId,Sucursal
		ORDER BY Id,Fecha, Sucursal
	END

	

GO
/****** Object:  StoredProcedure [dbo].[p_rpt_sucursales_precios]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_sucursales_precios 0,1
CREATE PROC [dbo].[p_rpt_sucursales_precios]
@pSucursalId INT,
@pUsuarioId INT
AS


	SELECT
		Id = CAST(ROW_NUMBER() OVER(ORDER BY S.Clave ASC) AS INT),
		SucursalId = S.Clave,
		Sucursal = S.NombreSucursal,
		ProductoId = P.ProductoId,
		Producto = P.Descripcion,
		Precio = CASE WHEN ISNULL(PED.PrecioEspecial,0) > 0 THEN ISNULL(PED.PrecioEspecial,0) ELSE ISNULL(PP.Precio,0) END
	from cat_sucursales S
	INNER JOIN cat_usuarios_sucursales US ON US.SucursalId = s.Clave AND
										US.UsuarioId = @pUsuarioId AND
										@pSucursalId in(0,s.Clave)
	INNER JOIN cat_productos P ON P.Empresa = S.Empresa
	INNER JOIN cat_productos_precios PP ON PP.IdProducto = P.ProductoId AND
										PP.IdPrecio = 1
	LEFT JOIN doc_precios_especiales PE ON PE.SucursalId = S.Clave
	LEFT JOIN doc_precios_especiales_detalle PED ON PED.ProductoId = P.ProductoId AND
													PED.PrecioEspeciaId  = PE.Id
	ORDER BY S.NombreSucursal, p.Descripcion
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_venta_ticket_formaspago]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_venta_ticket_formaspago 1
Create Proc [dbo].[p_rpt_venta_ticket_formaspago]
@pVentaId int
as

	select Monto = dfp.Cantidad,
		FormaPago=fp.Descripcion
	from doc_ventas_formas_pago dfp
	inner join cat_formas_pago fp on fp.FormaPagoId = dfp.FormaPagoId
	where VentaId = @pVentaId
	order by fp.Descripcion





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_ventas_caja_movil]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_rpt_ventas_caja_movil 10,'20221020','20221020'
CREATE PROC [dbo].[p_rpt_ventas_caja_movil]
@pSucursalId INT,
@pDel DATETIME,
@pAl DATETIME
AS

	SELECT 
		P.ProductoId,
		Producto = ISNULL(P.Clave,'') +'-'+ ISNULL(p.DescripcionCorta,'') ,
		
		Cantidad = SUM(VD.Cantidad),
		vd.PrecioUnitario,
		Total = SUM(VD.total)
	FROM doc_pedidos_orden po
	INNER JOIN cat_usuarios u on u.IdUsuario = po.CreadoPor AND							
								PO.VentaId IS NOT NULL
	INNER JOIN cat_cajas caj on caj.Clave = po.CajaId 						
	INNER JOIN cat_tipos_cajas TC ON TC.TipoCajaId = CAJ.TipoCajaId AND
							TC.Nombre LIKE '%MOVIL%'
	INNER JOIN doc_ventas V ON V.VentaId = PO.VentaId AND
						V.FechaCancelacion IS NULL AND
						CONVERT(VARCHAR,V.FechaCreacion,112) BETWEEN CONVERT(VARCHAR,@pDel,112) AND CONVERT(VARCHAR,@pAl,112) AND
						V.SucursalId = @pSucursalId
	INNER JOIN doc_ventas_Detalle VD ON VD.VentaId = V.VentaId
	INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId
	GROUP BY P.ProductoId,P.Clave,p.DescripcionCorta,vd.PrecioUnitario,P.Orden
	ORDER BY P.Orden
	
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_ventas_detalle]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_ventas_detalle 4,'20230530','20230530'
CREATE PROC [dbo].[p_rpt_ventas_detalle]
@pSucursalId INT,
@pFechaIni DATETIME,
@pFechaFin DATETIME
AS



SELECT	Id=CAST(ROW_NUMBER() OVER(ORDER BY Folio DESC) AS INT),
		V.Folio,
		P.Clave, 
		Producto = P.Descripcion,
		FechaMovimiento = V.FechaCreacion,
		FormaPago = fp.Descripcion,
		Cantidad = vd.Cantidad,
		PrecioUnitario = vd.PrecioUnitario,
		Total = vd.Total,
		Usuario = u.NombreUsuario,
		Caja = c.Descripcion,
		Cancelada = case when v.Activo = 1 THEN 'NO' ELSE 'SI' END,
		FechaCancelacion = V.FechaCancelacion,
		Sucursal = S.NombreSucursal,
		Cliente = ISNULL(CLI.Nombre,'')
FROM doc_ventas_detalle VD
INNER JOIN doc_ventas V ON CONVERT(VARCHAR,v.FechaCreacion,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) and CONVERT(VARCHAR,@pFechaFin,112)  AND
					V.VentaId = VD.VentaId AND v.SucursalId = @pSucursalId 
INNER JOIN doc_ventas_formas_pago VFP ON VFP.VentaId = V.VentaId
INNER JOIN cat_formas_pago FP ON FP.FormaPagoId = VFP.FormaPagoId
INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId
inner join cat_usuarios u on u.IdUsuario = v.UsuarioCreacionId
INNER JOIN cat_cajas C ON C.Clave = v.CajaId
INNER JOIN cat_sucursales S ON S.Clave = V.SucursalId
LEFT JOIN cat_clientes CLI ON CLI.ClienteId = V.ClienteId
ORDER BY v.FechaCreacion DESC



GO
/****** Object:  StoredProcedure [dbo].[p_rpt_ventas_encript]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_ventas_encript 1,'20220101','20220401'
create PROC [dbo].[p_rpt_ventas_encript]
@pSucursalId INT,
@pFechaDel DATETIME,
@pFechaAl DATETIME
AS

	SELECT VD.VentaDetalleId,
			Serie = V.Serie,
			Folio = V.Folio,
			Clave = P.Clave,
			Fecha = V.Fecha,
			Producto = P.DescripcionCorta,
			Sucursal = S.NombreSucursal,
			Cantidad = cast(VD.Cantidad AS varchar) ,
			Total = CAST(VD.Total AS VARCHAR)
	into #TMP_Resultado
	FROM doc_ventas_detalle VD
	INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId
	INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId
	INNER JOIN cat_sucursales S ON S.Clave = V.SucursalId
	WHERE V.Fecha BETWEEN @pFechaDel AND @pFechaAl AND
	V.SucursalId = @pSucursalId



	UPDATE #TMP_Resultado
	SET Cantidad = REPLACE(Cantidad,'0','A'),
		Total = REPLACE(Total,'0','A')

	UPDATE #TMP_Resultado
	SET Cantidad = REPLACE(Cantidad,'1','B'),
		Total = REPLACE(Total,'1','B')

	UPDATE #TMP_Resultado
	SET Cantidad = REPLACE(Cantidad,'2','C'),
		Total = REPLACE(Total,'2','C')

	UPDATE #TMP_Resultado
	SET Cantidad = REPLACE(Cantidad,'3','D'),
		Total = REPLACE(Total,'3','D')

	UPDATE #TMP_Resultado
	SET Cantidad = REPLACE(Cantidad,'4','E'),
		Total = REPLACE(Total,'4','E')

	UPDATE #TMP_Resultado
	SET Cantidad = REPLACE(Cantidad,'5','F'),
		Total = REPLACE(Total,'5','F')

	UPDATE #TMP_Resultado
	SET Cantidad = REPLACE(Cantidad,'6','G'),
		Total = REPLACE(Total,'6','G')

	UPDATE #TMP_Resultado
	SET Cantidad = REPLACE(Cantidad,'7','H'),
		Total = REPLACE(Total,'7','H')

	UPDATE #TMP_Resultado
	SET Cantidad = REPLACE(Cantidad,'8','I'),
		Total = REPLACE(Total,'8','I')

		UPDATE #TMP_Resultado
	SET Cantidad = REPLACE(Cantidad,'9','J'),
		Total = REPLACE(Total,'9','J')

	SELECT * FROM  #TMP_Resultado


GO
/****** Object:  StoredProcedure [dbo].[p_rpt_ventas_gastos_sucursal]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- p_rpt_ventas_gastos_sucursal 0,'20221101','20221220',0
CREATE PROC [dbo].[p_rpt_ventas_gastos_sucursal]
@pSucursalId INT,
@pDel DATETIME,
@pAl DATETIME,
@pUsuarioId INT=0

AS

	DECLARE @ProductoId1 INT= 1,
			@ProductoId2 INT = 2

	CREATE TABLE #TMP_RESULTADO(
		SucursalId INT,
		Sucursal VARCHAR(500),
		VentasProducto1 MONEY,
		VentasProducto2 MONEY,
		NombreProducto1 VARCHAR(500),
		NombreProducto2 VARCHAR(500),
		VentasOtros MONEY,
		VentasTotal MONEY,
		Gastos MONEY,
		Utilidad MONEY
	)


	--PRODUCTO 1
	SELECT V.SucursalId,
			VentasProducto1 = ISNULL(SUM(VD.Total),0)
	INTO #TMP_VENTAS_PRODUCTO1
	FROM doc_ventas_detalle VD
	INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId AND	
							VD.ProductoId = @ProductoId1 AND
							CONVERT(VARCHAR,VD.FechaCreacion,112) BETWEEN CONVERT(VARCHAR,@pDel,112) AND CONVERT(VARCHAR,@pAl,112)
	WHERE @pSucursalId in (0,v.SucursalId) AND
	V.Activo = 1
	GROUP BY V.SucursalId

	--PRODUCTO 2
	SELECT V.SucursalId,
			VentasProducto1 = ISNULL(SUM(VD.Total),0)
	INTO #TMP_VENTAS_PRODUCTO2
	FROM doc_ventas_detalle VD
	INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId AND	
							VD.ProductoId = @ProductoId2 AND
							CONVERT(VARCHAR,VD.FechaCreacion,112) BETWEEN CONVERT(VARCHAR,@pDel,112) AND CONVERT(VARCHAR,@pAl,112)
	WHERE @pSucursalId in (0,v.SucursalId) AND
	V.Activo = 1
	GROUP BY V.SucursalId


	--VENTAS OTROS
	SELECT V.SucursalId,
			VentasOtros = ISNULL(SUM(VD.Total),0)
	INTO #TMP_VENTAS_OTROS
	FROM doc_ventas_detalle VD
	INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId AND	
							VD.ProductoId NOT IN (@ProductoId1,@ProductoId2) AND
							CONVERT(VARCHAR,VD.FechaCreacion,112) BETWEEN CONVERT(VARCHAR,@pDel,112) AND CONVERT(VARCHAR,@pAl,112)
	WHERE @pSucursalId in (0,v.SucursalId) AND
	V.Activo = 1
	GROUP BY V.SucursalId

	--GASTOS
	SELECT G.SucursalId,
		Gastos = ISNULL(SUM(G.Monto),0)
	INTO #TMP_GASTOS
	FROM doc_gastos G
	WHERE G.Activo = 1 AND
	CONVERT(VARCHAR,g.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pDel,112) AND CONVERT(VARCHAR,@pAl,112)
	GROUP BY G.SucursalId

	INSERT INTO #TMP_RESULTADO(
		SucursalId ,		Sucursal ,		VentasProducto1 ,		VentasProducto2 ,
		NombreProducto1 ,	NombreProducto2 ,VentasOtros ,			VentasTotal ,
		Gastos ,			Utilidad 
	)
	SELECT S.Clave,			S.NombreSucursal,ISNULL(MAX(VP1.VentasProducto1),0), ISNULL(MAX(VP2.VentasProducto1),0),
	MAX(P1.Descripcion),	MAX(P2.Descripcion),ISNULL(MAX(VO.VentasOtros),0), ISNULL(MAX(VP1.VentasProducto1),0) + ISNULL(MAX(VP2.VentasProducto1),0) + ISNULL(MAX(VO.VentasOtros),0),
	ISNULL(MAX(G.Gastos),0),			0
	FROM cat_sucursales S
	LEFT JOIN #TMP_VENTAS_PRODUCTO1 VP1 ON VP1.SucursalId = S.Clave
	LEFT JOIN #TMP_VENTAS_PRODUCTO2 VP2 ON VP2.SucursalId = S.Clave
	LEFT JOIN #TMP_VENTAS_OTROS VO ON VO.SucursalId = S.Clave
	LEFT JOIN #TMP_GASTOS G ON G.SucursalId = S.Clave
	LEFT JOIN cat_productos P1 ON P1.ProductoId = @ProductoId1
	LEFT JOIN cat_productos P2 ON P2.ProductoId = @ProductoId2
	group by S.Clave,			S.NombreSucursal

	update #TMP_RESULTADO
	set VentasTotal = isnull(VentasProducto1,0) + isnull(VentasProducto2,0) + isnull(VentasOtros,0)

	update #TMP_RESULTADO
	set Utilidad = VentasTotal - Gastos

	SELECT distinct	TMP.* 
	FROM #TMP_RESULTADO TMP
	INNER JOIN cat_usuarios_sucursales US ON @pUsuarioId IN (0,US.UsuarioId) AND
										US.SucursalId = TMP.SucursalId
	WHERE Utilidad <> 0
	ORDER BY VentasTotal 

GO
/****** Object:  StoredProcedure [dbo].[p_rpt_ventas_movs_dia]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_ventas_movs_dia 4,'20230211','20230211'
create proc [dbo].[p_rpt_ventas_movs_dia]
@pSucursalId INT,
@pFechaIni DATETIME,
@pFechaFin DATETIME
AS


	declare @ValorPreferencia VARCHAR(500),
			@UsarOtros BIT=0
	
	--Obtener productos que se quieren agrupar
	SELECT @ValorPreferencia = ISNULL(pe.Valor,'')
	FROM sis_preferencias_empresa PE
	INNER JOIN cat_sucursales S ON S.Clave = @pSucursalId
	INNER JOIN sis_preferencias P ON P.Id = PE.PreferenciaId AND P.Preferencia = 'CorteCajaSubReporteVentasProd'
	WHERE PE.EmpresaId = S.Empresa


	SELECT ProductoId = splitdata
	INTO #TMP_IdProdcutos
	FROM [dbo].[fnSplitString](@ValorPreferencia,',')

	

	CREATE TABLE #TMP_RESULT(
		Id Int IDENTITY(1,1),
		TipoId INT ,		
		Fecha DATETIME NULL,
		Detalle VARCHAR(250) NULL,
		Detalle2 VARCHAR(250) NULL,
		Cantidad FLOAT NULL,
		Valor	FLOAT,
		Abono BIT

	)
	CREATE TABLE #TMP_TIPOS(
		TipoId INT,
		Descripcion VARCHAR(250)
	)

	INSERT INTO #TMP_TIPOS(TipoId,Descripcion)
	VALUES(1,'VENTAS TOTALES')
	INSERT INTO #TMP_TIPOS(TipoId,Descripcion)
	VALUES(2,'RESUMEN DIARIO')
	INSERT INTO #TMP_TIPOS(TipoId,Descripcion)
	VALUES(3,'VENTAS POR PRODUCTO')
	INSERT INTO #TMP_TIPOS(TipoId,Descripcion)
	VALUES(4,'PEDIDOS PAGADOS')
	INSERT INTO #TMP_TIPOS(TipoId,Descripcion)
	VALUES(5,'PEDIDOS PENDIENTES DE PAGAR')
	INSERT INTO #TMP_TIPOS(TipoId,Descripcion)
	VALUES(6,'GASTOS')
	INSERT INTO #TMP_TIPOS(TipoId,Descripcion)
	VALUES(7,'RETIROS')
	INSERT INTO #TMP_TIPOS(TipoId,Descripcion)
	VALUES(8,'RETIRO FINAL')

	/************************VENTAS TOTALES*******************************/
	INSERT INTO #TMP_RESULT(TipoId,Detalle,Valor,Abono)
	SELECT  1,
			'VENTAS',
			Sum(VD.Total),
			1
	FROM doc_ventas_detalle VD
	iNNER JOIN doc_ventas V ON V.VentaId = VD.VentaId AND
							V.SucursalId = @pSucursalId AND
							CAST(V.Fecha AS DATE) BETWEEN CAST(@pFechaIni AS DATE) AND CAST(@pFechaFin AS DATE)
	
	WHERE V.Activo = 1 
	
	
	/**************************RESUMEN VENTAS*****************************/
	--RESUMEN
	INSERT INTO #TMP_RESULT(TipoId,Detalle,Valor,Abono)
	SELECT  2,
			CASE WHEN MAX(TMP.ProductoId) = MAX(VD.ProductoId) THEN MAX(P.Descripcion) ELSE 'OTROS PRODUCTOS' END,
			Sum(VD.Total),
			1
	FROM doc_ventas_detalle VD
	INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId
	INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId AND
							V.SucursalId = @pSucursalId AND
							CAST(V.Fecha AS DATE) BETWEEN CAST(@pFechaIni AS DATE) AND CAST(@pFechaFin AS DATE)
	LEFT JOIN #TMP_IdProdcutos TMP ON TMP.ProductoId = VD.ProductoId
	WHERE V.Activo = 1 
	GROUP BY (CASE WHEN TMP.ProductoId IS NULL THEN 99999999 ELSE TMP.ProductoId END)
	ORDER BY (CASE WHEN TMP.ProductoId IS NULL THEN 99999999 ELSE TMP.ProductoId END) 


	/*************************VENTAS POR PRODUCTO*******************************/
	--RESUMEN
	INSERT INTO #TMP_RESULT(TipoId,Detalle,Detalle2,Cantidad,Valor,Abono)
	SELECT  3,
			P.Descripcion,
			p.ProductoId,
			SUM(VD.Cantidad),
			Sum(VD.Total),
			1
	FROM doc_ventas_detalle VD
	INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId
	INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId AND
							V.SucursalId = @pSucursalId AND
							CAST(V.Fecha AS DATE) BETWEEN CAST(@pFechaIni AS DATE) AND CAST(@pFechaFin AS DATE)
	LEFT JOIN #TMP_IdProdcutos TMP ON TMP.ProductoId = VD.ProductoId
	WHERE V.Activo = 1 
	GROUP BY P.Descripcion,p.ProductoId
	ORDER BY p.ProductoId

	--GASTOS
	INSERT INTO #TMP_RESULT(TipoId,Detalle,Valor,Abono)
	SELECT 6,'Gastos',SUM(G.Monto),0
	FROM doc_gastos G
	WHERE G.SucursalId = @pSucursalId AND
	G.Activo = 1 AND
	CAST(G.CreadoEl AS DATE) BETWEEN CAST(@pFechaIni AS DATE)AND CAST(@pFechaFin AS DATE)

	--RETIROS
	INSERT INTO #TMP_RESULT(TipoId,Detalle,Valor,Abono)
	SELECT 7,'Retiros',SUM(R.MontoRetiro),0 
	FROM doc_retiros R
	WHERE R.SucursalId = @pSucursalId AND
	CAST(R.FechaRetiro AS DATE)  BETWEEN CAST(@pFechaIni AS DATE) AND  CAST(@pFechaFin AS DATE)

	--RETIRO FINAL
	INSERT INTO #TMP_RESULT(TipoId,Detalle,Valor,Abono)
	SELECT 8,'Retiro Final',ISNULL(SUM(CCD.Total),0),0
	FROM doc_corte_caja_denominaciones CCD
	INNER JOIN doc_corte_caja CC ON CC.CorteCajaId = CCD.CorteCajaId AND
								CAST(CC.FechaCorte AS DATE) BETWEEN CAST(@pFechaIni AS DATE) AND CAST(@pFechaFin AS DATE)
	INNER JOIN cat_cajas C ON C.Clave = CC.CajaId AND
								C.Sucursal = @pSucursalId 
								
	--DIFERENCIA
	--INSERT INTO #TMP_RESULT(TipoId,Detalle,Valor,Abono)
	--SELECT 2,'Ventas - Gastos - Retiros - Retiro Final = ',(SUM(CASE WHEN Abono = 1 THEN Valor ELSE (Valor*-1) END))*-1,0
	--FROM #TMP_RESULT WHERE TipoId = 2


	/**********************PEDIDOS PAGADOS******************************/
	INSERT INTO #TMP_RESULT(TipoId,Detalle,Detalle2,Cantidad,Valor,Abono)
	select 4,ISNULL(C.Nombre,'SIN NOMBRE') , P.DescripcionCorta,SUM(VD.Cantidad), SUM(VD.Total),1
	from doc_ventas V
	INNER JOIN cat_clientes C ON C.ClienteId = V.ClienteId
	INNER JOIN doc_pedidos_orden PO ON PO.VentaId = V.VentaId AND
											V.SucursalId = @pSucursalId AND
											V.Activo = 1 AND 
											CAST(V.FechaCreacion AS DATE) BETWEEN CAST(@pFechaIni AS DATE) AND CAST(@pFechaFin AS DATE) 
	INNER JOIN doc_ventas_detalle VD ON VD.VentaId = V.VentaId
	INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId
	GROUP BY C.Nombre, P.DescripcionCorta

	/**********************PEDIDOS PENDIENTES DE PAGAR******************************/
	INSERT INTO #TMP_RESULT(TipoId,Detalle,Detalle2,Fecha,Cantidad,Valor,Abono)
	SELECT 5, ISNULL(C.Nombre,'SIN NOMBRE'),P.DescripcionCorta,PO.CreadoEl,SUM(POD.Cantidad),SUM(POD.Total),0
	FROM doc_pedidos_orden PO
	INNER JOIN cat_clientes C ON C.ClienteId = PO.ClienteId 
	INNER JOIN doc_pedidos_orden_detalle POD ON POD.PedidoId = PO.PedidoId AND									 
									 PO.Activo = 1 AND
									 PO.VentaId IS NULL AND
									 PO.SucursalId = @pSucursalId
	INNER JOIN cat_productos P ON P.ProductoId = POD.ProductoId
	GROUP BY C.Nombre, P.DescripcionCorta,PO.CreadoEl
	ORDER BY C.Nombre


	SELECT TMP.Id,
			TIPO.TipoId,
			TIPO.Descripcion,
			TMP.Detalle,
			Detalle2=ISNULL(TMP.Detalle2,''),
			tmp.Fecha,
			Cantidad = ISNULL(TMP.Cantidad,0),	
			Total = ISNULL(TMP.Valor,0),
			TMP.Abono
	FROM #TMP_RESULT TMP
	INNER JOIN #TMP_TIPOS TIPO ON TIPO.TipoId = TMP.TipoId
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_ventas_producto_pct]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_rpt_ventas_producto_pct '20210126','20210625',0
CREATE proc [dbo].[p_rpt_ventas_producto_pct]
@pFechaIni DateTime,
@pFechaFin DateTime,
@pSucursalId int,
@pUsuarioId INT = 0
as

	SELECT P.ProductoId,
		   Impuestos = isnull(SUM(id.Porcentaje),0)
	into #tmpProductosImpuestos
	FROM cat_productos P
	INNER JOIN cat_productos_impuestos i on i.ProductoId = p.ProductoId
	INNER JOIN cat_impuestos id on id.Clave = i.ImpuestoId
	GROUP BY P.ProductoId

	SELECT productoId = vd.ProductoId,
			sucursal = CASE WHEN @pSucursalId = 0 THEN 'TODOS' ELSE max(suc.NombreSucursal) END,
			claveProducto = p.Clave,
			descripcion = p.Descripcion,
			unidad = u.Descripcion,
			cantidad = cast(SUM(vd.Cantidad) as decimal(10,4)),			
			subTotal = cast(ISNULL(sum(VD.Total),0) / (1+(ISNULL(max(PI.Impuestos),0)/100)) as decimal(10,2)),
			impuestos = cast(ISNULL(sum(VD.Total),0) - ISNULL(sum(VD.Total),0) / (1+(ISNULL(max(PI.Impuestos),0)/100)) as decimal(10,2)),
			
			total = cast(sum(VD.Total) as decimal(10,2)),
			porcentajeVenta = cast(0 as decimal(10,2))
	into #tmpResult
	FROM doc_ventas_detalle vd
	INNER JOIN doc_ventas v on v.VentaId = vd.VentaId
	INNER JOIN cat_sucursales suc on suc.Clave = v.SucursalId
	INNER JOIN cat_productos p on p.ProductoId = vd.ProductoId
	INNER JOIN cat_unidadesmed u on u.Clave = p.ClaveUnidadMedida
	INNER JOIN dbo.fnUsuarioSucursales(@pUsuarioId) US ON US.SucursalId = V.SucursalId
	LEFT JOIN #tmpProductosImpuestos PI ON PI.ProductoId = p.ProductoId
	where @pSucursalId in (0,v.SucursalId) AND
	v.Activo = 1 AND
	CONVERT(VARCHAR,v.Fecha,112) >= CONVERT(VARCHAR,@pFechaIni,112) AND
	CONVERT(VARCHAR,v.Fecha,112) <= CONVERT(VARCHAR,@pFechaFin,112)
	GROUP BY vd.ProductoId,
			p.Clave,
			p.Descripcion,
			u.Descripcion

			

	DECLARE @TotalVentas float

	SELECT @TotalVentas = SUM(Total)
	FROM #tmpResult

	IF @TotalVentas > 0

		UPDATE #tmpResult
		set porcentajeVenta = ISNULL(Total,0) * 100 / @TotalVentas
		FROM #tmpResult TMP

	SELECT ProductoId ,
			sucursal,
			claveProducto ,
			Descripcion ,
			Unidad ,
			Cantidad ,			
			Impuestos ,
			Subtotal ,
			Total ,
			porcentajeVenta 
	FROM #tmpResult


	


GO
/****** Object:  StoredProcedure [dbo].[p_rpt_ventas_resumen]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_ventas_resumen 1
CREATE proc [dbo].[p_rpt_ventas_resumen]
@pSucursalId int
as


	select  
		v.SucursalId,
		Sucursal = suc.NombreSucursal,
		v.Serie,
		v.Folio,
		p.Clave,
		FechaHora = v.FechaCreacion,
		p.Descripcion,
		vd.Cantidad,
		vd.Descuento,
		Cancelado =cast(case when v.FechaCancelacion is null then 0 else 1 end as bit),
		Total =  case when v.FechaCancelacion is null then  vd.Total else 0 end ,
		Cliente =isnull(c.clave,'') +' '+ c.Nombre,
		Coche = cast(aut.Modelo as varchar) + ' Color:' + isnull(aut.Color,'') +' Placas:' +  isnull(aut.Placas,''),
		FolioPagoWeb = 'Folio:'+cast(w.id as varchar) +' Ref:'+ isnull(TransactionRef,''), 
		Observaciones = isnull(aut.Observaciones,'') +' ' + isnull(v.MotivoCancelacion,'')
	from doc_ventas v
	inner join cat_sucursales suc on suc.Clave = v.SucursalId
	inner join doc_ventas_detalle vd on vd.VentaID= v.ventaId
	inner join cat_productos p on p.ProductoId = vd.ProductoId
	left join cat_clientes c on c.ClienteId = v.ClienteId
	left join cat_clientes_automovil aut on aut.ClienteId = c.ClienteId
	left join doc_web_carrito w on w.VentaId = v.VentaId

	where @pSucursalId in (v.SucursalId,0)
	group by v.SucursalId, suc.NombreSucursal,
	v.Serie,
		v.Folio,
		p.Clave,
		v.FechaCreacion,
		p.Descripcion,
		vd.Cantidad,
		vd.Descuento,
		v.FechaCancelacion,
		vd.Total,
		c.Nombre,
		aut.Modelo,
		aut.Color,
		aut.Placas,
		aut.Observaciones,
		v.MotivoCancelacion,
		c.clave,
		w.id,
		TransactionRef
	order by v.FechaCreacion desc
	

GO
/****** Object:  StoredProcedure [dbo].[p_rpt_ventas_vendedor]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_rpt_ventas_vendedor 1,1,7,'20220706','20220707'
CREATE proc [dbo].[p_rpt_ventas_vendedor]
@pSucursalId int,
@pCajaId int,
@pCajeroId int,
@pDel DateTime,
@pAl DateTime
as

		select v.UsuarioCreacionId,
			Efectivo = sum(case when vfp.FormaPagoId = 1 then Cantidad  else 0 end),
			Tarjeta = sum(case when vfp.FormaPagoId in( 2,3) then Cantidad  else 0 end),
			Vales = sum(case when vfp.FormaPagoId not in( 1,2,3 ) then Cantidad  else 0 end),
			Total = sum(case when vfp.FormaPagoId in( 1,2,3,4,5) then Cantidad  else 0 end),
			Fecha = convert(varchar,v.Fecha,112)
		into #tmpFormasPagoV
		from [doc_ventas_formas_pago] vfp
		inner join doc_ventas v on v.VentaId = vfp.VentaId
		where @pCajeroId in (0,v.UsuarioCreacionId) and 
		@pCajaId IN (0,V.CajaId) and
		v.SucursalId = @pSucursalId and
		v.FechaCancelacion is null and
		convert(varchar,v.Fecha,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112)
		group by v.UsuarioCreacionId,convert(varchar,v.Fecha,112)

		union

		select ap.CreadoPor,
			Efectivo = sum(case when vfp.FormaPagoId = 1 then Cantidad  else 0 end),
			Tarjeta = sum(case when vfp.FormaPagoId in( 2,3) then Cantidad  else 0 end),
			Vales = sum(case when vfp.FormaPagoId  not in( 1,2,3 ) then Cantidad  else 0 end),
			Total = sum(case when vfp.FormaPagoId in( 1,2,3,4,5) then Cantidad  else 0 end),
			Fecha = convert(varchar,v.CreadoEl,112)
		
		from doc_apartados_formas_pago vfp
		inner join doc_apartados_pagos ap on ap.ApartadoPagoId = vfp.ApartadoPagoId
		inner join doc_apartados v on v.ApartadoId = ap.ApartadoId
		where @pCajeroId in (0,ap.CreadoPor) and 
		@pCajaId IN (0,V.CajaId) and
		v.SucursalId = @pSucursalId and		
		convert(varchar,v.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112)
		group by ap.CreadoPor,convert(varchar,v.CreadoEl,112)

		--select * from #tmpFormasPagoV


		select UsuarioCreacionId,
			Efectivo =sum(Efectivo),
			Tarjeta =sum(Tarjeta),
			Vales =sum(Vales),
			Total =sum(Total),
			Fecha
		into  #tmpFormasPagoV2
		from #tmpFormasPagoV
		group by UsuarioCreacionId,Fecha

		select 
		Del = @pDel,
		Al = @pAl,
		u.IdUsuario,
		Fecha = convert(varchar,v.Fecha,103),
		Vendedora = u.NombreUsuario,
		Efectivo = fp.Efectivo,
		Tpv = fp.Tarjeta,
		Vales = fp.Vales,
		Total = fp.Total,
		Gastos = (
			select isnull(sum(Monto),0)
			from doc_gastos g
			where @pCajaId in (0,g.cajaId) and
			g.SucursalId = @pSucursalId and
			v.UsuarioCreacionId = g.CreadoPor and
			convert(varchar,g.CreadoEl,103) = convert(varchar,v.Fecha,103)
		),
		Cancelaciones = (
			select isnull(sum(sv.TotalVenta),0)
			from doc_ventas sv
			where @pCajaId in(sv.CajaId,0)  and
			v.UsuarioCreacionId = sv.UsuarioCancelacionId and
			sv.FechaCancelacion is not null and
			convert(varchar,sv.FechaCancelacion,103) = convert(varchar,v.Fecha,103)
		),
		Retiros =(
			select isnull(sum(sv.MontoRetiro),0)
			from doc_retiros sv
			where @pCajaId in(sv.CajaId,0)  and
			v.UsuarioCreacionId = sv.CreadoPor and			
			convert(varchar,sv.FechaRetiro,103) = convert(varchar,v.Fecha,103)
		),-- isnull(sum(ret.MontoRetiro),0),
		Devoluciones = (
			select isnull(sum(sdev.Total),0)
			from doc_devoluciones sdev
			inner join doc_ventas sv on sv.VentaId = sdev.VentaId
			where convert(varchar,sv.Fecha,103) = convert(varchar,v.Fecha,103) and
			@pCajaId in (0,sv.CajaId) and
			v.UsuarioCreacionId = sdev.CreadoPor and
			sv.SucursalId = @pSucursalId		
			
		),
		TotalCorte = fp.Total 
				-
					(
					select isnull(sum(Monto),0)
					from doc_gastos g
					where @pCajaId in (0,g.cajaId) and
					g.SucursalId = @pSucursalId and
					v.UsuarioCreacionId = g.CreadoPor and
					convert(varchar,g.CreadoEl,103) = convert(varchar,v.Fecha,103) 
				)
				---
				--(
				--	select isnull(sum(sv.TotalVenta),0)
				--	from doc_ventas sv
				--	where @pCajaId in(sv.CajaId,0)  and
				--	v.UsuarioCreacionId = sv.UsuarioCancelacionId and
				--	sv.FechaCancelacion is not null and
				--	convert(varchar,sv.FechaCancelacion,103) = convert(varchar,v.Fecha,103) 
				--)
				-
				(
					select isnull(sum(sdev.Total),0)
					from doc_devoluciones sdev
					inner join doc_ventas sv on sv.VentaId = sdev.VentaId
					where convert(varchar,sv.Fecha,103) = convert(varchar,v.Fecha,103) and
					@pCajaId in (0,sv.CajaId) and
					v.UsuarioCreacionId = sdev.CreadoPor and
					sv.SucursalId = @pSucursalId		
			
				)
				-
				(
					select isnull(sum(sv.MontoRetiro),0)
					from doc_retiros sv
					where @pCajaId in(sv.CajaId,0)  and
					v.UsuarioCreacionId = sv.CreadoPor and			
					convert(varchar,sv.FechaRetiro,103) = convert(varchar,v.Fecha,103) 
				)			,
			Empresa = emp.NombreComercial,
			Sucursal = suc.NombreSucursal
		from doc_ventas v
		inner join #tmpFormasPagoV2 fp on 	convert(varchar,fp.Fecha,112) = convert(varchar,v.Fecha,112)
		inner join cat_usuarios u on u.IdUsuario = v.UsuarioCreacionId and
									fp.UsuarioCreacionId = u.IdUsuario
		--inner join cat_formas_pago cfp on cfp.FormaPagoId = fp.FormaPagoId
		inner join cat_sucursales suc on suc.Clave = v.SucursalId
		inner join cat_empresas emp on emp.Clave = suc.Empresa
		
		where v.SucursalId =@pSucursalId and
		@pCajaId in (0,v.CajaId) and
		@pCajeroId in (v.UsuarioCreacionId ,0) and
		convert(varchar,v.Fecha,112) 
			between convert(varchar,@pDel,112) and convert(varchar,@pAl,112)

			group by  convert(varchar,v.Fecha,103),
			u.NombreUsuario,
			IdUsuario,
			 emp.NombreComercial,
			suc.NombreSucursal,
			v.UsuarioCreacionId,
			fp.Efectivo,
			fp.Tarjeta,
			fp.Vales,
			fp.Total


GO
/****** Object:  StoredProcedure [dbo].[p_rpt_VentaTicket]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- [p_rpt_VentaTicket] 66
CREATE PROC [dbo].[p_rpt_VentaTicket]
@pVentaId INT
AS


	declare @Giro varchar(20) ,
		@Observaciones varchar(500)	

	select @Giro = Giro
	from cat_configuracion

	select @Observaciones = case when @Giro = 'AUTOLAV'
								then 'Nombre:'+cli.Nombre + ', ' +
									'Modelo:'+isnull(a.Modelo,'') + ' ' +
									isnull(a.Color,'') + ' ' +
									isnull(a.placas,'') + ', '+
									'Obs:'+isnull(a.Observaciones,'')
								else ''
							End
	from doc_ventas v
	inner join cat_clientes cli on cli.clienteId = v.ClienteId
	inner join cat_clientes_automovil a on a.ClienteId = cli.clienteId
	where VentaId = @pVentaId

	SELECT  suc.NombreSucursal,
			Direccion = RTRIM(ISNULL(suc.Calle,'')) + ' '+
						RTRIM(ISNULL(suc.NoExt ,'')) + ' ' +
						RTRIM(ISNULL(suc.NoInt,'')) +' '+
						RTRIM(ISNULL(suc.Colonia, '')) + ' '+
						RTRIM(ISNULL(suc.Ciudad,'')) +','+
						RTRIM(ISNULL(suc.Estado,'')) +','+
						RTRIM(ISNULL(suc.Pais,'')) ,
			FOLIO = cast(v.Folio as bigint),
			vd.VentaDetalleId,
			FECHA = CONVERT(VARCHAR,v.FechaCreacion,103),
			HORA = CONVERT(VARCHAR,v.FechaCreacion,108),
			Producto = case when isnull(vd.Descripcion,'') = '' then
									prod.DescripcionCorta + ' ' +isnull(prod.talla,'') + ' ' + 
									case 
										when prod.ProductoId = 0 then isnull(pcm.NombrePromocion,'') 
										when vd.cargoAdicionalId > 0 then cargo.Descripcion
										else '' 
									end
							else isnull(vd.Descripcion,'')
						end + ' '+
						CASE WHEN VD.ParaLlevar = 1 THEN '(LL)'
							 WHEN VD.ParaMesa = 1 THEN '(M)'
								ELSE ''
						END,
			Cantidad = vd.Cantidad,
			ImportePartida = vd.Total,
			TotalVenta = v.TotalVenta,
			TotalDescuentoVenta = v.TotalDescuento,
			SubTotalVenta = v.TotalVenta - v.Impuestos,
			ImpuestosVenta = v.Impuestos,
			TotalRecibido = SUM(vfp.Cantidad) + isnull(v.cambio,0),
			suc.Telefono1,
			RFC = emp.RFC,
			vd.PrecioUnitario,
			v.Cambio,
			TextoCabecera1 = conf.TextoCabecera1,
			conf.TextoCabecera2,
			conf.TextoPie,
			Serie = isnull(conf.Serie,''),
			Atendio = rhe.Nombre,
			MotivoCancelacion =case when isnull(v.MotivoCancelacion,'') = '' then ''
									else 'Motivo Cancelaci�n:' + isnull(v.MotivoCancelacion,'')
								End,
			TasaIVA = isnull(max(vd.TasaIVA),0),
			Observaciones = @Observaciones,
			FolioOrden = ISNULL(TP.Folio,'') + PO.Folio,
			Titulo = ISNULL(emp.NombreComercial,'')+ISNULL(suc.NombreSucursal,'')
	FROM dbo.doc_ventas v
	INNER JOIN dbo.doc_ventas_detalle vd ON vd.VentaId = v.VentaId
	INNER JOIN dbo.cat_productos prod ON prod.ProductoId = vd.ProductoId
	INNER JOIN dbo.cat_sucursales suc ON suc.Clave = v.SucursalId	
	inner join cat_empresas emp on emp.Clave = 1
	inner join cat_usuarios usu on usu.IdUsuario = v.UsuarioCreacionId
	inner join rh_empleados rhE on rhE.NumEmpleado = usu.IdEmpleado
	left JOIN dbo.doc_ventas_formas_pago vfp ON vfp.VentaId = v.VentaId
	LEFT JOIN cat_configuracion_ticket_venta conf on conf.SucursalId = v.SucursalId
	left join doc_promociones_cm pcm on pcm.PromocionCMId = vd.PromocionCMId
	left join	cat_cargos_adicionales cargo on cargo.CargoAdicionalId = vd.CargoAdicionalId
	LEFT JOIN	doc_pedidos_orden PO on PO.VentaId = v.VentaId
	LEFT JOIN	cat_tipos_pedido TP on TP.TipoPedidoId = PO.TipoPedidoId
	WHERE v.VentaId = @pVentaId
	GROUP BY v.VentaId,suc.Calle,suc.NoExt ,suc.NoInt,suc.Colonia,suc.Ciudad,suc.Estado,suc.Pais,v.FechaCreacion,
	prod.DescripcionCorta,vd.Cantidad,vd.Total,v.TotalVenta,v.TotalDescuento,v.Impuestos,v.Impuestos,vd.VentaDetalleId,
	suc.NombreSucursal,suc.Telefono1,emp.RFC,vd.PrecioUnitario,v.Cambio,prod.talla,
	conf.TextoCabecera1,conf.TextoCabecera2,conf.TextoPie,conf.Serie,rhe.Nombre,
	v.MotivoCancelacion,v.Folio,pcm.NombrePromocion,prod.ProductoId,
	vd.cargoAdicionalId,cargo.Descripcion,vd.Descripcion,PO.Folio,TP.Folio,emp.NombreComercial,
	VD.ParaLlevar,VD.ParaMesa













GO
/****** Object:  StoredProcedure [dbo].[p_rpt_VentaTicket_Restaurante]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- p_rpt_VentaTicket_Restaurante 1
CREATE proc [dbo].[p_rpt_VentaTicket_Restaurante]
@pVentaId int
as
	

	select 
		v.VentaId,
			po.Personas,
		   Mesas = [dbo].[fnGetComandaMesas](po.PedidoId) + ' ' +po.Para
	from doc_ventas v
	inner join doc_pedidos_orden po  on po.VentaId = v.VentaId
	
	where v.VentaId = @pVentaId


GO
/****** Object:  StoredProcedure [dbo].[p_salidas_traspaso_grd]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Proc [dbo].[p_salidas_traspaso_grd]
@pFolio int,
@pDel datetime,
@pAl datetime
as

	select i.MovimientoId,
			i.SucursalId,
			i.FolioMovimiento,
			i.TipoMovimientoId,
			i.FechaMovimiento,
			i.HoraMovimiento,
			i.Comentarios,
			i.ImporteTotal,
			i.Activo,
			i.CreadoPor,
			i.CreadoEl,
			i.Autorizado,
			i.FechaAutoriza,
			i.SucursalDestinoId,
			Destino = s.NombreSucursal
	from [dbo].[doc_inv_movimiento] i
	inner join cat_sucursales s on s.clave = i.SucursalDestinoId
	where (
		MovimientoId = @pFolio and
		@pFolio > 0
	)
	Or
	(
		convert(varchar,FechaMovimiento,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112)
	)
	and isnull(Autorizado,0) = 1





GO
/****** Object:  StoredProcedure [dbo].[p_sis_bitacora_errores_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_sis_bitacora_errores_ins]
@pIdError	int out,
@pSistema	varchar(50),
@pClase	varchar(250),
@pMetodo	varchar(250),
@pError	varchar(500)
as

	select @pIdError = isnull(max(IdError),0) + 1
	from sis_bitacora_errores

	insert into sis_bitacora_errores(
		IdError,	Sistema,	Clase,		Metodo,
		Error,		CreadoEl
	)
	values(
		@pIdError,@pSistema,@pClase,@pMetodo,
		@pError,getdate()
	)
GO
/****** Object:  StoredProcedure [dbo].[p_sis_bitacora_general_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_sis_bitacora_general_ins]
(
    @BitacoraId INT OUT,
    @SucursalId INT,
    @Detalle VARCHAR(8000),
   
    @CreadoPor INT
)
AS
BEGIN

	SELECT @BitacoraId = ISNULL(MAX(BitacoraId),0) +1
	FROM [sis_bitacora_general]

    INSERT INTO [dbo].[sis_bitacora_general] (BitacoraId, SucursalId, Detalle, CreadoEl, CreadoPor)
    VALUES (@BitacoraId, @SucursalId, @Detalle, getdate(), @CreadoPor)
END;
GO
/****** Object:  StoredProcedure [dbo].[p_sis_permisos_menu_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_sis_permisos_menu_sel]
@pUsuarioId int,
@pSucursalId int
as

	select m.MenuId,m.Descripcion
	from sis_usuarios_roles ur
	inner join sis_roles_perfiles rp on rp.RolId = ur.RolId
	inner join sis_roles r on r.RolId = rp.RolId and r.Activo = 1
	inner join sis_perfiles_menu pm on pm.PerfilId = rp.PerfilId
	inner join sis_perfiles p on p.PerfilId = pm.PerfilId and p.Activo = 1
	inner join sis_menu m on m.MenuId = pm.MenuId and m.Activo = 1
	inner join cat_usuarios_sucursales us on us.UsuarioId = ur.UsuarioId
	where ur.UsuarioId = @pUsuarioId and
	us.SucursalId = @pSucursalId
	group by m.MenuId,m.Descripcion
GO
/****** Object:  StoredProcedure [dbo].[p_sis_preferencia_aplica]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[p_sis_preferencia_aplica]
@pEmpresaId INT,
@pSucursalId INT,
@pPreferencia VARCHAR(50)
AS


	DECLARE @Result BIT=0

	IF EXISTS(
		SELECT 1
		FROM sis_preferencias_sucursales		
	)
	BEGIN

		
		SELECT p.Id,P.Preferencia,PS.Valor
		FROM sis_preferencias_sucursales PS
		INNER JOIN sis_preferencias P ON P.Id = PS.PreferenciaId
		WHERE SucursalId = @pSucursalId

	END
	ELSE
	BEGIN
		SELECT p.Id,P.Preferencia,PE.Valor
		FROM sis_preferencias_empresa PE
		INNER JOIN sis_preferencias P ON P.Id = PE.PreferenciaId
		WHERE PE.EmpresaId = @pEmpresaId

	END

GO
/****** Object:  StoredProcedure [dbo].[p_sis_usuarios_menu]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_sis_usuarios_menu 1,3
CREATE PROC [dbo].[p_sis_usuarios_menu]
@UsuarioId INT,
@TipoId INT
AS

	SELECT M.MenuId,
		M.Titulo,
		M.Descripcion,
		M.Tipo,
		MenuWinBarNameId = ISNULL(M.MenuWinBarNameId,''),
		MenuPadreId = ISNULL(M.MenuPadreId,0),
		Activo = CAST(ISNULL(M.Activo,0) AS BIT),
		Clave = ISNULL(M.Clave,''),
		IconoApp = ISNULL(M.IconoApp,'')
	FROM cat_usuarios U
	INNER JOIN sis_usuarios_perfiles UP ON UP.UsuarioId = U.IdUsuario
	INNER JOIN sis_perfiles_menu PM ON PM.PerfilId = UP.PerfilId
	INNER JOIN sis_menu M ON M.MenuId = PM.MenuId
	WHERE U.IdUsuario = @UsuarioId AND
	M.Tipo = @TipoId


	
GO
/****** Object:  StoredProcedure [dbo].[p_sis_versiones_detalle_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc [dbo].[p_sis_versiones_detalle_ins]
@pVersion varchar(20) ,
@pScriptName varchar(250)
as

	declare @VersionId int,
		 @VersionDetalleId int

	select @VersionId = VersionId
	from sis_versiones
	where Nombre = @pVersion

	select @VersionDetalleId = isnull(max(VersionDetalleId),0) + 1
	from sis_versiones_detalle

	if not exists(
		select 1
		from sis_versiones_detalle
		where ScriptName = @pScriptName and
		VersionId = @VersionId
	)
	begin

		insert into sis_versiones_detalle(VersionDetalleId,VersionId,ScriptName,Completado)
		select @VersionDetalleId,@VersionId,@pScriptName,0

	end









	
GO
/****** Object:  StoredProcedure [dbo].[p_sis_versiones_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_sis_versiones_ins '2010.10.02,2010.10.03'
create proc [dbo].[p_sis_versiones_ins]
@pVersiones varchar(5000)
as

	declare @versionId int

	select @versionId = isnull(max(VersionId),0) 
	from [sis_versiones]
	
	select *
	into #tmpVersiones
	from [dbo].fnSplitString(@pVersiones,',')

	insert into [dbo].[sis_versiones](VersionId,Nombre,CreadoEl,Completado,Intentos)
	select ROW_NUMBER() OVER(ORDER BY splitdata ASC)  + @versionId,splitdata,getdate(),0,0
	from #tmpVersiones
	where not exists (
		select 1
		from [sis_versiones]
		where Nombre = splitdata
	)
	order by splitdata
GO
/****** Object:  StoredProcedure [dbo].[p_sucursales_productos_config_por_precio_especial]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_sucursales_productos_config_por_precio_especial 7
CREATE PROC [dbo].[p_sucursales_productos_config_por_precio_especial]
@PrecioEspecialId INT
AS

	SELECT PE.SucursalId,
		PED.ProductoId
	INTO #TMP_SUCURSALES_PRODUCTOS
	FROM doc_precios_especiales PE
	INNER JOIN doc_precios_especiales_detalle PED ON PED.PrecioEspeciaId = PE.Id AND
											(ISNULL(PED.PrecioEspecial,0) > 0 OR ISNULL(PED.MontoAdicional,0) > 0 OR PED.ProductoId = 1 OR PED.ProductoId = 2)
	WHERE PE.FechaVigencia >= GETDATE() AND
	PE.Id = @PrecioEspecialId


	DELETE cat_sucursales_productos
	FROM cat_sucursales_productos SP
	INNER JOIN #TMP_SUCURSALES_PRODUCTOS TMP ON TMP.SucursalId = SP.SucursalId

	INSERT INTO cat_sucursales_productos(SucursalId,ProductoId,CreadoEl)
	SELECT SucursalId,ProductoId,GETDATE()
	FROM #TMP_SUCURSALES_PRODUCTOS
GO
/****** Object:  StoredProcedure [dbo].[p_sucursales_usuario_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_sucursales_usuario_sel]
@pUsuario varchar(20)
as

	declare @esSupervisor bit

	select @esSupervisor = u.EsSupervisor
	from cat_usuarios u
	where rtrim(u.NombreUsuario) = rtrim(@pUsuario)


	if(@esSupervisor = 1)
	begin

		select s.Clave,
				s.NombreSucursal
		from cat_sucursales s
		
	end
	else
	begin
		select s.Clave,
				s.NombreSucursal
		from cat_sucursales s
		inner join cat_usuarios u on rtrim(u.NombreUsuario) = rtrim(@pUsuario) and
					u.IdSucursal = s.Clave
	end



GO
/****** Object:  StoredProcedure [dbo].[p_traspaso_automatico]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_traspaso_automatico]
@pMovimientoOrigenId INT,
@pUsuarioId INT,
@pError VARCHAR(250) OUT
AS

	DECLARE @TipoMovimientoId INT,
		@TipoMovimientoNuevoId INT,
		@SucursalOrigenId INT,
		@SucursalDestinoId INT,
		@MovimientoId INT,
		@MovimientoDetalleId INT,
		@Consecutivo INT,
		@Generar BIT=0

	SET @pError = ''

	BEGIN TRY

	BEGIN TRAN

	SELECT @TipoMovimientoId = TipoMovimientoId
	FROM doc_inv_movimiento M 
	WHERE M.MovimientoId = @pMovimientoOrigenId

	--SI ES SALIDA POR TRASPASO
	IF(@TipoMovimientoId = 4)
	BEGIN

		SELECT @SucursalOrigenId = SucursalDestinoId
		FROM doc_inv_movimiento M 
		WHERE M.MovimientoId = @pMovimientoOrigenId

		SET @TipoMovimientoNuevoId = 3--entrada por traspaso

		SET @Generar = 1
	
	END



	--SI ES SALIDA POR TRASPASO (DEVOLUCI�N)
	IF(@TipoMovimientoId = 30)
	BEGIN

		SELECT @SucursalOrigenId = SucursalDestinoId
		FROM doc_inv_movimiento M 
		WHERE M.MovimientoId = @pMovimientoOrigenId

		SET @TipoMovimientoNuevoId = 28--entrada por traspaso(Devoluci�n)

		SET @Generar = 1
		
	END

	if @Generar = 1
	BEGIN

		SELECT @MovimientoId = ISNULL(MAX(MovimientoId),0) + 1
		FROM doc_inv_movimiento

		SELECT @Consecutivo = ISNULL(MAX(Consecutivo),0) + 1
		FROM doc_inv_movimiento
		WHERE SucursalId = @SucursalOrigenId AND
		TipoMovimientoId = @TipoMovimientoNuevoId


		INSERT INTO doc_inv_movimiento(MovimientoId,	SucursalId,		FolioMovimiento,		TipoMovimientoId,
									FechaMovimiento,	HoraMovimiento,	Comentarios,			ImporteTotal,
									Activo,				CreadoPor,		CreadoEl,				Autorizado,
									FechaAutoriza,		SucursalDestinoId,	AutorizadoPor,		FechaCancelacion,
									ProductoCompraId,	Consecutivo,	SucursalOrigenId,		VentaId,
									MovimientoRefId,	Cancelado,		TipoMermaId,			FechaCorteExistencia)
		SELECT						@MovimientoId,		@SucursalOrigenId,		FolioMovimiento,		@TipoMovimientoNuevoId,
									GETDATE(),			GETDATE(),	Comentarios+'|TRASPASO GENERADO DE MENERA AUTM�TICA',			ImporteTotal,
									1,					@pUsuarioId,		GETDATE(),				1,
									GETDATE(),			SucursalDestinoId,	AutorizadoPor,		FechaCancelacion,
									ProductoCompraId,	Consecutivo,	SucursalOrigenId,		VentaId,
									MovimientoRefId,	0,				TipoMermaId,			FechaCorteExistencia
		FROM doc_inv_movimiento
		WHERE MovimientoId = @pMovimientoOrigenId

		SELECT @MovimientoDetalleId = ISNULL(MAX(MovimientoDetalleId),0)
		FROM doc_inv_movimiento_detalle

		INSERT INTO doc_inv_movimiento_detalle(
			MovimientoDetalleId,	MovimientoId,		ProductoId,			Consecutivo,
			Cantidad,				PrecioUnitario,		Importe,			Disponible,
			CreadoPor,				CreadoEl,			CostoUltimaCompra,	CostoPromedio,
			ValCostoUltimaCompra,	ValCostoPromedio,	ValorMovimiento,	Flete,
			Comisiones,				SubTotal,			PrecioNeto
		)
		SELECT @MovimientoDetalleId + ROW_NUMBER() OVER(ORDER BY MovimientoId DESC) ,	@MovimientoId,		ProductoId,			Consecutivo,
			Cantidad,				PrecioUnitario,		Importe,			Disponible,
			@pUsuarioId,				GETDATE(),			CostoUltimaCompra,	CostoPromedio,
			ValCostoUltimaCompra,	ValCostoPromedio,	ValorMovimiento,	Flete,
			Comisiones,				SubTotal,			PrecioNeto
		FROM doc_inv_movimiento_detalle
		WHERE MovimientoId = @pMovimientoOrigenId

	END

	COMMIT TRAN

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN

		SET @pError = ERROR_MESSAGE()
		
	END CATCH
GO
/****** Object:  StoredProcedure [dbo].[p_venta_afecta_inventario]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Proc [dbo].[p_venta_afecta_inventario]
@pVentaId int,
@pSucursalId int
as
BEGIN

PRINT 1

	--DECLARE @dommie BIT = 0

	--IF EXISTS (
	--	SELECT 1
	--	FROM cat_sucursales S
	--	INNER JOIN sis_preferencias_empresa PE ON PE.EmpresaId = S.Empresa
	--	INNER JOIN sis_preferencias P ON P.Id = PE.PreferenciaId AND
	--							P.Preferencia = 'PV-QuitarCalculoInventarioEnVenta'
		
	--)
	--OR EXISTS (
	--	SELECT 1
	--	FROM cat_sucursales S
	--	INNER JOIN sis_preferencias_sucursales PE ON PE.SucursalId = S.Clave AND
	--										PE.SucursalId = @pSucursalId
	--	INNER JOIN sis_preferencias P ON P.Id = PE.PreferenciaId AND
	--							P.Preferencia = 'PV-QuitarCalculoInventarioEnVenta'		
	--)
	
	--BEGIN

	--	SET @dommie = 1

	--END
	--ELSE
	--BEGIN
	--	DECLARE @movimientoid int,
	--			@consecutivo int,
	--			@movimientoDetalleId int,
	--			@folioVenta varchar(20)

	--	select @movimientoid = isnull(max(MovimientoId),0) + 1
	--	from doc_inv_movimiento

	--	select @consecutivo = isnull(max(Consecutivo),0) + 1
	--	from doc_inv_movimiento 
	--	where SucursalId = @pSucursalId and
	--	TipoMovimientoId = 8 --Venta en Caja

	--	select @folioVenta = isnull(Serie,'') + cast(@pVentaId as varchar)
	--	from [dbo].[cat_configuracion_ticket_venta]
	--	where sucursalId = @pSucursalId

	--	if(@folioVenta is null)
	--	begin
	--		select @folioVenta = cast(@pVentaId as varchar)
	--	end

	--	begin tran


	--	insert into doc_inv_movimiento(
	--		MovimientoId,		SucursalId,		FolioMovimiento,		TipoMovimientoId,		FechaMovimiento,
	--		HoraMovimiento,		Comentarios,	ImporteTotal,			Activo,					CreadoPor,
	--		CreadoEl,			Autorizado,		FechaAutoriza,			SucursalDestinoId,		AutorizadoPor,
	--		FechaCancelacion,	ProductoCompraId,Consecutivo,			SucursalOrigenId,		VentaId
	--	)
	--	select @movimientoid,	v.SucursalId,	@consecutivo,			8,						GETDATE(),
	--	getdate(),				@folioVenta,	v.TotalVenta,			1,						v.UsuarioCreacionId,
	--	getdate(),				1,				GETDATE(),				null,					UsuarioCreacionId,
	--	null,					null,			@consecutivo,			null,					v.VentaId
	--	from doc_ventas V
	--	where VentaId = @pVentaId AND
	--	V.Activo = 1

	--	if @@error <> 0
	--	begin
	--		rollback tran
	--		goto fin
	--	end

	

	--	select @movimientoDetalleId = isnull(max(MovimientoDetalleId),0) + 1
	--	from doc_inv_movimiento_detalle

	--	--Detalle de movs sin productos base
	--	insert into doc_inv_movimiento_detalle(
	--		MovimientoDetalleId,	MovimientoId,	ProductoId,	Consecutivo,	Cantidad,
	--		PrecioUnitario,			Importe,		Disponible,	CreadoPor,		CreadoEl
	--	)
	--	select @movimientoDetalleId + ROW_NUMBER() OVER(ORDER BY vd.ProductoId ASC), @movimientoid, 
	--	vd.ProductoId,ROW_NUMBER() OVER(ORDER BY vd.ProductoId ASC),
	--	Cantidad = sum(vd.Cantidad),			VD.PrecioUnitario,			VD.Total,	
	--	--Si tiene productos base, insertar cantidad 0 ya que no se debe de inventariar, solo dejar registro		
	--	Disponible =  sum(vd.Cantidad),
	--	v.UsuarioCreacionId,GETDATE()
	--	from doc_ventas V
	--	inner join doc_ventas_detalle vd on vd.VentaId = V.VentaId
	--	--left join cat_productos_base pb on pb.ProductoId = vd.ProductoId
	--	where v.VentaId = @pVentaId AND
	--	V.Activo = 1
	--	group by vd.ProductoId,VD.PrecioUnitario,VD.Total,v.UsuarioCreacionId

	--	select @movimientoDetalleId = isnull(max(MovimientoDetalleId),0) + 1
	--	from doc_inv_movimiento_detalle

	



	--		if @@error <> 0
	--		begin
	--			rollback tran
	--			goto fin
	--		end

	--		commit tran

	--		fin:
	--END
	

END










GO
/****** Object:  StoredProcedure [dbo].[p_venta_afecta_inventario_corte]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [p_venta_afecta_inventario_corte] 0,''
CREATE PROC [dbo].[p_venta_afecta_inventario_corte]
@pSucursalId INT,
@pError VARCHAR(250) OUT
AS
BEGIN

DECLARE @VentaId INT,
	@SucursalId INT


	BEGIN TRY

		SELECT V.VentaId
		INTO #TMP_VENTA
		FROM doc_ventas V
		WHERE V.VentaId NOT IN (
			SELECT IM.VentaId
			FROM doc_inv_movimiento IM
			WHERE IM.VentaId = V.VentaId
		) 
		AND	@pSucursalId IN(0,V.SucursalId)
		AND V.FechaCancelacion IS NULL

		SELECT @VentaId = MIN(VentaId)
		FROM #TMP_VENTA TMP
	

		WHILE @VentaId IS NOT NULL
		BEGIN

			PRINT @VentaId
			BEGIN TRY

				--BEGIN TRAN

				SELECT @SucursalId = SucursalId
				FROM doc_ventas
				WHERE VentaId = @VentaId

				DECLARE @movimientoid int,
						@consecutivo int,
						@movimientoDetalleId int,
						@folioVenta varchar(20)

				select @movimientoid = isnull(max(MovimientoId),0) + 1
				from doc_inv_movimiento

				select @consecutivo = isnull(max(Consecutivo),0) + 1
				from doc_inv_movimiento 
				where SucursalId = @SucursalId and
				TipoMovimientoId = 8 --Venta en Caja

				select @folioVenta = isnull(Serie,'') + cast(@VentaId as varchar)
				from [dbo].[cat_configuracion_ticket_venta]
				where sucursalId = @SucursalId

				if(@folioVenta is null)
				begin
					select @folioVenta = cast(@VentaId as varchar)
				end


		
				insert into doc_inv_movimiento(
					MovimientoId,		SucursalId,		FolioMovimiento,		TipoMovimientoId,		FechaMovimiento,
					HoraMovimiento,		Comentarios,	ImporteTotal,			Activo,					CreadoPor,
					CreadoEl,			Autorizado,		FechaAutoriza,			SucursalDestinoId,		AutorizadoPor,
					FechaCancelacion,	ProductoCompraId,Consecutivo,			SucursalOrigenId,		VentaId
				)
				select @movimientoid,	v.SucursalId,	@consecutivo,			8,						GETDATE(),
				getdate(),				@folioVenta,	v.TotalVenta,			1,						v.UsuarioCreacionId,
				getdate(),				1,				GETDATE(),				null,					UsuarioCreacionId,
				null,					null,			@consecutivo,			null,					v.VentaId
				from doc_ventas V
				where VentaId = @VentaId AND
				V.Activo = 1


				select @movimientoDetalleId = isnull(max(MovimientoDetalleId),0) + 1
				from doc_inv_movimiento_detalle

				--Detalle de movs sin productos base
				insert into doc_inv_movimiento_detalle(
					MovimientoDetalleId,	MovimientoId,	ProductoId,	Consecutivo,	Cantidad,
					PrecioUnitario,			Importe,		Disponible,	CreadoPor,		CreadoEl
				)
				select @movimientoDetalleId + ROW_NUMBER() OVER(ORDER BY vd.ProductoId ASC), @movimientoid, 
				vd.ProductoId,ROW_NUMBER() OVER(ORDER BY vd.ProductoId ASC),
				Cantidad = sum(vd.Cantidad),			VD.PrecioUnitario,			VD.Total,	
				--Si tiene productos base, insertar cantidad 0 ya que no se debe de inventariar, solo dejar registro		
				Disponible =  sum(vd.Cantidad),
				v.UsuarioCreacionId,GETDATE()
				from doc_ventas V
				inner join doc_ventas_detalle vd on vd.VentaId = V.VentaId
				--left join cat_productos_base pb on pb.ProductoId = vd.ProductoId
				where v.VentaId = @VentaId AND
				V.Activo = 1
				group by vd.ProductoId,VD.PrecioUnitario,VD.Total,v.UsuarioCreacionId

				select @movimientoDetalleId = isnull(max(MovimientoDetalleId),0) + 1
				from doc_inv_movimiento_detalle

				--COMMIT TRAN

			END TRY
			BEGIN CATCH
				--ROLLBACK TRAN
				SET @pError = ERROR_MESSAGE()
				return

			END CATCH


			SELECT @VentaId = MIN(VentaId)
			FROM #TMP_VENTA
			WHERE VentaId > @VentaId

		END

	
	

	END TRY
	BEGIN CATCH
	
		SET @pError = ERROR_MESSAGE()
		return
	END CATCH


END
GO
/****** Object:  StoredProcedure [dbo].[p_web_pedido_cliente_ins]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_web_pedido_cliente_ins 1,0,'Daniel','8331593533',1,1,1,0,'Monaco','2015','5','Arenal',1,29,'00000'
create proc [dbo].[p_web_pedido_cliente_ins]
@pSucursalId int,
@pPedidoClienteId int out,
@pNombre varchar(100),
@pWhatsApp varchar(20),
@pProductoId int,
@pPedidoConfiguracionId int,
@pTieneCostoEnvio bit,
@pSitioEntregaId int,
@pCalle varchar(50),
@pNumeroExt varchar(10),
@pNumeroInt varchar(10),
@pColonia varchar(50),
@pMunicipioId int,
@pEstadoId int,
@pCP varchar(5)
as

	declare @pClienteId int,
		@pClienteDireccionId int,
		@municipio varchar(100),
		@pedidoClienteId int,
		@pedidoClienteDetId int

	set @pEstadoId = 29 --TAMAULIPAS
	set @pSitioEntregaId = case when isnull(@pSitioEntregaId,0) =0 then null else @pSitioEntregaId end

	set @pMunicipioId = case when @pMunicipioId = 0 then null else @pMunicipioId end

	select @municipio = Nombre
	from cat_municipios
	where MunicipioId = @pMunicipioId

	begin tran
	--Crear Cliente


	select @pClienteId = min(ClienteId)
	from cat_clientes
	where ltrim(Telefono) = ltrim(@pWhatsApp)
	Or LTRIM(Telefono2) = ltrim(@pWhatsApp)

	


	if(
		isnull(@pClienteId,0) = 0
	)
	begin

	

		select @pClienteId = isnull(max(ClienteId),0) + 1
		from cat_clientes



		insert into cat_clientes(
			ClienteId,	Nombre,		RFC,	Calle,
			NumeroExt,	NumeroInt,	Colonia,	CodigoPostal,
			EstadoId,	MunicipioId, PaisId,	Telefono,
			Telefono2,	TipoClienteId,	DiasCredito,	LimiteCredito,
			Activo		
		)
		select @pClienteId,@pNombre, '',	@pCalle,
		@pNumeroExt,	@pNumeroInt, @pColonia, @pCP,
		@pEstadoId,		@pMunicipioId, 1,		@pWhatsApp,
			@pWhatsApp,	null,		null,				null,
			1


		if @@error <> 0
		begin
			rollback tran
			goto fin
		end
	end

	--Crear direcci�n cliente
	if (
		isnull(@pSitioEntregaId,0) = 0 and
		isnull(@pCP,'') <> ''
	)
	begin
		
		select @pClienteDireccionId = MAX(ClienteDireccionId)
		from cat_clientes_direcciones
		where ClienteId = @pClienteId and
		CodigoPostal = @pCP

		IF(
			ISNULL(@pClienteDireccionId ,0) = 0
		)
		BEGIN

			SELECT @pClienteDireccionId = isnull(max(ClienteDireccionId),0) + 1
			FROM cat_clientes_direcciones

			INSERT INTO cat_clientes_direcciones(
				ClienteDireccionId,	ClienteId,			TipoDireccionId,
				Calle,				NumeroInterior,		NumeroExterior,
				Colonia,			Ciudad,				EstadoId,
				PaisId,				CodigoPostal,	CreadoEl
			)
			SELECT @pClienteDireccionId, @pClienteId, 1,
			@pCalle,		@pNumeroInt,				@pNumeroExt,
			@pColonia,			@municipio,				@pEstadoId,
			1,						@pCP,				getdate()

			if @@error <> 0
			begin
				rollback tran
				goto fin
			end
			
		END
		else
		begin
			update cat_clientes_direcciones
			set Calle = @pCalle,
				NumeroInterior = @pNumeroInt,
				NumeroExterior = @pNumeroExt,
				Colonia = @pColonia,
				Ciudad = @municipio,
				EstadoId = @pEstadoId,
				CodigoPostal = @pCP
			where ClienteDireccionId = @pClienteDireccionId

			if @@error <> 0
			begin
				rollback tran
				goto fin
			end
		end
	end

	--Crear Pedido
	select @pedidoClienteId = isnull(max(PedidoClienteId),0) + 1
	from doc_pedidos_clientes

	insert into doc_pedidos_clientes(
		PedidoClienteId,	SucursalId,		ClienteId,		EstatusId,	
		FechaEntregaProgramada,HoraEntrega,	FechaEntregaReal,SitioEntregaId,
		ClienteDireccionId,	CreadoEl,		PedidoConfiguracionId
	)
	select @pedidoClienteId,@pSucursalId,	@pClienteId,   1,
		FechaInicioEntrega,		null,		null,			@pSitioEntregaId,
		@pClienteDireccionId,GETDATE(),		@pPedidoConfiguracionId
	from doc_pedidos_configuracion
	where PedidoConfiguracionId = @pPedidoConfiguracionId
	
	if @@error <> 0
	begin
			rollback tran
			goto fin
	end

	select @pedidoClienteDetId = isnull(max(PedidoClienteDetId),0) + 1
	from doc_pedidos_clientes_det

	insert into doc_pedidos_clientes_det(
		PedidoClienteDetId,	PedidoClienteId,	ProductoId,	Cantidad,
		CreadoEl
	)
	select @pedidoClienteDetId,@pedidoClienteId,@pProductoId,1,
	GETDATE()

	if @@error <> 0
	begin
			rollback tran
			goto fin
	end




	commit tran
	
	fin:
	
GO
/****** Object:  StoredProcedure [dbo].[p_web_pedido_producto_agrupado_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_web_pedido_producto_agrupado_sel 1
create proc [dbo].[p_web_pedido_producto_agrupado_sel]
@pPedidoConfiguracionId int
as


	select Color = p.Color,
	Descripcion = pa.Descripcion,
	pa.DescripcionCorta,
	pa.Especificaciones,
	pa.Liquidacion,
	pa.Rating,
	productoImagenId = min(pi.ProductoId),
	NombreFoto = min(p2.Clave),
	PrecioVenta = confd.Precio,
	pa.ProductoAgrupadoId
	from doc_pedidos_configuracion conf
	INNER JOIN doc_pedidos_configuracion_det confd on confd.PedidoConfiguracionId = conf.PedidoConfiguracionId
	inner join cat_productos_agrupados_detalle pad on pad.ProductoId = confd.ProductoId
	
	inner join cat_productos_agrupados pa on pa.ProductoAgrupadoId = pad.ProductoAgrupadoId

	inner join cat_productos_agrupados_detalle pad2 on pad2.ProductoAgrupadoId = pa.ProductoAgrupadoId
	inner join cat_productos p on p.ProductoId = confd.ProductoId
	LEFT JOIN cat_productos_imagenes pi on pi.ProductoId = pad2.ProductoId
	left join cat_productos p2 on p2.ProductoiD = PI.ProductoId 
	
	where conf.PedidoConfiguracionId = @pPedidoConfiguracionId
	GROUP BY p.Color,pa.Descripcion,pa.DescripcionCorta,pa.Especificaciones,pa.Liquidacion,
	pa.Rating,confd.Precio,pa.ProductoAgrupadoId
	order by pa.Descripcion
	
GO
/****** Object:  StoredProcedure [dbo].[p_web_producto_agrupado_det_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_web_producto_agrupado_det_sel 9
CREATE proc [dbo].[p_web_producto_agrupado_det_sel]
@pProductoAgrupadoId int
as

	select pa.ProductoAgrupadoId,
		pa.Descripcion,
		pa.DescripcionCorta,
		pre.Precio,
		Rating = 0,
		Clave = p.Clave,
		p.ProductoId,
		p.Talla,
		Especificaciones = cast(pa.Especificaciones as varchar(500)),
		p.Color,
		P.Color2,
		p.SobrePedido,
		ProductoImagenId =(
			select min(s1.ProductoId)
			from cat_productos s1
			inner join cat_productos_agrupados s2 on s2.productoid=s1.productoId
			inner join cat_productos_imagenes si on si.productoId = s1.ProductoId
			where s2.ProductoAgrupadoId = pa.ProductoAgrupadoId
		),
		pe.ExistenciaTeorica
	from cat_productos_agrupados pa
	inner join cat_productos_agrupados_detalle pad on pad.ProductoAgrupadoId = pa.ProductoAgrupadoId
	inner join cat_productos p on p.ProductoId = pad.ProductoId and
							p.estatus = 1
	inner join cat_productos_existencias pe on pe.ProductoId = p.ProductoId
	inner join cat_productos_precios pre on pre.IdProducto = p.ProductoId and
									pre.IdPrecio = 1
	left join cat_productos_imagenes pi on pi.ProductoId = p.ProductoId
	where pa.ProductoAgrupadoId = @pProductoAgrupadoId and
	(
		p.SobrePedido = 1 OR
		pe.ExistenciaTeorica > 0
	)
	group by pa.ProductoAgrupadoId,
		pa.Descripcion,
		pa.DescripcionCorta,
		pre.Precio,
		p.Clave,
		p.ProductoId,
		p.Talla,
		p.Color,
		P.Color2,
		p.SobrePedido,
		PE.ExistenciaTeorica,
		pa.Especificaciones
	


GO
/****** Object:  StoredProcedure [dbo].[p_web_productos_sel]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- [p_web_productos_sel] 1,'',0,1,0
CREATE proc [dbo].[p_web_productos_sel]
@pSucursalId int,
@pTexto varchar(200),
@pLinea int,
@pFamilia int,
@pSubfamilia int
as

	select pa.ProductoAgrupadoId,
		pa.Descripcion,
		pa.DescripcionCorta,
		pre.Precio,
		Rating = 0,
		Clave = (
			select min(s1.clave)
			from cat_productos s1
			inner join cat_productos_agrupados s2 on s2.productoid=s1.productoId
			inner join cat_productos_imagenes si on si.productoId = s1.ProductoId
			where s2.ProductoAgrupadoId = pa.ProductoAgrupadoId
		)
	from cat_productos_agrupados pa
	inner join cat_productos_agrupados_detalle pad on pad.ProductoAgrupadoId = pa.ProductoAgrupadoId
	inner join cat_productos p on p.ProductoId = pad.ProductoId and p.Estatus = 1
	
								
	inner join cat_productos_existencias pe on pe.ProductoId = p.ProductoId
	inner join cat_productos_precios pre on pre.IdProducto = p.ProductoId and
									pre.IdPrecio = 1
	where pe.SucursalId = @pSucursalId and
	(
		pa.Descripcion like '%'+isnull(@pTexto,'')+'%'
	) and
	(
		@pFamilia in(0,p.ClaveFamilia)
		OR
		(
			@pFamilia = 9999 --Liquidacion
			and 
			p.Liquidacion = 1
		)
	)
	group by pa.ProductoAgrupadoId,
		pa.Descripcion,
		pa.DescripcionCorta,
		pre.Precio
	
	



GO
/****** Object:  StoredProcedure [dbo].[sis_sucursal_autocreate]    Script Date: 24/01/2024 07:12:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- sis_sucursal_autocreate 'GONZALEZ','caja1.gonzalez','admin.gonzalez','cajero1.gonzalez','danielwong.proyectos@gmail.com'
CREATE PROC [dbo].[sis_sucursal_autocreate]
@NombreSucursal varchar(250),
@caja varchar(250),
@usuarioAdmin varchar(250),
@usuarioCajero varchar(250),
@emailSupervisor varchar(250)
AS

DECLARE @SucursalId_Last INT=0 
DECLARE @SucursalId_New INT=0 
DECLARE @cajaId INT=0
DECLARE @BasculaId INT = 0
DECLARE @EmpleadoId INT =0
DECLARE @UsuarioId INT = 0
DECLARE @Password VARCHAR(250)
DECLARE @Id INT
DECLARE @ClienteId INT
DECLARE @ClienteProductoPrecioId INT
DECLARE @PrecioEspecialId INT
DECLARE @ImpresoraId INT
DECLARE @CajaImpresoraId INT

BEGIN TRAN


BEGIN TRY

	IF EXISTS (SELECT 1 FROM cat_sucursales WHERE NombreSucursal = @NombreSucursal) RETURN

	SELECT @SucursalId_Last = max(Clave)
	FROM cat_sucursales

	SET @SucursalId_New = @SucursalId_Last + 1 


	--CREAR SUCURSAL
	INSERT INTO cat_sucursales(Clave,Empresa,Calle,Colonia,NoExt,NoInt,
	Ciudad,Estado,Pais,Telefono1,Telefono2,Email,
	Estatus,NombreSucursal,CP,ServidorMailSMTP,ServidorMailFrom,
	ServidorMailPort,ServidorMailPassword)
	SELECT @SucursalId_New ,Empresa,'','','','',
	'','','','','','',
	1,@NombreSucursal,'',ServidorMailSMTP,ServidorMailFrom,
	ServidorMailPort,ServidorMailPassword
	FROM cat_sucursales
	WHERE Clave = @SucursalId_Last


	SELECT * FROM cat_sucursales
	WHERE Clave = @SucursalId_New

	SELECT @cajaId = ISNULL(MAX(Clave),0) + 1
	FROM cat_cajas
	--CREAR CAJA
	INSERT INTO cat_cajas(
		Clave,Descripcion,Ubicacion,Estatus,Empresa,Sucursal,TipoCajaId
	)
	SELECT @cajaId,@caja,@NombreSucursal,1,1,@SucursalId_New,1

	SELECT * FROM cat_cajas WHERE Clave = @cajaId


	--BASCULA

	SELECT @BasculaId = ISNULL(MAX(BasculaId),0) + 1
	FROM cat_basculas

	INSERT INTO cat_basculas(
		BasculaId,EmpresaId,Alias,Marca,Modelo,Serie,SucursalAsignadaId,Activo,CreadoEl,CreadoPor,ModificadoEl,ModificadoPor
	)
	SELECT @BasculaId,1,'BASCULA-' +@NombreSucursal,'','','',@SucursalId_New,1,getdate(),1,NULL,NULL

	SELECT * FROM cat_basculas WHERE BasculaId = @BasculaId


	--PERSONAL ADMIN

	SELECT @EmpleadoId = ISNULL(MAX(NumEmpleado),0) + 1
	FROM rh_empleados

	INSERT INTO rh_empleados(
		NumEmpleado,		Nombre,			SueldoNeto,		SueldoDiario,		SueldoHra,
		FormaPago,			TipoContrato,	Puesto,			Departamento,		FechaIngreso,
		FechaInicioLab,		Estatus,		Foto,			Empresa,			Sucursal
	)
	VALUES( @EmpleadoId,		@usuarioAdmin,	0,				0,					0,
	null,					null,			1,				NULL,				GETDATE(),
	GETDATE(),				1,				NULL,			NULL,					NULL)

	--USUARIO ADMIN
	SELECT @UsuarioId = MAX(ISNULL(IdUsuario,0)) + 1
	FROM cat_usuarios

	set @Password = CAST(FLOOR(RAND() * 90000 + 10000) AS VARCHAR);

	INSERT INTO cat_usuarios(
	IdUsuario,		IdEmpleado,		NombreUsuario,		Password,
	CreadoEl,		Activo,			EsSupervisor,		PasswordSupervisor,
	IdSucursal,		EsSupervisorCajero,PasswordSupervisorCajero,Email,
	CajaDefaultId)
	VALUES(@UsuarioId,@EmpleadoId,@usuarioAdmin,@Password,
	GETDATE(),		1,				1,					@Password,
	@SucursalId_New,1,				@Password,@emailSupervisor,
	NULL)

	INSERT INTO cat_usuarios_sucursales(UsuarioId,SucursalId,CreadoEl)
	VALUES(@UsuarioId,@SucursalId_New,GETDATE())


	SELECT * FROM rh_empleados WHERE NumEmpleado = @EmpleadoId

	SELECT * FROM cat_usuarios WHERE IdUsuario = @UsuarioId

	SELECT * FROM cat_usuarios_sucursales WHERE UsuarioId = @UsuarioId


	--PERSONAL CAJERO

	SELECT @EmpleadoId = ISNULL(MAX(NumEmpleado),0) + 1
	FROM rh_empleados
	INSERT INTO rh_empleados(
		NumEmpleado,		Nombre,			SueldoNeto,		SueldoDiario,		SueldoHra,
		FormaPago,			TipoContrato,	Puesto,			Departamento,		FechaIngreso,
		FechaInicioLab,		Estatus,		Foto,			Empresa,			Sucursal
	)
	SELECT @EmpleadoId,@usuarioCajero,0,0,0,
	null,					null,			2,				NULL,				GETDATE(),
	GETDATE(),				1,				NULL,			NULL,					NULL


	--USUARIO cajero
	SELECT @UsuarioId = MAX(ISNULL(IdUsuario,0)) + 1
	FROM cat_usuarios

	set @Password = CAST(FLOOR(RAND() * 90000 + 10000) AS VARCHAR);

	INSERT INTO cat_usuarios(
	IdUsuario,		IdEmpleado,		NombreUsuario,		Password,
	CreadoEl,		Activo,			EsSupervisor,		PasswordSupervisor,
	IdSucursal,		EsSupervisorCajero,PasswordSupervisorCajero,Email,
	CajaDefaultId)
	VALUES(@UsuarioId,@EmpleadoId,@usuarioCajero,@Password,
	GETDATE(),		1,				0,					NULL,
	@SucursalId_New,0,				NULL,'',
	@cajaId)

	INSERT INTO cat_usuarios_sucursales(UsuarioId,SucursalId,CreadoEl)
	VALUES(@UsuarioId,@SucursalId_New,GETDATE())

	SELECT * FROM rh_empleados WHERE NumEmpleado = @EmpleadoId
	SELECT * FROM cat_usuarios WHERE IdUsuario = @UsuarioId
	SELECT * FROM cat_usuarios_sucursales WHERE UsuarioId = @UsuarioId

	SELECT @Id = ISNULL(MAX(Id),0)+1
	FROM sis_preferencias_sucursales

	INSERT INTO sis_preferencias_sucursales(Id,SucursalId,PreferenciaId,Valor,CreadoEl)
	SELECT  @Id + ROW_NUMBER() OVER(ORDER BY iD ASC)  ,@SucursalId_New ,PreferenciaId,
		CASE WHEN PreferenciaId = 19 then @emailSupervisor ELSE Valor END
		,CreadoEl
	from sis_preferencias_sucursales
	WHERE SucursalId = @SucursalId_Last


	SELECT * FROM sis_preferencias_sucursales
	WHERE SucursalId = @SucursalId_New


	--REPARTOS
	SELECT @ClienteId = ISNULL(MAX(ClienteId),0) + 1
	FROM cat_clientes 
	INSERT INTO cat_clientes(ClienteId,Nombre,Telefono,SucursalBaseId,Activo)
	VALUES(@ClienteId,'REPARTOS ('+@NombreSucursal+')','(833) 000-00'+(CAST(@SucursalId_New AS VARCHAR)),@SucursalId_New,1 )

	SELECT * FROM cat_clientes WHERE ClienteId = @ClienteId


	SELECT @ClienteProductoPrecioId = ISNULL(MAX(ClienteProductoPrecioId),0) + 1
	FROM doc_clientes_productos_precios

	INSERT INTO doc_clientes_productos_precios(
		ClienteProductoPrecioId,ClienteId,ProductoId,Precio,CreadoEl
	)
	VALUES(@ClienteProductoPrecioId,@ClienteId,1,26,getdate())


	SELECT @ClienteProductoPrecioId = ISNULL(MAX(ClienteProductoPrecioId),0) + 1
	FROM doc_clientes_productos_precios

	INSERT INTO doc_clientes_productos_precios(
		ClienteProductoPrecioId,ClienteId,ProductoId,Precio,CreadoEl
	)
	VALUES(@ClienteProductoPrecioId,@ClienteId,2,20,getdate())

	SELECT *
	FROM doc_clientes_productos_precios
	WHERE ClienteId = @ClienteId

	--NUEVA SUCURSAL PARA ADMIN
	INSERT INTO cat_usuarios_sucursales(UsuarioId,SucursalId,CreadoEl)
	VALUES(1,@SucursalId_New,GETDATE())

	--PRECIOS SUCURSAL
	INSERT INTO doc_precios_especiales(
		Descripcion,FechaVigencia,HoraVigencia,CreadoEl,CreadoPor,SucursalId
	)
	VALUES('PRECIOS '+@NombreSucursal,'20501201','2050-12-01 11:59:00.000',getdate(),1,@SucursalId_New)

	SET @PrecioEspecialId = SCOPE_IDENTITY()

	SELECT * FROM doc_precios_especiales Where SucursalId = @SucursalId_New

	INSERT INTO doc_precios_especiales_detalle(
		PrecioEspeciaId,ProductoId,PrecioEspecial,MontoAdicional,CreadoEl,CreadoPor,ModificadoEl,ModificadoPor
	)
	SELECT @PrecioEspecialId,ProductoId,PP.Precio,0,GETDATE(),1,NULL,NULL
	FROM cat_productos P
	inner join cat_productos_precios pp on pp.IdProducto = p.ProductoId AND PP.IdPrecio = 1
	WHERE P.ProdParaVenta = 1

	SELECT *
	FROM doc_precios_especiales_detalle
	WHERE PrecioEspeciaId = @PrecioEspecialId


	INSERT INTO cat_sucursales_productos(
		SucursalId,ProductoId,CreadoEl
	)	
	SELECT @SucursalId_New,ProductoId,getdate()
	FROM doc_precios_especiales_detalle
	WHERE PrecioEspeciaId = @PrecioEspecialId

	select *
	from cat_sucursales_productos
	where SucursalId = @SucursalId_New


	--IMPRESORAS
	
		SELECT @ImpresoraId = ISNULL(MAX(ImpresoraId),0) + 1
		from cat_impresoras 

		INSERT INTO cat_impresoras(ImpresoraId,SucursalId,NombreRed,NombreImpresora,Activa,CreadoEl)
		VALUES(@ImpresoraId,@SucursalId_New,'POS-80C',@NombreSucursal,1,GETDATE())



		select @CajaImpresoraId = ISNULL(MAX(CajaImpresoraId),0) + 1
		FROM cat_cajas_impresora

		INSERT INTO cat_cajas_impresora(
		CajaImpresoraId,CajaId,ImpresoraId,CreadoEl
		)
		SELECT @CajaImpresoraId,Clave,@ImpresoraId, GETDATE()
		FROM cat_cajas
		WHERE Sucursal = @SucursalId_New
	
	COMMIT  TRAN
END TRY
BEGIN CATCH
	select ERROR_MESSAGE()
	ROLLBACK TRAN
END CATCH
GO
