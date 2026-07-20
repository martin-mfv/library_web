module LibraryFiles
  class ChangeVisibilityService
    def initialize(file:)
      @file = file
    end

    def call
      next_visibility = file.visibility_public? ? :private : :public
      file.update(visibility: next_visibility)
    end

    private

    attr_reader :file
  end
end
