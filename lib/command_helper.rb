require 'open3'
require 'awesome_print'

# Simplified access to shell commands
module CommandHelper
  # Returns true if the specified command exits with 0, false otherwise
  def command_success?(command)
    _, _, status = Open3.capture3(command)
    status.success?
  end
end
