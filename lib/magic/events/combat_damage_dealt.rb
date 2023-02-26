module Magic
  module Events
    class CombatDamageDealt
      attr_reader :source, :target, :damage

      def initialize(source:, target:, damage:)
        @source = source
        @target = target
        @damage = damage
      end

      def inspect
        "#<Events::CombatDamageDealt source: #{source}, target: #{target}, damage: #{damage}>"
      end
    end
  end
end
