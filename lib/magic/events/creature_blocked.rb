module Magic
  module Events
    class CreatureBlocked
      attr_reader :attacker, :blocker

      def initialize(attacker:, blocker:)
        @attacker = attacker
        @blocker = blocker
      end

      def permanent
        attacker
      end
    end
  end
end