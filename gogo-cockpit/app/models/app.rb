class AppValidator < ActiveModel::Validator
	def validate(record)
		if record.name.nil? && record.name.length > 0
			record.errors[:base] << "App must have a name"
		end
	end
end

class App < ActiveRecord::Base
	has_many :placements
	belongs_to :ownership

	include ActiveModel::Validations
	validates_with AppValidator
end
