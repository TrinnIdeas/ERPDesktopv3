//------------------------------------------------------------------------------
// <auto-generated>
//     Este código se generó a partir de una plantilla.
//
//     Los cambios manuales en este archivo pueden causar un comportamiento inesperado de la aplicación.
//     Los cambios manuales en este archivo se sobrescribirán si se regenera el código.
// </auto-generated>
//------------------------------------------------------------------------------

namespace ConexionBD
{
    using System;
    using System.Collections.Generic;
    
    public partial class cat_productos_maximos_minimos
    {
        public int SucursalId { get; set; }
        public int ProductoId { get; set; }
        public double Maximo { get; set; }
        public double Minimo { get; set; }
        public System.DateTime CreadoEl { get; set; }
        public int CreadoPor { get; set; }
        public Nullable<System.DateTime> ModificadoEl { get; set; }
        public Nullable<int> ModificadoPor { get; set; }
    
        public virtual cat_productos cat_productos { get; set; }
        public virtual cat_sucursales cat_sucursales { get; set; }
        public virtual cat_usuarios cat_usuarios { get; set; }
        public virtual cat_usuarios cat_usuarios1 { get; set; }
    }
}