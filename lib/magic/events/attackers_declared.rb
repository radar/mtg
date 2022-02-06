module Magic
  module Events
    class AttackersDeclared
      attr_reader :active_player, :turn, :attacks

      def initialize(active_player:, turn:, attacks:)
        @active_player = active_player
        @turn = turn
        @attacks = attacks
      end

      def inspect
        "#<Events::AttackersDeclared turn: #{turn}, attacks: #{@attacks.map(&:attacker)}>"
      end
    end
  end
end
