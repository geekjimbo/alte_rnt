module ApplicationHelper

  def full_title(page_title = '')
    base_title = "RNT app"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  def busqueda_historica(nodo)
    if !nodo.nil?
      session[:historico] = nodo.num_asiento
      return asientos_path
    else
      session[:historico] = ""
      return asientos_path
    end
  end

  def resolve_poly_path(nodo)
    def edit_padre_path(nodo)
       my_id = nodo.id.to_s
       "/"+ nodo.class.name.underscore.pluralize + "/" + my_id + "/edit"
    end

    if nodo.acto_type != "TituloHabilitante"
      edit_polymorphic_path(nodo.acto) 
    else
      padre = nodo.acto 
      return edit_padre_path(padre.espectrable) if padre.espectrable_type != "Espectro" #nivel autorizacion
      return edit_padre_path(padre.espectrable.titulo) if padre.espectrable_type == "Espectro"
      return "" if padre.nil? or padre.espectrable.nil? or padre.espectrable.titulo.nil? #para que no falle devuelva un blanco
    end
  end

  def link_to_add_fields(name, f, association)
    new_object = get_new_object(f,association) #if association != :zona
    if association != :servicios_interconexion and association != :servicio_contrato_adhesions and association != :oferta_interconexion_servicios
      fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
        s = ""
        s = render("servicios_habilitados", :f=> builder) if association == :servicio_habilitados
        s = render("shared/frecuencias", :f=> builder) if association == :frecuencia_espectro
        s = render("shared/zonas", :f=> builder) if association == :zona
        s 
      end
    end

    #debugger
    fields = "" if fields.nil?
    old_fields = fields
    old_fields = "" if old_fields.nil?
    fields = detalle_tarifas_string if association == :detalle_precios_tarifas
    fields = operadores_acuerdo_acceso_interconexions_string if association == :operadores_acuerdo_acceso_interconexions
    fields = operadores_orden_acceso_interconexions_string if association == :operadores_orden_acceso_interconexions
    fields = operadores_resolucion_ubicacion_equipos_string if association == :operadores_resolucion_ubicacion_equipos
    fields = operadores_convenio_ubicacion_equipos_string if association == :operadores_convenio_ubicacion_equipos
    fields = detalle_recurso_numericos_string if association == :detalle_recurso_numericos
    fields = servicios_interconexion_string if association == :servicios_interconexion
    fields = servicio_contrato_adhesions_string if association == :servicio_contrato_adhesions
    fields = oferta_interconexion_servicios_string if association == :oferta_interconexion_servicios
    fields = zona_string if association == :zona
    fields = servicios_fields if association == :servicio_habilitados # and old_fields.include?("espectro_attributes")
    fields = frecuencias_string if association == :frecuencia_espectro and old_fields.include?("frecuencia_espectro")    
    fields = fields.gsub(/permiso\[espectro_attributes\]\[frecuencia_espectro_attributes\]\[0\]/,'autorizacion') if f.object.class.name == "Autorizacion" and !f.object.nil? and association == :zona
    fields = fields.gsub(/permiso_espectro_attributes_frecuencia_espectro_attributes_0_/,'autorizacion_') if f.object.class.name == "Autorizacion" and !f.object.nil? and association == :zona
    fields = fields.gsub(/permiso/,'concesion_direct')   if old_fields.include?("concesion_direct")
    fields = fields.gsub(/permiso/,'consecion_anterior') if old_fields.include?("consecion_anterior")
    fields = fields.gsub(/permiso/,'consecion_publica')  if old_fields.include?("consecion_publica")

    fields = fields.gsub(/concesion_direct/,'autorizacion') if association == :servicio_habilitados and old_fields.include?("autorizacion")
    fields = fields.gsub(/concesion_direct/,'consecion_publica[espectro_attributes]') if association == :servicio_habilitados and old_fields.include?("espectro_attributes") and old_fields.include?("consecion_publica")
    fields = fields.gsub(/concesion_direct/,'consecion_anterior[espectro_attributes]') if association == :servicio_habilitados and old_fields.include?("espectro_attributes") and old_fields.include?("consecion_anterior")
    fields = fields.gsub(/concesion_direct/,'permiso[espectro_attributes]') if association == :servicio_habilitados and old_fields.include?("espectro_attributes") and old_fields.include?("permiso")
    fields = fields.gsub(/concesion_direct/,'concesion_direct[espectro_attributes]') if association == :servicio_habilitados and old_fields.include?("espectro_attributes") and old_fields.include?("concesion_direct")

    my_association = association
    my_association = "frecuencia_espectro_attributes" if association == :frecuencia_espectro
    my_association = "detalle_recurso_numericos_attributes" if association == :detalle_recurso_numericos

    my_call = "add_fields(this, \"#{my_association}\", \"#{escape_javascript(fields)}\");" if association != :zona
    my_call = "add_zona_fields(this, \"#{my_association}\", \"#{escape_javascript(fields)}\");" if association == :zona
    link_to "", "javascript:void(0)", :onclick=> my_call, :class => "glyphicon glyphicon-plus".html_safe
  end

  def get_new_object(f,association)
 
    if association == :detalle_precios_tarifas
      return f.object.class.reflect_on_association(:detalle_precios_tarifas).klass.new
    end
       
    if association == :detalle_recurso_numericos
      return f.object.class.reflect_on_association(:detalle_recurso_numericos).klass.new
    end

    if association == :operadores_convenio_ubicacion_equipos
      return f.object.class.reflect_on_association(:operadores_convenio_ubicacion_equipos).klass.new
    end

    if association == :operadores_acuerdo_acceso_interconexions
      return f.object.class.reflect_on_association(:operadores_acuerdo_acceso_interconexions).klass.new
    end

    if association == :servicio_habilitados
      if f.object.class.reflect_on_association(:espectro)
        my_f = f.object.class.reflect_on_association(:espectro).klass.reflect_on_association(:titulo_habilitante).klass.new
      else
        my_f = f.object
      end
      return my_f.class.reflect_on_association(:servicio_habilitados).klass.new 
    end

    if association == :zona
      return my_f = f.object.class.reflect_on_association(:espectro).klass.reflect_on_association(:frecuencia_espectro).klass.reflect_on_association(:zona).klass.new if f.object.class.name != "Autorizacion"
      return my_f = f.object.class.reflect_on_association(:zona).klass.new if f.object.class.name == "Autorizacion"
      #my_f = f.object.class.reflect_on_association(:espectro).klass.reflect_on_association(:frecuencia_espectro).klass.new
      #return my_f.class.reflect_on_association(:zona).klass.new 
    end
    if association == :frecuencia_espectro
      my_f = f.object.class.reflect_on_association(:frecuencia_espectro).klass.new
      return my_f
      #return my_f.class.reflect_on_association(:frecuencia_espectro).klass.new 
    end
    return ""
  end

  def get_operadores_xml
    op = OperadorRegulado.all
    result = ""
    op.each do |o|
      result += "<option value=\"#{o.id}\">#{o.nombre}</option>"
    end
    return result
  end
  
  def get_cantones_xml
    provs = Prov.all
    resultado = ""
    provs.each do |p|
      resultado += "<optgroup label=\"#{p.provincia}\"> "                                                                                                     
      p.cantons.order(:canton).each do |c|
        resultado += " <option value=\"#{c.id}\">#{c.canton}</option> "
      end
      resultado += '</optgroup>'
    end
    resultado
  end
  
  def get_distritos_xml
    provs = Prov.all
    resultado = ""
    provs.each do |p|
      p.cantons.order(:canton).each do |c|
        resultado += "<optgroup label=\"#{c.canton}\"> "
        c.distritos.order(:distrito).each do |d| 
          resultado += " <option value=\"#{d.id}\">#{d.distrito}</option> "
        end
        resultado += '</optgroup>'                                                                                                                            
      end
    end 
    resultado
  end

  def link_to_add_zonas_string
    my_string = '      <div class="form-group">
            <p><a onclick="add_fields(this, &quot;zona&quot;, &quot;&lt;div class=\&quot;col-md-4\&quot;&gt;\n        &lt;div class=\&quot;form-group\&quot;&gt;\n          &lt;select name=\&quot;permiso[espectro_attributes][frecuencia_espectro_attributes][0][zona_attributes][new_zona][tipo_zona]\&quot; id=\&quot;permiso_espectro_attributes_frecuencia_espectro_attributes_0_zona_attributes_new_zona_tipo_zona\&quot;&gt;&lt;option value=\&quot;nacional\&quot;&gt;Cobertura Nacional&lt;\/option&gt;\n&lt;option value=\&quot;regional\&quot;&gt;Cobertura Regional&lt;\/option&gt;\n&lt;option value=\&quot;poligono_cobertura\&quot;&gt;Polígono de Cobertura (long/lat)&lt;\/option&gt;&lt;\/select&gt;\n        &lt;\/div&gt;\n      &lt;\/div&gt;\n      &lt;div class=\&quot;col-md-2\&quot;&gt;\n        &lt;div class=\&quot;form-group\&quot;&gt;\n          &lt;label for=\&quot;permiso_espectro_attributes_frecuencia_espectro_attributes_0_zona_attributes_new_zona_Descripcion zona\&quot;&gt;Descripcion zona&lt;\/label&gt;\n          &lt;input class=\&quot;form-control\&quot; type=\&quot;text\&quot; name=\&quot;permiso[espectro_attributes][frecuencia_espectro_attributes][0][zona_attributes][new_zona][descripcion_zona]\&quot; id=\&quot;permiso_espectro_attributes_frecuencia_espectro_attributes_0_zona_attributes_new_zona_descripcion_zona\&quot; /&gt;\n        &lt;\/div&gt;\n      &lt;\/div&gt;\n      &lt;div class=\&quot;col-md-4\&quot;&gt;\n        &lt;div class=\&quot;form-group\&quot;&gt;\n          &lt;label for=\&quot;permiso_espectro_attributes_frecuencia_espectro_attributes_0_zona_attributes_new_zona_Nota\&quot;&gt;Nota&lt;\/label&gt;\n          &lt;textarea class: \&#39;form-control\&#39; rows=3&gt;  &lt;\/textarea&gt;\n        &lt;\/div&gt;\n      &lt;\/div&gt;&quot;);" class="glyphicon glyphicon-plus" href="javascript:void(0)"></a> </p>
                  </div>'
    my_string = my_string.gsub(/&quot\;/,'"').gsub(/&gt\;/,'>').gsub(/&lt\;/,"<").gsub(/\'/,'"').gsub(/&amb\;/,":").gsub(/\#39\;/,'"')
  end

  def frecuencia_top_string
    '<div class="panel panel-default">
      <div class="panel-heading">Zona</div>
          <div class="panel-body">'
  end

  def frecuencia_bottom_string
    '</textarea>
            </div>
                  </div>
                    '
  end

  def zona_string
    cantones = get_cantones_xml
    distritos = get_distritos_xml
    resultado = '
    <div class="row">
 <div class="col-md-4">
 <div class="form-group">
 <select name="permiso[espectro_attributes][frecuencia_espectro_attributes][0][zona_attributes][new_zona][tipo_zona]" id="permiso_espectro_attributes_frecuencia_espectro_attributes_0_zona_attributes_new_zona_tipo_zona"><option value="nacional">Cobertura Nacional</option>
 <option value="regional">Cobertura Regional</option>
 <option value="poligono_cobertura">Polígono de Cobertura (long/lat)</option></select>
 </div>
 <div class="form-group">
 <input placeholder="Descripción Zona" class="form-control" type="text" name="permiso[espectro_attributes][frecuencia_espectro_attributes][0][zona_attributes][new_zona][descripcion_zona]" id="permiso_espectro_attributes_frecuencia_espectro_attributes_0_zona_attributes_new_zona_descripcion_zona" />
 </div>
 </div>
 <div class="col-md-4">
 <div class="form-group">
 <select onchange="cantones_list(this);" class="form-control" name="permiso[espectro_attributes][frecuencia_espectro_attributes][0][zona_attributes][new_zona][provincia]" id="permiso_espectro_attributes_frecuencia_espectro_attributes_0_zona_attributes_new_zona_provincia"><option value="">Seleccione Provincia</option>

 <option value="1">ALAJUELA</option>
 <option value="2">CARTAGO</option>
 <option value="3">GUANACASTE</option>
 <option value="4">HEREDIA</option>
 <option value="5">LIMON</option>
 <option value="6">PUNTARENAS</option>
 <option value="7">SAN_JOSE</option></select>
 </div>
 <div class="form-group">
 <select onchange="distritos_list(this);" class="form-control" name="permiso[espectro_attributes][frecuencia_espectro_attributes][0][zona_attributes][new_zona][canton]" id="permiso_espectro_attributes_frecuencia_espectro_attributes_0_zona_attributes_new_zona_canton"><option value="">Seleccione Cantón</option>
 ' + cantones + '
 </select>
 </div>
 
 <div class="form-group">
 <select class="form-control" name="permiso[espectro_attributes][frecuencia_espectro_attributes][0][zona_attributes][new_zona][distrito]" id="permiso_espectro_attributes_frecuencia_espectro_attributes_0_zona_attributes_new_zona_distrito"><option value="">Seleccione Distrito</option>
 ' + distritos + '
 </select>
 </div>

 </div>
 
 
 <div class="col-md-4">
 <div class="form-group">
 <label for="permiso_espectro_attributes_frecuencia_espectro_attributes_0_zona_attributes_new_zona_Nota">Nota</label>
 <textarea rows="3" name="permiso[espectro_attributes][frecuencia_espectro_attributes][0][zona_attributes][new_zona][nota]" id="permiso_espectro_attributes_frecuencia_espectro_attributes_0_zona_attributes_new_zona_Nota">
</textarea>
 </div>
    '
  end

  def frecuencias_string
   my_string = '
<div class="panel panel-default">
<div class="panel-heading">Frecuencias</div>
<div class="panel-body">
<div class="col-md-4">
<div class="form-group">
<select " name="permiso[espectro_attributes][frecuencia_espectro_attributes][new_frecuencia_espectro_attributes][tipo_frecuencia]" id="permiso_espectro_attributes_frecuencia_espectro_attributes_new_frecuencia_espectro_attributes_tipo_frecuencia"><option value="">Seleccionar Tipo Frecuencia</option>
<option value="frecuencia">Frecuencia</option>
<option value="frecuencia_tx_rx">Frecuencia Rx-Tx</option>
<option value="rango_frecuencias">Rango Frecuencias</option>
<option value="rango_frecuencias_tx_rx">Rango Frecuencias Rx-Tx</option></select>
</div>
</div>
<div class="col-md-2">
<div class="form-group">
<label for="permiso_espectro_attributes_frecuencia_espectro_attributes_new_frecuencia_espectro_attributes_Unidad">Unidad</label>
<select name="permiso[espectro_attributes][frecuencia_espectro_attributes][new_frecuencia_espectro_attributes][unidad_desde]" id="permiso_espectro_attributes_frecuencia_espectro_attributes_new_frecuencia_espectro_attributes_unidad_desde"><option value="mhz">MHz</option>
<option value="khz">KHz</option>
<option value="ghz">GHz</option>
<option value="hz">Hz</option></select>
</div>
</div>
<div class="col-md-2">
<div class="form-group">
<label for="permiso_espectro_attributes_frecuencia_espectro_attributes_new_frecuencia_espectro_attributes_desde">Desde</label>
<input class="form-control" step="0.0001" type="number" name="permiso[espectro_attributes][frecuencia_espectro_attributes][new_frecuencia_espectro_attributes][desde]" id="permiso_espectro_attributes_frecuencia_espectro_attributes_new_frecuencia_espectro_attributes_desde" />
</div>
<div class="form-group">
<label for="permiso_espectro_attributes_frecuencia_espectro_attributes_new_frecuencia_espectro_attributes_hasta">Hasta</label>
<input class="form-control" step="0.0001" type="number" name="permiso[espectro_attributes][frecuencia_espectro_attributes][new_frecuencia_espectro_attributes][hasta]" id="permiso_espectro_attributes_frecuencia_espectro_attributes_new_frecuencia_espectro_attributes_hasta" />
</div>
</div>
<div class="col-md-2">
<div class="form-group">
<label for="permiso_espectro_attributes_frecuencia_espectro_attributes_new_frecuencia_espectro_attributes_Tx Desde">Tx desde</label>
<input class="form-control" step="0.0001" type="number" name="permiso[espectro_attributes][frecuencia_espectro_attributes][new_frecuencia_espectro_attributes][tx_desde]" id="permiso_espectro_attributes_frecuencia_espectro_attributes_new_frecuencia_espectro_attributes_tx_desde" />
</div>
<div class="form-group">
<label for="permiso_espectro_attributes_frecuencia_espectro_attributes_new_frecuencia_espectro_attributes_Tx Hasta">Tx hasta</label>
<input class="form-control" step="0.0001" type="number" name="permiso[espectro_attributes][frecuencia_espectro_attributes][new_frecuencia_espectro_attributes][tx_hasta]" id="permiso_espectro_attributes_frecuencia_espectro_attributes_new_frecuencia_espectro_attributes_tx_hasta" />
</div>
</div>
<div class="col-md-2">
<div class="form-group">
<label for="permiso_espectro_attributes_frecuencia_espectro_attributes_new_frecuencia_espectro_attributes_Rx Desde">Rx desde</label>
<input class="form-control" step="0.0001"  type="number" name="permiso[espectro_attributes][frecuencia_espectro_attributes][new_frecuencia_espectro_attributes][rx_desde]" id="permiso_espectro_attributes_frecuencia_espectro_attributes_new_frecuencia_espectro_attributes_rx_desde" />
</div>
<div class="form-group">
<label for="permiso_espectro_attributes_frecuencia_espectro_attributes_new_frecuencia_espectro_attributes_Rx Hasta">Rx hasta</label>
<input class="form-control" step="0.0001"  type="number" name="permiso[espectro_attributes][frecuencia_espectro_attributes][new_frecuencia_espectro_attributes][rx_hasta]" id="permiso_espectro_attributes_frecuencia_espectro_attributes_new_frecuencia_espectro_attributes_rx_hasta" />
</div>
</div>
</div>
</div>

<div class="panel panel-default">
<div class="panel-heading">Zona</div>
<div class="panel-body">

<div class="form-group">

  <p><a onclick="add_zona_fields(this, &quot;zona&quot;, &quot;\n    &lt;div class=\&quot;row\&quot;&gt;\n &lt;div class=\&quot;col-md-4\&quot;&gt;\n &lt;div class=\&quot;form-group\&quot;&gt;\n &lt;select name=\&quot;permiso[espectro_attributes][frecuencia_espectro_attributes][0][zona_attributes][new_zona][tipo_zona]\&quot; id=\&quot;permiso_espectro_attributes_frecuencia_espectro_attributes_0_zona_attributes_new_zona_tipo_zona\&quot;&gt;&lt;option value=\&quot;nacional\&quot;&gt;Cobertura Nacional&lt;\/option&gt;\n &lt;option value=\&quot;regional\&quot;&gt;Cobertura Regional&lt;\/option&gt;\n &lt;option value=\&quot;poligono_cobertura\&quot;&gt;Polígono de Cobertura (long/lat)&lt;\/option&gt;&lt;\/select&gt;\n &lt;\/div&gt;\n &lt;div class=\&quot;form-group\&quot;&gt;\n &lt;input placeholder=\&quot;Descripción Zona\&quot; class=\&quot;form-control\&quot; type=\&quot;text\&quot; name=\&quot;permiso[espectro_attributes][frecuencia_espectro_attributes][0][zona_attributes][new_zona][descripcion_zona]\&quot; id=\&quot;permiso_espectro_attributes_frecuencia_espectro_attributes_0_zona_attributes_new_zona_descripcion_zona\&quot; /&gt;\n &lt;\/div&gt;\n &lt;\/div&gt;\n &lt;div class=\&quot;col-md-4\&quot;&gt;\n &lt;div class=\&quot;form-group\&quot;&gt;\n &lt;select onchange=\&quot;cantones_list(this);\&quot; class=\&quot;form-control\&quot; name=\&quot;permiso[espectro_attributes][frecuencia_espectro_attributes][0][zona_attributes][new_zona][provincia]\&quot; id=\&quot;permiso_espectro_attributes_frecuencia_espectro_attributes_0_zona_attributes_new_zona_provincia\&quot;&gt;&lt;option value=\&quot;\&quot;&gt;Seleccione Provincia&lt;\/option&gt;\n\n &lt;option value=\&quot;8\&quot;&gt;ALAJUELA&lt;\/option&gt;\n &lt;option value=\&quot;9\&quot;&gt;CARTAGO&lt;\/option&gt;\n &lt;option value=\&quot;10\&quot;&gt;GUANACASTE&lt;\/option&gt;\n &lt;option value=\&quot;11\&quot;&gt;HEREDIA&lt;\/option&gt;\n &lt;option value=\&quot;12\&quot;&gt;LIMON&lt;\/option&gt;\n &lt;option value=\&quot;13\&quot;&gt;PUNTARENAS&lt;\/option&gt;\n &lt;option value=\&quot;14\&quot;&gt;SAN_JOSE&lt;\/option&gt;&lt;\/select&gt;\n &lt;\/div&gt;\n &lt;div class=\&quot;form-group\&quot;&gt;\n &lt;select onchange=\&quot;distritos_list(this);\&quot; class=\&quot;form-control\&quot; name=\&quot;permiso[espectro_attributes][frecuencia_espectro_attributes][0][zona_attributes][new_zona][canton]\&quot; id=\&quot;permiso_espectro_attributes_frecuencia_espectro_attributes_0_zona_attributes_new_zona_canton\&quot;&gt;&lt;option value=\&quot;\&quot;&gt;Seleccione Cantón&lt;\/option&gt;\n &lt;optgroup label=\&quot;ALAJUELA\&quot;&gt;  &lt;option value=\&quot;1000\&quot;&gt;.Cantón no indicado&lt;\/option&gt;  &lt;option value=\&quot;82\&quot;&gt;ALAJUELA&lt;\/option&gt;  &lt;option value=\&quot;83\&quot;&gt;ALFARO_RUIZ&lt;\/option&gt;  &lt;option value=\&quot;84\&quot;&gt;ATENAS&lt;\/option&gt;  &lt;option value=\&quot;85\&quot;&gt;GRECIA&lt;\/option&gt;  &lt;option value=\&quot;86\&quot;&gt;GUATUSO&lt;\/option&gt;  &lt;option value=\&quot;87\&quot;&gt;LOS_CHILES&lt;\/option&gt;  &lt;option value=\&quot;88\&quot;&gt;NARANJO&lt;\/option&gt;  &lt;option value=\&quot;89\&quot;&gt;OROTINA&lt;\/option&gt;  &lt;option value=\&quot;90\&quot;&gt;PALMARES&lt;\/option&gt;  &lt;option value=\&quot;91\&quot;&gt;POAS&lt;\/option&gt;  &lt;option value=\&quot;92\&quot;&gt;SAN_CARLOS&lt;\/option&gt;  &lt;option value=\&quot;93\&quot;&gt;SAN_MATEO&lt;\/option&gt;  &lt;option value=\&quot;94\&quot;&gt;SAN_RAMON&lt;\/option&gt;  &lt;option value=\&quot;95\&quot;&gt;UPALA&lt;\/option&gt;  &lt;option value=\&quot;96\&quot;&gt;VALVERDE_VEGA&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;CARTAGO\&quot;&gt;  &lt;option value=\&quot;164\&quot;&gt;.Cantón no indicado&lt;\/option&gt;  &lt;option value=\&quot;97\&quot;&gt;ALVARADO&lt;\/option&gt;  &lt;option value=\&quot;98\&quot;&gt;CARTAGO&lt;\/option&gt;  &lt;option value=\&quot;99\&quot;&gt;EL_GUARCO&lt;\/option&gt;  &lt;option value=\&quot;100\&quot;&gt;JIMENEZ&lt;\/option&gt;  &lt;option value=\&quot;101\&quot;&gt;LA_UNION&lt;\/option&gt;  &lt;option value=\&quot;102\&quot;&gt;OREAMUNO&lt;\/option&gt;  &lt;option value=\&quot;103\&quot;&gt;PARAISO&lt;\/option&gt;  &lt;option value=\&quot;104\&quot;&gt;TURRIALBA&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;GUANACASTE\&quot;&gt;  &lt;option value=\&quot;165\&quot;&gt;.Cantón no indicado&lt;\/option&gt;  &lt;option value=\&quot;105\&quot;&gt;ABANGARES&lt;\/option&gt;  &lt;option value=\&quot;106\&quot;&gt;BAGACES&lt;\/option&gt;  &lt;option value=\&quot;107\&quot;&gt;CANAS&lt;\/option&gt;  &lt;option value=\&quot;108\&quot;&gt;CARRILLO&lt;\/option&gt;  &lt;option value=\&quot;109\&quot;&gt;HOJANCHA&lt;\/option&gt;  &lt;option value=\&quot;110\&quot;&gt;LA_CRUZ&lt;\/option&gt;  &lt;option value=\&quot;111\&quot;&gt;LIBERIA&lt;\/option&gt;  &lt;option value=\&quot;112\&quot;&gt;NANDAYURE&lt;\/option&gt;  &lt;option value=\&quot;113\&quot;&gt;NICOYA&lt;\/option&gt;  &lt;option value=\&quot;114\&quot;&gt;SANTA_CRUZ&lt;\/option&gt;  &lt;option value=\&quot;115\&quot;&gt;TILARAN&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;HEREDIA\&quot;&gt;  &lt;option value=\&quot;166\&quot;&gt;.Cantón no indicado&lt;\/option&gt;  &lt;option value=\&quot;116\&quot;&gt;BARVA&lt;\/option&gt;  &lt;option value=\&quot;117\&quot;&gt;BELEN&lt;\/option&gt;  &lt;option value=\&quot;118\&quot;&gt;FLORES&lt;\/option&gt;  &lt;option value=\&quot;119\&quot;&gt;HEREDIA&lt;\/option&gt;  &lt;option value=\&quot;123\&quot;&gt;SANTA_BARBARA&lt;\/option&gt;  &lt;option value=\&quot;124\&quot;&gt;SANTO_DOMINGO&lt;\/option&gt;  &lt;option value=\&quot;120\&quot;&gt;SAN_ISIDRO&lt;\/option&gt;  &lt;option value=\&quot;121\&quot;&gt;SAN_PABLO&lt;\/option&gt;  &lt;option value=\&quot;122\&quot;&gt;SAN_RAFAEL&lt;\/option&gt;  &lt;option value=\&quot;125\&quot;&gt;SARAPIQUI&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;LIMON\&quot;&gt;  &lt;option value=\&quot;167\&quot;&gt;.Cantón no indicado&lt;\/option&gt;  &lt;option value=\&quot;126\&quot;&gt;GUACIMO&lt;\/option&gt;  &lt;option value=\&quot;127\&quot;&gt;LIMON&lt;\/option&gt;  &lt;option value=\&quot;128\&quot;&gt;MATINA&lt;\/option&gt;  &lt;option value=\&quot;129\&quot;&gt;POCOCI&lt;\/option&gt;  &lt;option value=\&quot;130\&quot;&gt;SIQUIRRES&lt;\/option&gt;  &lt;option value=\&quot;131\&quot;&gt;TALAMANCA&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;PUNTARENAS\&quot;&gt;  &lt;option value=\&quot;168\&quot;&gt;.Cantón no indicado&lt;\/option&gt;  &lt;option value=\&quot;132\&quot;&gt;AGUIRRE&lt;\/option&gt;  &lt;option value=\&quot;133\&quot;&gt;BUENOS_AIRES&lt;\/option&gt;  &lt;option value=\&quot;134\&quot;&gt;CORREDORES&lt;\/option&gt;  &lt;option value=\&quot;135\&quot;&gt;COTO_BRUS&lt;\/option&gt;  &lt;option value=\&quot;136\&quot;&gt;ESPARZA&lt;\/option&gt;  &lt;option value=\&quot;137\&quot;&gt;GARABITO&lt;\/option&gt;  &lt;option value=\&quot;138\&quot;&gt;GOLFITO&lt;\/option&gt;  &lt;option value=\&quot;139\&quot;&gt;MONTES_DE_ORO&lt;\/option&gt;  &lt;option value=\&quot;140\&quot;&gt;OSA&lt;\/option&gt;  &lt;option value=\&quot;141\&quot;&gt;PARRITA&lt;\/option&gt;  &lt;option value=\&quot;142\&quot;&gt;PUNTARENAS&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;SAN_JOSE\&quot;&gt;  &lt;option value=\&quot;169\&quot;&gt;.Cantón no indicado&lt;\/option&gt;  &lt;option value=\&quot;143\&quot;&gt;ACOSTA&lt;\/option&gt;  &lt;option value=\&quot;144\&quot;&gt;ALAJUELITA&lt;\/option&gt;  &lt;option value=\&quot;145\&quot;&gt;ASERRI&lt;\/option&gt;  &lt;option value=\&quot;146\&quot;&gt;CURRIDABAT&lt;\/option&gt;  &lt;option value=\&quot;147\&quot;&gt;DESAMPARADOS&lt;\/option&gt;  &lt;option value=\&quot;148\&quot;&gt;DOTA&lt;\/option&gt;  &lt;option value=\&quot;149\&quot;&gt;ESCAZU&lt;\/option&gt;  &lt;option value=\&quot;150\&quot;&gt;GOICOECHEA&lt;\/option&gt;  &lt;option value=\&quot;151\&quot;&gt;LEON_CORTES&lt;\/option&gt;  &lt;option value=\&quot;152\&quot;&gt;MONTES_DE_OCA&lt;\/option&gt;  &lt;option value=\&quot;153\&quot;&gt;MORA&lt;\/option&gt;  &lt;option value=\&quot;154\&quot;&gt;MORAVIA&lt;\/option&gt;  &lt;option value=\&quot;155\&quot;&gt;PEREZ_ZELEDON&lt;\/option&gt;  &lt;option value=\&quot;156\&quot;&gt;PURISCAL&lt;\/option&gt;  &lt;option value=\&quot;158\&quot;&gt;SANTA_ANA&lt;\/option&gt;  &lt;option value=\&quot;157\&quot;&gt;SAN_JOSE&lt;\/option&gt;  &lt;option value=\&quot;159\&quot;&gt;TARRAZU&lt;\/option&gt;  &lt;option value=\&quot;160\&quot;&gt;TIBAS&lt;\/option&gt;  &lt;option value=\&quot;161\&quot;&gt;TURRUBARES&lt;\/option&gt;  &lt;option value=\&quot;162\&quot;&gt;VAZQUEZ_DE_CORONADO&lt;\/option&gt; &lt;\/optgroup&gt;\n &lt;\/select&gt;\n &lt;\/div&gt;\n \n &lt;div class=\&quot;form-group\&quot;&gt;\n &lt;select class=\&quot;form-control\&quot; name=\&quot;permiso[espectro_attributes][frecuencia_espectro_attributes][0][zona_attributes][new_zona][distrito]\&quot; id=\&quot;permiso_espectro_attributes_frecuencia_espectro_attributes_0_zona_attributes_new_zona_distrito\&quot;&gt;&lt;option value=\&quot;\&quot;&gt;Seleccione Distrito&lt;\/option&gt;\n &lt;optgroup label=\&quot;.Cantón no indicado\&quot;&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;ALAJUELA\&quot;&gt;  &lt;option value=\&quot;943\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;472\&quot;&gt;ALAJUELA&lt;\/option&gt;  &lt;option value=\&quot;473\&quot;&gt;CARRIZAL&lt;\/option&gt;  &lt;option value=\&quot;474\&quot;&gt;DESAMPARADOS&lt;\/option&gt;  &lt;option value=\&quot;475\&quot;&gt;GARITA&lt;\/option&gt;  &lt;option value=\&quot;476\&quot;&gt;GUACIMA&lt;\/option&gt;  &lt;option value=\&quot;477\&quot;&gt;RIO_SEGUNDO&lt;\/option&gt;  &lt;option value=\&quot;478\&quot;&gt;SABANILLA&lt;\/option&gt;  &lt;option value=\&quot;479\&quot;&gt;SAN_ANTONIO&lt;\/option&gt;  &lt;option value=\&quot;480\&quot;&gt;SAN_ISIDRO&lt;\/option&gt;  &lt;option value=\&quot;481\&quot;&gt;SAN_JOSE&lt;\/option&gt;  &lt;option value=\&quot;482\&quot;&gt;SAN_RAFAEL&lt;\/option&gt;  &lt;option value=\&quot;483\&quot;&gt;SARAPIQUI&lt;\/option&gt;  &lt;option value=\&quot;484\&quot;&gt;TAMBOR&lt;\/option&gt;  &lt;option value=\&quot;485\&quot;&gt;TURRUCARES&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;ALFARO_RUIZ\&quot;&gt;  &lt;option value=\&quot;944\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;486\&quot;&gt;BRISAS&lt;\/option&gt;  &lt;option value=\&quot;487\&quot;&gt;GUADALUPE&lt;\/option&gt;  &lt;option value=\&quot;488\&quot;&gt;LAGUNA&lt;\/option&gt;  &lt;option value=\&quot;489\&quot;&gt;PALMIRA&lt;\/option&gt;  &lt;option value=\&quot;490\&quot;&gt;TAPESCO&lt;\/option&gt;  &lt;option value=\&quot;491\&quot;&gt;ZAPOTE&lt;\/option&gt;  &lt;option value=\&quot;492\&quot;&gt;ZARCERO&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;ATENAS\&quot;&gt;  &lt;option value=\&quot;945\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;493\&quot;&gt;ATENAS&lt;\/option&gt;  &lt;option value=\&quot;494\&quot;&gt;CONCEPCION&lt;\/option&gt;  &lt;option value=\&quot;495\&quot;&gt;ESCOBAL&lt;\/option&gt;  &lt;option value=\&quot;496\&quot;&gt;JESUS&lt;\/option&gt;  &lt;option value=\&quot;497\&quot;&gt;MERCEDES&lt;\/option&gt;  &lt;option value=\&quot;500\&quot;&gt;SANTA_EULALIA&lt;\/option&gt;  &lt;option value=\&quot;498\&quot;&gt;SAN_ISIDRO&lt;\/option&gt;  &lt;option value=\&quot;499\&quot;&gt;SAN_JOSE&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;GRECIA\&quot;&gt;  &lt;option value=\&quot;946\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;501\&quot;&gt;BOLIVAR&lt;\/option&gt;  &lt;option value=\&quot;502\&quot;&gt;GRECIA&lt;\/option&gt;  &lt;option value=\&quot;503\&quot;&gt;PUENTE_DE_PIEDRA&lt;\/option&gt;  &lt;option value=\&quot;504\&quot;&gt;RIO_CUARTO&lt;\/option&gt;  &lt;option value=\&quot;505\&quot;&gt;SAN_ISIDRO&lt;\/option&gt;  &lt;option value=\&quot;506\&quot;&gt;SAN_JOSE&lt;\/option&gt;  &lt;option value=\&quot;507\&quot;&gt;SAN_ROQUE&lt;\/option&gt;  &lt;option value=\&quot;508\&quot;&gt;TACARES&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;GUATUSO\&quot;&gt;  &lt;option value=\&quot;947\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;509\&quot;&gt;BUENAVISTA&lt;\/option&gt;  &lt;option value=\&quot;510\&quot;&gt;COTE&lt;\/option&gt;  &lt;option value=\&quot;511\&quot;&gt;SAN_RAFAEL&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;LOS_CHILES\&quot;&gt;  &lt;option value=\&quot;948\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;512\&quot;&gt;CANO_NEGRO&lt;\/option&gt;  &lt;option value=\&quot;513\&quot;&gt;EL_AMPARO&lt;\/option&gt;  &lt;option value=\&quot;514\&quot;&gt;LOS_CHILES&lt;\/option&gt;  &lt;option value=\&quot;515\&quot;&gt;SAN_JORGE&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;NARANJO\&quot;&gt;  &lt;option value=\&quot;949\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;516\&quot;&gt;CIRRI_SUR&lt;\/option&gt;  &lt;option value=\&quot;517\&quot;&gt;NARANJO&lt;\/option&gt;  &lt;option value=\&quot;518\&quot;&gt;ROSARIO&lt;\/option&gt;  &lt;option value=\&quot;519\&quot;&gt;SAN_JERONIMO&lt;\/option&gt;  &lt;option value=\&quot;520\&quot;&gt;SAN_JOSE&lt;\/option&gt;  &lt;option value=\&quot;521\&quot;&gt;SAN_JUAN&lt;\/option&gt;  &lt;option value=\&quot;522\&quot;&gt;SAN_MIGUEL&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;OROTINA\&quot;&gt;  &lt;option value=\&quot;950\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;523\&quot;&gt;CEIBA&lt;\/option&gt;  &lt;option value=\&quot;524\&quot;&gt;COYOLAR&lt;\/option&gt;  &lt;option value=\&quot;525\&quot;&gt;HACIENDA_VIEJA&lt;\/option&gt;  &lt;option value=\&quot;526\&quot;&gt;MASTATE&lt;\/option&gt;  &lt;option value=\&quot;527\&quot;&gt;OROTINA&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;PALMARES\&quot;&gt;  &lt;option value=\&quot;951\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;528\&quot;&gt;BUENOS_AIRES&lt;\/option&gt;  &lt;option value=\&quot;529\&quot;&gt;CANDELARIA&lt;\/option&gt;  &lt;option value=\&quot;530\&quot;&gt;ESQUIPULAS&lt;\/option&gt;  &lt;option value=\&quot;531\&quot;&gt;GRANJA&lt;\/option&gt;  &lt;option value=\&quot;532\&quot;&gt;PALMARES&lt;\/option&gt;  &lt;option value=\&quot;533\&quot;&gt;SANTIAGO&lt;\/option&gt;  &lt;option value=\&quot;534\&quot;&gt;ZARAGOZA&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;POAS\&quot;&gt;  &lt;option value=\&quot;952\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;535\&quot;&gt;CARRILLOS&lt;\/option&gt;  &lt;option value=\&quot;536\&quot;&gt;SABANA_REDONDA&lt;\/option&gt;  &lt;option value=\&quot;537\&quot;&gt;SAN_JUAN&lt;\/option&gt;  &lt;option value=\&quot;538\&quot;&gt;SAN_PEDRO&lt;\/option&gt;  &lt;option value=\&quot;539\&quot;&gt;SAN_RAFAEL&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;SAN_CARLOS\&quot;&gt;  &lt;option value=\&quot;953\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;540\&quot;&gt;AGUAS_ZARCAS&lt;\/option&gt;  &lt;option value=\&quot;541\&quot;&gt;BUENA_VISTA&lt;\/option&gt;  &lt;option value=\&quot;542\&quot;&gt;CUTRIS&lt;\/option&gt;  &lt;option value=\&quot;543\&quot;&gt;FLORENCIA&lt;\/option&gt;  &lt;option value=\&quot;544\&quot;&gt;FORTUNA&lt;\/option&gt;  &lt;option value=\&quot;545\&quot;&gt;MONTERREY&lt;\/option&gt;  &lt;option value=\&quot;546\&quot;&gt;PALMERA&lt;\/option&gt;  &lt;option value=\&quot;547\&quot;&gt;PITAL&lt;\/option&gt;  &lt;option value=\&quot;548\&quot;&gt;POCOSOL&lt;\/option&gt;  &lt;option value=\&quot;549\&quot;&gt;QUESADA&lt;\/option&gt;  &lt;option value=\&quot;550\&quot;&gt;TIGRA&lt;\/option&gt;  &lt;option value=\&quot;551\&quot;&gt;VENADO&lt;\/option&gt;  &lt;option value=\&quot;552\&quot;&gt;VENECIA&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;SAN_MATEO\&quot;&gt;  &lt;option value=\&quot;954\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;553\&quot;&gt;DESMONTE&lt;\/option&gt;  &lt;option value=\&quot;554\&quot;&gt;JESUS_MARIA&lt;\/option&gt;  &lt;option value=\&quot;555\&quot;&gt;SAN_MATEO&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;SAN_RAMON\&quot;&gt;  &lt;option value=\&quot;955\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;556\&quot;&gt;ALFARO&lt;\/option&gt;  &lt;option value=\&quot;557\&quot;&gt;ANGELES&lt;\/option&gt;  &lt;option value=\&quot;558\&quot;&gt;CONCEPCION&lt;\/option&gt;  &lt;option value=\&quot;559\&quot;&gt;PEÑAS_BLANCAS&lt;\/option&gt;  &lt;option value=\&quot;560\&quot;&gt;PIEDADES_NORTE&lt;\/option&gt;  &lt;option value=\&quot;561\&quot;&gt;PIEDADES_SUR&lt;\/option&gt;  &lt;option value=\&quot;566\&quot;&gt;SANTIAGO&lt;\/option&gt;  &lt;option value=\&quot;562\&quot;&gt;SAN_ISIDRO&lt;\/option&gt;  &lt;option value=\&quot;563\&quot;&gt;SAN_JUAN&lt;\/option&gt;  &lt;option value=\&quot;564\&quot;&gt;SAN_RAFAEL&lt;\/option&gt;  &lt;option value=\&quot;565\&quot;&gt;SAN_RAMON&lt;\/option&gt;  &lt;option value=\&quot;567\&quot;&gt;VOLIO&lt;\/option&gt;  &lt;option value=\&quot;568\&quot;&gt;ZAPOTAL&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;UPALA\&quot;&gt;  &lt;option value=\&quot;956\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;569\&quot;&gt;AGUAS_CLARAS&lt;\/option&gt;  &lt;option value=\&quot;570\&quot;&gt;BIJAGUA&lt;\/option&gt;  &lt;option value=\&quot;571\&quot;&gt;DELICIAS&lt;\/option&gt;  &lt;option value=\&quot;572\&quot;&gt;DOS_RIOS&lt;\/option&gt;  &lt;option value=\&quot;573\&quot;&gt;SAN_JOSE&lt;\/option&gt;  &lt;option value=\&quot;574\&quot;&gt;UPALA&lt;\/option&gt;  &lt;option value=\&quot;575\&quot;&gt;YOLILLAL&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;VALVERDE_VEGA\&quot;&gt;  &lt;option value=\&quot;957\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;576\&quot;&gt;RODRIGUEZ&lt;\/option&gt;  &lt;option value=\&quot;577\&quot;&gt;SAN_PEDRO&lt;\/option&gt;  &lt;option value=\&quot;578\&quot;&gt;SARCHI_NORTE&lt;\/option&gt;  &lt;option value=\&quot;579\&quot;&gt;SARCHI_SUR&lt;\/option&gt;  &lt;option value=\&quot;580\&quot;&gt;TORO_AMARILLO&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;.Cantón no indicado\&quot;&gt;  &lt;option value=\&quot;967\&quot;&gt;.Distrito no indicado&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;ALVARADO\&quot;&gt;  &lt;option value=\&quot;959\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;581\&quot;&gt;CAPELLADES&lt;\/option&gt;  &lt;option value=\&quot;582\&quot;&gt;CERVANTES&lt;\/option&gt;  &lt;option value=\&quot;583\&quot;&gt;PACAYAS&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;CARTAGO\&quot;&gt;  &lt;option value=\&quot;960\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;584\&quot;&gt;AGUACALIENTE&lt;\/option&gt;  &lt;option value=\&quot;585\&quot;&gt;CARMEN&lt;\/option&gt;  &lt;option value=\&quot;586\&quot;&gt;CORRALILLO&lt;\/option&gt;  &lt;option value=\&quot;587\&quot;&gt;DULCE_NOMBRE&lt;\/option&gt;  &lt;option value=\&quot;588\&quot;&gt;GUADALUPE&lt;\/option&gt;  &lt;option value=\&quot;589\&quot;&gt;LLANO_GRANDE&lt;\/option&gt;  &lt;option value=\&quot;590\&quot;&gt;OCCIDENTAL&lt;\/option&gt;  &lt;option value=\&quot;591\&quot;&gt;ORIENTAL&lt;\/option&gt;  &lt;option value=\&quot;592\&quot;&gt;QUEBRADILLA&lt;\/option&gt;  &lt;option value=\&quot;593\&quot;&gt;SAN_NICOLAS&lt;\/option&gt;  &lt;option value=\&quot;594\&quot;&gt;TIERRA_BLANCA&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;EL_GUARCO\&quot;&gt;  &lt;option value=\&quot;961\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;595\&quot;&gt;PATIO_DE_AGUA&lt;\/option&gt;  &lt;option value=\&quot;596\&quot;&gt;SAN_ISIDRO&lt;\/option&gt;  &lt;option value=\&quot;597\&quot;&gt;TEJAR&lt;\/option&gt;  &lt;option value=\&quot;598\&quot;&gt;TOBOSI&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;JIMENEZ\&quot;&gt;  &lt;option value=\&quot;962\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;599\&quot;&gt;JUAN_VIÑAS&lt;\/option&gt;  &lt;option value=\&quot;600\&quot;&gt;PEJIBAYE&lt;\/option&gt;  &lt;option value=\&quot;601\&quot;&gt;TUCURRIQUE&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;LA_UNION\&quot;&gt;  &lt;option value=\&quot;963\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;602\&quot;&gt;CONCEPCION&lt;\/option&gt;  &lt;option value=\&quot;603\&quot;&gt;DULCE_NOMBRE&lt;\/option&gt;  &lt;option value=\&quot;604\&quot;&gt;RIO_AZUL&lt;\/option&gt;  &lt;option value=\&quot;605\&quot;&gt;SAN_DIEGO&lt;\/option&gt;  &lt;option value=\&quot;606\&quot;&gt;SAN_JUAN&lt;\/option&gt;  &lt;option value=\&quot;607\&quot;&gt;SAN_RAFAEL&lt;\/option&gt;  &lt;option value=\&quot;608\&quot;&gt;SAN_RAMON&lt;\/option&gt;  &lt;option value=\&quot;609\&quot;&gt;TRES_RIOS&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;OREAMUNO\&quot;&gt;  &lt;option value=\&quot;964\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;610\&quot;&gt;CIPRESES&lt;\/option&gt;  &lt;option value=\&quot;611\&quot;&gt;COT&lt;\/option&gt;  &lt;option value=\&quot;612\&quot;&gt;POTRERO_CERRADO&lt;\/option&gt;  &lt;option value=\&quot;614\&quot;&gt;SANTA_ROSA&lt;\/option&gt;  &lt;option value=\&quot;613\&quot;&gt;SAN_RAFAEL&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;PARAISO\&quot;&gt;  &lt;option value=\&quot;965\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;615\&quot;&gt;CACHI&lt;\/option&gt;  &lt;option value=\&quot;616\&quot;&gt;LLANOS_DE_SANTA_LUCIA&lt;\/option&gt;  &lt;option value=\&quot;617\&quot;&gt;OROSI&lt;\/option&gt;  &lt;option value=\&quot;618\&quot;&gt;PARAISO&lt;\/option&gt;  &lt;option value=\&quot;619\&quot;&gt;SANTIAGO&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;TURRIALBA\&quot;&gt;  &lt;option value=\&quot;966\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;620\&quot;&gt;CHIRRIPO&lt;\/option&gt;  &lt;option value=\&quot;621\&quot;&gt;LA_ISABEL&lt;\/option&gt;  &lt;option value=\&quot;622\&quot;&gt;LA_SUIZA&lt;\/option&gt;  &lt;option value=\&quot;623\&quot;&gt;PAVONES&lt;\/option&gt;  &lt;option value=\&quot;624\&quot;&gt;PERALTA&lt;\/option&gt;  &lt;option value=\&quot;625\&quot;&gt;SANTA_CRUZ&lt;\/option&gt;  &lt;option value=\&quot;626\&quot;&gt;SANTA_ROSA&lt;\/option&gt;  &lt;option value=\&quot;627\&quot;&gt;SANTA_TERESITA&lt;\/option&gt;  &lt;option value=\&quot;628\&quot;&gt;TAYUTIC&lt;\/option&gt;  &lt;option value=\&quot;629\&quot;&gt;TRES_EQUIS&lt;\/option&gt;  &lt;option value=\&quot;630\&quot;&gt;TUIS&lt;\/option&gt;  &lt;option value=\&quot;631\&quot;&gt;TURRIALBA&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;.Cantón no indicado\&quot;&gt;  &lt;option value=\&quot;979\&quot;&gt;.Distrito no indicado&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;ABANGARES\&quot;&gt;  &lt;option value=\&quot;968\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;632\&quot;&gt;COLORADO_(CMD)&lt;\/option&gt;  &lt;option value=\&quot;633\&quot;&gt;JUNTAS&lt;\/option&gt;  &lt;option value=\&quot;634\&quot;&gt;SAN_JUAN&lt;\/option&gt;  &lt;option value=\&quot;635\&quot;&gt;SIERRA&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;BAGACES\&quot;&gt;  &lt;option value=\&quot;969\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;636\&quot;&gt;BAGACES&lt;\/option&gt;  &lt;option value=\&quot;637\&quot;&gt;FORTUNA&lt;\/option&gt;  &lt;option value=\&quot;638\&quot;&gt;MOGOTE&lt;\/option&gt;  &lt;option value=\&quot;639\&quot;&gt;RIO_NARANJO&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;CANAS\&quot;&gt;  &lt;option value=\&quot;970\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;640\&quot;&gt;BEBEDERO&lt;\/option&gt;  &lt;option value=\&quot;641\&quot;&gt;CANAS&lt;\/option&gt;  &lt;option value=\&quot;642\&quot;&gt;PALMIRA&lt;\/option&gt;  &lt;option value=\&quot;643\&quot;&gt;POROZAL&lt;\/option&gt;  &lt;option value=\&quot;644\&quot;&gt;SAN_MIGUEL&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;CARRILLO\&quot;&gt;  &lt;option value=\&quot;971\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;645\&quot;&gt;BELEN&lt;\/option&gt;  &lt;option value=\&quot;646\&quot;&gt;FILADELFIA&lt;\/option&gt;  &lt;option value=\&quot;647\&quot;&gt;PALMIRA&lt;\/option&gt;  &lt;option value=\&quot;648\&quot;&gt;SARDINAL&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;HOJANCHA\&quot;&gt;  &lt;option value=\&quot;972\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;649\&quot;&gt;HOJANCHA&lt;\/option&gt;  &lt;option value=\&quot;650\&quot;&gt;HUACAS&lt;\/option&gt;  &lt;option value=\&quot;651\&quot;&gt;MONTE_ROMO&lt;\/option&gt;  &lt;option value=\&quot;652\&quot;&gt;PUERTO_CARRILLO&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;LA_CRUZ\&quot;&gt;  &lt;option value=\&quot;973\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;653\&quot;&gt;LA_CRUZ&lt;\/option&gt;  &lt;option value=\&quot;654\&quot;&gt;LA_GARITA&lt;\/option&gt;  &lt;option value=\&quot;655\&quot;&gt;SANTA_CECILIA&lt;\/option&gt;  &lt;option value=\&quot;656\&quot;&gt;SANTA_ELENA&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;LIBERIA\&quot;&gt;  &lt;option value=\&quot;974\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;657\&quot;&gt;CANAS_DULCES&lt;\/option&gt;  &lt;option value=\&quot;658\&quot;&gt;CURUBANDE&lt;\/option&gt;  &lt;option value=\&quot;659\&quot;&gt;LIBERIA&lt;\/option&gt;  &lt;option value=\&quot;660\&quot;&gt;MAYORGA&lt;\/option&gt;  &lt;option value=\&quot;661\&quot;&gt;NACASCOLO&lt;\/option&gt;  &lt;option value=\&quot;662\&quot;&gt;SARDINAL&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;NANDAYURE\&quot;&gt;  &lt;option value=\&quot;975\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;663\&quot;&gt;BEJUCO&lt;\/option&gt;  &lt;option value=\&quot;664\&quot;&gt;CARMONA&lt;\/option&gt;  &lt;option value=\&quot;665\&quot;&gt;PORVENIR&lt;\/option&gt;  &lt;option value=\&quot;667\&quot;&gt;SANTA_RITA&lt;\/option&gt;  &lt;option value=\&quot;666\&quot;&gt;SAN_PABLO&lt;\/option&gt;  &lt;option value=\&quot;668\&quot;&gt;ZAPOTAL&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;NICOYA\&quot;&gt;  &lt;option value=\&quot;976\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;669\&quot;&gt;BELEN_DE_NOSARITA&lt;\/option&gt;  &lt;option value=\&quot;670\&quot;&gt;MANSION&lt;\/option&gt;  &lt;option value=\&quot;671\&quot;&gt;NICOYA&lt;\/option&gt;  &lt;option value=\&quot;672\&quot;&gt;NOSARA&lt;\/option&gt;  &lt;option value=\&quot;673\&quot;&gt;QUEBRADA_HONDA&lt;\/option&gt;  &lt;option value=\&quot;674\&quot;&gt;SAMARA&lt;\/option&gt;  &lt;option value=\&quot;675\&quot;&gt;SAN_ANTONIO&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;SANTA_CRUZ\&quot;&gt;  &lt;option value=\&quot;977\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;676\&quot;&gt;BOLSON&lt;\/option&gt;  &lt;option value=\&quot;677\&quot;&gt;CABO_VELAS&lt;\/option&gt;  &lt;option value=\&quot;678\&quot;&gt;CARTAGENA&lt;\/option&gt;  &lt;option value=\&quot;679\&quot;&gt;CUAJINIQUIL&lt;\/option&gt;  &lt;option value=\&quot;680\&quot;&gt;DIRIA&lt;\/option&gt;  &lt;option value=\&quot;681\&quot;&gt;SANTA_CRUZ&lt;\/option&gt;  &lt;option value=\&quot;682\&quot;&gt;TAMARINDO&lt;\/option&gt;  &lt;option value=\&quot;683\&quot;&gt;TEMPATE&lt;\/option&gt;  &lt;option value=\&quot;684\&quot;&gt;VEINTISIETE_DE_ABRIL&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;TILARAN\&quot;&gt;  &lt;option value=\&quot;978\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;685\&quot;&gt;ARENAL&lt;\/option&gt;  &lt;option value=\&quot;686\&quot;&gt;LIBANO&lt;\/option&gt;  &lt;option value=\&quot;687\&quot;&gt;QUEBRADA_GRANDE&lt;\/option&gt;  &lt;option value=\&quot;688\&quot;&gt;SANTA_ROSA&lt;\/option&gt;  &lt;option value=\&quot;689\&quot;&gt;TIERRAS_MORENAS&lt;\/option&gt;  &lt;option value=\&quot;690\&quot;&gt;TILARAN&lt;\/option&gt;  &lt;option value=\&quot;691\&quot;&gt;TRONADORA&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;.Cantón no indicado\&quot;&gt;  &lt;option value=\&quot;990\&quot;&gt;.Distrito no indicado&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;BARVA\&quot;&gt;  &lt;option value=\&quot;980\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;692\&quot;&gt;BARVA&lt;\/option&gt;  &lt;option value=\&quot;697\&quot;&gt;SANTA_LUCIA&lt;\/option&gt;  &lt;option value=\&quot;693\&quot;&gt;SAN_JOSE_DE_LA_MONTANA&lt;\/option&gt;  &lt;option value=\&quot;694\&quot;&gt;SAN_PABLO&lt;\/option&gt;  &lt;option value=\&quot;695\&quot;&gt;SAN_PEDRO&lt;\/option&gt;  &lt;option value=\&quot;696\&quot;&gt;SAN_ROQUE&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;BELEN\&quot;&gt;  &lt;option value=\&quot;981\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;698\&quot;&gt;ASUNCION&lt;\/option&gt;  &lt;option value=\&quot;699\&quot;&gt;LA_RIBERA&lt;\/option&gt;  &lt;option value=\&quot;700\&quot;&gt;SAN_ANTONIO&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;FLORES\&quot;&gt;  &lt;option value=\&quot;982\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;701\&quot;&gt;BARRANTES&lt;\/option&gt;  &lt;option value=\&quot;702\&quot;&gt;LLORENTE&lt;\/option&gt;  &lt;option value=\&quot;703\&quot;&gt;SAN_JOAQUIN&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;HEREDIA\&quot;&gt;  &lt;option value=\&quot;983\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;704\&quot;&gt;HEREDIA&lt;\/option&gt;  &lt;option value=\&quot;705\&quot;&gt;MERCEDES&lt;\/option&gt;  &lt;option value=\&quot;706\&quot;&gt;SAN_FRANCISCO&lt;\/option&gt;  &lt;option value=\&quot;707\&quot;&gt;ULLOA&lt;\/option&gt;  &lt;option value=\&quot;708\&quot;&gt;VARABLANCA&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;SANTA_BARBARA\&quot;&gt;  &lt;option value=\&quot;987\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;719\&quot;&gt;JESUS&lt;\/option&gt;  &lt;option value=\&quot;720\&quot;&gt;PURABA&lt;\/option&gt;  &lt;option value=\&quot;723\&quot;&gt;SANTA_BARBARA&lt;\/option&gt;  &lt;option value=\&quot;724\&quot;&gt;SANTO_DOMINGO&lt;\/option&gt;  &lt;option value=\&quot;721\&quot;&gt;SAN_JUAN&lt;\/option&gt;  &lt;option value=\&quot;722\&quot;&gt;SAN_PEDRO&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;SANTO_DOMINGO\&quot;&gt;  &lt;option value=\&quot;988\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;725\&quot;&gt;PARA&lt;\/option&gt;  &lt;option value=\&quot;726\&quot;&gt;PARACITO&lt;\/option&gt;  &lt;option value=\&quot;729\&quot;&gt;SANTA_ROSA&lt;\/option&gt;  &lt;option value=\&quot;730\&quot;&gt;SANTO_DOMINGO&lt;\/option&gt;  &lt;option value=\&quot;731\&quot;&gt;SANTO_TOMAS&lt;\/option&gt;  &lt;option value=\&quot;727\&quot;&gt;SAN_MIGUEL&lt;\/option&gt;  &lt;option value=\&quot;728\&quot;&gt;SAN_VICENTE&lt;\/option&gt;  &lt;option value=\&quot;732\&quot;&gt;TURES&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;SAN_ISIDRO\&quot;&gt;  &lt;option value=\&quot;984\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;709\&quot;&gt;CONCEPCION&lt;\/option&gt;  &lt;option value=\&quot;710\&quot;&gt;SAN_FRANCISCO&lt;\/option&gt;  &lt;option value=\&quot;711\&quot;&gt;SAN_ISIDRO&lt;\/option&gt;  &lt;option value=\&quot;712\&quot;&gt;SAN_JOSE&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;SAN_PABLO\&quot;&gt;  &lt;option value=\&quot;985\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;713\&quot;&gt;SAN_PABLO&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;SAN_RAFAEL\&quot;&gt;  &lt;option value=\&quot;986\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;714\&quot;&gt;ANGELES&lt;\/option&gt;  &lt;option value=\&quot;715\&quot;&gt;CONCEPCION&lt;\/option&gt;  &lt;option value=\&quot;718\&quot;&gt;SANTIAGO&lt;\/option&gt;  &lt;option value=\&quot;716\&quot;&gt;SAN_JOSECITO&lt;\/option&gt;  &lt;option value=\&quot;717\&quot;&gt;SAN_RAFAEL&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;SARAPIQUI\&quot;&gt;  &lt;option value=\&quot;989\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;733\&quot;&gt;CURENA&lt;\/option&gt;  &lt;option value=\&quot;734\&quot;&gt;HORQUETAS&lt;\/option&gt;  &lt;option value=\&quot;735\&quot;&gt;LA_VIRGEN&lt;\/option&gt;  &lt;option value=\&quot;736\&quot;&gt;LLANURAS_DEL_GASPAR&lt;\/option&gt;  &lt;option value=\&quot;737\&quot;&gt;PUERTO_VIEJO&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;.Cantón no indicado\&quot;&gt;  &lt;option value=\&quot;997\&quot;&gt;.Distrito no indicado&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;GUACIMO\&quot;&gt;  &lt;option value=\&quot;991\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;738\&quot;&gt;DUACARI&lt;\/option&gt;  &lt;option value=\&quot;739\&quot;&gt;GUACIMO&lt;\/option&gt;  &lt;option value=\&quot;740\&quot;&gt;MERCEDES&lt;\/option&gt;  &lt;option value=\&quot;741\&quot;&gt;POCORA&lt;\/option&gt;  &lt;option value=\&quot;742\&quot;&gt;RIO_JIMENEZ&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;LIMON\&quot;&gt;  &lt;option value=\&quot;992\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;743\&quot;&gt;LIMON&lt;\/option&gt;  &lt;option value=\&quot;744\&quot;&gt;MATAMA&lt;\/option&gt;  &lt;option value=\&quot;745\&quot;&gt;RIO_BLANCO&lt;\/option&gt;  &lt;option value=\&quot;746\&quot;&gt;VALLE_DE_LA_ESTRELLA&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;MATINA\&quot;&gt;  &lt;option value=\&quot;993\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;747\&quot;&gt;BATAN&lt;\/option&gt;  &lt;option value=\&quot;748\&quot;&gt;CARRANDI&lt;\/option&gt;  &lt;option value=\&quot;749\&quot;&gt;MATINA&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;POCOCI\&quot;&gt;  &lt;option value=\&quot;994\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;750\&quot;&gt;CARIARI&lt;\/option&gt;  &lt;option value=\&quot;751\&quot;&gt;COLORADO&lt;\/option&gt;  &lt;option value=\&quot;752\&quot;&gt;GUAPILES&lt;\/option&gt;  &lt;option value=\&quot;753\&quot;&gt;JIMENEZ&lt;\/option&gt;  &lt;option value=\&quot;754\&quot;&gt;RITA&lt;\/option&gt;  &lt;option value=\&quot;755\&quot;&gt;ROXANA&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;SIQUIRRES\&quot;&gt;  &lt;option value=\&quot;995\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;756\&quot;&gt;ALEGRIA&lt;\/option&gt;  &lt;option value=\&quot;757\&quot;&gt;CAIRO&lt;\/option&gt;  &lt;option value=\&quot;758\&quot;&gt;FLORIDA&lt;\/option&gt;  &lt;option value=\&quot;759\&quot;&gt;GERMANIA&lt;\/option&gt;  &lt;option value=\&quot;760\&quot;&gt;PACUARITO&lt;\/option&gt;  &lt;option value=\&quot;761\&quot;&gt;SIQUIRRES&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;TALAMANCA\&quot;&gt;  &lt;option value=\&quot;996\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;762\&quot;&gt;BRATSI&lt;\/option&gt;  &lt;option value=\&quot;763\&quot;&gt;CAHUITA&lt;\/option&gt;  &lt;option value=\&quot;764\&quot;&gt;SIXAOLA&lt;\/option&gt;  &lt;option value=\&quot;765\&quot;&gt;TELIRE&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;.Cantón no indicado\&quot;&gt;  &lt;option value=\&quot;1009\&quot;&gt;.Distrito no indicado&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;AGUIRRE\&quot;&gt;  &lt;option value=\&quot;998\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;766\&quot;&gt;NARANJITO&lt;\/option&gt;  &lt;option value=\&quot;767\&quot;&gt;QUEPOS&lt;\/option&gt;  &lt;option value=\&quot;768\&quot;&gt;SAVEGRE&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;BUENOS_AIRES\&quot;&gt;  &lt;option value=\&quot;999\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;769\&quot;&gt;BIOLLEY&lt;\/option&gt;  &lt;option value=\&quot;770\&quot;&gt;BORUCA&lt;\/option&gt;  &lt;option value=\&quot;771\&quot;&gt;BRUNKA&lt;\/option&gt;  &lt;option value=\&quot;772\&quot;&gt;BUENOS_AIRES&lt;\/option&gt;  &lt;option value=\&quot;773\&quot;&gt;CHANGUENA&lt;\/option&gt;  &lt;option value=\&quot;774\&quot;&gt;COLINAS&lt;\/option&gt;  &lt;option value=\&quot;775\&quot;&gt;PILAS&lt;\/option&gt;  &lt;option value=\&quot;776\&quot;&gt;POTRERO_GRANDE&lt;\/option&gt;  &lt;option value=\&quot;777\&quot;&gt;VOLCAN&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;CORREDORES\&quot;&gt;  &lt;option value=\&quot;1000\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;778\&quot;&gt;CANOAS&lt;\/option&gt;  &lt;option value=\&quot;779\&quot;&gt;CORREDOR&lt;\/option&gt;  &lt;option value=\&quot;781\&quot;&gt;LAUREL&lt;\/option&gt;  &lt;option value=\&quot;780\&quot;&gt;LA_CUESTA&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;COTO_BRUS\&quot;&gt;  &lt;option value=\&quot;1001\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;782\&quot;&gt;AGUABUENA&lt;\/option&gt;  &lt;option value=\&quot;783\&quot;&gt;LIMONCITO&lt;\/option&gt;  &lt;option value=\&quot;784\&quot;&gt;PITTIER&lt;\/option&gt;  &lt;option value=\&quot;785\&quot;&gt;SABALITO&lt;\/option&gt;  &lt;option value=\&quot;786\&quot;&gt;SAN_VITO&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;ESPARZA\&quot;&gt;  &lt;option value=\&quot;1002\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;787\&quot;&gt;ESPIRITU_SANTO&lt;\/option&gt;  &lt;option value=\&quot;788\&quot;&gt;MACACONA&lt;\/option&gt;  &lt;option value=\&quot;789\&quot;&gt;SAN_JERONIMO&lt;\/option&gt;  &lt;option value=\&quot;790\&quot;&gt;SAN_JUAN_GRANDE&lt;\/option&gt;  &lt;option value=\&quot;791\&quot;&gt;SAN_RAFAEL&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;GARABITO\&quot;&gt;  &lt;option value=\&quot;1003\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;792\&quot;&gt;JACO&lt;\/option&gt;  &lt;option value=\&quot;793\&quot;&gt;TARCOLES&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;GOLFITO\&quot;&gt;  &lt;option value=\&quot;1004\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;794\&quot;&gt;GOLFITO&lt;\/option&gt;  &lt;option value=\&quot;795\&quot;&gt;GUAYCARA&lt;\/option&gt;  &lt;option value=\&quot;796\&quot;&gt;PAVON&lt;\/option&gt;  &lt;option value=\&quot;797\&quot;&gt;PUERTO_JIMENEZ&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;MONTES_DE_ORO\&quot;&gt;  &lt;option value=\&quot;1005\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;798\&quot;&gt;MIRAMAR&lt;\/option&gt;  &lt;option value=\&quot;799\&quot;&gt;SAN_ISIDRO&lt;\/option&gt;  &lt;option value=\&quot;800\&quot;&gt;UNION&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;OSA\&quot;&gt;  &lt;option value=\&quot;1006\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;801\&quot;&gt;BAHIA_BALLENA&lt;\/option&gt;  &lt;option value=\&quot;802\&quot;&gt;PALMAR&lt;\/option&gt;  &lt;option value=\&quot;803\&quot;&gt;PIEDRAS_BLANCAS&lt;\/option&gt;  &lt;option value=\&quot;804\&quot;&gt;PUERTO_CORTES&lt;\/option&gt;  &lt;option value=\&quot;805\&quot;&gt;SIERPE&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;PARRITA\&quot;&gt;  &lt;option value=\&quot;1007\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;806\&quot;&gt;PARRITA&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;PUNTARENAS\&quot;&gt;  &lt;option value=\&quot;1008\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;807\&quot;&gt;ACAPULCO&lt;\/option&gt;  &lt;option value=\&quot;808\&quot;&gt;ARANCIBIA&lt;\/option&gt;  &lt;option value=\&quot;809\&quot;&gt;BARRANCA&lt;\/option&gt;  &lt;option value=\&quot;810\&quot;&gt;CHACARITA&lt;\/option&gt;  &lt;option value=\&quot;811\&quot;&gt;CHIRA&lt;\/option&gt;  &lt;option value=\&quot;812\&quot;&gt;CHOMES&lt;\/option&gt;  &lt;option value=\&quot;813\&quot;&gt;COBANO&lt;\/option&gt;  &lt;option value=\&quot;814\&quot;&gt;EL_ROBLE&lt;\/option&gt;  &lt;option value=\&quot;815\&quot;&gt;GUACIMAL&lt;\/option&gt;  &lt;option value=\&quot;816\&quot;&gt;ISLA_DEL_COCO&lt;\/option&gt;  &lt;option value=\&quot;817\&quot;&gt;LEPANTO&lt;\/option&gt;  &lt;option value=\&quot;818\&quot;&gt;MANZANILLO&lt;\/option&gt;  &lt;option value=\&quot;819\&quot;&gt;MONTE_VERDE&lt;\/option&gt;  &lt;option value=\&quot;820\&quot;&gt;PAQUERA&lt;\/option&gt;  &lt;option value=\&quot;821\&quot;&gt;PITAHAYA&lt;\/option&gt;  &lt;option value=\&quot;822\&quot;&gt;PUNTARENAS&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;.Cantón no indicado\&quot;&gt;  &lt;option value=\&quot;1030\&quot;&gt;.Distrito no indicado&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;ACOSTA\&quot;&gt;  &lt;option value=\&quot;1010\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;823\&quot;&gt;CANGREJAL&lt;\/option&gt;  &lt;option value=\&quot;824\&quot;&gt;GUAITIL&lt;\/option&gt;  &lt;option value=\&quot;825\&quot;&gt;PALMICHAL&lt;\/option&gt;  &lt;option value=\&quot;826\&quot;&gt;SABANILLAS&lt;\/option&gt;  &lt;option value=\&quot;827\&quot;&gt;SAN_IGNACIO&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;ALAJUELITA\&quot;&gt;  &lt;option value=\&quot;1011\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;828\&quot;&gt;ALAJUELITA&lt;\/option&gt;  &lt;option value=\&quot;829\&quot;&gt;CONCEPCION&lt;\/option&gt;  &lt;option value=\&quot;830\&quot;&gt;SAN_ANTONIO&lt;\/option&gt;  &lt;option value=\&quot;831\&quot;&gt;SAN_FELIPE&lt;\/option&gt;  &lt;option value=\&quot;832\&quot;&gt;SAN_JOCESITO&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;ASERRI\&quot;&gt;  &lt;option value=\&quot;1012\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;833\&quot;&gt;ASERRI&lt;\/option&gt;  &lt;option value=\&quot;834\&quot;&gt;LEGUA&lt;\/option&gt;  &lt;option value=\&quot;835\&quot;&gt;MONTERREY&lt;\/option&gt;  &lt;option value=\&quot;836\&quot;&gt;SALITRILLOS&lt;\/option&gt;  &lt;option value=\&quot;837\&quot;&gt;SAN_GABRIEL&lt;\/option&gt;  &lt;option value=\&quot;838\&quot;&gt;TARBACA&lt;\/option&gt;  &lt;option value=\&quot;839\&quot;&gt;VUELTA_DE_JORCO&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;CURRIDABAT\&quot;&gt;  &lt;option value=\&quot;1013\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;840\&quot;&gt;CURRIDABAT&lt;\/option&gt;  &lt;option value=\&quot;841\&quot;&gt;GRANADILLA&lt;\/option&gt;  &lt;option value=\&quot;842\&quot;&gt;SANCHEZ&lt;\/option&gt;  &lt;option value=\&quot;843\&quot;&gt;TIRRASES&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;DESAMPARADOS\&quot;&gt;  &lt;option value=\&quot;1014\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;844\&quot;&gt;DAMAS&lt;\/option&gt;  &lt;option value=\&quot;845\&quot;&gt;DESAMPARADOS&lt;\/option&gt;  &lt;option value=\&quot;846\&quot;&gt;FRAILES&lt;\/option&gt;  &lt;option value=\&quot;847\&quot;&gt;GRAVILIAS&lt;\/option&gt;  &lt;option value=\&quot;848\&quot;&gt;LOS_GUIDO&lt;\/option&gt;  &lt;option value=\&quot;849\&quot;&gt;PATARRA&lt;\/option&gt;  &lt;option value=\&quot;850\&quot;&gt;ROSARIO&lt;\/option&gt;  &lt;option value=\&quot;851\&quot;&gt;SAN_ANTONIO&lt;\/option&gt;  &lt;option value=\&quot;852\&quot;&gt;SAN_CRISTOBAL&lt;\/option&gt;  &lt;option value=\&quot;853\&quot;&gt;SAN_JUAN_DE_DIOS&lt;\/option&gt;  &lt;option value=\&quot;854\&quot;&gt;SAN_MIGUEL&lt;\/option&gt;  &lt;option value=\&quot;855\&quot;&gt;SAN_RAFAEL_ABAJO&lt;\/option&gt;  &lt;option value=\&quot;856\&quot;&gt;SAN_RAFAEL_ARRIBA&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;DOTA\&quot;&gt;  &lt;option value=\&quot;1015\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;857\&quot;&gt;COPEY&lt;\/option&gt;  &lt;option value=\&quot;859\&quot;&gt;SANTA_MARIA&lt;\/option&gt;  &lt;option value=\&quot;858\&quot;&gt;SAN_PEDRO_(JARDIN)&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;ESCAZU\&quot;&gt;  &lt;option value=\&quot;1016\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;860\&quot;&gt;ESCAZU&lt;\/option&gt;  &lt;option value=\&quot;861\&quot;&gt;SAN_ANTONIO&lt;\/option&gt;  &lt;option value=\&quot;862\&quot;&gt;SAN_RAFAEL&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;GOICOECHEA\&quot;&gt;  &lt;option value=\&quot;1017\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;863\&quot;&gt;CALLE_BLANCOS&lt;\/option&gt;  &lt;option value=\&quot;864\&quot;&gt;GUADALUPE&lt;\/option&gt;  &lt;option value=\&quot;865\&quot;&gt;IPIS&lt;\/option&gt;  &lt;option value=\&quot;866\&quot;&gt;MATA_DE_PLATANO&lt;\/option&gt;  &lt;option value=\&quot;867\&quot;&gt;PURRAL&lt;\/option&gt;  &lt;option value=\&quot;868\&quot;&gt;RANCHO_REDONDO&lt;\/option&gt;  &lt;option value=\&quot;869\&quot;&gt;SAN_FRANCISCO&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;LEON_CORTES\&quot;&gt;  &lt;option value=\&quot;1018\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;870\&quot;&gt;LLANO_BONITO&lt;\/option&gt;  &lt;option value=\&quot;875\&quot;&gt;SANTA_CRUZ&lt;\/option&gt;  &lt;option value=\&quot;871\&quot;&gt;SAN_ANDRES&lt;\/option&gt;  &lt;option value=\&quot;872\&quot;&gt;SAN_ANTONIO&lt;\/option&gt;  &lt;option value=\&quot;873\&quot;&gt;SAN_ISIDRO&lt;\/option&gt;  &lt;option value=\&quot;874\&quot;&gt;SAN_PABLO&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;MONTES_DE_OCA\&quot;&gt;  &lt;option value=\&quot;1019\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;876\&quot;&gt;MERCEDES&lt;\/option&gt;  &lt;option value=\&quot;877\&quot;&gt;SABANILLA&lt;\/option&gt;  &lt;option value=\&quot;878\&quot;&gt;SAN_PEDRO&lt;\/option&gt;  &lt;option value=\&quot;879\&quot;&gt;SAN_RAFAEL&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;MORA\&quot;&gt;  &lt;option value=\&quot;1020\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;880\&quot;&gt;COLON&lt;\/option&gt;  &lt;option value=\&quot;881\&quot;&gt;GUAYABO&lt;\/option&gt;  &lt;option value=\&quot;882\&quot;&gt;PICAGRES&lt;\/option&gt;  &lt;option value=\&quot;883\&quot;&gt;PIEDRAS_NEGRAS&lt;\/option&gt;  &lt;option value=\&quot;884\&quot;&gt;TABARCIA&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;MORAVIA\&quot;&gt;  &lt;option value=\&quot;1021\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;885\&quot;&gt;SAN_JERONIMO&lt;\/option&gt;  &lt;option value=\&quot;886\&quot;&gt;SAN_VICENTE&lt;\/option&gt;  &lt;option value=\&quot;887\&quot;&gt;TRINIDAD&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;PEREZ_ZELEDON\&quot;&gt;  &lt;option value=\&quot;1022\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;888\&quot;&gt;BARU&lt;\/option&gt;  &lt;option value=\&quot;889\&quot;&gt;CAJON&lt;\/option&gt;  &lt;option value=\&quot;890\&quot;&gt;DANIEL_FLORES&lt;\/option&gt;  &lt;option value=\&quot;891\&quot;&gt;GENERAL&lt;\/option&gt;  &lt;option value=\&quot;892\&quot;&gt;PARAMO&lt;\/option&gt;  &lt;option value=\&quot;893\&quot;&gt;PEJIBAYE&lt;\/option&gt;  &lt;option value=\&quot;894\&quot;&gt;PLATANARES&lt;\/option&gt;  &lt;option value=\&quot;895\&quot;&gt;RIO_NUEVO&lt;\/option&gt;  &lt;option value=\&quot;896\&quot;&gt;RIVAS&lt;\/option&gt;  &lt;option value=\&quot;897\&quot;&gt;SAN_ISIDRO_DEL_GENERAL&lt;\/option&gt;  &lt;option value=\&quot;898\&quot;&gt;SAN_PEDRO&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;PURISCAL\&quot;&gt;  &lt;option value=\&quot;1023\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;899\&quot;&gt;BARBACOAS&lt;\/option&gt;  &lt;option value=\&quot;900\&quot;&gt;CANDELARITA&lt;\/option&gt;  &lt;option value=\&quot;901\&quot;&gt;CHIRES&lt;\/option&gt;  &lt;option value=\&quot;902\&quot;&gt;DESAMPARADITOS&lt;\/option&gt;  &lt;option value=\&quot;903\&quot;&gt;GRIFO_ALTO&lt;\/option&gt;  &lt;option value=\&quot;904\&quot;&gt;MERCEDES_SUR&lt;\/option&gt;  &lt;option value=\&quot;907\&quot;&gt;SANTIAGO&lt;\/option&gt;  &lt;option value=\&quot;905\&quot;&gt;SAN_ANTONIO&lt;\/option&gt;  &lt;option value=\&quot;906\&quot;&gt;SAN_RAFAEL&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;SANTA_ANA\&quot;&gt;  &lt;option value=\&quot;1025\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;919\&quot;&gt;BRASIL&lt;\/option&gt;  &lt;option value=\&quot;920\&quot;&gt;PIEDADES&lt;\/option&gt;  &lt;option value=\&quot;921\&quot;&gt;POZOS&lt;\/option&gt;  &lt;option value=\&quot;922\&quot;&gt;SALITRAL&lt;\/option&gt;  &lt;option value=\&quot;923\&quot;&gt;SANTA_ANA&lt;\/option&gt;  &lt;option value=\&quot;924\&quot;&gt;URUCA&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;SAN_JOSE\&quot;&gt;  &lt;option value=\&quot;1024\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;908\&quot;&gt;CARMEN&lt;\/option&gt;  &lt;option value=\&quot;909\&quot;&gt;CATEDRAL&lt;\/option&gt;  &lt;option value=\&quot;910\&quot;&gt;HATILLO&lt;\/option&gt;  &lt;option value=\&quot;911\&quot;&gt;HOSPITAL&lt;\/option&gt;  &lt;option value=\&quot;912\&quot;&gt;MATA_REDONDA&lt;\/option&gt;  &lt;option value=\&quot;913\&quot;&gt;MERCED&lt;\/option&gt;  &lt;option value=\&quot;914\&quot;&gt;PAVAS&lt;\/option&gt;  &lt;option value=\&quot;915\&quot;&gt;SAN_FCO._DE_DOS_RIOS&lt;\/option&gt;  &lt;option value=\&quot;916\&quot;&gt;SAN_SEBASTIAN&lt;\/option&gt;  &lt;option value=\&quot;917\&quot;&gt;URUCA&lt;\/option&gt;  &lt;option value=\&quot;918\&quot;&gt;ZAPOTE&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;TARRAZU\&quot;&gt;  &lt;option value=\&quot;1026\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;925\&quot;&gt;SAN_CARLOS&lt;\/option&gt;  &lt;option value=\&quot;926\&quot;&gt;SAN_LORENZO&lt;\/option&gt;  &lt;option value=\&quot;927\&quot;&gt;SAN_MARCOS&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;TIBAS\&quot;&gt;  &lt;option value=\&quot;1027\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;928\&quot;&gt;ANSELMO_LLORENTE&lt;\/option&gt;  &lt;option value=\&quot;929\&quot;&gt;CINCO_ESQUINAS&lt;\/option&gt;  &lt;option value=\&quot;930\&quot;&gt;COLIMA&lt;\/option&gt;  &lt;option value=\&quot;931\&quot;&gt;LEON_XIII&lt;\/option&gt;  &lt;option value=\&quot;932\&quot;&gt;SAN_JUAN&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;TURRUBARES\&quot;&gt;  &lt;option value=\&quot;1028\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;933\&quot;&gt;CARARA&lt;\/option&gt;  &lt;option value=\&quot;934\&quot;&gt;SAN_JUAN_DE_MATA&lt;\/option&gt;  &lt;option value=\&quot;935\&quot;&gt;SAN_LUIS&lt;\/option&gt;  &lt;option value=\&quot;936\&quot;&gt;SAN_PABLO&lt;\/option&gt;  &lt;option value=\&quot;937\&quot;&gt;SAN_PEDRO&lt;\/option&gt; &lt;\/optgroup&gt;&lt;optgroup label=\&quot;VAZQUEZ_DE_CORONADO\&quot;&gt;  &lt;option value=\&quot;1029\&quot;&gt;.Distrito no indicado&lt;\/option&gt;  &lt;option value=\&quot;938\&quot;&gt;CASCAJAL&lt;\/option&gt;  &lt;option value=\&quot;939\&quot;&gt;DULCE_NOMBRE_DE_JESUS&lt;\/option&gt;  &lt;option value=\&quot;940\&quot;&gt;PATALILLO&lt;\/option&gt;  &lt;option value=\&quot;941\&quot;&gt;SAN_ISIDRO&lt;\/option&gt;  &lt;option value=\&quot;942\&quot;&gt;SAN_RAFAEL&lt;\/option&gt; &lt;\/optgroup&gt;\n &lt;\/select&gt;\n &lt;\/div&gt;\n\n &lt;\/div&gt;\n \n \n &lt;div class=\&quot;col-md-4\&quot;&gt;\n &lt;div class=\&quot;form-group\&quot;&gt;\n &lt;label for=\&quot;permiso_espectro_attributes_frecuencia_espectro_attributes_0_zona_attributes_new_zona_Nota\&quot;&gt;Nota&lt;\/label&gt;\n &lt;textarea rows=\&quot;3\&quot; name=\&quot;permiso[espectro_attributes][frecuencia_espectro_attributes][0][zona_attributes][new_zona][nota]\&quot; id=\&quot;permiso_espectro_attributes_frecuencia_espectro_attributes_0_zona_attributes_new_zona_Nota\&quot;&gt;\n&lt;\/textarea&gt;\n &lt;\/div&gt;\n    &quot;);" class="glyphicon glyphicon-plus" href="javascript:void(0)"></a> </p>

</div>
</div>
</div>
   '
    n = Time.new
    #my_string = my_string.gsub(/frecuencia_espectro_attributes\]\[0\]/,'frecuencia_espectro_attributes]['+n.to_i.to_s+']').gsub(/frecuencia_espectro_attributes_0/,'frecuencia_espectro_attributes_'+n.to_i.to_s)
    my_string = my_string.gsub(/frecuencia_espectro_attributes\]\[0\]/,'frecuencia_espectro_attributes][new_frecuencia_espectro_attributes]').gsub(/frecuencia_espectro_attributes_0/,'frecuencia_espectro_attributes_new_frecuencia_espectro_attributes')
    my_string
  end

  def servicios_fields
   ' 
