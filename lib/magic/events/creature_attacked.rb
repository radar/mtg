module Magic
  module Events
    class CreatureAttacked
      attr_reader :attacker, :target

      def initialize(attacker:, target:)
        @attacker = attacker
        @target = target
      end

      def permanent
        attacker
      end

      def inspect
        "#<Events::CreatureAttacked attacker: #{attacker}, target: #{target}>"
      end
    end
  end
end
