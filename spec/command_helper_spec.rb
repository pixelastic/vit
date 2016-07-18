require 'spec_helper'

describe(CommandHelper) do
  let (:instance) { Class.new { include CommandHelper }.new }

  describe 'command_success?' do
    it 'should return true if command works' do
      # Given

      # When
      actual = instance.command_success?('true')

      # Then
      expect(actual).to eq true
    end

    it 'should return false if command fails' do
      # Given

      # When
      actual = instance.command_success?('false')

      # Then
      expect(actual).to eq false
    end
  end
end
