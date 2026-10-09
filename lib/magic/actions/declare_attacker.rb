module Magic
  module Actions
    class DeclareAttacker < Action
      def uses_priority?
        false
      end

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

        return "#{attacker.name} is summoning sick" if attacker.summoning_sick?

        "#{player.inspect} can't pay {#{attack_tax}} to attack with #{attacker.name}" unless attack_tax_cost.can_pay?(player)
      end

      # "Creatures can't attack you unless their controller pays {1} for each of those creatures" (Dain, Lord of the
      # Iron Hills): a battlefield static ability answering `attack_tax_for(attacker, target)` with generic mana.
      # Paid automatically from the mana pool as the attacker is declared.
      def attack_tax
        game.battlefield.static_abilities
          .select { |ability| ability.respond_to?(:attack_tax_for) }
          .sum { |ability| ability.attack_tax_for(attacker, target) }
      end

      def attack_tax_cost = Costs::Mana.new(generic: attack_tax)

      def perform
        unless game.current_turn.attacking?(attacker) || attack_tax.zero?
          cost = attack_tax_cost
          cost.auto_pay(player: player)
          cost.finalize!(player)
        end
        game.current_turn.declare_attacker(
          attacker,
          target: target,
        )
      end
    end
  end
end
