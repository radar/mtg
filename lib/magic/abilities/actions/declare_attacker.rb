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

      def perform
        game.current_turn.declare_attacker(
          attacker,
          target: target,
        )
      end
    end
  end
end
