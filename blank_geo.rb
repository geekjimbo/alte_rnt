def blanquear_provs_cantones
  provincias = Prov.all
  provincias.each do |provincia|
    c = provincia.cantons.new
    c.canton = ".Cantón no indicado"
    c.save
    provincia.cantons.each do |canton|
      d = canton.distritos.new
      d.distrito = ".Distrito no indicado"
      d.save
    end
  end
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
