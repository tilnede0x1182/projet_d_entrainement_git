# Importation des notions depuis les fichiers JSON
# ------------------------------------------------------------------
require 'json'

# Dossier contenant les fichiers Notion_*.json (relatif au projet Rails)
NOTIONS_SRC = Rails.root.join('../../Programme/Data/Notions')

puts "==> Démarrage de l'import des Notions"
Dir.glob(NOTIONS_SRC.join('Notion_*.json')).sort.each do |file_path|
	puts "Traitement de : #{file_path}"
	data = JSON.parse(File.read(file_path))

	notion = Notion.where(numero: data['numero']).first
	unless notion
		notion = Notion.create!(numero: data['numero'], notion: data['notion'], niveau: data['niveau'])
		puts "Créé Notion : #{notion.inspect}"
	else
		puts "Déjà existante : #{notion.inspect}"
	end

	data['exercices'].each do |ex_data|
		exercice = Exercice.where(notion: notion, numero: ex_data['numero']).first
		unless exercice
			exercice = Exercice.create!(
				notion: notion,
				numero: ex_data['numero'],
				mini_court: ex_data['mini_court'],
				situation: ex_data['situation']
			)
			puts "Créé Exercice : #{exercice.inspect}"
		else
			puts "Déjà existant : #{exercice.inspect}"
		end

		ex_data['questions'].each do |q_data|
			question = Question.where(exercice: exercice, numero: q_data['numero']).first
			unless question
				question = Question.create!(
					exercice: exercice,
					numero: q_data['numero'],
					intitule: q_data['intitule'],
					choix: q_data['choix'],
					reponse: q_data['reponse']
				)
				puts "Créé Question : #{question.inspect}"
			else
				puts "Déjà existante : #{question.inspect}"
			end
		end
	end
end
puts "==> Fin de l'import des Notions"
