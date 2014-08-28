class PlacementsController < ApplicationController
	load_and_authorize_resource
	check_authorization :unless => :modulo

	def new
		@app = App.find(params[:app_id])
		@placement = Placement.new()
	end

	def create
		@app = App.find(params[:app_id])
		@placement = @app.placements.create(placement_params)
		if @placement.errors.size > 0
			render "new"
		else
			redirect_to placement_path(@placement)
		end
	end

	def show
		respond_to do |format|
			format.html { 
				cache_key = request.original_fullpath
				puts cache_key
				content = Rails.cache.read(cache_key)
				if content.nil?
				  	@placement = Placement.find(params[:id])
				  	content = render_to_string(:template => "placements/show.html.erb")
					Rails.cache.write(cache_key, content, { :expires_in => 10.seconds })
				end
				render inline: content
			}
			format.json { 
				render inline: ActiveSupport::JSON.encode(Placement.find(params[:id])) 
			}
		end
	end

	def index
		unless params[:app_id].nil?
			@placements = App.find(params[:app_id]).placements
		else
			@placements = Placement.all
		end
	end

	def edit
		 @placement = Placement.find(params[:id])
	end

	def update
		@placement = Placement.find(params[:id])
		if @placement.update(placement_params)
			redirect_to(@placement)
		else
			render :edit
		end
	end

	def destroy
		@placement = Placement.find(params[:id])
		@placement.campaigns.each do |campaign|
			campaign.destroy
		end
		@placement.destroy
		redirect_to :back
	end

	def modulo
		placement = Placement.find(params[:placement_id])
		campaign = (placement.campaigns.select {|c| c.start <= DateTime.now && c.end >= DateTime.now })[0]
		if campaign.nil? || !campaign.assets.any?
			head :no_content
			return 
		end
		shares = []
		campaign.assets.each_with_index do |asset, idx|
			puts asset.inspect
			if asset.weight.nil? then asset.weight = 1 end
			(0..asset.weight-1).step(1) do |n|
				shares << idx
			end
		end
		idx = shares[params[:int].to_i % shares.length]
		asset = campaign.assets[idx]
		authorize! :modulo, asset
		headers["X-Num-Variations"] = "#{campaign.assets.length}"
		headers["X-Campaign"] = campaign.name
		headers["X-Content-Tag"] = asset.name
		expires_in [30*60, ((campaign.end - DateTime.now)*24*60*60).to_i].min.seconds
		send_file asset.filepath, :disposition => 'inline'
	end

	private

	def placement_params
		params.require(:placement).permit(:name, :description)
	end

end
