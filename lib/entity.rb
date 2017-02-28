
require './alchemyapi_ruby/alchemyapi'
require 'JSON'

def extraer(demo_text)
  demo_text = 'Yesterday dumb Bob destroyed my fancy iPhone in beautiful Denver, Colorado. I guess I will have to head over to the Apple Store and buy a new one.' if demo_text.nil? or demo_text.empty?

  alchemyapi = AlchemyAPI.new()
  response = alchemyapi.entities('text', demo_text, { 'sentiment'=>1 })

  if response['status'] == 'OK'
      response
  else
      ""
  end

end