<div class="row">
<div class="col-md-4">
<div class="form-group">
<input type="hidden" name="concesion_direct[titulo_habilitante_attributes][servicio_habilitados_attributes][new_servicio_habilitados][id]" id="concesion_direct_titulo_habilitante_attributes_servicio_habilitados_attributes_new_servicio_habilitados_id" />
<label for="concesion_direct_titulo_habilitante_attributes_servicio_habilitados_attributes_new_servicio_habilitados_seleccionar_servicio">Seleccionar servicio</label>
<select name="concesion_direct[titulo_habilitante_attributes][servicio_habilitados_attributes][new_servicio_habilitados][sciservicio_id]" id="concesion_direct_titulo_habilitante_attributes_servicio_habilitados_attributes_new_servicio_habilitados_sciservicio_id"><option value="">Seleccionar Servicio</option>
<option value="18">.No.Aplica</option>
<option value="5">General</option>
<option value="1">Telefonía Fija</option>
<option value="7">Telefonía IP</option>
<option value="6">Telefonía Internacional</option>
<option value="8">Telefonía Pública</option>
<option value="2">Telefonía móvil</option>
<option value="4">Televisión por suscripción</option>
<option value="3">Transferencia de datos</option></select>
</div>
</div>
<div class="col-md-4">
<div class="form-group">
<label for="concesion_direct_titulo_habilitante_attributes_servicio_habilitados_attributes_new_servicio_habilitados_Servicio sobre el Servicio">ó podes incluir el servicio aquí</label>
<input class="form-control" type="text" name="concesion_direct[titulo_habilitante_attributes][servicio_habilitados_attributes][new_servicio_habilitados][servicio]" id="concesion_direct_titulo_habilitante_attributes_servicio_habilitados_attributes_new_servicio_habilitados_servicio" />
</div>
</div>
</div>
    '
  end
  
  def operadores_resolucion_ubicacion_equipos_string
    x = get_operadores_xml
    resultado = '
