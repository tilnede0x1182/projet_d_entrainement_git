class PartiesController < ApplicationController
	def create
		notion = Notion.find(params[:notion_id])
		partie = Partie.create!(
			notion: notion,
			timestamp: Time.now.strftime('%Y-%m-%d_%H-%M-%S'),
			score: nil,
			finished: false
		)
		redirect_to partie_exercice_path(partie)
	end

	def exercice
		@partie = Partie.find(params[:id])
		@notion = @partie.notion
		@exercice = @notion.exercices.order(:numero).first
		if @exercice.nil?
			redirect_to notions_path, alert: "Aucun exercice trouvé."
		else
			first_question = @exercice.questions.order(:numero).first
			redirect_to partie_question_path(@partie, question_id: first_question.id)
		end
	end

	def question
		@partie = Partie.find(params[:id])
		@question = Question.find(params[:question_id])
		@exercice = @question.exercice
		@notion = @partie.notion

		# Récupérer le numéro de l'exercice et de la question pour affichage
		@numero_exercice = @exercice.numero
		@numero_question = @question.numero
	end

	def repondre
		@partie = Partie.find(params[:id])
		@question = Question.find(params[:question_id])
		@exercice = @question.exercice

		# Sauvegarder la réponse
		Reponse.create!(
			partie: @partie,
			ex_num: @exercice.numero,
			q_num: @question.numero,
			rep: params[:reponse]
		)

		# Trouver la question suivante dans l'exercice
		questions_ordered = @exercice.questions.order(:numero).to_a
		current_index = questions_ordered.index(@question)
		next_question = questions_ordered[current_index + 1]

		if next_question
			redirect_to partie_question_path(@partie, question_id: next_question.id)
		else
			# Pas de question suivante dans cet exercice, passer à l'exercice suivant
			exercices_ordered = @partie.notion.exercices.order(:numero).to_a
			current_ex_index = exercices_ordered.index(@exercice)
			next_exercice = exercices_ordered[current_ex_index + 1]

			if next_exercice
				# rediriger vers la première question du prochain exercice
				first_question = next_exercice.questions.order(:numero).first
				redirect_to partie_question_path(@partie, question_id: first_question.id)
			else
				# Dernier exercice terminé, calculer score, marquer fin de partie et rediriger vers résultat
				total_questions = Reponse.where(partie: @partie).count
				correct_answers = 0
				@partie.notion.exercices.each do |ex|
					ex.questions.each do |q|
						rep = Reponse.find_by(partie: @partie, ex_num: ex.numero, q_num: q.numero)
						correct_answers += 1 if rep && rep.rep == q.reponse
					end
				end
				@partie.update(score: "#{correct_answers}/#{total_questions}", finished: true)
				redirect_to resultat_partie_path(@partie)
			end
		end
	end

	def resultat
		@partie = Partie.find(params[:id])
		@notion = @partie.notion
		reponses = @partie.reponses

		corrections = []
		score = 0

		@notion.exercices.order(:numero).each do |ex|
			ex.questions.order(:numero).each do |q|
				user_rep = reponses.find_by(ex_num: ex.numero, q_num: q.numero)
				rep_utilisateur = user_rep&.rep || "-"
				correct = (rep_utilisateur == q.reponse)
				score += 1 if correct
				corrections << {
					situation: ex.situation,
					intitule: q.intitule,
					reponse_utilisateur: rep_utilisateur,
					texte_reponse_utilisateur: q.choix[rep_utilisateur],
					reponse_attendue: q.reponse,
					texte_bonne_reponse: q.choix[q.reponse],
					correct: correct
				}
			end
		end

		@score = "#{score}/#{corrections.size}"
		@corrections = corrections
		@partie.update(score: @score)
	end

	def sauvegardes
		@sauvegardes = Partie.where(finished: false)
	end
end
