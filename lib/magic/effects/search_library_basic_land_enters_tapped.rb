module Magic
  module Effects
    class SearchLibraryBasicLandEntersTapped
      def self.new(source:, library:)
        Effects::SearchLibrary.new(
          source: source,
          library: library,
          condition: -> (c) { c.basic_land? },
          resolve_action: -> (c) { c.resolve!; c.tapped = true }
        )
      end
    end
  end
end
