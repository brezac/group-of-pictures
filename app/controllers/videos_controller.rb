require 'open3'
class VideosController < ApplicationController
	# render json to screen
	def index 
		render json: JSON.pretty_generate(videos)
	end

	# get video data with boolean for I frames vs all Frames
	def videos(only_i_frames = true)
		# variables
		videos = []
		# path to location of app files appended with url param for file
		file_name = 'app/assets/videos/' + params[:file_name]
		# parse response for CLI command
		json_result = JSON.parse(`ffprobe -v error -hide_banner -show_format -of default=noprint_wrapper=0 -print_format json -select_streams v:0 -show_frames #{file_name}`)
		my_index = 0

		if json_result["frames"]
			# for each frame lets do some cleaning
			json_result["frames"].each do |record|
				# we only want I-frames
				if only_i_frames
					if record["pict_type"] == 'I'
						# ancillary data not desired so remove side_data_list
						videos.push(record.except("side_data_list"))
					end
				else
					if record["pict_type"] == 'I'
						# if there is not already an entry for this index, go to the next entry
						if !videos[my_index].nil?
							my_index = my_index + 1
						end
						videos.push({index: my_index, key_frame: record.except("side_data_list"), records: []})
					else
						videos[my_index][:records].push(record.except("side_data_list"))
					end
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
		input_location  = "app/assets/videos/#{file_name}"
		file_type       = file_name.partition('.').last
		group_index     = params[:group_index]
		index_num       = group_index.to_i
		next_index      = index_num + 1
		# get all frames, not just I
		videos          = videos(false)
		video_objects   = videos[index_num][:records]
		start_time      = videos[index_num][:key_frame]["pts_time"].to_f
		if !videos[next_index].nil?
      next_video = videos[next_index][:key_frame]
    end

		if !next_video.nil?
			duration = next_video["pts_time"].to_f - start_time
		else
			end_time = `ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 #{input_location}`.to_f
			duration = end_time - start_time
		end
		# ffmpeg does not produce seekable output while producing mp4 containers so have to use fragmented mp4s
		# we also want to pipe out the result directly to send_data
		send_data(`ffmpeg -ss 00:00:#{start_time} -t #{duration} -i #{input_location} -c copy -movflags frag_keyframe -f mp4 -`, :type => 'video/mp4', :disposition => 'inline')
	end

	def show
		file_name = params[:file_name]
		file_type = file_name.partition('.').last
		videos_array = []

		videos = videos(true)

		videos.each_with_index do |frame, index|
			input_location  = "app/assets/videos/#{file_name}"
			next_index      = index + 1
			start_time      = frame["pts_time"].to_f

			# if this is not the last frame in the video, calculate duration and end time 
			if !videos[next_index].nil?
				duration = videos[next_index]["pts_time"].to_f - start_time
				end_time = videos[next_index]["pts_time"].to_f
			# if this is the last frame, use the full video length to calculate duration/end
			else
				end_time = `ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 #{input_location}`.to_f
        duration = end_time - start_time
			end

			# create string specific to displaying time chunks
			timeslot = "From [#{sprintf('%.6f', start_time)} to #{sprintf('%.6f', end_time)}]"

			# create video object with the data points needed for the screen
			new_video = {
				title: "Group #{next_index}",
				timeslot: timeslot,
				index: index,
				file_type: file_type,
				url: "http://#{request.host}:#{request.port}/videos/#{file_name}/group-of-pictures/#{index}.#{file_type}"
			}

			videos_array.push(new_video)
		end
		# point to template and pass along our array of videos
		render template: "videos/show", :locals => { :videos_array => videos_array }
	end
end