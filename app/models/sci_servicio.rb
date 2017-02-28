class SciServicio < ActiveRecord::Base
  has_many :servicio_habilitado, dependent: :destroy, :foreign_key => "sciservicio_id"
end
