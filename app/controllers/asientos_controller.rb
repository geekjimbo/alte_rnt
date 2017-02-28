require 'lib/recursivo'
require 'lib/build_hash'
require 'lib/anatext_gdrive'

class AsientosController < ApplicationController

  PER_PAGE = 6

  def get_historico
    session[:historico] = Asiento.find(params[:id]).num_asiento
    session[:flag] = true
    redirect_to asientos_path
  end

  def index

    if session[:flag].nil?
       session[:flag] = false
    end

    unless params[:campo_busqueda] 
      params[:campo_busqueda] = {:etiqueta_busqueda => "todos", :label => "Todos"}
    end

    unless params[:sort]
      params[:sort] = "id"
    end

    unless params[:page]
      params[:page] = 1
    end

    unless params[:search]
      params[:search] = ""
    end

    if session[:flag] == true and session[:historico] != "2" and session[:historico] != "1"
        @lista_ids = []
        push_me = Asiento.find_by(:num_asiento => session[:historico])
        push_me = nil if !push_me.nil? and (push_me.num_asiento == push_me.num_asiento_original)
        @lista_ids.push(push_me.id) if !push_me.nil?
        recursively_search_asientos(session[:historico], @lista_ids) if !@lista_ids.empty? and !push_me.nil?
        @asientos = Asiento.where(:id => @lista_ids).order('num_asiento').paginate(page: params[:page], per_page: PER_PAGE) if !@lista_ids.nil? and !@lista_ids.empty?
        session[:historico] = ""
        session[:flag] = false
        @asientos if !@asientos.nil?
        @asientos = Asiento.all.order(params['num_asiento']).paginate(page: params[:page], per_page: PER_PAGE) if @asientos.nil? or push_me.nil?
    else
      @asientos = Asiento.search(params[:search], 
                                 params[:campo_busqueda][:etiqueta_busqueda]).
                                 order(params[:sort]).
                               paginate(page: params[:page], per_page: PER_PAGE)
    end
  end


  def show
    @asiento = Asiento.new
  end

  def new
    @asiento = Asiento.new
    #@asiento.gdrive_file = ""
    @google_drive_pdfs_hash = load_gdrive_hashes
    @google_drive_pdfs_hash[-2] = ".Seleccionar Archivo"
    @google_drive_pdfs_hash[-1] = ".No Aplica"
    @google_drive_pdfs_hash = @google_drive_pdfs_hash.sort
  end

  def edit
    @operadores = OperadorRegulado.all
    @asiento = Asiento.last
    @the_hash = {}
    if !session[:file_name].nil?
      @the_hash = File.open(session[:file_name], "r") {|from_file| Marshal.load(from_file)}
      @nombre_operador_hash = flatten_hash @the_hash[:nombre_operador]
      @identificacion_operador_hash = flatten_hash @the_hash[:identificacion_operador], :id => true
      @identificacion_operador_hash["-1"] = ".No Aplica"
      @identificacion_operador_hash = @identificacion_operador_hash.sort
      @nombre_representante_legal_hash = flatten_hash @the_hash[:nombre_representante_legal]
      @cedula_representante_legal_hash = flatten_hash @the_hash[:cedula_representante_legal], :id => true
      @cedula_representante_legal_hash["-1"] = ".No Aplica"
      @cedula_representante_legal_hash = @cedula_representante_legal_hash.sort
      @numero_resolucion_hash = flatten_hash @the_hash[:numero_resolucion]
      @numero_resolucion_hash["-1"] = ".No Aplica"
      @numero_acuerdo_hash = {}
	  @numero_acuerdo_hash["-1"] = ".No Aplica"
      @numero_acuerdo_hash = flatten_hash @the_hash[:numero_acuerdo_ejecutivo] if !@the_hash[:numero_acuerdo_ejecutivo].nil? 
      @titulo_resolucion_hash = flatten_hash @the_hash[:titulo_resolucion]
      @titulo_resolucion_hash[".No Aplica"] = ".No Aplica"
      @fecha_resolucion_hash = flatten_hash @the_hash[:fecha_resolucion]
      @fecha_resolucion_convertidas_hash = convert_fechas @the_hash[:fecha_resolucion]
      @fecha_resolucion_convertidas_hash["1/1/1966"] = ".No Aplica"
      @fecha_resolucion_hash["1/1/1966"] = ".No Aplica"
      @fecha_resolucion_hash = @fecha_resolucion_hash.sort unless @fecha_resolucion_hash.include?(nil)
      @fecha_resolucion_hash = @fecha_resolucion_hash.sort_by {|f| f[1]} if @fecha_resolucion_hash.include?(nil)
      @tipo_tramite_hash = flatten_hash @the_hash[:tipo_tramite], :tipo_tramite=>true
      @tipo_tramite_hash["1/1/1966"] = ".Seleccionar tipo de Tramite"
    end
  end

  def create
    # convertir el PDF en TXT
    condicion_gdrive = (params[:asiento][:fichero_gdrive] != "-1" and params[:asiento][:fichero_gdrive] != ".Seleccionar Archivo" and params[:asiento][:fichero_gdrive] != ".No Aplica" and params[:asiento][:fichero_gdrive] != "-2")
   if condicion_gdrive
       # descargar fichero desde google drive al directorio ~./tmp/
       pdf_files = load_gdrive_pdf_hashes
       file = find_gdrive_pdf pdf_files

       mfile = @gdrive.pdf_to_text_from_google_drive file
       #mypath = @gdrive.download_file file
       # convertir de pdf a texto
       #mfile = mypath.gsub('.pdf','.txt')
       #comando = 'pdftotext '+mypath+' '+ mfile
       #system(comando)
       # generar el hash con el texto analizado
       mhash = generar_hash.get_hash(mfile)
       # guardar el hash en un fichero TXT
       mtargetfile = mfile.gsub(".txt","")+"_out.txt"
       File.open(mtargetfile, "w") {|to_file| Marshal.dump(mhash,to_file)}
       @the_file_name = mtargetfile
       session[:file_name] = mtargetfile
    end

    if !params[:asiento].nil? and !params[:asiento][:fichero].nil? and !condicion_gdrive
      mypath = params[:asiento][:fichero].tempfile.path 
      #mypath = @asiento.fichero.staged_path
      if File.exists?(mypath) and !mypath.scan(/.pdf/i).empty?
        my_path = Rails.root.join('public/assets/ficheros', mypath.scan(/.{5}.pdf/)[0].delete('.pdf')+'.txt') 
        comando = 'pdftotext '+mypath+' '+my_path.to_s
        system(comando)
        
        # generar el hash con el texto analizado
         
        mfile_path = Rails.root.join('public/assets/ficheros', mypath.scan(/.{5}.pdf/)[0].delete('.pdf')+'.txt') 

        mfile = mfile_path.to_s
        mhash = generar_hash.get_hash(mfile)

        # guardar el hash en un fichero TXT
        mtargetfile = mfile.gsub(/.txt/,"")+"_out.txt"
        File.open(mtargetfile, "w") {|to_file| Marshal.dump(mhash,to_file)}

        @the_file_name = mtargetfile
        session[:file_name] = mtargetfile
      end
    end
    redirect_to asientos_edit_path
  end

  def update
    mfile = session[:file_name].gsub(/_out.txt/,"")+"_tramite.txt" 
    File.open(mfile, "w") {|to_file| Marshal.dump(params[:asiento],to_file)}
    session[:anatext_file_name] = mfile
    asientos_url = get_tramite_url
    navigate_to_tramite asientos_url
  end

  def destroy
  end

  def llenar_operador
    operador = params[:id]
  end

    def load_gdrive_hashes
      @gdrive = GoogleDrive.new
      @gdrive_all_files = @gdrive.get_files_list
      @gdrive_pdf_files = {}
      @gdrive_all_files.each {|f| @gdrive_pdf_files[@gdrive_pdf_files.size] = f if f.title.include?(".pdf")}
      @gdrive_pdf_files_idx = {}
      @gdrive_pdf_files.each_pair {|k,v| @gdrive_pdf_files_idx[@gdrive_pdf_files_idx.size] = v.title}
      return @gdrive_pdf_files_idx
    end

    def load_gdrive_pdf_hashes
      @gdrive = GoogleDrive.new
      @gdrive_all_files = @gdrive.get_files_list
      @gdrive_pdf_files = {}
      @gdrive_all_files.each {|f| @gdrive_pdf_files[@gdrive_pdf_files.size] = f if f.title.include?(".pdf")}
      return @gdrive_pdf_files
    end

    def find_gdrive_pdf(gdrive_pdf_files)
      resultado = {}
      gdrive_pdf_files.each {|f| resultado = f if f[1].title == params[:asiento][:fichero_gdrive]}
      return resultado[1]
    end

  private

    def navigate_to_tramite(my_url)
      s = get_tipos_tramites
      x = my_url.gsub(/new_/,"")
      r = ""
      #r = s[s.index(x)]+"_new_path" if s.include?(x.gsub(/new_/,""))
      r = x
      r = "asientos_new_path" if r == ""
      redirect_to asientos_new_path if r.include?("asientos_new_path") or r == ""
      redirect_to convenio_privado_new_path if r.include?("convenio_privado")
      redirect_to recurso_numerico_new_path if r.include?("recurso_numerico")
      redirect_to orden_acceso_interconexion_new_path if r.include?("orden_acceso_interconexion")
      redirect_to resolucion_ubicacion_equipo_new_path if r.include?("resolucion_ubicacion_equipo")
      redirect_to sancion_new_path if r.include?("sancion")
      redirect_to consecion_publica_new_path if r.include?("consecion_publica")
      redirect_to permiso_new_path if r.include?("permiso")
      redirect_to autorizacion_new_path if r.include?("autorizacion")
      redirect_to consecion_anterior_new_path if r.include?("consecion_anterior")
      redirect_to concesion_direct_new_path if r.include?("concesion_direct")
      redirect_to reglamento_tecnico_new_path if r.include?("reglamento_tecnico")
      redirect_to lab_new_path if r.include?("lab")
      redirect_to arbitro_new_path if r.include?("arbitro")
      redirect_to homologacion_new_path if r.include?("homologacion")
      redirect_to fonatel_new_path if r.include?("fonatel")
      redirect_to convenio_internacional_new_path if r.include?("convenio_internacional")
      redirect_to norma_new_path if r.include?("norma")
      redirect_to convenio_ubicacion_equipo_new_path if r.include?("convenio_ubicacion_equipo")
      redirect_to contrato_adhesion_new_path if r.include?("contrato_adhesion")
      redirect_to oferta_interconexion_new_path if r.include?("oferta_interconexion")
      redirect_to acuerdo_acceso_interconexion_new_path if r.include?("acuerdo_acceso_interconexion")
      redirect_to precios_tarifa_new_path if r.include?("precios_tarifa")
    end

    def get_tipos_tramites
      return ["recurso_numerico", "orden_acceso_interconexion", "resolucion_ubicacion_equipo", "sancion", "consecion_publica","permiso", "autorizacion", "consecion_anterior", "concesion_direct", "reglamento_tecnico", "lab", "arbitro", "homologacion", "fonatel", "convenio_internacional", "norma", "convenio_ubicacion_equipo", "contrato_adhesion", "oferta_interconexion", "acuerdo_acceso_interconexion", "convenio_privado", "precios_tarifa"]
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_asiento
      @asiento = Asiento.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def asiento_params
      params[:asiento]
    end

    def get_tramite_url
      as = ""
      Asiento::TIPO_TRAMITE.items.each {|v| as = v.value.to_s if v.value.to_s == params["asiento"]["asiento"]["acto_inscribible"]}
      return as
    end

    def flatten_hash(the_hash, options={})
      options = {:id => false, :tipo_tramite=>false}.merge(options)
      my_hash = {}
      the_hash.each_value do |v|
        indice = v.scan(/.*:/)[0].gsub(/:/,"") if options[:tipo_tramite] == true
        indice = v.scan(/.*->/)[0].gsub(/->/,"") if !v.nil? and !v.empty? and options[:id] == false and !v.scan(/.*->/)[0].nil? and options[:tipo_tramite]==false
        indice = v if options[:id] == true
        indice = 0 if v.nil? or v.empty?
        my_hash[indice] = v if options[:tipo_tramite] == false
        my_hash[indice] = v.scan(/:.*/)[0].gsub(/:/,"") if options[:tipo_tramite] == true and !v.nil? and !v.empty? and !v.scan(/:.*/)[0].nil?
      end
      return my_hash
    end

    def convert_fechas(the_hash)
      meses = "enero|febrero|marzo|abril|mayo|junio|julio|agosto|setiembre|octubre|noviembre|diciembre"
      meses_numero = {"enero"=>1, "febrero"=>2, "marzo"=>3, "abril"=>4, "mayo"=>5, "junio"=>6, "julio"=>7, "agosto"=>8, "setiembre"=>9,"octubre"=>10,"noviembre"=>11,"diciembre"=>12}
      my_hash = {}
      the_hash.each do |v|
         dia = v[1].gsub(/\n+/,"").scan(/\d{1,2}\D+/)[0].gsub(/\D+/,"") if !v[1].include?("No Aplica")
         year = v[1].gsub(/\n+/,"").scan(/\d{4}/)[0]  if !v[1].include?("No Aplica")

         mes = v[1].gsub(/\n+/,"").scan(/(#{meses})/i)[0][0]  if !v[1].include?("No Aplica")

         mes_numero = 1
         mes_numero = meses_numero.select{|k,h| k == mes}[mes] if !v[1].include?("No Aplica")

         date_field = ""
         if !year.nil? and !dia.nil? and !mes_numero.to_s.nil? and !mes_numero.nil? and dia.to_i != 0 and year.to_i != 0 and mes_numero != 0 and 
 !v[1].include?("No Aplica")
            year_i = year.to_i
            dia_i = dia.to_i
            if (year.to_i > 0 and year.to_i < 2200) and (mes_numero > 0 and mes_numero < 13) and (dia.to_i > 0 and dia.to_i < 29)
              date_field = (year+"-"+mes_numero.to_s+"-"+dia).to_time 
            end
         end
         #puts "Dia: #{dia}  Mes: #{mes}  Mes#: #{mes_numero}  Año: #{year}  Fecha#: #{date_field}  Fecha: #{v[1].gsub(/\n+/,"")}"
         my_hash[v[1]] = date_field.to_s if !date_field.nil? and !v[1].include?("No Aplica")
      end 
      return my_hash
    end
end
