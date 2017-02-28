require './lib/delete_merge'

class Nested

  def initialize
    # crear un hash con la jerarquia requerida por el modelo
    # cargar el hash de una vez con datos
    @id = nil
    @los_parametros = ActionController::Parameters.new(
                   {name: "", 
                    questions_attributes: 
                      [
                        { id: nil,
                          content: "", 
                          answer: [
                            {id: nil, answer_text: ""}
                          ]
                        }
                       ]  
                     } )  
      
    @hash_fresh = 
                   {name: "", 
                    questions_attributes: 
                      [
                        { id: nil,
                          content: "", 
                          answer: [
                            {id: nil, answer_text: ""}
                          ]
                        }
                       ]  
                     }
      # declarar safe parameters para toda la jerarquía de objetos del modelo
      # desde la raiz o el padre, root
      @permitted = @los_parametros.permit(:name, { questions_attributes: [:id, :content ,{ answers: [:id, :answer_text] } ] }  )
  end

  def survey(options ={})
      # set default options
      options = {action: :create, survey_id: nil, hash_fresh: {}}.merge(options)
      #hash_fresh = @hash_fresh.merge(options[:hash_fresh])
      hash_fresh = options[:hash_fresh]

      # remover nivel II de la jerarquia y guardarlo para uso posterior
      questions_array = @permitted.delete('questions_attributes') if options[:action] == :create
      questions_array = hash_fresh.delete(:questions_attributes) if options[:action] == :update

      # crear el padre root de la jerarquia
      @survey = Survey.new @permitted if options[:action] == :create
      hash_for_update = hash_diff(hash_fresh, :entity => :survey, :id => options[:survey_id]) if options[:action] == :update and :survey_id
      @survey = Survey.find(options[:survey_id]) if options[:action] == :update and !options[:survey_id].nil?
      @survey.update_attributes hash_for_update if options[:action] == :update and !options[:survey_id].nil?

      @survey = Survey.last if options[:action] == :create
      @survey = Survey.find(options[:survey_id]) if options[:action] == :update and !options[:survey_id].nil?

      # crear hijos nivel II de la jerarquia
      questions_array.each do |q_parent|
          q_child  = q_parent[1]
          q_child.delete(:_destroy)
          questions_attrs = q_child
          q = questions_attrs
          #questions_attrs.each do |q|
              # extraer nivel III de la jerarquia y guardarlo
              answers_array = q.delete(:answer)

              # crear hijo nivel II de la jerarquia
              hash_for_update = {}
              hash_for_update = hash_diff(q, :entity => :questions, :id => q[:id]) if options[:action] == :update and !q[:id].nil?
              id_incluido = (hash_for_update.include? :id) or (hash_for_update.include? "id")
              @survey.questions.new q if options[:action] == :create or q[:id].nil?
              @question = @survey.questions.find(q[:id]) if options[:action] == :update and !q[:id].nil? and @survey.questions.exists?(:id => q[:id])
              @question.update_attributes hash_for_update if options[:action] == :update and !q[:id].nil? and @survey.questions.exists?(:id => q[:id])
            
              @question = @survey.questions.find(q[:id]) if !q[:id].nil? and @survey.questions.exists?(:id => q[:id])
              @question = @survey.questions.last if options[:action] == :create or q[:id].nil? or hash_for_update.empty?

              answers_array.each do |aa|
                #aa.each do |ac|
                qqq = q
                #debugger
                  answers_attrs = aa[1]
                  if !answers_attrs.nil?  #and (@question.id == q[:id] or q[:id].nil?)
                   a = answers_attrs
                    # crear hijos de los hijos, nivel III de la jerarquia
                   # answers_attrs.each do |a|
                        hash_for_update = {}
                        hash_for_update = hash_diff(a, :entity => :answers, :id => a[:id]) if options[:action] == :update and !a[:id].nil?
                        id_incluido = (hash_for_update.include? :id or hash_for_update.include? "id")
                        @question.answers.new(a) if (options[:action] == :create or a[:id].nil?)
                        @answer = @question.answers.find(a[:id]) if !a[:id].nil? and options[:action] == :update and !a[:id].nil? and @question.answers.exists?(:id => a[:id])
                        @answer.update_attributes hash_for_update if options[:action] == :update and !id_incluido and !a[:id].nil?  and @question.answers.exists?(:id => a[:id])
                    end 
                  #end
                #end
          #end
        end
      end
    # grabar la jerarquia completa
    @survey.save

  end

  def hash_diff(hash_fresh, options={})
    options = {entity: :survey, :id => :nil}.merge(options)
    objeto = Survey.find(options[:id]) if !options[:id].nil? and options[:entity] == :survey
    objeto = Question.find(options[:id]) if !options[:id].nil? and options[:entity] == :questions
    objeto = Answer.find(options[:id]) if !options[:id].nil? and options[:entity] == :answers
    hash_current = {}
    hash_current = objeto.attributes.merge(hash_current)
    
    #debugger

    hash_dif = {}
    hash_dif = hash_fresh.delete_merge(hash_current) if hash_fresh
    hash_dif.delete(:id)
    @id = hash_current ? hash_current["id"] : nil
    return hash_dif ? hash_dif : {}
  end
end
