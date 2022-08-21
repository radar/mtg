module Magic
  module Effects
    class SearchLibraryBasicLandEntersTapped
      def self.new(source:, library:)
        Effects::SearchLibrary.new(
          choices: library.basic_lands,
          source: source,
          resolve_action: -> (c) { c.resolve!(source.controller, enters_tapped: true) }
        )
      end
    end
  end
end
