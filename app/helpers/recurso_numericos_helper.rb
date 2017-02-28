module RecursoNumericosHelper
  def nombre_operador
    if !@recurso_numerico.asiento.operadorregulado_id.nil? then 
       @operadores.find(@recurso_numerico.asiento.operadorregulado_id) 
    else
      :nombre_operador
    end
  end
end
