class OperadorRegulado < ActiveRecord::Base

  def to_json
    json = "{"
    json += "\"id\": \"#{self.id}\""
    json += ",\"nombre\": \"#{self.nombre}\""
    json += ",\"identificacion\": \"#{self.identificacion}\""
    json += ",\"codigo_operador\": \"#{self.codigo_operador}\""
    json += ",\"nombre_representante_legal\": \"#{self.nombre_representante_legal}\""
    json += ",\"cedula_representante_legal\": \"#{self.cedula_representante_legal}\""
    json += "}"
  end
end
