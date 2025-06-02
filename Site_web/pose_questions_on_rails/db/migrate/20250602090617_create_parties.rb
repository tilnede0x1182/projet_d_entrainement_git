class CreateParties < ActiveRecord::Migration[7.1]
  def change
    create_table :parties do |t|
      t.string :timestamp
      t.string :score
      t.boolean :finished
      t.references :notion, null: false, foreign_key: true

      t.timestamps
    end
  end
end
