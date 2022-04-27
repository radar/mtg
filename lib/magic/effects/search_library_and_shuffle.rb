module Magic
  module Effects
    class SearchLibraryAndShuffle < TargetedEffect
      attr_reader :resolve_action

      def initialize(resolve_action:, **args)
        @resolve_action = resolve_action
        super(**args)
      end

      def resolve(target)
        resolve_action.call(target)
        target.controller.shuffle!
      end
    end
  end
end
