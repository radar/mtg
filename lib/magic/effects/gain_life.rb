module Magic
  module Effects
    class GainLife < TargetedEffect
      attr_reader :life, :target
      def initialize(life:, target:, **args)
        @life = life
        @target = target
      end

      def requires_choices?
        false
      end

      def resolve
        target.gain_life(life)
      end
    end
  end
end
