Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

	# Accueil
	root "accueil#index"

	# Notions, affichage unique (tout sur /notions)
	get "/notions", to: "notions#index", as: :notions

	# Démarrage nouvelle partie (création à partir d'une notion)
	post "/parties", to: "parties#create", as: :parties

	# Reprise de partie (liste des sauvegardes)
	get "/parties/sauvegardes", to: "parties#sauvegardes", as: :sauvegardes_parties

	# Jeu : affichage exercice
	get "/parties/:id/exercice", to: "parties#exercice", as: :partie_exercice

	# Jeu : affichage question
	get "/parties/:id/exercice/question/:question_id", to: "parties#question", as: :partie_question
	post "/parties/:id/exercice/question/:question_id", to: "parties#repondre", as: :repondre_partie_question

	# Résultat
	get "/parties/:id/resultat", to: "parties#resultat", as: :resultat_partie

	# Scores (parties finies)
	get "/scores", to: "scores#index", as: :scores
end
