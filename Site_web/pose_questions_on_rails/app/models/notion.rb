class Notion < ApplicationRecord
	has_many :exercices, class_name: 'Exercice'
end
