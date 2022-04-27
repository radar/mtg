module Magic
  module Effects
    class SearchLibraryBasicLandEntersTapped
      def self.new(source:, choices:)
        Effects::SearchLibrary.new(
          choices: choices,
          source: source,
          resolve_action: -> (c) { c.resolve!; c.tapped = true }
        )
      end
    end
  end
end
