class Fonatel < ActiveRecord::Base
  has_one :asiento, as: :acto, dependent: :destroy
  accepts_nested_attributes_for :asiento, allow_destroy: true

  validates_associated :asiento

  validates :titulo_informe, presence: true
end
