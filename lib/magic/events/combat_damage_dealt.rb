module Magic
  module Events
    class CombatDamageDealt
      attr_reader :source, :target, :damage, :infect

      def initialize(source:, target:, damage:, infect: false)
        @source = source
        @target = target
        @damage = damage
        @infect = infect
      end

      def infect?
        @infect
      end

      def inspect
        "#<Events::CombatDamageDealt source: #{source}, target: #{target}, damage: #{damage}, infect:#{infect?}>"
      end
    end
  end
end
