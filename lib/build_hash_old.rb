#require './alchemyapi_ruby/entity'
require 'opencalais'
require 'chuncker'

def generar_hash

 def save_trace(myhash, n)
  f = File.open(n+'.out','w') 
  f.write(myhash.force_encoding("utf-8"))
 end

 def get_my_str(file_name)
  f = File.open(file_name) if File.exist?(file_name)
  my_str = ''
  my_str = f.read if !f.nil?
  my_str = my_str.encode("UTF-8", :invalid=>:replace, :replace=>"?").encode('UTF-8') if !f.nil?
  return my_str
 end

 def get_the_hash(my_arr)

   # get raw hash
   track_rhash = {}
   x = ""
   file_name = ""
   my_arr.each do |arr|
    file_name = arr.inspect.scan(/File:.*_\d{3}.txt/)[0].gsub(/File:/,"")
    f = File.open(file_name)
    my_str = ''
    my_str = f.read
    r = extraer my_str
    track_rhash[track_rhash.size+1] =  r
   end

   # get only entities from hash
   my_hash = {}
   track_rhash.each_value do |trh|
    trh.each_value do |e|
      clean_e = clean_regex e
      my_hash[my_hash.size+1] = clean_e if !clean_e.nil? and clean_e.split.size > 2
    end if trh != ""
   end

   # discard entities by text size
   #my2hash = {}
   #my_hash.each_value do |e|
   # my2hash[my2hash.size+1] = e if e["text"].split.size >2
   #end
   return my_hash
 end

 def get_alchemy(file_name)
   the_hash = {}
   #results = extraer(search_string) if !search_string.nil?
   the_hash = chunker file_name, file_name.gsub(/\D+\//,""), 21000
   the_hash = get_the_hash the_hash 

   #the_hash = get_mhash('./mhash.out')
   #the_hash = get_this_hash
   
   #optimize the_hash
   mhash = the_hash
   s = get_my_str(file_name)
   s = clean_regex s
   my_s = s
   #text_hash = get_only_text mhash
   text_hash = mhash
   r = get_ranking s, text_hash
   proximity_hash = get_proximity_hash r, text_hash
   ranked_hash = get_ranked_hash proximity_hash
   unique_hash = ranked_hash #get_unique_hash ranked_hash
   return unique_hash
 end

  def get_regex
    return /[\?\<\>\'\,\?\.\[\]\}\{\=\-\)\(\*\&\^\%\$\#\`\~\{\}]/
  end

  def clean_regex(s)
   s = s.encode("UTF-8", :invalid=>:replace, :replace=>"?").encode('UTF-8')
   my_s = s
   my_s = my_s.encode("UTF-8", :invalid=>:replace, :replace=>"?").encode('UTF-8')
   loop do
    caracter = my_s =~ get_regex
    break if caracter.nil?
      get_rid_of = my_s[caracter]
      my_s.gsub!(get_rid_of,"")
    end
    return my_s
  end

 def get_unique_hash(the_hash)
  unique_hash = the_hash.sort_by {|v| v[1]}.inject([]) {|m,e| m.last.nil? ? [e] : m.last[1] == e[1] ? m : m << e}
  return unique_hash.sort.to_h
 end

 def get_ranked_hash(the_hash)
  sorted = {}
  the_hash.inject({}) do |h, (k, v)|
    if !sorted.has_value?(v["valor"])
      sorted[v["rank"]] = v["valor"]
      #sorted[v["rank"]+k] = v["valor"] if sorted.has_key?(v["rank"]) if !k.nil?
    end
  end
  return sorted
 end

 def get_proximity_hash(r, the_hash)
  # algoritmo de proximidad de valores dentro del texto
  sorted_hash = {}
  the_hash.each_value do |m|
     indice = sorted_hash.size+1
     sorted_hash[indice] = {}
     sorted_hash[indice]["rank"] = {}
     sorted_hash[indice]["valor"] = {}
     resultado = []
     resultado << find_first(r, m)
     sorted_hash[indice]["rank"] = resultado[0][0] if !resultado[0].nil?
     sorted_hash[indice]["valor"] = resultado[0][1] if !resultado[0].nil?
  end
  return sorted_hash
 end

 def get_only_text the_hash
  mhash = {}
  the_hash.each do |v|
     mhash[mhash.size+1] = v[1]["text"]
  end
  return mhash
 end

 def get_hash(file_name)
   result_hash = get_alchemy file_name
   return_hash = get_casillas result_hash
   search_string = get_search_string file_name
   return_hash[:identificacion_operador] = {}
   return_hash[:identificacion_operador][0] = ".No Aplica"
   return_hash.merge!(get_cedulas_juridicas(search_string))
   return_hash[:cedula_representante_legal] = {}
   return_hash[:cedula_representante_legal][0] = ".No Aplica"
   return_hash.merge!(get_cedulas_fisicas(search_string))
   return_hash[:fecha_resolucion] = {}
   return_hash[:fecha_resolucion][0] = ".No Aplica"
   return_hash.merge!(get_fechas(search_string))
   return_hash[:numero_resolucion] = {}
   return_hash[:numero_resolucion][0] = ".No Aplica"
   return_hash.merge!(get_numero_resolucion(search_string))
   return_hash[:numero_acuerdo_ejecutivo] = {}
   return_hash[:numero_acuerdo_ejecutivo][0] = ".No Aplica"
   return_hash.merge!(get_numero_acuerdo_ejecutivo(search_string))
   return_hash[:titulo_resolucion] = {}
   return_hash[:titulo_resolucion][0] = ".No Aplica"
   return_hash.merge!(get_titulo_resolucion(search_string))
   return_hash[:tipo_tramite] = {}
   return_hash[:tipo_tramite][0] = ".Seleccionar Tipo Tramite"
   return_hash.merge!(get_tipo_tramite(search_string))
   # clean up txt files
   r = system('rm *.txt')
   return_hash
 end

 def get_casillas(the_hash)
   my_hash = {}
   my_hash[:nombre_operador] = {}
   my_hash[:nombre_operador][0] = ".No Aplica"
   my_hash[:nombre_representante_legal] = {}
   my_hash[:nombre_representante_legal][0] = ".No Aplica"
   return my_hash if the_hash.nil?
   the_hash.each do |e|
     my_hash[:nombre_operador][my_hash[:nombre_operador].count+1] =  e[1]
     my_hash[:nombre_representante_legal][my_hash[:nombre_representante_legal].count+1] =  e[1]
   end
   return my_hash
 end

 def get_numero_resolucion(search_string)
  resultado_arr = []
  my_hash = {}
  my_hash[-1] = ".No Aplica"
  return my_hash if search_string.nil?
  search_string = search_string.encode("UTF-8", :invalid=>:replace, :replace=>"?").encode('UTF-8')
  search_string.scan(/RCS\D+\d+\D+\d{4}/i).each do |v|
      resultado_arr << v if !resultado_arr.include?(v)
  end
  search_string.scan(/Acuerdo Ejecu\D+\d+\D+\d{4}/i).each do |v|
      resultado_arr << v if !resultado_arr.include?(v)
  end
  sorted_resultado = resultado_arr.sort_by {|v| v.scan(/\d{4}/)}.reverse
  context_resultado = add_contexto search_string, sorted_resultado
  my_hash = {}
  my_hash[-1] = ".No Aplica"
  my_hash_temp = convert_num_resolucion_to_hash context_resultado 
  my_hash.merge!(my_hash_temp)
  return my_hash
 end

 def get_numero_acuerdo_ejecutivo(search_string)
  resultado_arr = []
  my_hash = {}
  my_hash[-1] = ".No Aplica"
  return my_hash if search_string.nil?
  search_string = search_string.encode("UTF-8", :invalid=>:replace, :replace=>"?").encode('UTF-8')
  search_string.scan(/Acuerdo Ejecu\D+\d+\D+\d{4}/i).each do |v|
      resultado_arr << v if !resultado_arr.include?(v)
  end
  sorted_resultado = resultado_arr.sort_by {|v| v.scan(/\d{4}/)}.reverse
  context_resultado = add_contexto search_string, sorted_resultado
  my_hash = {}
  my_hash[-1] = ".No Aplica"
  my_hash_temp = convert_num_acuerdo_to_hash context_resultado 
  my_hash.merge!(my_hash_temp)
  return my_hash
 end

 def get_titulo_resolucion(search_string)
  my_arr = []
  my_hash = {}
  return my_hash if search_string.nil?
  search_string = search_string.encode("UTF-8", :invalid=>:replace, :replace=>"?").encode('UTF-8')
  search_string.scan(/".*"/).each {|x| x if x.size < 200 and x.split.size > 1}.each do |v|
    my_arr << v
  end
  context_resultado = add_contexto search_string, my_arr
  my_hash = convert_titulo_resolucion_to_hash context_resultado
  return my_hash
 end

 def convert_titulo_resolucion_to_hash(my_arr)
   my_hash = {}
   my_hash[:titulo_resolucion] = {}
   return my_hash if my_arr.nil?
   my_arr.each do |v|
     my_hash[:titulo_resolucion][my_hash[:titulo_resolucion].size+1] = v.gsub(/\"/,"")
   end
   return my_hash
 end

 def convert_num_acuerdo_to_hash(my_arr)
   my_hash = {}
   my_hash[:numero_acuerdo_ejecutivo] = {}
   return my_hash if my_arr.nil?
   my_arr.each do |v|
     my_hash[:numero_acuerdo_ejecutivo][my_hash[:numero_acuerdo_ejecutivo].size+1] = v
   end
   return my_hash
 end

 def convert_num_resolucion_to_hash(my_arr)
   my_hash = {}
   my_hash[:numero_resolucion] = {}
   return my_hash if my_arr.nil?
   my_arr.each do |v|
     my_hash[:numero_resolucion][my_hash[:numero_resolucion].size+1] = v
   end
   return my_hash
 end

 def add_contexto(search_string, my_str)
  my_result = []
  return my_result if search_string.nil?
  search_string = search_string.encode("UTF-8", :invalid=>:replace, :replace=>"?").encode('UTF-8')
  my_str.each do |x|
      y = clean_regex x
      my_search = search_string.scan(/.{50}#{y}.{50}/)[0]
      my_search = search_string.scan(/.{50}#{y}.{25}/)[0] if my_search.nil?
      my_search = search_string.scan(/.{50}#{y}/)[0] if my_search.nil?
      my_search = search_string.scan(/.{30}#{y}/)[0] if my_search.nil?
      my_search = search_string.scan(/#{y}/)[0] if my_search.nil?
      my_search = "" if my_search.nil?
      my_result << y+"  ->  "+ my_search if y.split.size > 1
  end
  return my_result
 end

 def get_cedulas_juridicas(search_string)
   my_hash = {}
   my_hash[:identificacion_operador] = {}
   return my_hash if search_string.nil?
   search_string = search_string.encode("UTF-8", :invalid=>:replace, :replace=>"?").encode('UTF-8')
   mis_cedulas = get_array_cedulas_juridicas(search_string)
   mis_cedulas.each do |c|
     my_hash[:identificacion_operador][my_hash[:identificacion_operador].count+1] =  c if c.size >= 10 and c.include?("-") and !my_hash[:identificacion_operador].has_value?(c)
   end
   my_hash
 end

 def get_cedulas_fisicas(search_string)
   my_hash = {}
   my_hash[:cedula_representante_legal] = {}
    return my_hash if search_string.nil?
    search_string = search_string.encode("UTF-8", :invalid=>:replace, :replace=>"?").encode('UTF-8')
   mis_cedulas = get_array_cedulas_fisicas(search_string)
   mis_cedulas.each do |c|
     my_hash[:cedula_representante_legal][my_hash[:cedula_representante_legal].count+1] =  c if c.size >= 8 and c.include?("-") and !my_hash[:cedula_representante_legal].has_value?(c)
   end
   search_string.scan(/\bpasaporte\D*\d*\b/i).each do |sc|
     my_hash[:cedula_representante_legal][my_hash[:cedula_representante_legal].count+1] = sc
   end
   my_hash
 end

 def get_fechas(search_string)
   my_hash = {}
   my_hash[:fecha_resolucion] = {}
   my_hash[:fecha_resolucion][0] = ".No Aplica"
   return my_hash if search_string.nil?
   search_string = search_string.encode("UTF-8", :invalid=>:replace, :replace=>"?").encode('UTF-8')
   mis_fechas = get_array_fechas(search_string)
   mis_fechas.each do |c|
     #c.each do |c2|
       my_hash[:fecha_resolucion][my_hash[:fecha_resolucion].count+1] =  c[1]
     #end
   end
   my_hash
 end

 def get_array_cedulas_juridicas(search_string)
   s = []
   search_string = search_string.encode("UTF-8", :invalid=>:replace, :replace=>"?").encode('UTF-8')
   search_string.scan(/3\D{1,5}[0-9]{3,4}\D{1,5}[0-9]{3,4}/).each do |v|
     s << v if v.size < 50
   end
   return s
 end

 def get_array_cedulas_fisicas(search_string)
   s = []
   return s if search_string.nil?
   search_string = search_string.encode("UTF-8", :invalid=>:replace, :replace=>"?").encode('UTF-8')
   search_string.scan(/[1-9]\D{1,5}[0-9]{3,4}\D{1,5}[0-9]{3,4}/).each do |v|
     s << v if v.size < 50
   end
   return s
 end

 def get_search_string(file_name)
   f = File.open(file_name) if File.exist?(file_name)
   r = ""
   r = f.read if !f.nil?
 end

 def get_array_fechas(search_string)
  r = {}
  return r if search_string.nil?
  search_string = search_string.encode("UTF-8", :invalid=>:replace, :replace=>"?").encode('UTF-8')
  ["enero","febrero","marzo","abril","mayo","junio","julio","agosto","setiembre","octubre","noviembre","diciembre"].each do |mes|
    r[r.size+1] = search_string.scan(/\b\d+\D*#{mes}\D*\d+\b/i).flatten
  end
  flattened_r = flatten_fechas(r)
  sorted_r = flattened_r.sort_by {|v| v[1].scan(/\d{4}/)}.reverse
  resultado_r = add_fechas_contexto search_string, sorted_r
  return resultado_r
 end

 def add_fechas_contexto(search_string, my_arr)
  return my_arr if search_string.nil?
  search_string = search_string.encode("UTF-8", :invalid=>:replace, :replace=>"?").encode('UTF-8')
  my_arr.each do |f|
    f[1] = f[1] + " -> "+ search_string.scan(/.{50}#{f[1]}.{50}/)[0] if !search_string.scan(/.{50}#{f[1]}.{50}/)[0].nil?
  end
  return my_arr
 end

 def flatten_fechas(my_arr)
  flattened = {}
  my_arr.each do |x|
    x[1].each do |y|
      flattened[flattened.size+1] = y
    end
  end
  return flattened
 end

 def get_tipo_tramite(search_string)
   search_string = search_string.encode("UTF-8", :invalid=>:replace, :replace=>"?").encode('UTF-8') if !search_string.nil?
   search_string = "" if search_string.nil?
   if search_string.scan(/espectro/i).count > 0 
      my_arr = 
	[
      ["new_norma",".Seleccionar Tipo de Tramite"],
      ["new_concesion_direct","Titulo Habilitante - Conseciones Directas"],
      ["new_consecion_publica","Titulo Habilitante - Conseciones Concurso Público"],
      ["new_consecion_anterior","Titulo Habilitante - Conseciones Anterior a la Ley"],
      ["new_permiso","Titulo Habilitante - Espectro - Permiso"],
      ["new_autorizacion","Titulo Habilitante - Autorizaciones"],
      ["new_arbitro","Acreditación Arbitros/Peritos"],
      ["new_acuerdo_acceso_interconexion","Acuerdo Acceso e Interconexión"],
      ["new_contrato_adhesion","Contrato Adhesión"],
      ["new_convenio_privado","Convenio Privado para el intercambio de tráfico internacional"],
      ["new_convenio_internacional","Convenio Internacional"],
      ["new_convenio_ubicacion_equipo","Convenio Ubicación Equipos"],
      ["new_homologacion","Lista de Homologación Equipos"],
      ["new_fonatel","Informe Fonatel"],
      ["new_lab","Laboratorio"],
      ["new_norma","Norma y Estándar de Calidad"],
      ["new_oferta_interconexion","Oferta Interconexión"],
      ["new_orden_acceso_interconexion","Orden Acceso Interconexión"],
      ["new_reglamento_tecnico","Reglamentos Técnicos"],
      ["new_recurso_numerico","Recurso de Numeración"],
      ["new_resolucion_ubicacion_equipo","Resoluciónes sobre Ubicación de Equipos, colocación y el suo compartido de infraestructuras físicas"],
      ["new_sancion","Sanción Impuesta por resolución en firme"],
      ["new_precios_tarifa","Aprobación de Precios y Tarifas"]
	]
   else
      my_arr = 
	[
      ["new_norma",".Seleccionar Tipo de Tramite"],
      ["new_arbitro","Acreditación Arbitros/Peritos"],
      ["new_acuerdo_acceso_interconexion","Acuerdo Acceso e Interconexión"],
      ["new_precios_tarifa","Aprobación de Precios y Tarifas"],
      ["new_contrato_adhesion","Contrato Adhesión"],
      ["new_convenio_privado","Convenio Privado para el intercambio de tráfico internacional"],
      ["new_convenio_internacional","Convenio Internacional"],
      ["new_convenio_ubicacion_equipo","Convenio Ubicación Equipos"],
      ["new_homologacion","Lista de Homologación Equipos"],
      ["new_fonatel","Informe Fonatel"],
      ["new_lab","Laboratorio"],
      ["new_norma","Norma y Estándar de Calidad"],
      ["new_oferta_interconexion","Oferta Interconexión"],
      ["new_orden_acceso_interconexion","Orden Acceso Interconexión"],
      ["new_reglamento_tecnico","Reglamentos Técnicos"],
      ["new_recurso_numerico","Recurso de Numeración"],
      ["new_resolucion_ubicacion_equipo","Resoluciónes sobre Ubicación de Equipos, colocación y el suo compartido de infraestructuras físicas"],
      ["new_sancion","Sanción Impuesta por resolución en firme"],
      ["new_autorizacion","Titulo Habilitante - Autorizaciones"],
      ["new_concesion_direct","Titulo Habilitante - Conseciones Directas"],
      ["new_consecion_publica","Titulo Habilitante - Conseciones Concurso Público"],
      ["new_consecion_anterior","Titulo Habilitante - Conseciones Anterior a la Ley"],
      ["new_permiso","Titulo Habilitante - Espectro - Permiso"]
	]
   end
   my_hash = convert_tipo_tramite_to_hash my_arr
   return my_hash
 end
 
 def convert_tipo_tramite_to_hash(my_arr)
   my_hash = {}
   my_hash[:tipo_tramite] = {}
   my_arr.each do |v|
     my_hash[:tipo_tramite][my_hash[:tipo_tramite].size+1] = v[0]+": "+v[1]
   end
   return my_hash
 end

 def scan_my_str(my_s, st)
     my_arr = []
	 return my_arr if my_s.nil?
	 my_s = my_s.encode("UTF-8", :invalid=>:replace, :replace=>"?").encode('UTF-8')
     last_match = 0
     my_s.scan(/#{st}/).each_with_index do |a,b|
       match = my_s.index("#{a}",last_match)
       last_match = match+a.size+1
       my_arr << match
     end
     return my_arr
 end

  def min_distance(a_arr, b_arr, st, st2)
      dif_arr = []
      a_arr.each do |a|
        b_arr.each do |b|
          off_set = 0
          off_set = st.size if b>a
          off_set = st2.size if a<b
          dif_arr << (a-b).abs - off_set
        end
      end
      return dif_arr.sort[0]
  end

  def get_ranking(s, mhash)
     mranking = {}
     mhash.each_value do |a|
       mhash.each_value do |b|
         a_arr = scan_my_str s, a
         b_arr = scan_my_str s, b
         indice = min_distance a_arr, b_arr, a, b
         mranking[indice] = {}
         mranking[indice]["a"] = a
         mranking[indice]["b"] = b
       end
     end
     return mranking
  end

  def find_first(r, search_string)
    r2 = {}    
	return r2 if search_string.nil?
	search_string = search_string.encode("UTF-8", :invalid=>:replace, :replace=>"?").encode('UTF-8')
    r.each_pair do |k1, v1|
      v1.each_pair do |k2, v2|
        r2[rand(10..1000)] = v2+" -> "+v1["b"] if v2 == search_string and v1["b"] != v2 and k1.nil?
        r2[k1] = v2+" -> "+v1["b"] if v2 == search_string and v1["b"] != v2 if !k1.nil?
      end
    end
    return r2.sort[0]
  end

  def get_this_hash
    mh = {1=>{"type"=>"PrintMedia", "relevance"=>"0.335687", "count"=>"8", "text"=>"Diario Oficial La Gaceta"}, 2=>{"type"=>"Person", "relevance"=>"0.299669", "count"=>"2", "text"=>"Manuel Antonio Gonzalez Sanz"}, 3=>{"type"=>"Person", "relevance"=>"0.296145", "count"=>"1", "text"=>"Gloriana Monge Munoz"}, 4=>{"type"=>"Organization", "relevance"=>"0.290309", "count"=>"2", "text"=>"Gerencia de Concesiones"}, 5=>{"type"=>"FieldTerminology", "relevance"=>"0.266445", "count"=>"1", "text"=>"Servicios de Telecomunicaciones Moviles"}, 6=>{"type"=>"Person", "relevance"=>"0.261768", "count"=>"1", "text"=>"Jorge Alberto Garcfa Cabezas"}, 7=>{"type"=>"Organization", "relevance"=>"0.25935", "count"=>"1", "text"=>"Superintendencia de Telecomunicaciones"}, 8=>{"type"=>"PrintMedia", "relevance"=>"0.258537", "count"=>"2", "text"=>"Diario Oficial La"}, 9=>{"type"=>"Person", "relevance"=>"0.256866", "count"=>"1", "text"=>"Alcance N° 90"}, 10=>{"type"=>"Person", "relevance"=>"0.256623", "count"=>"1", "text"=>"Alcance N° 44"}, 11=>{"type"=>"Person", "relevance"=>"0.253866", "count"=>"1", "text"=>"Licitacibn Pdblica N°"}, 12=>{"type"=>"Company", "relevance"=>"0.249102", "count"=>"1", "text"=>"CLARO CR TELECOMUNICACIONES"}, 13=>{"type"=>"Person", "relevance"=>"0.242538", "count"=>"2", "text"=>"Luis Alberto Cascante Alvarado"}, 14=>{"type"=>"Person", "relevance"=>"0.241749", "count"=>"1", "text"=>"S. A. Adicionalmente"}, 15=>{"type"=>"Person", "relevance"=>"0.241519", "count"=>"1", "text"=>"Ricardo Josh Taylor Cap6n"}, 16=>{"type"=>"TelevisionStation", "relevance"=>"0.334366", "count"=>"1", "text"=>"UKY 210 72/SC15"}, 17=>{"type"=>"TelevisionStation", "relevance"=>"0.343139", "count"=>"1", "text"=>"UKY 210 72/SC15"}, 18=>{"type"=>"Organization", "relevance"=>"0.256461", "count"=>"5", "text"=>"del Consejo SUTEL"}, 19=>{"type"=>"Company", "relevance"=>"0.253253", "count"=>"1", "text"=>"CLARO CR TELECOMUNICACIONES"}, 20=>{"type"=>"Person", "relevance"=>"0.25163", "count"=>"1", "text"=>"Decreto Ejecutivo N° 34765-MINAET"}, 21=>{"type"=>"Person", "relevance"=>"0.251293", "count"=>"2", "text"=>"Decreto Ejecutivo N° 34765"}, 22=>{"type"=>"FieldTerminology", "relevance"=>"0.250056", "count"=>"1", "text"=>"Telecomunicaciones M6viles Internacionales"}, 23=>{"type"=>"Company", "relevance"=>"0.785379", "count"=>"12", "text"=>"CLARO CR TELECOMUNICACIONES, S.A."}, 24=>{"type"=>"Organization", "relevance"=>"0.31966", "count"=>"3", "text"=>"Resoluci6n N° RCS"}, 25=>{"type"=>"Technology", "relevance"=>"0.313144", "count"=>"2", "text"=>"P6blica N° 2010LI"}, 26=>{"type"=>"Company", "relevance"=>"0.262692", "count"=>"1", "text"=>"CLARO CR TELECOMUNICACIONES,S.A.,porelmediosenaladodentrodelexpediente"}, 27=>{"type"=>"Organization", "relevance"=>"0.243153", "count"=>"1", "text"=>"del Sector Telecomunicaciones"}, 28=>{"type"=>"Organization", "relevance"=>"0.232632", "count"=>"1", "text"=>"Instituto Costarricense de Electricidad"}, 29=>{"type"=>"Organization", "relevance"=>"0.232093", "count"=>"1", "text"=>"del Consejo de la SUTEL"}, 30=>{"type"=>"Organization", "relevance"=>"0.207372", "count"=>"1", "text"=>"del Consejo de la Superintendencia de Telecomunicaciones del"}}
    mh
  end
end
