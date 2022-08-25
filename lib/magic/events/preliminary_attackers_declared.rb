module Magic
  module Events
    class PreliminaryAttackersDeclared
      attr_reader :active_player, :turn, :attacks

      def initialize(active_player:, turn:, attacks:)
        @active_player = active_player
        @turn = turn
        @attacks = attacks
      end

      def inspect
        "#<Events::PreliminaryAttackersDeclared turn: #{turn}, attacks: #{@attacks.map(&:attacker)}>"
      end
    end
  end
end
