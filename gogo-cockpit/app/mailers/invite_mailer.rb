class InviteMailer < ActionMailer::Base

	default :from => 'Rocket Ad Server <martin.biermann@rocket-internet.de>'

	def invite_email(invite)
		@invite_url = invite_url(invite)
		mail(:to => invite.email, :subject => "Invitation to join Ad Server")
	end
end