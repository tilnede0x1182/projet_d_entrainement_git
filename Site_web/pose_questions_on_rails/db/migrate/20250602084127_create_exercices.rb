class CreateExercices < ActiveRecord::Migration[7.1]
  def change
    create_table :exercices do |t|
      t.integer :numero
      t.text :mini_court
      t.text :situation
      t.references :notion, null: false, foreign_key: true

      t.timestamps
    end
  end
end
