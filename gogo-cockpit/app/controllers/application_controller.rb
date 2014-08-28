class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception
	rescue_from CanCan::AccessDenied do |exception|
		puts exception
		render :file => "#{Rails.root}/public/403.html", :status => 403, :layout => false
	end
	check_authorization :unless => :devise_controller?
	before_filter do
		resource = controller_name.singularize.to_sym
		method = "#{resource}_params"
		params[resource] &&= send(method) if respond_to?(method, true)
	end
end
