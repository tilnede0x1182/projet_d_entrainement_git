class CreateNotions < ActiveRecord::Migration[7.1]
  def change
    create_table :notions do |t|
      t.integer :numero
      t.string :notion
      t.integer :niveau

      t.timestamps
    end
  end
end
