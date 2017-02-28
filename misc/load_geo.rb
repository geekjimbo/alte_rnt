require 'csv'
require 'json'

def cargar_provincias
  extracted_data = CSV.table("./misc/distritos.csv")
  transformed_data = extracted_data.map{|row| row.to_hash}
  transformed_data.each do |row|
    @p = Prov.new if Prov.find_by(:provincia=>row[:provincia]).nil?
    @p.provincia = row[:provincia]
    @p.save
  end
end

def cargar_cantones
  extracted_data = CSV.table("./misc/distritos.csv")
  transformed_data = extracted_data.map{|row| row.to_hash}
  transformed_data.each do |row|
    @c = Canton.new if Canton.find_by(:canton=>row[:canton]).nil?
    @c.canton = row[:canton]
    @p = Prov.find_by(:provincia=>row[:provincia])
    @p.cantons << @c
    @p.save
  end
end

def cargar_distritos
  extracted_data = CSV.table("./misc/distritos.csv")
  transformed_data = extracted_data.map{|row| row.to_hash}
  transformed_data.each do |row|
    d = Prov.find_by(:provincia=>row[:provincia]).cantons.find_by(:canton=>row[:canton]).distritos.new if Prov.find_by(:provincia=>row[:provincia]).cantons.find_by(:canton=>row[:canton]).distritos.find_by(:distrito=>row[:distrito]).nil?
    d.distrito = row[:distrito]
    Prov.find_by(:provincia=>row[:provincia]).cantons.find_by(:canton=>row[:canton]).distritos << d if d
    @p.save
  end
end
