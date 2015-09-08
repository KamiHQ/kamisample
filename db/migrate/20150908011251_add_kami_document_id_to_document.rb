class AddKamiDocumentIdToDocument < ActiveRecord::Migration
  def change
    change_table :documents do |t|
      t.string :kami_document_id
    end
  end
end