<div class="panel panel-default">
<div class="panel-heading">Operadores</div>
<div class="panel-body">

<div class="col-xs-6 col-md-4">
<div class="form-group">
<label for="resolucion_ubicacion_equipo_operadores_resolucion_ubicacion_equipos_attributes_new_operadores_resolucion_ubicacion_equipos_seleccionar_operador">Seleccionar operador</label>
<select onchange="get_operadores(&quot;operadores_resolucion_ubicacion_equipos&quot;,this);" name="resolucion_ubicacion_equipo[operadores_resolucion_ubicacion_equipos_attributes][new_operadores_resolucion_ubicacion_equipos][operador_regulados_id]" id="resolucion_ubicacion_equipo_operadores_resolucion_ubicacion_equipos_attributes_new_operadores_resolucion_ubicacion_equipos_operador_regulados_id"><option value="">Seleccionar Operador (si aplica)</option>
' + x + '
</select>
</div>
</div>
<div id="operador">
<div class="col-xs-6 col-md-4">
<div class="form-group">
<label for="resolucion_ubicacion_equipo_operadores_resolucion_ubicacion_equipos_attributes_new_operadores_resolucion_ubicacion_equipos_Nombre Operador">Nombre operador</label>
<input class="form-control" type="text" name="resolucion_ubicacion_equipo[operadores_resolucion_ubicacion_equipos_attributes][new_operadores_resolucion_ubicacion_equipos][nombre_operador]" id="resolucion_ubicacion_equipo_operadores_resolucion_ubicacion_equipos_attributes_new_operadores_resolucion_ubicacion_equipos_nombre_operador" />
</div>
<div class="form-group">
<label for="resolucion_ubicacion_equipo_operadores_resolucion_ubicacion_equipos_attributes_new_operadores_resolucion_ubicacion_equipos_Identificación Operador">Identificación operador</label>
<input class="form-control" type="text" name="resolucion_ubicacion_equipo[operadores_resolucion_ubicacion_equipos_attributes][new_operadores_resolucion_ubicacion_equipos][identificacion_operador]" id="resolucion_ubicacion_equipo_operadores_resolucion_ubicacion_equipos_attributes_new_operadores_resolucion_ubicacion_equipos_identificacion_operador" />
</div>
</div>
<div class="col-xs-6 col-md-4">
<div class="form-group">
<label for="resolucion_ubicacion_equipo_operadores_resolucion_ubicacion_equipos_attributes_new_operadores_resolucion_ubicacion_equipos_nombre_representante_legal">Nombre representante legal</label>
<input class="form-control" type="text" name="resolucion_ubicacion_equipo[operadores_resolucion_ubicacion_equipos_attributes][new_operadores_resolucion_ubicacion_equipos][nombre_representante_legal]" id="resolucion_ubicacion_equipo_operadores_resolucion_ubicacion_equipos_attributes_new_operadores_resolucion_ubicacion_equipos_nombre_representante_legal" />
</div>
<div class="form-group">
<label for="resolucion_ubicacion_equipo_operadores_resolucion_ubicacion_equipos_attributes_new_operadores_resolucion_ubicacion_equipos_cedula_representante_legal">Cedula representante legal</label>
<input class="form-control" type="text" name="resolucion_ubicacion_equipo[operadores_resolucion_ubicacion_equipos_attributes][new_operadores_resolucion_ubicacion_equipos][cedula_representante_legal]" id="resolucion_ubicacion_equipo_operadores_resolucion_ubicacion_equipos_attributes_new_operadores_resolucion_ubicacion_equipos_cedula_representante_legal" />
</div>
</div>
</div>

