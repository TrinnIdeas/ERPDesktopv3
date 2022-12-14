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
    
    public partial class doc_produccion_solicitud_detalle
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public doc_produccion_solicitud_detalle()
        {
            this.doc_produccion_solicitud_requerido = new HashSet<doc_produccion_solicitud_requerido>();
            this.doc_produccion_solicitud_ajuste_unidad = new HashSet<doc_produccion_solicitud_ajuste_unidad>();
            this.doc_produccion_solicitud_aceptacion = new HashSet<doc_produccion_solicitud_aceptacion>();
        }
    
        public int Id { get; set; }
        public int ProduccionSolicitudId { get; set; }
        public int ProductoId { get; set; }
        public int UnidadId { get; set; }
        public double Cantidad { get; set; }
        public System.DateTime CreadoEl { get; set; }
        public int CreadoPor { get; set; }
    
        public virtual cat_productos cat_productos { get; set; }
        public virtual cat_unidadesmed cat_unidadesmed { get; set; }
        public virtual doc_produccion_solicitud doc_produccion_solicitud { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<doc_produccion_solicitud_requerido> doc_produccion_solicitud_requerido { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<doc_produccion_solicitud_ajuste_unidad> doc_produccion_solicitud_ajuste_unidad { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<doc_produccion_solicitud_aceptacion> doc_produccion_solicitud_aceptacion { get; set; }
    }
}
