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

  # Returns the number of commits ahead/behind two branches are
  def branch_difference(branch_a, branch_b)
    command = "git rev-list --left-right --count #{branch_a}...#{branch_b}"
    result = command_stdout(command)
    behind, ahead = result.split("\t")
    {
      behind: behind.to_i,
      ahead: ahead.to_i
    }
  end

  def branch_date_ago(branch_name)
    command = "git show --pretty=format:'%cr' #{branch_name} | head -1"
    command_stdout(command)
  end
end
