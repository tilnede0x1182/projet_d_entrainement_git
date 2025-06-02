class Exercice < ApplicationRecord
	belongs_to :notion
	has_many :questions
end