</div>
</div>
    '
    return resultado
  end

  def operadores_convenio_ubicacion_equipos_string
    x = get_operadores_xml
    resultado =  '
<div class="panel panel-default">
<div class="panel-heading">Operadores</div>
<div class="panel-body">

<div class="col-xs-6 col-md-4">
<div class="form-group">
<label for="convenio_ubicacion_equipo_operadores_convenio_ubicacion_equipos_attributes_new_operadores_convenio_ubicacion_equipos_seleccionar_operador">Seleccionar operador</label>
<select onchange="get_operadores(&quot;operadores_convenio_ubicacion_equipos&quot;,this);" name="convenio_ubicacion_equipo[operadores_convenio_ubicacion_equipos_attributes][new_operadores_convenio_ubicacion_equipos][operador_regulados_id]" id="convenio_ubicacion_equipo_operadores_convenio_ubicacion_equipos_attributes_new_operadores_convenio_ubicacion_equipos_operador_regulados_id"><option value="">Seleccionar Operador (si aplica)</option>
' + x + '
</select>
</div>
</div>
<div id="operador">
<div class="col-xs-6 col-md-4">
<div class="form-group">
<label for="convenio_ubicacion_equipo_operadores_convenio_ubicacion_equipos_attributes_new_operadores_convenio_ubicacion_equipos_Nombre Operador">Nombre operador</label>
<input class="form-control" type="text" name="convenio_ubicacion_equipo[operadores_convenio_ubicacion_equipos_attributes][new_operadores_convenio_ubicacion_equipos][nombre_operador]" id="convenio_ubicacion_equipo_operadores_convenio_ubicacion_equipos_attributes_new_operadores_convenio_ubicacion_equipos_nombre_operador" />
</div>
<div class="form-group">
<label for="convenio_ubicacion_equipo_operadores_convenio_ubicacion_equipos_attributes_new_operadores_convenio_ubicacion_equipos_Identificación Operador">Identificación operador</label>
<input class="form-control" type="text" name="convenio_ubicacion_equipo[operadores_convenio_ubicacion_equipos_attributes][new_operadores_convenio_ubicacion_equipos][identificacion_operador]" id="convenio_ubicacion_equipo_operadores_convenio_ubicacion_equipos_attributes_new_operadores_convenio_ubicacion_equipos_identificacion_operador" />
</div>
</div>
<div class="col-xs-6 col-md-4">
<div class="form-group">
<label for="convenio_ubicacion_equipo_operadores_convenio_ubicacion_equipos_attributes_new_operadores_convenio_ubicacion_equipos_nombre_representante_legal">Nombre representante legal</label>
<input class="form-control" type="text" name="convenio_ubicacion_equipo[operadores_convenio_ubicacion_equipos_attributes][new_operadores_convenio_ubicacion_equipos][nombre_representante_legal]" id="convenio_ubicacion_equipo_operadores_convenio_ubicacion_equipos_attributes_new_operadores_convenio_ubicacion_equipos_nombre_representante_legal" />
</div>
<div class="form-group">
<label for="convenio_ubicacion_equipo_operadores_convenio_ubicacion_equipos_attributes_new_operadores_convenio_ubicacion_equipos_cedula_representante_legal">Cedula representante legal</label>
<input class="form-control" type="text" name="convenio_ubicacion_equipo[operadores_convenio_ubicacion_equipos_attributes][new_operadores_convenio_ubicacion_equipos][cedula_representante_legal]" id="convenio_ubicacion_equipo_operadores_convenio_ubicacion_equipos_attributes_new_operadores_convenio_ubicacion_equipos_cedula_representante_legal" />
</div>
</div>
</div>

