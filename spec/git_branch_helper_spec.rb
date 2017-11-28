require 'spec_helper'

describe(GitBranchHelper) do
  let(:test_instance) { Class.new { include GitHelper }.new }

  after(:each) do |example|
    delete_directory(example)
  end

  describe 'branch?' do
    it 'returns true if the branch exists' do
      # Given
      create_repository
      create_branch 'foo'

      # When
      actual = test_instance.branch? 'foo'

      # Then
      expect(actual).to eq true
    end

    it 'returns false if the branch does not exist' do
      # Given
      create_repository

      # When
      actual = test_instance.branch? 'do_not_exist'

      # Then
      expect(actual).to eq false
    end

    it 'returns false if only partial match' do
      # Given
      create_repository
      create_branch 'foobar'

      # When
      actual = test_instance.branch? 'foo'

      # Then
      expect(actual).to eq false
    end
  end

  describe 'current_branch' do
    it 'returns the name of the current branch' do
      # Given
      create_repository
      create_branch 'foo'

      # When
      actual = test_instance.current_branch

      # Then
      expect(actual).to eq 'foo'
    end

    it 'returns HEAD if no current branch' do
      # Given
      create_repository

      # When
      actual = test_instance.current_branch

      # Then
      expect(actual).to eq 'HEAD'
    end
  end

  describe 'create_branch' do
    it 'should create a new branch' do
      # Given
      create_repository
      # Note: A branch can only be seen once at least one commit exists
      add_commit

      # When
      test_instance.create_branch('develop')

      # Then
      expect(test_instance.branch?('develop')).to eq true
    end

    it 'should return false when creating a branch that already exists' do
      # Given
      create_repository
      create_branch('develop')

      # When
      actual = test_instance.create_branch('develop')

      # Then
      expect(actual).to eq false
    end
  end
end
