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
    
    public partial class cat_rest_comandas
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public cat_rest_comandas()
        {
            this.doc_pedidos_orden = new HashSet<doc_pedidos_orden>();
            this.doc_pedidos_orden_detalle = new HashSet<doc_pedidos_orden_detalle>();
        }
    
        public int ComandaId { get; set; }
        public int SucursalId { get; set; }
        public int Folio { get; set; }
        public bool Disponible { get; set; }
        public int CreadoPor { get; set; }
        public System.DateTime CreadoEl { get; set; }
    
        public virtual cat_sucursales cat_sucursales { get; set; }
        public virtual cat_usuarios cat_usuarios { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<doc_pedidos_orden> doc_pedidos_orden { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<doc_pedidos_orden_detalle> doc_pedidos_orden_detalle { get; set; }
    }
}
