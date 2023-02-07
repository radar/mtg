module Magic
  module Effects
    class DealDamageToOpponents < TargetedEffect
      attr_reader :damage

      def initialize(damage:, **args)
        @damage = damage
        super(**args)
      end

      def requires_choices?
        false
      end

      def resolve(targets)
        targets.each do |target|
          target.take_damage(source: source, damage: damage)
        end
      end
    end
  end
end
