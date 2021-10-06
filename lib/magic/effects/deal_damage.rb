module Magic
  module Effects
    class DealDamage < Effect
      attr_reader :damage

      def initialize(damage:, **args)
        @damage = damage
        super(**args)
      end

      def requires_choices?
        true
      end

      def resolve(target:)
        target.take_damage(damage)
        target.destroy! if target.is_a?(Card) && target.dead?
      end
    end
  end
end
