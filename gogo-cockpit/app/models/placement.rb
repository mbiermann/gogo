class PlacementValidator < ActiveModel::Validator
	def validate(record)
		if record.name.nil? && record.name.length > 0
			record.errors[:base] << "Placement must have a name"
		end
	end
end

class Placement < ActiveRecord::Base
	has_many :campaigns
	belongs_to :app

	include ActiveModel::Validations
	validates_with PlacementValidator

	def any_active_campaign_in_duration(start, ende)
		campaigns = self.campaigns.select { |c| if c.is_active && (c.start <= ende && c.end >= start) then c end }
		return campaigns[0]
	end
end
