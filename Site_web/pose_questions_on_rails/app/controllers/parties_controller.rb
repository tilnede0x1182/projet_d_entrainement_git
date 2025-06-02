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
		if @exercice
			redirect_to partie_question_path(@partie, question_id: @exercice.questions.order(:numero).first.id)
		else
			redirect_to notions_path, alert: "Aucun exercice trouvé."
		end
	end

	def question
		@partie = Partie.find(params[:id])
		@notion = @partie.notion
		@exercice = @notion.exercices.joins(:questions).where(questions: { id: params[:question_id] }).first
		@question = @exercice.questions.find(params[:question_id])
	end

	def repondre
		@partie = Partie.find(params[:id])
		@notion = @partie.notion
		@exercice = @notion.exercices.joins(:questions).where(questions: { id: params[:question_id] }).first
		@question = @exercice.questions.find(params[:question_id])
		Reponse.create!(
			partie: @partie,
			ex_num: @exercice.numero,
			q_num: @question.numero,
			rep: params[:reponse]
		)

		# Passage à la prochaine question, exercice, ou résultat
		suivante = @exercice.questions.order(:numero).where("numero > ?", @question.numero).first
		if suivante
			redirect_to partie_question_path(@partie, question_id: suivante.id)
		else
			prochain_ex = @notion.exercices.order(:numero).where("numero > ?", @exercice.numero).first
			if prochain_ex
				redirect_to partie_exercice_path(@partie)
			else
				@partie.update(finished: true)
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
