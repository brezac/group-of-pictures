Rails.application.routes.draw do
  get 'videos/:file_name/group-of-pictures.json' => 'videos#index', :constraints => { :file_name => /.*/ }
  get 'videos/:file_name/group-of-pictures/:groupIndex' => 'videos#by_group', :constraints => { :file_name => /.*/, :groupIndex => '/.*/' }
end
