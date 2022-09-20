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
    
    public partial class doc_produccion_solicitud
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public doc_produccion_solicitud()
        {
            this.doc_produccion_solicitud_detalle = new HashSet<doc_produccion_solicitud_detalle>();
            this.doc_produccion1 = new HashSet<doc_produccion>();
        }
    
        public int ProduccionSolicitudId { get; set; }
        public int DeSucursalId { get; set; }
        public int ParaSucursalId { get; set; }
        public bool Completada { get; set; }
        public System.DateTime CreadoEl { get; set; }
        public int CreadoPor { get; set; }
        public bool Activa { get; set; }
        public Nullable<System.DateTime> FechaProgramada { get; set; }
        public Nullable<bool> Enviada { get; set; }
        public Nullable<bool> Iniciada { get; set; }
        public Nullable<System.DateTime> FechaInicioEjecucion { get; set; }
        public Nullable<System.DateTime> FechaFinEjecucion { get; set; }
        public Nullable<bool> Terminada { get; set; }
        public Nullable<bool> Aceptada { get; set; }
        public Nullable<int> DepartamentoId { get; set; }
        public Nullable<int> ProduccionId { get; set; }
    
        public virtual cat_sucursales cat_sucursales { get; set; }
        public virtual cat_sucursales cat_sucursales1 { get; set; }
        public virtual cat_usuarios cat_usuarios { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<doc_produccion_solicitud_detalle> doc_produccion_solicitud_detalle { get; set; }
        public virtual cat_departamentos cat_departamentos { get; set; }
        public virtual doc_produccion doc_produccion { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<doc_produccion> doc_produccion1 { get; set; }
    }
}
