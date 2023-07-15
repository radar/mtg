module Magic
  module Effects
    class LoseLife < TargetedEffect
      attr_reader :life, :targets
      def initialize(life:, targets:, **args)
        @life = life
        @targets = targets
      end

      def requires_choices?
        false
      end

      def resolve
        targets.each { _1.lose_life(life) }
      end
    end
  end
end
