class VideosController < ApplicationController
	# render json to screen
	def index 
		render json: videos
	end

	def videos
		# variables
		videos = []
		# path to location of app files appended with url param for file
		file_name = 'lib/assets/' + params[:file_name]
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
end