namespace :db do
	puts Dir.glob(File.expand_path('../../Programme/Data/Notions/Notion_*.json', Dir.pwd))
  desc "Importer les notions depuis JSON"
  task import_notions: :environment do
    path = File.expand_path('../../Data/Notions', Rails.root)
    Dir.glob(File.join(path, 'Notion_*.json')).each do |file|
      puts "Traitement du fichier : #{file}"
      data = JSON.parse(File.read(file))
      notion = Notion.create!(
        numero: data['numero'],
        notion: data['notion'],
        niveau: data['niveau']
      )
			data['exercices'].each do |ex|
				exercise = notion.exercises.create!(
					numero: ex['numero'],
					mini_court: ex['mini_court'],
					situation: ex['situation']
				)
				ex['questions'].each do |q|
					exercise.questions.create!(
						numero: q['numero'],
						intitule: q['intitule'],
						choix: q['choix'],
						reponse: q['reponse']
					)
				end
			end
      puts "Import Notion ##{notion.numero} - #{notion.notion}"
    end
  end
end
