module Magic
  module Actions
    # Ninjutsu (rule 702.49): "{cost}, Return an unblocked attacker you control to hand: Put this card onto the battlefield from
    # your hand tapped and attacking." Activated from hand after blockers are declared. Paying the cost returns the attacker;
    # the ability goes on the stack and the card enters attacking the same player or planeswalker when it resolves. It was
    # never declared as an attacker, so attack triggers don't see it.
    class Ninjutsu < Action
      attr_reader :card, :attacker

      def initialize(card:, attacker:, **args)
        @card = card
        @attacker = attacker
        super(**args)
      end

      def inspect = "#<Actions::Ninjutsu card: #{card.name}, returning: #{attacker.name}, player: #{player.inspect}>"
      def name = "Ninjutsu (#{card.name})"

      def mana_cost
        @mana_cost ||= Costs::Mana.new(card.ninjutsu_cost.cost.dup).tap { |cost| cost.for_use = card }
      end

      def pay_mana(payment)
        mana_cost.pay(player: player, payment: payment)
        self
      end

      def can_perform?
        mana_cost.can_pay?(player)
      end

      def illegal_reason
        return "#{card.name} has no ninjutsu" unless card.respond_to?(:ninjutsu_cost)
        return "#{card.name} is not in #{player.inspect}'s hand" unless card.zone&.hand? && card.owner == player
        return "ninjutsu can only be activated after blockers are declared" unless game.current_turn.step?(:declare_blockers)

        attack = game.current_turn.combat.attack_for_attacker(attacker)
        return "#{attacker.name} is not attacking" unless attack
        return "#{player.inspect} does not control #{attacker.name}" unless attacker.controller == player

        "#{attacker.name} is blocked" if attack.blocked?
      end

      def perform
        combat = game.current_turn.combat
        @target = combat.attack_for_attacker(attacker).target
        mana_cost.finalize!(player)
        combat.remove_from_combat(attacker)
        attacker.return_to_hand
        game.stack.add(self)
      end

      def resolve!
        return unless card.zone&.hand?

        permanent = Permanent.put_onto_battlefield(game: game, card: card, from_zone: card.zone, controller: player, enters_tapped: true)
        game.current_turn.combat.declare_attacker(permanent, target: @target)
        permanent
      end

      def countered! = nil
      def exile! = nil
    end
  end
end
