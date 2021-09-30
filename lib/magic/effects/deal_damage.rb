module Magic
  module Effects
    class DealDamage
      attr_reader :choices, :damage

      def initialize(choices:, damage:)
        @choices = choices
        @damage = damage
      end

      def requires_choices?
        true
      end

      def single_choice?
        choices.count == 1
      end

      def resolve(target:)
        target.take_damage(damage)
      end
    end
  end
end