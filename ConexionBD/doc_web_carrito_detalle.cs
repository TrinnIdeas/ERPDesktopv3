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
    
    public partial class doc_web_carrito_detalle
    {
        public int IdDetalle { get; set; }
        public string uUID { get; set; }
        public int ProductoId { get; set; }
        public decimal Cantidad { get; set; }
        public string Descripcion { get; set; }
        public decimal PrecioUnitario { get; set; }
        public decimal Importe { get; set; }
        public System.DateTime CreadoEl { get; set; }
        public Nullable<decimal> Impuestos { get; set; }
        public Nullable<decimal> Subtotal { get; set; }
        public Nullable<int> Id { get; set; }
        public Nullable<int> CargoDetalleId { get; set; }
    
        public virtual cat_productos cat_productos { get; set; }
        public virtual doc_web_carrito doc_web_carrito { get; set; }
        public virtual doc_cargos_detalle doc_cargos_detalle { get; set; }
    }
}
