class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  include SessionsHelper

  def obtener_numero_asiento(tipo)
    if tipo == "AS"
      @consecutivo = Consecutivo.find_by(as: false)
      @consecutivo.as = true
    else
      @consecutivo = Consecutivo.find_by(md: false)
      @consecutivo.md = true
    end
    @consecutivo.save
    return tipo + "-" + "%06d" % @consecutivo.contador_as + "-" + Time.now.year.to_s if tipo == "AS"
    return tipo + "-" + "%06d" % @consecutivo.contador_md + "-" + Time.now.year.to_s if tipo == "MD"
  end

  def borrar_objetos(child)
    unless child.nil? 
      child.each do |c|
        c.destroy
      end
    end
  end

  def deep_copy(objeto, hash, objeto_id)
    # clonar el pobjetosermiso y toda la jerarquía incluyendo los objetos anidados y los objetos ancestros
    # copiar objeto permiso
    # hash[:permiso] or hash[:consecion_publica], etc...
    neutro = hash
    tramite = objeto.new
    neutro.each do |key, val|
      unless key.include? "_attributes" or key == "servicio_habilitados" or key == "asiento" or key == "titulo_habilitante" or key == "frecuencia_espectro" or key == "zona"
        tramite[key] = val if key != "id"
      end
    end

    # copiar objeto espectro
    espectro = tramite.build_espectro
    neutro = hash[:espectro_attributes]
    neutro.each do |key, val|
      unless key.include? "_attributes" 
        espectro[key] = val if key != "id" and key != "asiento"
      end
    end if neutro

    # copiar objeto frecuencia_espectro
    frecuencias = hash[:espectro_attributes][:frecuencia_espectro_attributes]      
    unless frecuencias.nil? 
      frecuencias.each do |fn|
        frecuencia_espectro = tramite.espectro.frecuencia_espectro.new
        neutro = fn[1] 
        neutro.each do |key, val|
          unless key.include? "_attributes" 
            frecuencia_espectro[key] = val if key != "id"
          end
        end if neutro
        # copiar objeto zonas
        zonas = neutro[:zona_attributes]      
        zonas.each do |zonas|
          zona = frecuencia_espectro.zona.new
          neutro = zonas[1] 
          neutro.each do |key, val|
            zona[key] = val if key != "id"
          end if neutro
        end if zonas
      end if frecuencias
    end

    # copiar objeto titulo habilitante
    titulo_habilitante = tramite.espectro.build_titulo_habilitante
    neutro = hash[:espectro_attributes][:titulo_habilitante_attributes]
    neutro.each do |key, val|
      unless key.include? "_attributes" 
          titulo_habilitante[key] = val if key != "id"
      end
    end if neutro
    # copiar objeto servicios_habilitados
    servicios_habilitados = neutro[:servicio_habilitados_attributes]
    unless servicios_habilitados.nil? 
      servicios_habilitados.each do |sn|
        sci_servicio = titulo_habilitante.servicio_habilitados.new
        sn[1].each do |key, val|
          sci_servicio[key] = val if key != "id"
        end
      end
    end

    asiento = tramite.espectro.titulo_habilitante.build_asiento
    neutro = hash[:espectro_attributes][:asiento]
    #copiar objeto asiento
    neutro.each do |key, val|
      asiento[key] = val if key != "id"
    end if neutro

    #intercambiar llaves
	res = objeto.find(objeto_id).nil? rescue true 
	return {} if res 
    obj = objeto.find(objeto_id)

    if neutro[:tipo_asiento] == "MD"
      tramite.espectro.titulo_habilitante.asiento.num_asiento_original = obj.espectro.titulo_habilitante.asiento.num_asiento
      tramite.espectro.titulo_habilitante.asiento.num_asiento = obtener_numero_asiento("MD")
      tramite.espectro.titulo_habilitante.asiento.tipo_asiento = "MD"
      tramite.espectro.titulo_habilitante.asiento.tipo_inscripcion = "Modificación de Asiento"
      tramite.espectro.titulo_habilitante.asiento.acto_type = "TituloHabilitante"
      tramite.espectro.titulo_habilitante.asiento.acto_inscribible = obj.espectro.titulo_habilitante.asiento.acto_inscribible
     else
      tramite.espectro.titulo_habilitante.asiento.num_asiento_original = obj.espectro.titulo_habilitante.asiento.num_asiento_original
      tramite.espectro.titulo_habilitante.asiento.num_asiento = obj.espectro.titulo_habilitante.asiento.num_asiento
      tramite.espectro.titulo_habilitante.asiento.tipo_asiento = obj.espectro.titulo_habilitante.asiento.tipo_asiento
      tramite.espectro.titulo_habilitante.asiento.tipo_inscripcion = obj.espectro.titulo_habilitante.asiento.tipo_inscripcion
      tramite.espectro.titulo_habilitante.asiento.acto_type = obj.espectro.titulo_habilitante.asiento.acto_type
      tramite.espectro.titulo_habilitante.asiento.fecha_solicitud = obj.espectro.titulo_habilitante.asiento.fecha_solicitud
      tramite.espectro.titulo_habilitante.asiento.acto_inscribible = obj.espectro.titulo_habilitante.asiento.acto_inscribible

      #borrar objetos
      borrar_objetos(obj.espectro.titulo_habilitante.servicio_habilitados)
      obj.espectro.frecuencia_espectro.each do |f|
        borrar_objetos(f.zona)
      end
      borrar_objetos(obj.espectro.frecuencia_espectro)
      obj.espectro.titulo_habilitante.destroy
      obj.destroy
     end
    return tramite
 end

 def autorizacion_deep_copy(objeto, hash, objeto_id)
    # clonar el pobjetosermiso y toda la jerarquía incluyendo los objetos anidados y los objetos ancestros
    # copiar objeto permiso
    neutro = hash
    tramite = objeto.new
    neutro.each do |key, val|
      unless key.include? "_attributes" or key == "servicio_habilitados" or key == "asiento" or key == "titulo_habilitante" or key == "frecuencia_espectro" or key == "zona"
        tramite[key] = val if key != "id"
      end
    end

    # copiar objeto titulo habilitante
    titulo_habilitante = tramite.build_titulo_habilitante
    neutro = hash[:titulo_habilitante_attributes]
    neutro.each do |key, val|
      unless key.include? "_attributes" 
          titulo_habilitante[key] = val if key != "id"
      end
    end
    # copiar objeto servicios_habilitados
    servicios_habilitados = neutro[:servicio_habilitados_attributes]
    unless servicios_habilitados.nil? 
      servicios_habilitados.each do |sn|
        sci_servicio = titulo_habilitante.servicio_habilitados.new
        sn[1].each do |key, val|
          sci_servicio[key] = val if key != "id"
        end
      end
    end

    # copiar objeto zonas
    zonas = hash[:zona_attributes]
    unless zonas.nil? 
      zonas.each do |zn|
        zona = tramite.zona.new 
        zn[1].each do |key, val|
          zona[key] = val if key != "id"
        end
      end
    end

    asiento = tramite.titulo_habilitante.build_asiento
    neutro = hash[:asiento]
    #copiar objeto asiento
    neutro.each do |key, val|
      asiento[key] = val if key != "id"
    end

    #intercambiar llaves
    obj = objeto.find(objeto_id)
    if neutro[:tipo_asiento] == "MD"
      tramite.titulo_habilitante.asiento.num_asiento_original = obj.titulo_habilitante.asiento.num_asiento
      tramite.titulo_habilitante.asiento.num_asiento = obtener_numero_asiento("MD")
      tramite.titulo_habilitante.asiento.tipo_asiento = "MD"
      tramite.titulo_habilitante.asiento.tipo_inscripcion = "Modificación de Asiento"
      tramite.titulo_habilitante.asiento.acto_type = "TituloHabilitante"
      tramite.titulo_habilitante.asiento.fecha_solicitud = obj.titulo_habilitante.asiento.fecha_solicitud
      tramite.titulo_habilitante.asiento.acto_inscribible = obj.titulo_habilitante.asiento.acto_inscribible
    else
      tramite.titulo_habilitante.asiento.num_asiento_original = obj.titulo_habilitante.asiento.num_asiento_original
      tramite.titulo_habilitante.asiento.num_asiento = obj.titulo_habilitante.asiento.num_asiento
      tramite.titulo_habilitante.asiento.tipo_asiento = obj.titulo_habilitante.asiento.tipo_asiento
      tramite.titulo_habilitante.asiento.tipo_inscripcion = obj.titulo_habilitante.asiento.tipo_inscripcion
      tramite.titulo_habilitante.asiento.acto_type = obj.titulo_habilitante.asiento.acto_type
      tramite.titulo_habilitante.asiento.fecha_solicitud = obj.titulo_habilitante.asiento.fecha_solicitud
      tramite.titulo_habilitante.asiento.acto_inscribible = obj.titulo_habilitante.asiento.acto_inscribible

      #borrar objetos
      #borrar_objetos(obj.titulo_habilitante.asiento)
      borrar_objetos(obj.titulo_habilitante.servicio_habilitados)
      obj.titulo_habilitante.destroy
      obj.destroy
    end
    return tramite
 end

  def get_anatext_hash(file_name)
    the_hash = {}
    if !file_name.nil? and !file_name.empty?
       the_hash = File.open(file_name, "r") {|from_file| Marshal.load(from_file)}
    end
    return the_hash
  end

  def cargar_anatext(tramite, anatext_hash)
      tramite.acto_inscribible =  anatext_hash["asiento"]["acto_inscribible"]
      tramite.numero_resolucion =  anatext_hash["asiento"]["numero_resolucion"]
      tramite.titulo_resolucion =  anatext_hash["asiento"]["titulo_resolucion"]
      tramite.fecha_resolucion =  anatext_hash["asiento"]["fecha_resolucion"]
      tramite.num_expediente_sutel =  anatext_hash["asiento"]["num_expediente_sutel"]
      tramite.nombre_operador =  anatext_hash["asiento"]["nombre_operador"]
      tramite.identificacion_operador =  anatext_hash["asiento"]["identificacion_operador"]
      tramite.nombre_representante_legal =  anatext_hash["asiento"]["nombre_representante_legal"]
      tramite.cedula_representante_legal =  anatext_hash["asiento"]["cedula_representante_legal"]
      return tramite
  end

  def check_for_anatext(tramite)
    if !session[:anatext_file_name].nil? and !session[:anatext_file_name].empty?
      anatext_hash = {}
      anatext_hash = get_anatext_hash session[:anatext_file_name]
      tramite = cargar_anatext tramite, anatext_hash
      session[:anatext_file_name] = ""
      tramite
    end
  end

end
