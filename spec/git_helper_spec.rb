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
      actual = test_instance.repository?(@repo_path)

      # Then
      expect(actual).to eq false
    end

    it 'returns true when given a git directory as input' do
      # Given
      create_repository
      move_out_of_directory

      # When
      actual = test_instance.repository?(@repo_path)

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

  describe 'repo_root' do
    it 'should return the current path when in the root' do
      # Given
      create_repository

      # When
      actual = test_instance.repo_root

      # Then
      expect(actual).to eq @repo_path
    end

    it 'should return the root when in a subdirectory' do
      # Given
      create_repository
      create_and_move_to_subdirectory

      # When
      actual = test_instance.repo_root

      # Then
      expect(actual).to eq @repo_path
    end

    it 'should return nil if not in a repo' do
      # Given
      create_directory

      # When
      actual = test_instance.repo_root

      # Then
      expect(actual).to eq nil
    end

    it 'should return the path when given path to a repo' do
      # Given
      create_repository
      move_out_of_directory

      # When
      actual = test_instance.repo_root(@repo_path)

      # Then
      expect(actual).to eq @repo_path
    end

    it 'should return the root when given path a subdirectory of a repo' do
      # Given
      create_repository
      create_and_move_to_subdirectory
      move_out_of_directory

      # When
      actual = test_instance.repo_root(@repo_subdir_path)

      # Then
      expect(actual).to eq @repo_path
    end

    it 'should return nil when given the path to a normal directory' do
      # Given
      create_directory
      move_out_of_directory

      # When
      actual = test_instance.repo_root(@repo_path)

      # Then
      expect(actual).to eq nil
    end

    it 'should return the nil when in the special .git folder' do
      # Given
      create_repository
      Dir.chdir('./.git/objects')

      # When
      actual = test_instance.repo_root

      # Then
      expect(actual).to eq nil
    end
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

  describe 'tag?' do
    it 'returns true if the tag exists' do
      # Given
      create_repository
      create_tag 'foo'

      # When
      actual = test_instance.tag? 'foo'

      # Then
      expect(actual).to eq true
    end

    it 'returns false if the tag does not exist' do
      # Given
      create_repository

      # When
      actual = test_instance.tag? 'do_not_exist'

      # Then
      expect(actual).to eq false
    end

    it 'returns false if only partial match' do
      # Given
      create_repository
      create_tag 'foobar'

      # When
      actual = test_instance.tag? 'foo'

      # Then
      expect(actual).to eq false
    end
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

  describe 'current_tags' do
    it 'return the name of the tag on the current commit if any' do
      # Given
      create_repository
      create_tag 'foo'

      # When
      actual = test_instance.current_tag

      # Then
      expect(actual).to eq 'foo'
    end

    it 'returns nil if no tag set' do
      # Given
      create_repository

      # When
      actual = test_instance.current_tag

      # Then
      expect(actual).to eq nil
    end

    it 'returns the name of the closest tag' do
      # Given
      create_repository
      create_tag 'foo'
      add_commit

      # When
      actual = test_instance.current_tag

      # Then
      expect(actual).to eq 'foo'
    end
  end

  describe 'guess_elements' do
    it 'should guess the branch' do
      # Given
      create_repository
      create_branch 'develop'
      input = ['develop']

      # When
      actual = test_instance.guess_elements(input)

      # Then
      expect(actual[:branch]).to eq 'develop'
    end

    it 'should guess the tag' do
      # Given
      create_repository
      create_tag 'v1'
      input = ['v1']

      # When
      actual = test_instance.guess_elements(input)

      # Then
      expect(actual[:tag]).to eq 'v1'
    end

    it 'should guess the remote' do
      # Given
      create_repository
      create_remote('foo')
      input = ['foo']

      # When
      actual = test_instance.guess_elements(input)

      # Then
      expect(actual[:remote]).to eq 'foo'
    end

    it 'should guess them all' do
      # Given
      create_repository
      create_branch_with_remote('develop', 'upstream')
      create_tag 'v1'
      input = %w(develop v1 upstream)

      # When
      actual = test_instance.guess_elements(input)

      # Then
      expect(actual[:branch]).to eq 'develop'
      expect(actual[:tag]).to eq 'v1'
      expect(actual[:remote]).to eq 'upstream'
    end

    it 'should accept either an array or splats' do
      # Given
      create_repository
      create_branch_with_remote('develop', 'upstream')
      create_tag 'v1'
      input = %w(develop v1 upstream)

      # When
      actual = test_instance.guess_elements(*input)

      # Then
      expect(actual[:branch]).to eq 'develop'
      expect(actual[:tag]).to eq 'v1'
      expect(actual[:remote]).to eq 'upstream'
    end

    it 'should default to current branch' do
      # Given
      create_repository
      create_branch('develop')
      input = []

      # When
      actual = test_instance.guess_elements(input)

      # Then
      expect(actual[:branch]).to eq 'develop'
    end

    it 'should default to current tag' do
      # Given
      create_repository
      create_tag('v1')
      input = []

      # When
      actual = test_instance.guess_elements(input)

      # Then
      expect(actual[:tag]).to eq 'v1'
    end

    it 'should default to current remote' do
      # Given
      create_repository
      input = []

      # When
      actual = test_instance.guess_elements(input)

      # Then
      expect(actual[:remote]).to eq 'origin'
    end

    it 'should put all unknown in a special attribute' do
      # Given
      create_repository
      input = %w(foo bar)

      # When
      actual = test_instance.guess_elements(input)

      # Then
      expect(actual[:unknown]).to eq %w(foo bar)
    end
  end
end
