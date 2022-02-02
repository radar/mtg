module Magic
  module Events
    class AttackersDeclared
      attr_reader :active_player, :turn, :attackers

      def initialize(active_player:, turn:, attackers:)
        @active_player = active_player
        @turn = turn
        @attackers = attackers
      end

      def inspect
        "#<Events::AttackersDeclared turn: #{turn}, attackers: #{@attackers}>"
      end
    end
  end
end
