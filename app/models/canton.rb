class Canton < ActiveRecord::Base
  belongs_to :prov
  has_many :distritos
end
