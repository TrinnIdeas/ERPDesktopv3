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
    
    public partial class doc_pedidos_orden_cargos
    {
        public int PedidoId { get; set; }
        public short CargoAdicionalId { get; set; }
        public System.DateTime CreadoEl { get; set; }
    
        public virtual cat_cargos_adicionales cat_cargos_adicionales { get; set; }
        public virtual doc_pedidos_orden doc_pedidos_orden { get; set; }
    }
}
