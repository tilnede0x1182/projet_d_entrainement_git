########################################################
# Importations
require 'json'

# Données (variables globales)
SCRIPT_DIR             = File.dirname(__FILE__)    # Répertoire du script courant
NOTIONS_DIR            = File.expand_path('../Data', SCRIPT_DIR).freeze
REQUIRED_QUESTION_KEYS = %w[intitule choix reponse].freeze
REQUIRED_CHOICES       = %w[a b c d].freeze

# Fonctions utilitaires
## Lecture d’un fichier JSON (renvoie nil si vide)
def charger_json(chemin)
	content = File.read(chemin).strip
	return nil if content.empty?

	JSON.parse(content)
end

## Validation d’une question
def question_valide?(question)
	REQUIRED_QUESTION_KEYS.all? { |k| question[k].to_s.strip != '' } &&
		REQUIRED_CHOICES.all?    { |c| question['choix'][c].to_s.strip != '' }
end

## Validation d’une notion complète avec affichage et KO/OK par étape
def notion_valide?(notion, fichier)
	print "  Vérification numéro de notion... "
	if notion['numero'].nil?
		puts "KO (absent)"
		raise "Clé 'numero' manquante dans #{fichier}"
	elsif notion['numero'] <= 0
		puts "KO (non valide)"
		raise "Clé 'numero' invalide dans #{fichier}"
	else
		puts "OK"
	end

	print "  Vérification intitulés questions non vides... "
	intitules_ok = notion['exercices'].all? do |exercice|
		exercice['questions'].all? { |q| !q['intitule'].to_s.strip.empty? }
	end
	unless intitules_ok
		puts "KO"
		raise "Un intitulé de question est vide dans #{fichier}"
	end
	puts "OK"

	print "  Vérification nombre total questions >= 4... "
	questions_count = notion['exercices'].sum { |ex| ex['questions'].size }
	if questions_count < 4
		puts "KO (#{questions_count} < 4)"
		raise "Moins de 4 questions dans #{fichier}"
	end
	puts "OK"

	print "  Vérification choix a-d complets pour chaque question... "
	choix_ok = notion['exercices'].all? do |exercice|
		exercice['questions'].all? { |q| question_valide?(q) }
	end
	unless choix_ok
		puts "KO"
		raise "Choix incomplets dans une question de #{fichier}"
	end
	puts "OK"

	true
end

# Fonctions principales
def verifier_fichiers
	puts "Vérification des fichiers du dossier #{NOTIONS_DIR} en cours..."

	# Parcours de 1 à 10 dans l’ordre
	(1..10).each do |num|
		filename = File.join(NOTIONS_DIR, "Notion_#{num}.json")
		puts "- Fichier : Notion_#{num}.json"

		unless File.exist?(filename)
			puts "  Notion_#{num}.json est vide."
			next
		end

		notion = charger_json(filename)

		if notion.nil?
			puts "  Notion_#{num}.json est vide."
			next
		end

		# Vérification que le numéro dans JSON correspond au numéro dans le nom
		if notion['numero'] != num
			puts "  KO (numero attendu: #{num}, trouvé: #{notion['numero'] || 'nil'})"
			raise "Clé 'numero' incorrecte dans Notion_#{num}.json"
		else
			puts "  Numero de notion : OK (#{notion['numero']})"
		end

		notion_valide?(notion, filename)
		puts "  --> Notion_#{num}.json validé."
	end

	puts "Tout est bon"
end

# Main
def main
	verifier_fichiers
rescue StandardError => err
	warn "Erreur : #{err.message}"
	exit 1
end

# Lancement du programme
main if __FILE__ == $PROGRAM_NAME
