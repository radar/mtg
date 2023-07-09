module Magic
  module Effects
    class SearchLibrary < TargetedEffect
      attr_reader :resolve_action

      def initialize(resolve_action:, **args)
        @resolve_action = resolve_action
        super(**args)
      end

      def resolve(target)
        resolve_action.call(target)
        source.controller.library.shuffle!
      end
    end
  end
end
