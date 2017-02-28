require './lib/delete_merge'

class Nested

  def initialize
    # crear un hash con la jerarquia requerida por el modelo
    # cargar el hash de una vez con datos
    @los_parametros = ActionController::Parameters.new(
                      [
                        { id: "",
                          sciservicio_id: ""
                        }
                      ]  
                     )
      
    @hash_fresh = 
                      [
                        { id: "",
                          sciservicio_id: ""
                        }
                       ]  
      # declarar safe parameters para toda la jerarquía de objetos del modelo
      # desde la raiz o el padre, root
      @permitted = @los_parametros.permit([:id,  :sciservicio_id ] )
  end

  def servicios(options ={})
      # set default options
      options = {action: :create, titulo_habilitante_id: nil, hash_fresh: {}}.merge(options)
      #hash_fresh = @hash_fresh.merge(options[:hash_fresh])
      hash_fresh = options[:hash_fresh]
      servicios_array = hash_fresh
      @titulohabilitante = TituloHabilitante.find(options[:titulo_habilitante_id])

      # crear hijos nivel II de la jerarquia
      servicios_array.each do |q_parent|
          q_child  = q_parent[1]
          q_child.delete(:_destroy)
          servicios_attrs = q_child
          q = servicios_attrs

          # crear hijo nivel II de la jerarquia
          hash_for_update = {}
          hash_for_update = hash_diff(q, :entity => :servicio_habilitados, :id => q[:id]) if options[:action] == :update and !q[:id].nil?
          
          id_incluido = (hash_for_update.include? :id) or (hash_for_update.include? "id")

          @titulohabilitante.servicio_habilitados.new q if options[:action] == :create or q[:id].nil? or q[:id].empty?
          @servicio = @titulohabilitante.servicio_habilitados.find(q[:id]) if options[:action] == :update and !q[:id].nil? and !q[:id].empty? and @titulohabilitante.servicio_habilitados.exists?(:id => q[:id])
          @servicio.update_attributes hash_for_update if options[:action] == :update and !q[:id].nil? and @titulohabilitante.servicio_habilitados.exists?(:id => q[:id])
        
          @servicio = @titulohabilitante.servicio_habilitados.find(q[:id]) if !q[:id].nil? and @titulohabilitante.servicio_habilitados.exists?(:id => q[:id])
          @servicio = @titulohabilitante.servicio_habilitados.last if options[:action] == :create or q[:id].nil? or hash_for_update.empty?

      end
    # grabar la jerarquia completa
    @titulohabilitante.save

  end

  def hash_diff(hash_fresh, options={})
    options = {entity: :survey, :id => :nil}.merge(options)
    objeto = ServicioHabilitado.find(options[:id]) if !options[:id].nil? and !options[:id].empty? and options[:entity] == :servicio_habilitados
    hash_current = {}
    hash_current = objeto.attributes.merge(hash_current) if objeto
    
    #debugger

    hash_dif = {}
    hash_dif = hash_fresh.delete_merge(hash_current) if hash_fresh
    hash_dif.delete(:id)
    return hash_dif ? hash_dif : {}
  end
end
