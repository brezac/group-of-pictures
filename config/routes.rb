Rails.application.routes.draw do
  get 'videos/:file_name/group-of-pictures.json'         => 'videos#index',    :constraints => { :file_name => /.*/ }
  get 'videos/:file_name/group-of-pictures/:group_index' => 'videos#create', :constraints => { :file_name => /.*/, :groupIndex => '/.*/' }
  get 'videos/play' => 'videos#play'
end
