module Magic
  module Actions
    # Blocking previously bypassed the Action/legality pipeline entirely: specs and any
    # future caller had to call `current_turn.declare_blocker(blocker, attacker:)` (the raw
    # `CombatPhase` delegate) directly, which raises `CombatPhase::IllegalBlock`/
    # `AttackerHasProtection` instead of `Magic::IllegalAction` and never goes through
    # `Turn#take_action`. This wraps that in an `Action` the same way `DeclareAttacker`
    # wraps `CombatPhase#declare_attacker`, so blocks can be enumerated by
    # `Game#legal_actions` (roadmap C2b) and, later, requested through an `Agent`. The raw
    # `current_turn.declare_blocker` path is untouched.
    class DeclareBlocker < Action
      def uses_priority?
        false
      end

      attr_reader :blocker, :attacker

      def initialize(blocker:, attacker:, **args)
        @blocker = blocker
        @attacker = attacker
        super(**args)
      end

      def inspect
        "#<Actions::DeclareBlocker blocker: #{blocker.name}, attacker: #{attacker.name}>"
      end

      def illegal_reason
        turn = game.current_turn
        return "it is not the declare blockers step" unless turn.step?(:declare_blockers)
        return "#{player.inspect} does not control #{blocker.name}" unless blocker.controller == player

        turn.illegal_block_reason(attacker: attacker, blocker: blocker)
      end

      def perform
        game.current_turn.declare_blocker(blocker, attacker: attacker)
      end
    end
  end
end
