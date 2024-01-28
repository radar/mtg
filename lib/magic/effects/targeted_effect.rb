module Magic
  module Effects
    class TargetedEffect < Effect
      class InvalidTarget < StandardError; end;

      attr_reader :source, :target

      def initialize(source:, target:)
        @source = source
        @target = target
      end
    end
  end
end
