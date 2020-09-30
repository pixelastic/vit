# Update dependencies (yarn, bundle) if needed
module DependencyHelper

  # Update dependencies if their list changed since we pulled
  def update_dependencies(old_commit)
    update_dependencies_node(old_commit)
    update_dependencies_ruby(old_commit)
  end

  # Run yarn install if package.json changed
  def update_dependencies_node(old_commit)
    filepath = File.join(repo_root, 'package.json')
    return unless File.exist?(filepath)
    return unless file_changed(old_commit, current_commit, filepath)
    puts "package.json has changed. Running yarn install"
    system('yarn install')
  end
  
  # Run bundle install if Gemfile changed
  def update_dependencies_ruby(old_commit)
    filepath = File.join(repo_root, 'Gemfile')
    return unless File.exist?(filepath)
    return unless file_changed(old_commit, current_commit, filepath)
    puts "Gemfile has changed. Running bundle install"
    system('bundle install')
  end
end
