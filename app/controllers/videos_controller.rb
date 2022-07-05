class VideosController < ApplicationController
	# render json to screen
	def index 
		render json: JSON.pretty_generate(videos)
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
		response = {
			:data => videos
		}
		response[:data]
	end

	def create
		file_name       = params[:file_name]
		file_type       = file_name.partition('.').last
		group_index     = params[:group_index]
		index_num       = group_index.to_i
		next_index      = index_num + 1
		input_location  = "app/assets/videos/#{file_name}"
		output_location = "app/assets/videos/#{group_index}.#{file_type}"
		video           = videos[index_num]

		start_time = video["pts_time"].to_f

		if !videos[next_index].nil?
			duration = videos[next_index]["pts_time"].to_f - start_time
		else
			end_time = `ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 #{input_location}`.to_f
			duration = end_time - start_time
		end
		`ffmpeg -y -ss 00:00:#{start_time} -i #{input_location} -t #{duration} -c copy #{output_location}`
		send_file(output_location, :type => 'video/mp4', :disposition => 'inline')
	end

	def show
		file_name = params[:file_name]
		file_type = file_name.partition('.').last
		videos_array = []

		videos.each_with_index do |frame, index|
			input_location  = "app/assets/videos/#{file_name}"
			output_location = "app/assets/videos/#{index}.#{file_type}"
			next_index      = index + 1
			start_time      = frame["pts_time"].to_f

			# if this is not the last frame in the video, calculate duration and end time 
			if !videos[next_index].nil?
				duration = videos[next_index]["pts_time"].to_f - start_time
				end_time = videos[next_index]["pts_time"].to_f
			# if it is the last video, we need to get total video length and subtract this frame length from it
			else
				end_time = `ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 #{input_location}`.to_f
				duration = end_time - start_time
			end

			# create string specific to displaying time chunks
			timeslot = "From [#{sprintf('%.6f', start_time)} to #{sprintf('%.6f', end_time)}]"

			# Cut video without re-encoding
			`ffmpeg -y -ss 00:00:#{start_time} -i #{input_location} -t #{duration} -c copy #{output_location}`

			# create video object with the data points needed for the screen
			new_video = {
				title: "Group #{next_index}",
				timeslot: timeslot,
				index: index
			}

			videos_array.push(new_video)
		end
		# point to template and pass along our array of videos
		render template: "videos/show", :locals => { :videos_array => videos_array }
	end
end