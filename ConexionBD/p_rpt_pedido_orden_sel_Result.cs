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
    
    public partial class p_rpt_pedido_orden_sel_Result
    {
        public int PedidoId { get; set; }
        public string Folio { get; set; }
        public string Cliente { get; set; }
        public string Direccion { get; set; }
        public System.DateTime FechaPedido { get; set; }
        public string ClaveProducto { get; set; }
        public string Producto { get; set; }
        public decimal Cantidad { get; set; }
        public decimal Precio { get; set; }
        public decimal Total { get; set; }
        public Nullable<decimal> Devolucion { get; set; }
    }
}
