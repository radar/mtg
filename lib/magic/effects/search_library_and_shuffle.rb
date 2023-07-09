module Magic
  module Effects
    class SearchLibraryAndShuffle < TargetedEffect
      attr_reader :resolver
      def on_resolve(&block)
        @resolver = block
      end

      def resolve(target)
        resolver.call(target)
        source.controller.shuffle!

      end
    end
  end
end
