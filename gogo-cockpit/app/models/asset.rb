class AssetValidator < ActiveModel::Validator
	def validate(record)
		if record.name.nil? && record.name.length > 0
			record.errors[:base] << "Asset must have a name"
		end
		if record.weight > 5
			record.errors[:base] << "Asset weight must not be bigger than 5"
			return
		elsif record.weight == 0
			record.errors[:base] << "Asset weight must not be 0"
			return
		end
	end
end


class Asset < ActiveRecord::Base
	belongs_to :campaign
	attr_accessor :upload

	include ActiveModel::Validations
	validates_with AssetValidator

	def save_file(upload, dir)   
		if upload.nil? then return end
		unless self.filepath.nil? then File.delete(self.filepath) end
		filename = upload['datafile'].original_filename if (upload['datafile'] != '')    
		file = upload['datafile'].read

		file_type = filename.split('.').last
		new_name_file = Time.now.to_i
		filename = "#{new_name_file}." + file_type

		dirname = dir + "#{self.campaign.id}"
		Dir.mkdir(dirname) unless File.exist?(dirname)
		self.filepath = "#{dirname}/#{filename}"
		File.open(self.filepath, "wb")  do |f|  
			f.write(file) 
		end


	end

	def delete_file(dir)
		File.delete(dir + "#{self.filepath}") unless self.filepath.nil?
	end

end
