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
    
    public partial class cat_tipos_mermas
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public cat_tipos_mermas()
        {
            this.doc_inv_movimiento = new HashSet<doc_inv_movimiento>();
        }
    
        public short TipoMermaId { get; set; }
        public string Tipo { get; set; }
        public Nullable<System.DateTime> CreadoEl { get; set; }
    
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<doc_inv_movimiento> doc_inv_movimiento { get; set; }
    }
}
