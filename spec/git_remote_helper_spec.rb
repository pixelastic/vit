require 'spec_helper'

describe(GitRemoteHelper) do
  let (:test_instance) { Class.new { include GitHelper }.new }

  after(:each) do |example|
    delete_directory(example)
  end

  describe 'remote?' do
    it 'returns true if the remote exists' do
      # Given
      create_repository
      create_remote('foo')

      # When
      actual = test_instance.remote? 'foo'

      # Then
      expect(actual).to eq true
    end

    it 'returns false if the remote does not exist' do
      # Given
      create_repository

      # When
      actual = test_instance.remote? 'do_not_exist'

      # Then
      expect(actual).to eq false
    end

  end

  describe 'current_remote' do
    it 'returns the name of the current remote associated with the branch' do
      # Given
      create_repository
      create_branch_with_remote('develop', 'upstream')

      # When
      actual = test_instance.current_remote

      # Then
      expect(actual).to eq 'upstream'
    end

    it 'returns origin if no remote specified' do
      # Given
      create_repository

      # When
      actual = test_instance.current_remote

      # Then
      expect(actual).to eq 'origin'
    end
  end
end
