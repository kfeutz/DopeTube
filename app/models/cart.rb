class Cart < ActiveRecord::Base
	has_many :mp3s
	has_many :videos
end
