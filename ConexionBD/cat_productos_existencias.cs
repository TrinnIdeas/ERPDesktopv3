//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace ConexionBD
{
    using System;
    using System.Collections.Generic;
    
    public partial class cat_productos_existencias
    {
        public int ProductoId { get; set; }
        public int SucursalId { get; set; }
        public Nullable<decimal> ExistenciaTeorica { get; set; }
        public decimal CostoUltimaCompra { get; set; }
        public decimal CostoPromedio { get; set; }
        public decimal ValCostoUltimaCompra { get; set; }
        public decimal ValCostoPromedio { get; set; }
        public System.DateTime ModificadoEl { get; set; }
        public System.DateTime CreadoEl { get; set; }
        public Nullable<decimal> Apartado { get; set; }
        public Nullable<decimal> Disponible { get; set; }
        public Nullable<decimal> CostoPromedioInicial { get; set; }
        public Nullable<decimal> CostoCapturaUsuario { get; set; }
    
        public virtual cat_productos cat_productos { get; set; }
        public virtual cat_sucursales cat_sucursales { get; set; }
    }
}
