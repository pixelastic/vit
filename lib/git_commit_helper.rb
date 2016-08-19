require 'date'
require_relative './command_helper'

# Commits-related methods
module GitCommitHelper
  include CommandHelper

  # Check if specified commit exists in the repo
  # http://stackoverflow.com/questions/18515488/how-to-check-if-the-commit-exists-in-a-git-repository-by-its-sha-1
  def commit?(hash)
    command = "git cat-file -t #{hash}"
    output = command_stdout(command)
    output == 'commit'
  end

  # Returns hash of current commit
  def current_commit
    return false unless repository?
    command = "git log --pretty=format:'%h' -n 1"
    output = command_stdout(command)
    return nil if output.empty?
    output
  end

  # Returns a hash of more info about the commit
  def commit_info(sha)
    return nil unless commit?(sha)
    command = "git log --format=format:'%h%n%ct%n%an%n%s%n%b' -n 1 #{sha}"
    output = command_stdout(command)
    split = output.split("\n")
    {
      sha: split[0],
      date: DateTime.strptime(split[1], '%s'),
      author: split[2],
      subject: split[3],
      body: split[4]
    }
  end

  # Commit the current files in staging area with the specified message
  def create_commit(message)
    command = "git commit -m #{message.shellescape}"
    command_success?(command)
  end
end