</div>
</div>
    '
  end
  
  def servicios_interconexion_string
    '
    <div class="row">
    <div class="col-md-2">
    <div class="form-group">
    <input type="hidden" name="acuerdo_acceso_interconexion[servicios_interconexion_attributes][new_servicios_interconexion][id]" id="acuerdo_acceso_interconexion_servicios_interconexion_attributes_new_servicios_interconexion_id" />
    <label for="acuerdo_acceso_interconexion_servicios_interconexion_attributes_new_servicios_interconexion_seleccionar_servicio">Seleccionar servicio</label>
    <select name="acuerdo_acceso_interconexion[servicios_interconexion_attributes][new_servicios_interconexion][sci_servicios_id]" id="acuerdo_acceso_interconexion_servicios_interconexion_attributes_new_servicios_interconexion_sci_servicios_id">
<option value="18">.No.Aplica</option>
<option value="5">General</option>
<option value="1">Telefonía Fija</option>
<option value="7">Telefonía IP</option>
<option value="6">Telefonía Internacional</option>
<option value="8">Telefonía Pública</option>
<option value="2">Telefonía móvil</option>
<option value="4">Televisión por suscripción</option>
<option value="3">Transferencia de datos</option></select>
    </div>
    </div>
    

  <div class="col-md-6">
    <div class="form-group">
        <input type="hidden" name="acuerdo_acceso_interconexion[servicios_interconexion_attributes][new_servicios_interconexion][id]" id="acuerdo_acceso_interconexion_servicios_interconexion_attributes_new_servicios_interconexion_id" />
        <label for="acuerdo_acceso_interconexion_servicios_interconexion_attributes_0_ó podes incluir el servicio aquí">ó podes incluir el servicio aquí</label>
        <input class="form-control" placeholder="usar esta casilla si no encontrás el servicio en la lista" type="text" name="acuerdo_acceso_interconexion[servicios_interconexion_attributes][new_servicios_interconexion][servicio]" id="acuerdo_acceso_interconexion_servicios_interconexion_attributes_new_servicios_interconexion_servicio" />
    </div>
  </div>

  <div class="col-md-3">
    <div class="form-group">
      <label for="acuerdo_acceso_interconexion_servicios_interconexion_attributes_new_servicios_interconexion_Precio">Precio</label>
      <input class="form-control" step="0.001" type="number" name="acuerdo_acceso_interconexion[servicios_interconexion_attributes][new_servicios_interconexion][precio_interconexion]" id="acuerdo_acceso_interconexion_servicios_interconexion_attributes_new_servicios_interconexion_precio_interconexion" />
    </div>
  </div>
    
    </div>
    '
  end
  
  def servicio_contrato_adhesions_string
    '
