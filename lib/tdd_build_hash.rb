require './build_hash'

describe "test Algo OpenCalais" do

  def grabar_resultado
    f = File.open('./out.txt','w')
    f.write(@my_hash)
  end

  before do
    #@my_alchemy_hash = generar_hash.get_alchemy("./sample.txt")
    @my_hash = generar_hash.get_hash("./sample.txt")
    grabar_resultado
  end

  after do
    r = system('rm sample.txt_*.txt')
  end

  it "debe invocar alchemy" do
    expect(@my_hash.size).to eq(8)
  end

  it "debe cargar valores para nombre_operador" do
    expect(@my_hash[:nombre_operador].size).to eq(28)
  end

  it "debe cargar valores para nombre_representante_legal" do
    expect(@my_hash[:nombre_representante_legal].size).to eq(28)
  end

  it "debe cargar valores para cedula juridica (t.c.c. identificacion operador" do
    expect(@my_hash[:identificacion_operador].size).to eq(2)
  end

  it "debe cargar valores para cedula fisica o pasaporte" do
    expect(@my_hash[:cedula_representante_legal].size).to eq(11)
  end

  it "debe cargar valores para fechas" do
    expect(@my_hash[:fecha_resolucion].size).to eq(51)
  end

  it "debe cargar valores para numero de resolucion" do
    expect(@my_hash[:numero_resolucion].size).to eq(6)
  end

  it "debe cargar valores para titulo resolucion" do
    expect(@my_hash[:titulo_resolucion].size).to eq(14)
  end

  it "debe cargar valores para tipo_tramite" do
    expect(@my_hash[:tipo_tramite].size).to eq(21)
  end
end
