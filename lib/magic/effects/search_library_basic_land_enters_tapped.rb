module Magic
  module Effects
    class SearchLibraryBasicLandEntersTapped
      def self.new(library:)
        Effects::SearchLibrary.new(
          library: library,
          condition: -> (c) { c.basic_land? },
          resolve_action: -> (c) { c.resolve!; c.tapped = true }
        )
      end
    end
  end
end
