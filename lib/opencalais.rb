require 'open_calais'

API_KEY = 'gv9zSZ0B4cXVDANzyYRQHQh0JuCxCCVm'

def extraer(s)
  #f = File.open(file_name)
  #s = f.read


  # you can configure for all calls
  #OpenCalais.configure do |c|
  #  c.api_key = "this is a test key"
  #end

  # or you can configure for a single call
  open_calais = OpenCalais::Client.new(:api_key=>API_KEY)

  # it returns a OpenCalais::Response instance
  response = open_calais.enrich(s)
  ehash = {}
  response.entities.each {|e| ehash[ehash.size+1] = e[:name]}

  # which has the 'raw' response
  #response.raw

  # and has been parsed a bit to get :language, :topics, :tags, :entities, :relations, :locations
  # as lists of hashes
  #response.tags.each{|t| puts t[:name] }
  return ehash
end
