class AddFieldToTituloHabilitante < ActiveRecord::Base
  belongs_to :auth_espectro, polymorphic: true
end
