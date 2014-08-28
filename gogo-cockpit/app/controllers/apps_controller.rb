class AppsController < ApplicationController
	load_and_authorize_resource

	def index
		ownerships = Ownership.where :user_id => current_user.id
		@apps = App.where :id => ownerships.collect { |o| o.app_id }
		puts @apps
	end

	def new 
		@app = App.new()
	end

  	def create
		@app = App.new(params.require(:app).permit(:name))
		unless !!@app.save
			render "new"
		else
			params[:ownership] = {:app_id => @app.id, :user_id => current_user.id, :role => "admin" }
			puts params
			ownership = Ownership.new(params.require(:ownership).permit(:app_id, :user_id, :role))
			ownership.save
			redirect_to app_path(@app)
		end
	end

	def show
		@app = App.find(params[:id])
	end

	def edit
		@app = App.find(params[:id])
	end

	def update
		@app = App.find(params[:id])
		if @app.update(app_params)
			redirect_to(@app)
		else
			render :edit
		end
	end

	def destroy
		App.find(params[:id]).destroy
		redirect_to apps_path
	end

	private

	def app_params
		params.require(:app).permit(:name)
	end

end
