########################################################
# Importations
require 'json'

# Données (variables globales)
NOTIONS_DIR            = 'notions'.freeze          # Dossier contenant « Notion x.json »
REQUIRED_QUESTION_KEYS = %w[intitule choix reponse].freeze
REQUIRED_CHOICES       = %w[a b c d].freeze

# Fonctions utilitaires
## Lecture d’un fichier JSON
def charger_json(chemin)
	JSON.parse(File.read(chemin))
end

## Validation d’une question
def question_valide?(question)
	REQUIRED_QUESTION_KEYS.all? { |k| question[k].to_s.strip != '' } &&
		REQUIRED_CHOICES.all?    { |c| question['choix'][c].to_s.strip != '' }
end

## Validation d’une notion complète
def notion_valide?(notion)
	intitules_ok   = notion['exercices'].all? { |ex| ex['questions'].all? { |q| q['intitule'].to_s.strip != '' } }
	questions_cnt  = notion['exercices'].sum  { |ex| ex['questions'].size } >= 4
	choix_complets = notion['exercices'].all? { |ex| ex['questions'].all? { |q| question_valide?(q) } }
	intitules_ok && questions_cnt && choix_complets
end

# Fonctions principales
def verifier_fichiers
	Dir.glob(File.join(NOTIONS_DIR, 'Notion *.json')).sort.each_with_index do |fichier, index|
		notion = charger_json(fichier)
		raise "Clé 'numero' manquante ou invalide dans #{fichier}" unless notion['numero'] == index + 1
		raise "Notion invalide dans #{fichier}"               unless notion_valide?(notion)
		puts "✓ #{fichier} OK"
	end
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
