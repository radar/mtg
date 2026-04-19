module Magic
  module Events
    class DamageDealt
      attr_reader :source, :target, :damage, :combat, :infect

      def initialize(source:, target:, damage:, combat: false, infect: false)
        @source = source
        @target = target
        @damage = damage
        @combat = combat
        @infect = infect
      end

      def combat?
        @combat
      end

      def infect?
        @infect
      end

      def inspect
        "#<Events::DamageDealt source: #{source}, target: #{target}, damage: #{damage}, combat: #{combat?}, infect: #{infect?}>"
      end
    end
  end
end
