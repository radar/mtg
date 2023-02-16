module Magic
  module Actions
    class Cast < Action
      extend Forwardable

      def_delegators :@card, :enchantment?, :artifact?
      attr_reader :card, :targets
      def initialize(card:, **args)
        super(**args)
        @card = card
        @targets = []
        @card.controller = player
      end

      def inspect
        "#<Actions::Cast card: #{card.name}, player: #{player.inspect}>"
      end
      alias_method :name, :inspect

      def countered?
        @countered
      end

      def counter!
        @countered = true
      end

      def countered!
        card.move_to_graveyard!(player)
      end

      def exile!
        card.move_to_exile!
      end

      def mana_cost=(cost)
        @mana_cost = Costs::Mana.new(cost)
      end

      def mana_cost
        @mana_cost ||= begin
          mana_cost_adjustment_abilities = game.battlefield.static_abilities
          .of_type(Abilities::Static::ManaCostAdjustment)
          .applies_to(card)

          mana_cost_adjustment_abilities.each_with_object(card.cost.dup) { |ability, cost| ability.apply(cost) }
        end
      end

      def can_perform?
        return false if card.land? && player.can_play_lands?
        return false unless card.zone.hand?
        return true if mana_cost.zero?

        mana_cost.can_pay?(player)
      end

      def target_choices
        choices = card.method(:target_choices)
        choices = choices.arity == 1 ? card.target_choices(player) : card.target_choices
      end

      def can_target?(target)
        target_choices.include?(target)
      end

      def targeting(*targets)
        targets.each do |target|
          raise "Invalid target for #{card.name}: #{target}" unless can_target?(target)
        end
        @targets = targets
        self
      end

      def pay_mana(payment)
        mana_cost.pay(player, payment)
        self
      end

      def perform
        mana_cost.finalize!(player)
        game.stack.add(self)

        game.notify!(Events::SpellCast.new(spell: card, player: player))
      end

      def resolve!
        if targets.none?
          card.resolve!(player)
          return
        end

        if card.single_target?
          card.resolve!(player, target: targets.first)
        else
          card.resolve!(player, targets: target)
        end

        if card.instant? || card.sorcery?
          card.move_to_graveyard!(player)
        end
      end
    end
  end
end