<div class="row">
<div class="col-md-4">
  <div class="form-group">
        <input type="hidden" name="contrato_adhesion[servicio_contrato_adhesions_attributes][new_servicio_contrato_adhesions][id]" id="contrato_adhesion_servicio_contrato_adhesions_attributes_new_servicio_contrato_adhesions_id" />
              <label for="contrato_adhesion_servicio_contrato_adhesions_attributes_new_servicio_contrato_adhesions_seleccionar_servicio">Seleccionar servicio</label>
                    <select name="contrato_adhesion[servicio_contrato_adhesions_attributes][new_servicio_contrato_adhesions][sci_servicios_id]" id="contrato_adhesion_servicio_contrato_adhesions_attributes_new_servicio_contrato_adhesions_sci_servicios_id">
<option value="18">.No.Aplica</option>
<option value="5">General</option>
<option value="1">Telefonía Fija</option>
<option value="7">Telefonía IP</option>
<option value="6">Telefonía Internacional</option>
<option value="8">Telefonía Pública</option>
<option value="2">Telefonía móvil</option>
<option value="4">Televisión por suscripción</option>
<option value="3">Transferencia de datos</option></select>
                      </div>
                      </div>

    <div class="col-md-6">
      <div class="form-group">
          <label for="contrato_adhesion_servicio_contrato_adhesions_attributes_new_servicio_contrato_adhesions_ó podes incluir el servicio aquí">ó podes incluir el servicio aquí</label>
          <input class="form-control" placeholder="usar esta casilla si no encontrás el servicio en la lista" type="text" name="contrato_adhesion[servicio_contrato_adhesions_attributes][new_servicio_contrato_adhesions][servicio]" id="contrato_adhesion_servicio_contrato_adhesions_attributes_new_servicio_contrato_adhesions_servicio" />
      </div>
    </div>
    </div>

    '
  end
  
  def operadores_acuerdo_acceso_interconexions_string
    x = get_operadores_xml
    resultado =  '

          <div class="panel panel-default">
            <div class="panel-heading">Operadores</div>
              <div class="panel-body">
                    
                      <div class="col-xs-6 col-md-4">
  <div class="form-group">
    <label for="acuerdo_acceso_interconexion_operadores_acuerdo_acceso_interconexions_attributes_new_operadores_acuerdo_acceso_interconexions_seleccionar_operador">Seleccionar operador</label>
    <select onchange="get_operadores(&quot;operadores_acuerdo_acceso_interconexions&quot;,this);" name="acuerdo_acceso_interconexion[operadores_acuerdo_acceso_interconexions_attributes][new_operadores_acuerdo_acceso_interconexions][operador_regulados_id]" id="acuerdo_acceso_interconexion_operadores_acuerdo_acceso_interconexions_attributes_new_operadores_acuerdo_acceso_interconexions_operador_regulados_id"><option value="">Seleccionar Operador (si aplica)</option>
