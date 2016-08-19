require_relative './command_helper'

# Branch-related methods
module GitBranchHelper
  include CommandHelper

  # Checks if the specified branch exists
  def branch?(name)
    command = 'git branch -l'
    list = command_stdout(command)
    tokens = list.split(' ')
    tokens.delete('*')
    tokens.include?(name)
  end

  # Returns the current branch name
  def current_branch
    command = 'git rev-parse --abbrev-ref HEAD'
    command_stdout(command)
  end

  # Creates a branch of the specified name
  def create_branch(branch)
    command = "git checkout --quiet -b #{branch}"
    command_success?(command)
  end
end
