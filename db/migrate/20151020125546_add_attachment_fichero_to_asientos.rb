class AddAttachmentFicheroToAsientos < ActiveRecord::Migration
  def self.up
    change_table :asientos do |t|
      t.attachment :fichero
    end
  end

  def self.down
    remove_attachment :asientos, :fichero
  end
end
