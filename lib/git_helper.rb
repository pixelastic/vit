require 'shellwords'
require 'English'
require 'open3'
require 'awesome_print'
require_relative './command_helper'

# Allow access to current git repository state
module GitHelper
  include CommandHelper

  # Check if the directory is a git repository
  def repository?(directory = nil)
    command = 'git rev-parse'
    directory = File.expand_path('.') if directory.nil?

    # Directory does not exist, so can't be a git one
    return false unless File.exist?(directory)

    # Special .git directory can't be considered a repo
    return false if directory =~ /\.git/

    # We temporarily change dir if one is specified
    previous_dir = File.expand_path('.')
    Dir.chdir(directory)
    success = command_success?(command)
    Dir.chdir(previous_dir)
    success
  end

  # Returns the path to the repo root
  def repo_root(directory = nil)
    directory = File.expand_path('.') if directory.nil?
    return nil unless repository?(directory)

    previous_dir = File.expand_path('.')
    Dir.chdir(directory)
    output = command_stdout('git root')
    Dir.chdir(previous_dir)
    output
  end

  # Checks if the specified remote exists
  def remote?(name)
    command = "git config --get remote.#{name}.url"
    command_success?(command)
  end

  # Checks if the specified tag exists
  def tag?(name)
    command = "git tag -l #{name.shellescape}"
    output = command_stdout(command)
    output == name
  end

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

  def current_remote
    command = "git config --get branch.#{current_branch}.remote"
    remote = command_stdout(command)
    return 'origin' if remote == ''
    remote
  end

  def current_tag
    command = 'git describe --tags --abbrev=0'
    tag = command_stdout(command)
    return nil if tag == ''
    tag
  end

  def guess_elements(elements)
    output = {}
    initial_elements = elements.clone

    # Guess element types from the list of passed elements, by importance.
    # First the remotes, then the tags, and finally the branches.
    elements.each do |element|
      if remote?(element) && !output.key?(:remote)
        output[:remote] = element
        initial_elements.delete(element)
        next
      end

      if tag?(element) && !output.key?(:tag)
        output[:tag] = element
        initial_elements.delete(element)
        next
      end

      next unless branch?(element) && !output.key?(:branch)
      output[:branch] = element
      initial_elements.delete(element)
      next
    end

    # If no more args passed, we use current settings
    if initial_elements.size == 0
      output[:branch] = current_branch unless output[:branch]
      output[:remote] = current_remote unless output[:remote]
      output[:tag] = current_tag unless output[:tag]
    else
      output[:unknown] = initial_elements
    end

    # If still no remote, we default to origin
    output[:remote] = 'origin' if output[:remote].nil?

    output
  end




  @@colors = {
    branch: 202,
    branch_gone: 160,
    branch_bugfix: 203,
    branch_develop: 184,
    branch_gh_pages: 24,
    branch_heroku: 141,
    branch_master: 69,
    branch_release: 171,
    hash: 67,
    message: 250,
    remote: 202,
    remote_github: 24,
    remote_heroku: 141,
    remote_origin: 184,
    remote_upstream: 69,
    remote_algolia: 67,
    tag: 241,
    url: 250,
    valid: 35
  }

  def color(type)
    @@colors[type]
  end

  def branch_color(branch)
    return @@colors[:branch_gone] if branch_gone?(branch)
    return nil if branch.nil?
    color_symbol = ('branch_' + branch.tr('-', '_')).to_sym
    return @@colors[color_symbol] if @@colors[color_symbol]
    @@colors[:branch]
  end

  def remote_color(remote)
    color_symbol = ('remote_' + remote).to_sym
    return @@colors[color_symbol] if @@colors[color_symbol]
    @@colors[:remote]
  end

  # Return only --flags
  def get_flag_args(args)
    flags = []
    args.each do |arg|
      flags << arg if arg =~ /^-/
    end
    flags
  end

  # Return only non --flags
  def get_real_args(args)
    real_args = []
    args.each do |arg|
      real_args << arg if arg !~ /^-/
    end
    replace_short_aliases real_args
  end

  def replace_short_aliases(elements)
    elements.map do |element|
      next 'develop' if element == 'd'
      next 'gh-pages' if element == 'g'
      next 'heroku' if element == 'h'
      next 'master' if element == 'm'
      next 'origin' if element == 'o'
      next 'release' if element == 'r'
      next 'upstream' if element == 'u'
      element
    end
  end

  def push_pull_indicator(branchName)
    return ' ' if branch_gone?(branchName)
    system("git branch-remote-status #{branchName}")
    code = $CHILD_STATUS.exitstatus
    return ' ' if code == 1
    return ' ' if code == 2
    return ' ' if code == 3
    return ' ' if code == 4
  end

  def colorize(text, color)
    return nil if color.nil?
    color = format('%03d', color)
    "[38;5;#{color}m#{text}[00m"
  end

  def longest_by_type(list, type)
    ordered = list.map { |obj| obj[type] }.group_by(&:size)
    return nil if ordered.size == 0
    ordered.max.last[0]
  end

  def submodule?(path)
    system("git-is-submodule #{path.shellescape}")
  end


  def current_commit
    `git commit-current`.strip
  end

  def current_tags
    tags = `git tag-current-all`.strip.split("\n")
    tags << current_tag
    tags.uniq
  end

  def closer_commit(commitA, commitB)
    `git-commit-closer #{commitA} #{commitB}`.strip
  end

  def remote_owner(remote)
    `git-remote-owner #{remote}`.strip
  end

  def remote_url(remote: nil)
    `git-remote-url #{remote}`.strip
  end


  def branch_gone?(name)
    system("git branch-gone #{name}")
  end



  # Run npm install if package.json changed since old_commit
  def npm_install(old_commit)
    root = repo_root
    # No need to update if not an npm project
    return unless File.exist?(File.join(root, 'node_modules'))
    # No need to update if the file did not change
    changed_file = `git diff --name-only #{old_commit}..#{current_commit} -- package.json`.strip
    return unless changed_file.length > 0
    system('npm install')
  end

  def never_pushed?
    system('git branch-remote-status')
    return true if $CHILD_STATUS.exitstatus == 4
    false
  end

  # Pad every cell of a two-dimensionnal array so they are all the same length
  def pad_two_dimensionnal_array(array)
    column_count = array[0].length
    longests = Array.new(column_count, 0)
    array.each do |line|
      line.each_with_index do |cell, column|
        cell = '' if cell.nil?
        length = cell.size
        longest = longests[column]
        longests[column] = length if length > longest
      end
    end

    padded_array = array.map do |line|
      line.map.with_index do |cell, index|
        cell = '' if cell.nil?
        cell.ljust(longests[index])
      end
    end
    padded_array
  end

end
