class CreateReponses < ActiveRecord::Migration[7.1]
  def change
    create_table :reponses do |t|
      t.integer :ex_num
      t.integer :q_num
      t.string :rep
      t.references :partie, null: false, foreign_key: true

      t.timestamps
    end
  end
end
