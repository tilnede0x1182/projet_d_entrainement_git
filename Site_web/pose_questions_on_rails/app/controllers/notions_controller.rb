class NotionsController < ApplicationController
	def index
		@notions = Notion.includes(:exercices)
	end
end
