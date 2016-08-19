require_relative './command_helper'

# Remote-related methods
module GitRemoteHelper
  include CommandHelper

  # Checks if the specified remote exists
  def remote?(name)
    command = "git config --get remote.#{name}.url"
    command_success?(command)
  end

  def current_remote
    command = "git config --get branch.#{current_branch}.remote"
    remote = command_stdout(command)
    return 'origin' if remote == ''
    remote
  end
end
