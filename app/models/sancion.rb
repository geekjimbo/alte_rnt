class Sancion < ActiveRecord::Base
  has_one :asiento, as: :acto, dependent: :destroy
  accepts_nested_attributes_for :asiento, allow_destroy: true

  validates_associated :asiento

  ##validates :fecha_vigencia, presence: true
  validates :tipo_sancion, presence: true

  TIPO_SANCION = Enum.new([
      ["Sanción X", 'Sanción X'],
      ["Sanción Y", 'Sanción Y'],
      ["Sanción Z", 'Sanción Z'],
      ["Sanción W", 'Sanción W'],
      ["Sanción T", 'Sanción T']
      ])
end
