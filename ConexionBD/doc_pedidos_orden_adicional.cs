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
    
    public partial class doc_pedidos_orden_adicional
    {
        public int PedidoDetalleId { get; set; }
        public int AdicionalId { get; set; }
        public System.DateTime CreadoEl { get; set; }
        public int CreadoPor { get; set; }
    
        public virtual cat_rest_platillo_adicionales cat_rest_platillo_adicionales { get; set; }
        public virtual cat_usuarios cat_usuarios { get; set; }
        public virtual doc_pedidos_orden_detalle doc_pedidos_orden_detalle { get; set; }
    }
}