' + x + '
</select>
  </div>
</div>
<div id="operador">
  <div class="col-xs-6 col-md-4">
    <div class="form-group">
      <label for="acuerdo_acceso_interconexion_operadores_acuerdo_acceso_interconexions_attributes_new_operadores_acuerdo_acceso_interconexions_Nombre Operador">Nombre operador</label>
      <input class="form-control" type="text" name="acuerdo_acceso_interconexion[operadores_acuerdo_acceso_interconexions_attributes][new_operadores_acuerdo_acceso_interconexions][nombre_operador]" id="acuerdo_acceso_interconexion_operadores_acuerdo_acceso_interconexions_attributes_new_operadores_acuerdo_acceso_interconexions_nombre_operador" />
    </div>
    <div class="form-group">
      <label for="acuerdo_acceso_interconexion_operadores_acuerdo_acceso_interconexions_attributes_new_operadores_acuerdo_acceso_interconexions_Identificación Operador">Identificación operador</label>
      <input class="form-control" type="text" name="acuerdo_acceso_interconexion[operadores_acuerdo_acceso_interconexions_attributes][new_operadores_acuerdo_acceso_interconexions][identificacion_operador]" id="acuerdo_acceso_interconexion_operadores_acuerdo_acceso_interconexions_attributes_new_operadores_acuerdo_acceso_interconexions_identificacion_operador" />
    </div>
  </div>
  <div class="col-xs-6 col-md-4">
    <div class="form-group">
      <label for="acuerdo_acceso_interconexion_operadores_acuerdo_acceso_interconexions_attributes_new_operadores_acuerdo_acceso_interconexions_nombre_representante_legal">Nombre representante legal</label>
      <input class="form-control" type="text" name="acuerdo_acceso_interconexion[operadores_acuerdo_acceso_interconexions_attributes][new_operadores_acuerdo_acceso_interconexions][nombre_representante_legal]" id="acuerdo_acceso_interconexion_operadores_acuerdo_acceso_interconexions_attributes_new_operadores_acuerdo_acceso_interconexions_nombre_representante_legal" />
    </div>
    <div class="form-group">
      <label for="acuerdo_acceso_interconexion_operadores_acuerdo_acceso_interconexions_attributes_new_operadores_acuerdo_acceso_interconexions_cedula_representante_legal">Cedula representante legal</label>
      <input class="form-control" type="text" name="acuerdo_acceso_interconexion[operadores_acuerdo_acceso_interconexions_attributes][new_operadores_acuerdo_acceso_interconexions][cedula_representante_legal]" id="acuerdo_acceso_interconexion_operadores_acuerdo_acceso_interconexions_attributes_new_operadores_acuerdo_acceso_interconexions_cedula_representante_legal" />
    </div>
  </div>
