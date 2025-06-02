class Notion < ApplicationRecord
	  has_many :exercises, dependent: :destroy
end
