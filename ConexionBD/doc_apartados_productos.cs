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
    
    public partial class doc_apartados_productos
    {
        public int ApartadoProductoId { get; set; }
        public int ApartadoId { get; set; }
        public int ProductoId { get; set; }
        public decimal Cantidad { get; set; }
        public decimal Precio { get; set; }
        public decimal Total { get; set; }
        public System.DateTime CreadoEl { get; set; }
        public int CreadoPor { get; set; }
        public Nullable<System.DateTime> ModificadoEl { get; set; }
        public Nullable<int> ModificadoPor { get; set; }
        public Nullable<decimal> SubTotal { get; set; }
        public Nullable<decimal> Impuestos { get; set; }
        public Nullable<decimal> Descuentos { get; set; }
        public Nullable<decimal> POrcentajeDescuento { get; set; }
    
        public virtual cat_productos cat_productos { get; set; }
        public virtual cat_usuarios cat_usuarios { get; set; }
        public virtual cat_usuarios cat_usuarios1 { get; set; }
        public virtual doc_apartados doc_apartados { get; set; }
    }
}
