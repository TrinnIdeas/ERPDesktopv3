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
    
    public partial class doc_inventario_captura
    {
        public int Id { get; set; }
        public int SucursalId { get; set; }
        public int ProductoId { get; set; }
        public decimal Cantidad { get; set; }
        public int CreadoPor { get; set; }
        public System.DateTime CreadoEl { get; set; }
        public bool Cerrado { get; set; }
    
        public virtual cat_productos cat_productos { get; set; }
        public virtual cat_sucursales cat_sucursales { get; set; }
        public virtual cat_usuarios cat_usuarios { get; set; }
    }
}
