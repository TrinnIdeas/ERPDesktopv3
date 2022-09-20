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
    
    public partial class cat_impuestos
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public cat_impuestos()
        {
            this.cat_productos_impuestos = new HashSet<cat_productos_impuestos>();
        }
    
        public int Clave { get; set; }
        public string CodigoSAT { get; set; }
        public string Descripcion { get; set; }
        public int IdAbreviatura { get; set; }
        public byte OrdenImpresion { get; set; }
        public int IdClasificacionImpuesto { get; set; }
        public int IdTipoFactor { get; set; }
        public Nullable<decimal> Porcentaje { get; set; }
        public Nullable<decimal> CuotaFija { get; set; }
        public Nullable<byte> DecimalesPorcCuota { get; set; }
        public Nullable<bool> DesglosarImpPrecioVta { get; set; }
        public Nullable<bool> AgregarImpPrecioVta { get; set; }
    
        public virtual cat_abreviaturas_SAT cat_abreviaturas_SAT { get; set; }
        public virtual cat_clasificacion_impuestos cat_clasificacion_impuestos { get; set; }
        public virtual cat_tipo_factor_SAT cat_tipo_factor_SAT { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<cat_productos_impuestos> cat_productos_impuestos { get; set; }
    }
}
