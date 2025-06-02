class CreateQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :questions do |t|
      t.integer :numero
      t.string :intitule
      t.json :choix
      t.string :reponse
      t.references :exercice, null: false, foreign_key: true

      t.timestamps
    end
  end
end
