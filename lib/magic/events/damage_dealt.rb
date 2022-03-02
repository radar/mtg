module Magic
  module Events
    class DamageDealt
      attr_reader :source, :target, :damage

      def initialize(source:, target:, damage:)
        @source = source
        @target = target
        @damage = damage
      end

      def inspect
        "#<Events::DamageDealt source: #{source}, target: #{target}, damage: #{damage}>"
      end
    end
  end
end
