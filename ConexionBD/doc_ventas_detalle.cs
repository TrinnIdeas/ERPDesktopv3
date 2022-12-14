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
    
    public partial class doc_ventas_detalle
    {
        public long VentaDetalleId { get; set; }
        public long VentaId { get; set; }
        public int ProductoId { get; set; }
        public Nullable<decimal> Cantidad { get; set; }
        public decimal PrecioUnitario { get; set; }
        public decimal PorcDescuneto { get; set; }
        public decimal Descuento { get; set; }
        public decimal Impuestos { get; set; }
        public decimal Total { get; set; }
        public int UsuarioCreacionId { get; set; }
        public System.DateTime FechaCreacion { get; set; }
        public Nullable<decimal> TasaIVA { get; set; }
        public Nullable<byte> TipoDescuentoId { get; set; }
        public Nullable<int> PromocionCMId { get; set; }
        public Nullable<short> CargoAdicionalId { get; set; }
        public Nullable<int> CargoDetalleId { get; set; }
        public string Descripcion { get; set; }
        public Nullable<bool> ParaLlevar { get; set; }
        public Nullable<bool> ParaMesa { get; set; }
    
        public virtual cat_productos cat_productos { get; set; }
        public virtual cat_tipos_descuento cat_tipos_descuento { get; set; }
        public virtual cat_usuarios cat_usuarios { get; set; }
        public virtual doc_ventas doc_ventas { get; set; }
        public virtual doc_promociones_cm doc_promociones_cm { get; set; }
        public virtual cat_cargos_adicionales cat_cargos_adicionales { get; set; }
        public virtual doc_cargos_detalle doc_cargos_detalle { get; set; }
    }
}
