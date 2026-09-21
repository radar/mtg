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
        return "#{attacker.name} is not on the battlefield" unless attacker.zone&.battlefield?
        return "#{attacker.name} is not controlled by #{player.inspect}" unless attacker.controller == player
        return "attackers can only be declared during the declare attackers step" unless game.current_turn.step?(:declare_attackers)
        return "it is not #{player.inspect}'s turn" unless game.current_turn.active_player == player
        return "#{attacker.name} is tapped" if attacker.tapped?
        return "#{attacker.name} cannot attack" unless attacker.can_attack?
        return "#{attacker.name} has summoning sickness" if attacker.summoning_sick? && !attacker.has_keyword?(:haste)
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
