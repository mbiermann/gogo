class InviteValidator < ActiveModel::Validator
	def validate(record)
		if record.pin.nil? || record.pin.length < 4
			record.errors[:base] << "An invite must have a PIN of at least 4 characters"
		end
		if record.email.nil? || record.email.length < 2
			record.errors[:base] << "An invite must have a recipient email address"
		end
	end
end

class Invite < ActiveRecord::Base

	include ActiveModel::Validations
	validates_with InviteValidator

	def registered?
		!!self.is_fulfilled
	end

	def registered!
		self.is_fulfilled = true
	end

end
