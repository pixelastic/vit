require 'English'
require 'awesome_print'
require 'fileutils'
require 'open3'
require 'shellwords'
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
    split = directory.split('/')
    return false if split.include?('.git')

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

  # Checks if the specified input looks like a filepath
  # Note: This is a best effort guess as anything could be a filepath
  def path?(input)
    return true if File.exist?(input)
    return true unless (%r{^\./} =~ input).nil?
    false
  end

  # Checks if the specified input looks like a repo url
  def url?(input)
    # Example: git@github.com:pixelastic/vit.git
    regexp = /^(.*)@(.*):(.*)\.git$/
    !(regexp =~ input).nil?
  end

  # Checks if the specified input looks like a command line argument
  def argument?(input)
    !(input =~ /^--?/).nil?
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

  def guess_elements(*inputs)
    # Allow for one array or splats
    inputs = inputs[0] if inputs.length == 1

    types = %w(remote tag branch url path)
    elements = {
      unknown: [],
      arguments: []
    }

    # Guessing each type
    inputs.each do |element|
      found_type = nil

      types.each do |type|
        # Already found the remote/tag/branch
        next if elements.key?(type.to_sym)

        # Is of this type, we remember it and break out of the loop
        if send("#{type}?", element)
          found_type = type
          break
        end
      end

      if found_type.nil?
        elements[:unknown] << element
      else
        elements[found_type.to_sym] = element
      end
    end

    # Setting default values
    types.each do |type|
      type_sym = type.to_sym
      current_type_method = "current_#{type}"

      # Already set
      next if elements.key?(type_sym)
      # Setting default if such a default is even possible
      if respond_to?(current_type_method)
        elements[type_sym] = send(current_type_method)
      end
    end

    # Finding arguments in "unknown" elements
    final_unknown = []
    elements[:unknown].each do |unknown|
      if argument?(unknown)
        elements[:arguments] << unknown
      else
        final_unknown << unknown
      end
    end
    elements[:unknown] = final_unknown

    elements
  end

  # Create a git repo on the specified filepath (default to current directory)
  def create_repo(directory = nil)
    current_dir = File.expand_path('.')
    directory = current_dir if directory.nil?
    FileUtils.mkdir_p(directory) unless File.exist?(directory)
    Dir.chdir(directory)

    command = 'git init'
    success = command_success?(command)

    Dir.chdir(current_dir)
    success
  end

  # Creates a branch of the specified name
  def create_branch(branch)
    command = "git checkout --quiet -b #{branch}"
    command_success?(command)
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
