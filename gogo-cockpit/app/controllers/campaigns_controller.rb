class CampaignsController < ApplicationController
	load_and_authorize_resource
	
	def index
		@placement = Placement.find(params[:placement_id])
	end

	def new 
		@placement = Placement.find(params[:placement_id])
		@campaign = Campaign.new()
	end

  	def create
		@placement = Placement.find(params[:placement_id])
		@campaign = Campaign.new(campaign_params)
		overlap_campaign = @placement.any_active_campaign_in_duration(@campaign.start, @campaign.end)
		unless overlap_campaign.nil? then
			@campaign.errors[:base] << "Campaign must not overlap with existing campaign '#{overlap_campaign.name}' (#{overlap_campaign.start} - #{overlap_campaign.end})"
		end
		if @campaign.errors.any?
			render "new"
		else
			@placement.campaigns.create(campaign_params)
			redirect_to placement_path(@placement)
		end
	end

	def show
		@campaign = Campaign.find(params[:id])
	end

	def edit
		@campaign = Campaign.find(params[:id])
	end

	def update
		@campaign = Campaign.find(params[:id])
		if @campaign.update(campaign_params)
			redirect_to(@campaign)
		else
			render :edit
		end
	end

	def destroy
		@campaign = Campaign.find(params[:id])
		placement = @campaign.placement
		@campaign.destroy
		redirect_to placement
	end

	def toggle
		@campaign = Campaign.find(params[:id])
		@campaign.toggle!
		redirect_to :back
	rescue Campaign::ActiveStateChange => e
		redirect_to :back, :alert => e.message
	end


	private

	def campaign_params
		params.require(:campaign).permit(:name, :configuration, :start, :end)
	end

end
