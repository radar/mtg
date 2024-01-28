module Magic
  module Effects
    class LoseLife < TargetedEffect
      attr_reader :life
      def initialize(life:, **args)
        @life = life
        super(**args)
      end

      def resolve!
        target.lose_life(life)
      end
    end
  end
end
