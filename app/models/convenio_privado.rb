class ConvenioPrivado < ActiveRecord::Base
  after_initialize :set_defaults
  has_one :asiento, as: :acto, dependent: :destroy
  accepts_nested_attributes_for :asiento, allow_destroy: true

  validates_associated :asiento

  validates :titulo_convenio, presence: true
  validates :num_anexos, presence: true

  def set_defaults
  end
end
