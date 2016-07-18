require 'spec_helper'

describe(GitHelper) do
  let (:test_instance) { Class.new { include GitHelper }.new }

  after(:each) do |example|
    delete_directory(example)
  end

  describe 'repository?' do
    it 'returns false when not in a git repository' do
      # Given
      create_directory

      # When
      actual = test_instance.repository?

      # Then
      expect(actual).to eq false
    end

    it 'returns true when in a git repository' do
      # Given
      create_repository

      # When
      actual = test_instance.repository?

      # Then
      expect(actual).to eq true
    end

    it 'returns false when given a non-git directory as input' do
      # Given
      create_directory
      move_out_of_directory

      # When
      actual = test_instance.repository?(@tmp_repo)

      # Then
      expect(actual).to eq false
    end

    it 'returns true when given a git directory as input' do
      # Given
      create_repository
      move_out_of_directory

      # When
      actual = test_instance.repository?(@tmp_repo)

      # Then
      expect(actual).to eq true
    end

    it 'returns false when given a non-existent directory as input' do
      # Given

      # When
      actual = test_instance.repository?('/i_do_not_exist')

      # Then
      expect(actual).to eq false
    end

    it 'returns false when given the special .git directory' do
      # Given
      create_repository

      # When
      actual = test_instance.repository?('./.git')

      # Then
      expect(actual).to eq false
    end

    it 'returns false when in the special .git directory' do
      # Given
      create_repository
      Dir.chdir('./.git')

      # When
      actual = test_instance.repository?

      # Then
      expect(actual).to eq false
    end

    it 'returns false when given a special .git directory subdir' do
      # Given
      create_repository

      # When
      actual = test_instance.repository?('./.git/objects')

      # Then
      expect(actual).to eq false
    end

    it 'returns false when in a special .git directory subdir' do
      # Given
      create_repository
      Dir.chdir('./.git/objects')

      # When
      actual = test_instance.repository?

      # Then
      expect(actual).to eq false
    end


    # it 'returns true when in a submodule' do
    # end
  end
end
