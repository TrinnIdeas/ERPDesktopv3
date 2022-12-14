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
    
    public partial class doc_basculas_bitacora
    {
        public int Id { get; set; }
        public int BasculaId { get; set; }
        public int SucursalId { get; set; }
        public decimal Cantidad { get; set; }
        public System.DateTime Fecha { get; set; }
        public Nullable<int> TipoBasculaBitacoraId { get; set; }
        public Nullable<int> ProductoId { get; set; }
        public Nullable<int> PedidoDetalleId { get; set; }
        public string Detalle { get; set; }
        public Nullable<bool> Credito { get; set; }
    
        public virtual cat_basculas cat_basculas { get; set; }
        public virtual cat_sucursales cat_sucursales { get; set; }
        public virtual cat_tipos_bascula_bitacora cat_tipos_bascula_bitacora { get; set; }
        public virtual cat_productos cat_productos { get; set; }
        public virtual doc_pedidos_orden_detalle doc_pedidos_orden_detalle { get; set; }
    }
}
