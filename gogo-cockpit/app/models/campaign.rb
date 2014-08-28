class CampaignValidator < ActiveModel::Validator
	def validate(record)
		if record.name.nil? && record.name.length > 0
			record.errors[:base] << "Campaign must have a name"
		end
		if record.start >= record.end 
			record.errors[:base] << "Campaign start date must be before its end date"
		elsif record.start <= DateTime.now
			record.errors[:base] << "Campaign start date must be in the future"
		end
	end
end

class Campaign < ActiveRecord::Base
	belongs_to :placement
	has_many :assets

	include ActiveModel::Validations
	validates_with CampaignValidator

	class ActiveStateChange < RuntimeError; end

	def toggle!
		unless self.is_active
			if !!self.placement.any_active_campaign_in_duration(self.start, self.end)
				raise ActiveStateChange.new("Campaign cannot set active because there is another campaign active overlapping it.")
				return
			end
		end
		self.is_active = !self.is_active
		self.save
	end

	def before_save
		if self.id.nil?
			self.is_active = true
		end
		super 
	end

end
