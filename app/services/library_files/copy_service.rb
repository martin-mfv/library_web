module LibraryFiles
  class CopyService
    def initialize(source_file:, actor:)
      @source_file = source_file
      @actor = actor
    end

    def call
      copy = actor.library_files.new(
        name: copied_name(source_file.name),
        visibility: :private,
        copied_from: source_file
      )

      copy.attachment.attach(source_file.attachment.blob)

      copy.save ? copy : nil
    end

    private

    attr_reader :source_file, :actor

    def copied_name(name)
      "#{name} (copy)"
    end
  end
end
