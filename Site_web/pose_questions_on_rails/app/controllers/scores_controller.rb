class ScoresController < ApplicationController
	def index
		@parties = Partie.where(finished: true).order(created_at: :desc)
	end
end
