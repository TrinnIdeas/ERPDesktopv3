﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ConexionBD.Utilerias;
using System.Data;

namespace ConexionBD
{
    public class DivisionesSatInterface
    {
        Business con;
        Resultado resultado;

        public DivisionesSatInterface()
        {
            con = new Business();
        }

        public DataTable ConsultarListado(string busqueda)
        {
            string comandoSelect = "", tabla = "";
            resultado = new Resultado();

            DataTable dt = new DataTable();
            try
            {
                comandoSelect = "select Clave,CodigoSAT as[Codigo SAT], Descripcion as [Nombre División] from cat_divisiones_sat ";
                int clave = 0;
                if (int.TryParse(busqueda, out clave))
                {
                    comandoSelect = comandoSelect + "where " + clave + " = 0 or Clave = " + clave;
                }
                else
                {
                    if (busqueda != "")
                        comandoSelect = comandoSelect + "where Descripcion like '%" + busqueda + "%'";
                }

                tabla = "DivisionesSat";

                dt = con.Select(comandoSelect, tabla);
            }
            catch (Exception ex)
            {
                resultado.ok = false;
                resultado.mensaje = "Ocurrió un error al tratar de consultar los datos. " + ex.Message;
            }
            return dt;
        }

        public DataTable ConsultarRegistro(int clave, bool verificarNoExistaClave)
        {
            string comandoSelect = "", tabla = "";
            resultado = new Resultado();

            DataTable dt = new DataTable();
            try
            {
                comandoSelect = "select Clave,CodigoSAT as [Codigo SAT], Descripcion as [Nombre División], Estatus "
                                + "from cat_divisiones_sat "
                                + "where Clave " + (verificarNoExistaClave ? "!" : "") + "= " + clave;

                tabla = "DivisionesSat";

                dt = con.Select(comandoSelect, tabla);
            }
            catch (Exception ex)
            {
                resultado.ok = false;
                resultado.mensaje = "Ocurrió un error al tratar de consultar el registro. " + ex.Message;
            }
            return dt;
        }

        public Resultado Agregar(int clave,string claveSAT, string descripcion, bool estatus, int? empresa, int? sucursal)
        {
            resultado = new Resultado();
            string comandoInsert = "";
            string strEmpresa = empresa == null ? "null" : empresa.ToString();
            string strSucursal = sucursal == null ? "null" : sucursal.ToString();
            try
            {
                comandoInsert = "insert into cat_divisiones_sat "
                                + "(Clave, Descripcion, Estatus, Empresa, Sucursal,codigoSAT) "
                                + "values(" + clave + ", '" + descripcion + "', " + (estatus ? 1 : 0) + ", " + strEmpresa + ", " + strSucursal +",'"+ claveSAT+ "')";
                resultado = con.Insert(comandoInsert);
            }
            catch (Exception ex)
            {
                resultado.ok = false;
                resultado.mensaje = "Ocurrió un error al tratar de insertar los datos. " + ex.Message;
            }

            return resultado;
        }

        public Resultado Actualizar(int clave,string claveSAT, string descripcion, bool estatus)
        {
            resultado = new Resultado();
            string comandoUpdate = "";
            try
            {
                comandoUpdate = "update cat_divisiones_sat "
                                + "set Descripcion = '" + descripcion + "', Estatus = " + (estatus ? 1 : 0) + ",CodigoSAT= '" + claveSAT +"' "
                                + " where Clave = " + clave;
                resultado = con.Update(comandoUpdate);
            }
            catch (Exception ex)
            {
                resultado.ok = false;
                resultado.mensaje = "Ocurrió un error al tratar de actualizar los datos. " + ex.Message;
            }
            return resultado;
        }

        public Resultado Eliminar(int clave)
        {
            resultado = new Resultado();
            string comandoDelete = "";
            try
            {
                comandoDelete = string.Format("delete from cat_divisiones_sat where Clave = {0}", clave);
                resultado = con.Delete(comandoDelete);
            }
            catch (Exception ex)
            {
                resultado.ok = false;
                resultado.mensaje = "Ocurrió un error al tratar de eliminar los datos. " + ex.Message;
            }
            return resultado;
        }

        #region ComboBox

        public DataTable ConsultaComboBox()
        {
            string comandoSelect = "", tabla = "";
            resultado = new Resultado();

            DataTable dt = new DataTable();
            try
            {
                comandoSelect = "select Clave, Descripcion from cat_divisiones_sat where Estatus = 1";
                tabla = "DivisionesSat";

                dt = con.Select(comandoSelect, tabla);
            }
            catch (Exception ex)
            {
                resultado.ok = false;
                resultado.mensaje = "Ocurrió un error al tratar de consultar los datos. " + ex.Message;
            }

            return dt;
        }

        #endregion
    }
}
