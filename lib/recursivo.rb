def recursively_search_asientos(param_asiento, lista_ids = [])
  if param_asiento.nil? or param_asiento.empty? or (!lista_ids.nil? and lista_ids.size == 50)
    return param_asiento
  else
    asiento = Asiento.find_by(:num_asiento_original => param_asiento)
    lista_ids.push(asiento.id) if !asiento.nil? and !lista_ids.nil?
    recursively_search_asientos(asiento.num_asiento, lista_ids) if !asiento.nil? and asiento.num_asiento != asiento.num_asiento_original
  end
end