</div>


            </div>
          </div>
          <div>
    '
  end

  def oferta_interconexion_servicios_string
    '
    <div class="row">
    <div class="col-md-2">
    <div class="form-group">
    <input type="hidden" name="oferta_interconexion[oferta_interconexion_servicios_attributes][new_oferta_interconexion_servicios][id]" id="oferta_interconexion_oferta_interconexion_servicios_attributes_new_oferta_interconexion_servicios_id" />
    <label for="oferta_interconexion_oferta_interconexion_servicios_attributes_new_oferta_interconexion_servicios_seleccionar_servicio">Seleccionar servicio</label>
    <select name="oferta_interconexion[oferta_interconexion_servicios_attributes][new_oferta_interconexion_servicios][sci_servicios_id]" id="oferta_interconexion_oferta_interconexion_servicios_attributes_new_oferta_interconexion_servicios_sci_servicios_id">
<option value="18">.No.Aplica</option>
<option value="5">General</option>
<option value="1">Telefonía Fija</option>
<option value="7">Telefonía IP</option>
<option value="6">Telefonía Internacional</option>
<option value="8">Telefonía Pública</option>
<option value="2">Telefonía móvil</option>
<option value="4">Televisión por suscripción</option>
<option value="3">Transferencia de datos</option></select>
    </div>
    </div>


  <div class="col-md-6">
    <div class="form-group">
        <label for="oferta_interconexion_oferta_interconexion_servicios_attributes_new_oferta_interconexion_servicios_ó podes incluir el servicio aquí">ó podes incluir el servicio aquí</label>
        <input class="form-control" placeholder="usar esta casilla si no encontrás el servicio en la lista" type="text" name="oferta_interconexion[oferta_interconexion_servicios_attributes][new_oferta_interconexion_servicios][servicio]" id="oferta_interconexion_oferta_interconexion_servicios_attributes_new_oferta_interconexion_servicios_servicio" />
    </div>
  </div>

    <div class="col-md-3">
    <div class="form-group">
    <label for="oferta_interconexion_oferta_interconexion_servicios_attributes_new_oferta_interconexion_servicios_Precio">Precio</label>
    <input class="form-control" step="0.01" type="number" name="oferta_interconexion[oferta_interconexion_servicios_attributes][new_oferta_interconexion_servicios][precio]" id="oferta_interconexion_oferta_interconexion_servicios_attributes_new_oferta_interconexion_servicios_precio" />
    </div>
    </div>
    </div>
    '
  end

  def operadores_orden_acceso_interconexions_string
    x = get_operadores_xml
    resultado =   '

<div class="panel panel-default">
<div class="panel-heading">Operadores</div>
<div class="panel-body">

<div class="col-xs-6 col-md-4">
<div class="form-group">
<label for="orden_acceso_interconexion_operadores_orden_acceso_interconexions_attributes_new_operadores_orden_acceso_interconexions_seleccionar_operador">Seleccionar operador</label>
<select onchange="get_operadores(&quot;operadores_orden_acceso_interconexions&quot;,this);" name="orden_acceso_interconexion[operadores_orden_acceso_interconexions_attributes][new_operadores_orden_acceso_interconexions][operador_regulados_id]" id="orden_acceso_interconexion_operadores_orden_acceso_interconexions_attributes_new_operadores_orden_acceso_interconexions_operador_regulados_id"><option value="">Seleccionar Operador (si aplica)</option>
' + x + '
</select>
</div>
</div>
<div id="operador">
<div class="col-xs-6 col-md-4">
<div class="form-group">
<label for="orden_acceso_interconexion_operadores_orden_acceso_interconexions_attributes_new_operadores_orden_acceso_interconexions_Nombre Operador">Nombre operador</label>
<input class="form-control" type="text" name="orden_acceso_interconexion[operadores_orden_acceso_interconexions_attributes][new_operadores_orden_acceso_interconexions][nombre_operador]" id="orden_acceso_interconexion_operadores_orden_acceso_interconexions_attributes_new_operadores_orden_acceso_interconexions_nombre_operador" />
</div>
<div class="form-group">
<label for="orden_acceso_interconexion_operadores_orden_acceso_interconexions_attributes_new_operadores_orden_acceso_interconexions_Identificación Operador">Identificación operador</label>
<input class="form-control" type="text" name="orden_acceso_interconexion[operadores_orden_acceso_interconexions_attributes][new_operadores_orden_acceso_interconexions][identificacion_operador]" id="orden_acceso_interconexion_operadores_orden_acceso_interconexions_attributes_new_operadores_orden_acceso_interconexions_identificacion_operador" />
</div>
</div>
<div class="col-xs-6 col-md-4">
<div class="form-group">
<label for="orden_acceso_interconexion_operadores_orden_acceso_interconexions_attributes_new_operadores_orden_acceso_interconexions_nombre_representante_legal">Nombre representante legal</label>
<input class="form-control" type="text" name="orden_acceso_interconexion[operadores_orden_acceso_interconexions_attributes][new_operadores_orden_acceso_interconexions][nombre_representante_legal]" id="orden_acceso_interconexion_operadores_orden_acceso_interconexions_attributes_new_operadores_orden_acceso_interconexions_nombre_representante_legal" />
</div>
<div class="form-group">
<label for="orden_acceso_interconexion_operadores_orden_acceso_interconexions_attributes_new_operadores_orden_acceso_interconexions_cedula_representante_legal">Cedula representante legal</label>
<input class="form-control" type="text" name="orden_acceso_interconexion[operadores_orden_acceso_interconexions_attributes][new_operadores_orden_acceso_interconexions][cedula_representante_legal]" id="orden_acceso_interconexion_operadores_orden_acceso_interconexions_attributes_new_operadores_orden_acceso_interconexions_cedula_representante_legal" />
</div>
</div>
</div>

</div>
</div>
    '
  end
  
  def detalle_recurso_numericos_string
   '
<div class="panel panel-default">
<div class="panel-heading">El Recurso de Numeración</div>
<div class="panel-body">
<div class="col-md-4">
<div class="form-group">
<label for="recurso_numerico_detalle_recurso_numericos_attributes_new_detalle_recurso_numericos_attributes_Rango de Numeración">Rango de numeración</label>
<input class="form-control" type="text" value="" name="recurso_numerico[detalle_recurso_numericos_attributes][new_detalle_recurso_numericos_attributes][rango_numeracion]" id="recurso_numerico_detalle_recurso_numericos_attributes_new_detalle_recurso_numericos_attributes_rango_numeracion" />
</div>
<div class="form-group">
<label for="recurso_numerico_detalle_recurso_numericos_attributes_new_detalle_recurso_numericos_attributes_numero_asignado">Numero asignado</label>
<input class="form-control" type="text" value="" name="recurso_numerico[detalle_recurso_numericos_attributes][new_detalle_recurso_numericos_attributes][numero_asignado]" id="recurso_numerico_detalle_recurso_numericos_attributes_new_detalle_recurso_numericos_attributes_numero_asignado" />
</div>
</div>
<div class="col-md-8">
<div class="form-group">
<label for="recurso_numerico_detalle_recurso_numericos_attributes_new_detalle_recurso_numericos_attributes_Tipo recurso numérico">Tipo recurso numérico</label>
<select name="recurso_numerico[detalle_recurso_numericos_attributes][new_detalle_recurso_numericos_attributes][tipo_recurso_numerico]" id="recurso_numerico_detalle_recurso_numericos_attributes_new_detalle_recurso_numericos_attributes_tipo_recurso_numerico"><option value="ochodigitos">Usuario final 8 dígitos</option>
<option value="revertido800">Servicios de Cobro Revertido numeración 800-10 dígitos</option>
<option selected="selected" value="numeracion900">Servicios de llamadas de contenido numeración 900-10 dígitos</option>
<option value="especial4digitos">Servicios de numeración especial de cuatro dígitos</option>
<option value="sms_4digitos">Servicios de numeración corta SMS cuatro dígitos</option>
<option value="mms">Servicios MMS</option>
<option value="numeracion">Servicios de numeración</option>
<option value="maritimo_mmsi">Servicios de numeración móvil marítimo MMSI</option>
<option value="aeronautica">Servicios de numeración aeronáutica</option></select>
</div>
<div class="form-group">
<label for="recurso_numerico_detalle_recurso_numericos_attributes_new_detalle_recurso_numericos_attributes_nota">Nota</label>
<textarea rows="3" name="recurso_numerico[detalle_recurso_numericos_attributes][new_detalle_recurso_numericos_attributes][nota]" id="recurso_numerico_detalle_recurso_numericos_attributes_new_detalle_recurso_numericos_attributes_nota">
</textarea>
</div>
</div>
</div>
</div>
   '
  end
  
  def detalle_tarifas_string
    '

          <div class="panel panel-default">
            <div class="panel-heading">Detalle Precios y Tarifas</div>
              <div class="panel-body">
<div class="row">       
                      <div class="col-xs-6 col-md-4">
  <div class="form-group">
    <label for="precios_tarifa_detalle_precios_tarifas_attributes_new_detalle_precios_tarifas_Descripción Servicio">Descripción servicio</label>
    <select name="precios_tarifa[detalle_precios_tarifas_attributes][new_detalle_precios_tarifas][sci_servicios_id]" id="precios_tarifa_detalle_precios_tarifas_attributes_new_detalle_precios_tarifas_sci_servicios_id">
<option value="18">.No.Aplica</option>
<option value="5">General</option>
<option value="1">Telefonía Fija</option>
<option value="7">Telefonía IP</option>
<option value="6">Telefonía Internacional</option>
<option value="8">Telefonía Pública</option>
<option value="2">Telefonía móvil</option>
<option value="4">Televisión por suscripción</option>
<option value="3">Transferencia de datos</option></select>
    <input class="form-control" placeholder="si no aparece en la lista, digitelo aquí" type="text" name="precios_tarifa[detalle_precios_tarifas_attributes][new_detalle_precios_tarifas][servicio]" id="precios_tarifa_detalle_precios_tarifas_attributes_new_detalle_precios_tarifas_servicio" />
  </div>
  <div class="form-group">
    <label for="precios_tarifa_detalle_precios_tarifas_attributes_new_detalle_precios_tarifas_Modalidad">Modalidad</label>
    <input class="form-control" placeholder="ej. post-pago, pre-pago, etc." type="text" name="precios_tarifa[detalle_precios_tarifas_attributes][new_detalle_precios_tarifas][modalidad]" id="precios_tarifa_detalle_precios_tarifas_attributes_new_detalle_precios_tarifas_modalidad" />
  </div>
</div>
<div id="precio_tarifa">
  <div class="col-xs-6 col-md-4">
    <div class="form-group">
      <label for="precios_tarifa_detalle_precios_tarifas_attributes_new_detalle_precios_tarifas_Tipo Precio Tarifa">Tipo precio tarifa</label>
      <select name="precios_tarifa[detalle_precios_tarifas_attributes][new_detalle_precios_tarifas][tipo_precio_tarifa]" id="precios_tarifa_detalle_precios_tarifas_attributes_new_detalle_precios_tarifas_tipo_precio_tarifa"><option value="tarifa_maxima_acceso">Tarifa Máxima por Acceso</option>
<option value="tarifa_maxima_minuto">Tarifa Máxima por Minuto</option></select>
    </div>

    <div class="form-group">
      <label for="precios_tarifa_detalle_precios_tarifas_attributes_new_detalle_precios_tarifas_Fecha Vigencia">Fecha vigencia</label>
      <input class="form-control" type="date" name="precios_tarifa[detalle_precios_tarifas_attributes][new_detalle_precios_tarifas][fecha_vigencia]" id="precios_tarifa_detalle_precios_tarifas_attributes_new_detalle_precios_tarifas_fecha_vigencia" />
    </div>
    <div class="form-group">
      <label for="precios_tarifa_detalle_precios_tarifas_attributes_new_detalle_precios_tarifas_Estado">Estado</label>
      <select name="precios_tarifa[detalle_precios_tarifas_attributes][new_detalle_precios_tarifas][estado]" id="precios_tarifa_detalle_precios_tarifas_attributes_new_detalle_precios_tarifas_estado"><option value="VIGENTE">Vigente</option>
<option value="NO_VIGENTE">No Vigente</option></select>
    </div>
  </div>
  <div class="col-xs-6 col-md-4">
    <div class="form-group">
      <label for="precios_tarifa_detalle_precios_tarifas_attributes_new_detalle_precios_tarifas_Precio-Tarifa">Precio-tarifa</label>
      <input class="form-control" step="0.01" type="number" name="precios_tarifa[detalle_precios_tarifas_attributes][new_detalle_precios_tarifas][precio_tarifa]" id="precios_tarifa_detalle_precios_tarifas_attributes_new_detalle_precios_tarifas_precio_tarifa" />
    </div>
  </div>
</div>
</div>

            </div>
          </div>
    '
  end
end
