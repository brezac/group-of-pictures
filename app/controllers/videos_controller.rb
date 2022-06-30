class VideosController < ApplicationController
	# render json to screen
	def index 
		render json: videos
	end

	def videos
		# variables
		videos = []
		# path to location of app files appended with url param for file
		file_name = 'app/assets/videos/' + params[:file_name]
		# parse response for CLI command
		json_result = JSON.parse(`ffprobe -v error -hide_banner -of default=noprint_wrapper=0 -print_format json -select_streams v:0 -show_frames #{file_name}`)

		if json_result["frames"]
			# for each frame lets do some cleaning
			json_result["frames"].each do |record|
				# we only want I-frames
				if record["pict_type"] == 'I'
					# ancillary data not desired so remove side_data_list
					videos.push(record.except("side_data_list"))
				end
			end
		end
		JSON.pretty_generate(videos)
	end

	def create
		file_name = 'app/assets/videos/' + params[:file_name]
		group_index = params[:group_index]
		output_location = 'app/assets/videos/output_file.mp4'
		Rails.logger.info("group_index: #{group_index}")
		`ffmpeg -y -i #{file_name} -c:v libx264 -preset slow -crf 22 -pix_fmt yuv420p -c:a libvo_aacenc -b:a 128k #{output_location}`
		send_file(output_location, :type => 'video/mp4', :disposition => 'inline')
	end
end