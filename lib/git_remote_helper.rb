require_relative './command_helper'

# Remote-related methods
module GitRemoteHelper
  include CommandHelper

  # Checks if the specified remote exists
  def remote?(name)
    command = "git config --get remote.#{name}.url"
    command_success?(command)
  end

  # Return the name of the current remote
  def current_remote
    command = "git config --get branch.#{current_branch}.remote"
    remote = command_stdout(command)
    return 'origin' if remote == ''
    remote
  end

  # Set the current remote as the specified one
  def set_current_remote(remote, branch = nil)
    return false unless remote?(remote)
    branch = current_branch if branch.nil?
    return false if branch == 'HEAD'
    return false unless branch?(branch)
    return false if remote == current_remote

    command = "git config branch.#{branch}.remote #{remote}"
    command_success?(command)
  end

  # Create the specified remote with specified url
  def create_remote(name, url)
    return false if remote?(name)
    command = "git remote add '#{name}' '#{url}'"
    command_success?(command)
  end

  # Returns the url of a given remote
  def remote_url(name)
    return false unless remote?(name)
    command = "git config --get remote.#{name}.url"
    command_stdout(command)
  end


end
