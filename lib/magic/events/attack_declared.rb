module Magic
  module Events
    class AttackDeclared
      attr_reader :active_player, :turn, :attack

      def initialize(active_player:, turn:, attack:)
        @active_player = active_player
        @turn = turn
        @attack = attack
      end

      def inspect
        "#<Events::AttackersDeclared turn: #{turn}, attacker: #{attack.attacker}, target: #{attack.target&.name}>"
      end
    end
  end
end
