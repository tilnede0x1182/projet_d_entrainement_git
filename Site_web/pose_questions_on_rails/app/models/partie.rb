class Partie < ApplicationRecord
	belongs_to :notion
	has_many :reponses, dependent: :destroy
end
