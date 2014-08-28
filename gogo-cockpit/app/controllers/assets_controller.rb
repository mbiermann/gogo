class AssetsController < ApplicationController
	load_and_authorize_resource
	
	def new
		@campaign = Campaign.find(params[:campaign_id])
		@asset = Asset.new()
		@asset_max_weight = 5
		@asset_weight_unit = 1
	end

	def create
		@campaign = Campaign.find(params[:campaign_id])
		@asset = @campaign.assets.create(asset_params)
		if @asset.errors.any?
			render "new"
		else
			@asset.save_file(params[:upload], Rails.public_path.join("assets"))
			@asset.update(asset_params)
			redirect_to placement_campaign_path(@campaign.placement, @campaign)
		end
	end

	def destroy
		asset = Asset.find(params[:id])
		campaign = asset.campaign
		asset.delete_file(Rails.public_path.join("assets"))
		asset.destroy
		redirect_to campaign
	end

	def show
		@asset = Asset.find(params[:id])
		if request.format == "json" then
			out = Hash.new
			out[:url] = raw_asset_url(@asset)
			out[:name] = asset.name
			render inline: ActiveSupport::JSON.encode(out) 
			return
		end
	end

	def edit
		@asset = Asset.find(params[:id])
		@asset_max_weight = 5
		@asset_weight_unit = 1
	end

	def update
		@asset = Asset.find(params[:id])
		@asset.save_file(params[:upload], Rails.public_path.join("assets"))
		@asset.update(asset_params)
		redirect_to placement_campaign_path(@asset.campaign.placement, @asset.campaign)
	end

	def raw
		send_file Asset.find(params[:id]).filepath, :type => 'image/jpeg', :disposition => 'inline'
	end

	private

	def asset_params
		params.require(:asset).permit(:name, :weight)
	end
end
