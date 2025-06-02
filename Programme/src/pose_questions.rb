#!/usr/bin/env ruby
# frozen_string_literal: true
# ------------------------------------------------------------------
# Importations
# ------------------------------------------------------------------
require 'json'
require 'fileutils'
require 'time'

# ------------------------------------------------------------------
# Données
# ------------------------------------------------------------------
ROOT_DIR	= __dir__
NOTIONS_DIR	= File.expand_path('../Data/Notions', ROOT_DIR)
PARTIES_DIR	= File.expand_path('../Data/Parties', ROOT_DIR)
FileUtils.mkdir_p(PARTIES_DIR)
CHOICES		= %w[a b c d].freeze

# ------------------------------------------------------------------
# Fonctions utilitaires
# ------------------------------------------------------------------
##
# Lecture sécurisée d'un entier borné
# @min borne inférieure
# @max borne supérieure
##
def ask_int(min, max, prompt = '? = ')
	loop do
		print prompt
		value = Integer($stdin.gets.chomp) rescue nil
		return value if value && value.between?(min, max)
		puts "Veuillez entrer un entier entre #{min} et #{max}"
	end
end

##
# Lecture JSON
# @path chemin du fichier
##
def read_json(path)
	JSON.parse(File.read(path))
end

##
# Écriture JSON pretty
# @path chemin du fichier
# @hash contenu
##
def write_json(path, hash)
	File.write(path, JSON.pretty_generate(hash))
end

# ------------------------------------------------------------------
# Fonctions utilitaires principales
# ------------------------------------------------------------------
##
# Persistance immédiate de la partie
# @save hash de sauvegarde
##
def persist_save(save)
	path = File.join(PARTIES_DIR, "Partie_#{save['timestamp']}.json")
	write_json(path, save)
end

# ------------------------------------------------------------------
# Fonctions principales
# ------------------------------------------------------------------
class QuizGame
	##
	# Boucle principale du programme
	##
	def run
		loop do
			handle_main_choice(main_menu)
		end
	end

	private

	# ---------- Menus ----------
	def main_menu
		puts "\n### Menu principal :\n1 : Jouer\n2 : Scores\n3 : Quitter"
		ask_int(1, 3)
	end

	def handle_main_choice(choice)
		case choice
		when 1 then game_menu
		when 2 then show_scores
		when 3 then puts 'Au revoir !'; exit
		end
	end

	def game_menu
		puts "\n## Menu Jeu :\n1 : Nouvelle partie\n2 : Parties sauvegardées"
		choice = ask_int(1, 2)
		choice == 1 ? start_new_game : resume_game
	end

	# ---------- Nouvelle partie ----------
	def start_new_game
		paths = Dir[File.join(NOTIONS_DIR, 'Notion_*.json')].sort_by { |p| p[/\d+/].to_i }
		return puts 'Aucune notion disponible.' if paths.empty?
		list_notions(paths)
		n_path = paths[ask_int(1, paths.size) - 1]
		play_notation(read_json(n_path), n_path)
	end

	def list_notions(paths)
		puts "\n# Menu Notions :"
		paths.each_with_index do |p, idx|
			data = read_json(p)
			puts "#{idx + 1} : #{data['notion']} – #{data['exercices'].size} ex."
		end
	end

	# ---------- Jeu ----------
	def play_notation(notion, path, resume = nil)
		save = resume || init_save_hash(path, notion['notion'])
		ex_idx, q_idx = save['progress'].values_at('exercise', 'question')
		notion['exercices'][ex_idx..].each do |ex|
			puts "\n--- Exercice #{ex['numero']} ---\n#{ex['texte']}"
			ex['questions'][q_idx..].each { |q| q_idx = ask_question(q, save) }
			q_idx = 0
			save['progress']['exercise'] += 1
			persist_save(save)
		end
		finish_game(save, notion)
	end

	def ask_question(question, save)
		puts "\nQuestion #{question['numero']} : #{question['intitule']}"
		CHOICES.each_with_index { |c, i| puts "#{i + 1}. #{question['choix'][c]}" }
		ans = CHOICES[ask_int(1, 4) - 1]
		save['answers'] << { 'ex' => save['progress']['exercise'], 'q' => question['numero'], 'rep' => ans }
		save['progress']['question'] += 1
		persist_save(save)
		save['progress']['question']
	end

	def finish_game(save, notion)
		total = save['answers'].size
		good = save['answers'].count.with_index { |a, _| correct?(a, notion) }
		save.merge!('finished' => true, 'score' => "#{good}/#{total}")
		persist_save(save)
		puts "\n=== Fin de la partie ===\nScore : #{save['score']}"
		show_recap(notion)
	end

	def correct?(answer_hash, notion)
		ex = notion['exercices'][answer_hash['ex']]
		q = ex['questions'][answer_hash['q'] - 1]
		answer_hash['rep'] == q['reponse']
	end

	def show_recap(notion)
		notion['exercices'].each do |ex|
			ex['questions'].each do |q|
				puts "\nQuestion #{q['numero']} : #{q['intitule']}\n#{q['reponse'].upcase} : #{q['choix'][q['reponse']]}"
			end
		end
	end

	# ---------- Sauvegardes ----------
	def resume_game
		saves = Dir[File.join(PARTIES_DIR, 'Partie_*.json')].map { |f| read_json(f).merge('file' => f) }
		saves.select! { |h| !h['finished'] }
		return puts 'Aucune partie inachevée.' if saves.empty?
		saves.sort_by! { |h| h['timestamp'] }.reverse!
		puts "\n# Parties sauvegardées :"
		saves.each_with_index { |h, i| puts "#{i + 1} : Partie #{h['timestamp']}" }
		chosen = saves[ask_int(1, saves.size) - 1]
		play_notation(read_json(chosen['notion_path']), chosen['notion_path'], chosen)
	end

	def show_scores
		finished = Dir[File.join(PARTIES_DIR, 'Partie_*.json')].map { |f| read_json(f) }.select { |h| h['finished'] }
		puts "\n=== Scores des parties terminées ==="
		finished.sort_by { |h| h['timestamp'] }.reverse_each { |h| puts "partie #{h['timestamp']} : #{h['score']}" }
		puts "\nPour revenir au menu principal, taper 1 :"
		ask_int(1, 1)
	end

	# ---------- Initialisation ----------
	def init_save_hash(path, notion_title)
		{
			'timestamp'		=> Time.now.strftime('%Y-%m-%d_%H-%M-%S'),
			'notion_path'	=> path,
			'notion'		=> notion_title,
			'progress'		=> { 'exercise' => 0, 'question' => 0 },
			'answers'		=> [],
			'finished'		=> false,
			'score'			=> nil
		}
	end
end

# ------------------------------------------------------------------
# Main
# ------------------------------------------------------------------
def main
	QuizGame.new.run
end

# ------------------------------------------------------------------
# Lancement du programme
# ------------------------------------------------------------------
main
