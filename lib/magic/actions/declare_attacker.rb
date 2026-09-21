module Magic
  module Actions
    class DeclareAttacker < Action
      attr_reader :attacker, :target
      def initialize(attacker:, target:, **args)
        @attacker = attacker
        @target = target
        super(**args)
      end

      def inspect
        "#<Actions::DeclareAttacker attacker: #{attacker}, target: #{target.name}}>"
      end

      def illegal_reason
        turn = game.current_turn
        return "it is not the declare attackers step" unless turn.step?(:declare_attackers)
        return "it is not #{player.inspect}'s turn" unless turn.active_player == player
        return "#{attacker.name} is not a creature" unless attacker.creature?
        return "#{player.inspect} does not control #{attacker.name}" unless attacker.controller == player
        # Declaring an attacker again just retargets it.
        return if turn.attacking?(attacker)
        return "#{attacker.name} is tapped" if attacker.tapped?
        return "#{attacker.name} can't attack" unless attacker.can_attack?

        "#{attacker.name} is summoning sick" if attacker.summoning_sick?
      end

      def perform
        game.current_turn.declare_attacker(
          attacker,
          target: target,
        )
      end
    end
  end
end
