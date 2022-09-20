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
    
    public partial class doc_promociones
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public doc_promociones()
        {
            this.doc_promociones_detalle = new HashSet<doc_promociones_detalle>();
            this.doc_promociones_excepcion = new HashSet<doc_promociones_excepcion>();
        }
    
        public int PromocionId { get; set; }
        public System.DateTime FechaRegistro { get; set; }
        public decimal PorcentajeDescuento { get; set; }
        public System.DateTime FechaInicioVigencia { get; set; }
        public System.DateTime FechaFinVigencia { get; set; }
        public int CreadoPor { get; set; }
        public int EmpresaId { get; set; }
        public int SucursalId { get; set; }
        public bool Activo { get; set; }
        public string NombrePromocion { get; set; }
        public Nullable<bool> Lunes { get; set; }
        public Nullable<bool> Martes { get; set; }
        public Nullable<bool> Miercoles { get; set; }
        public Nullable<bool> Jueves { get; set; }
        public Nullable<bool> Viernes { get; set; }
        public Nullable<bool> Sabado { get; set; }
        public Nullable<bool> Domingo { get; set; }
        public Nullable<bool> Permanente { get; set; }
    
        public virtual cat_empresas cat_empresas { get; set; }
        public virtual cat_sucursales cat_sucursales { get; set; }
        public virtual cat_usuarios cat_usuarios { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<doc_promociones_detalle> doc_promociones_detalle { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<doc_promociones_excepcion> doc_promociones_excepcion { get; set; }
    }
}
