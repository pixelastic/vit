require 'awesome_print'
require 'fileutils'
require './lib/git_helper.rb'

RSpec.configure do |config|
  config.filter_run(focus: true)
  config.fail_fast = true
  config.run_all_when_everything_filtered = true
end



# Create a directory
def create_directory
  @root_dir = File.expand_path('.')

  now = [
    Time.now.strftime('%Y-%m-%d_%H-%M-%S'),
    Time.now.to_f.to_s.tr('.', '')
  ].join('_')
  @repo_path = File.join(Dir.tmpdir, 'vit', "repo_#{now}")
  FileUtils.mkdir_p(@repo_path)

  move_in_directory
end

# Move in current directory
def move_in_directory
  Dir.chdir(@repo_path)
end

# Create a subdirectory
def create_and_move_to_subdirectory
  subdir = File.join(@repo_path, 'subdir')
  FileUtils.mkdir_p(subdir)
  Dir.chdir(subdir)
  @repo_subdir_path = subdir
end

# Creates a new repo in the dir
def init_repository
  `git init`
end

# Create a repository
def create_repository
  create_directory
  init_repository
end

# Move the current directory out
def move_out_of_directory
  Dir.chdir(@root_dir) unless @root_dir.nil?
end

# Deletes the previously created directory
def delete_directory(example)
  move_out_of_directory
  # Delete temp dir if no error
  FileUtils.remove_dir(@repo_path) if !@repo_path.nil? && !example.exception
end

