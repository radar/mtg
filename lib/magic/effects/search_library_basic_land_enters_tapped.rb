module Magic
  module Effects
    class SearchLibraryBasicLandEntersTapped
      def self.new(source:, controller:)
        Effects::SearchLibrary.new(
          choices: controller.library.basic_lands,
          source: source,
          resolve_action: -> (c) { c.resolve!(controller, enters_tapped: true) },
        )
      end
    end
  end
end
