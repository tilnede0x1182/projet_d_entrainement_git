class Partie < ApplicationRecord
	belongs_to :notion
	has_many :reponses
end
