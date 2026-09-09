module Magic
  module Actions
    class Cast < Action
      extend Forwardable

      class InvalidTarget < StandardError; end

      def_delegators :@card, :enchantment?, :artifact?, :multi_target?
      attr_reader :card, :targets, :value_for_x, :controller, :modes, :additional_costs

      # @param flashback [Boolean] When true, allows casting from graveyard and exiles after resolution
      def initialize(card:, value_for_x: nil, controller: card.controller, flashback: false, **args)
        super(**args)
        @card = card
        @targets = []
        @modes = []
        @additional_costs = card.respond_to?(:additional_costs) ? card.additional_costs : []
        @paid_additional_costs = []
        @flashback = flashback

        @value_for_x = value_for_x
      end

      def inspect
        "#<Actions::Cast card: #{card.name}, player: #{player.inspect}>"
      end
      alias_method :name, :inspect

      def countered!
        game.notify!(Events::SpellCountered.new(spell: card, player: player))
        card.move_to_graveyard!(player)
      end

      def return_to_hand!
        card.move_to_hand!(player)
      end

      def exile!
        card.exile!
      end

      def mana_cost=(cost)
        @mana_cost = Costs::Mana.new(cost)
      end

      def mana_cost
        @mana_cost ||= begin
          if @flashback && card.zone.graveyard?
            cost = card.flashback_cost
          else
            cost = card.cost
          end

          mana_cost_adjustment_abilities = game.battlefield.static_abilities
          .of_type(Abilities::Static::ManaCostAdjustment)
          .applies_to(card)

          cost = mana_cost_adjustment_abilities.each_with_object(cost.dup) { |ability, cost| ability.apply(cost) }
          cost.x = value_for_x if value_for_x
          cost
        end
      end

      def auto_pay
        mana_cost.auto_pay(player)
      end

      def kicker_cost
        card.kicker_cost
      end

      def can_perform?
        from_top_of_library = card.zone&.library? && card == player.library.first &&
          game.battlefield.static_abilities.any? do |ability|
            ability.respond_to?(:permits_casting_from_top?) && ability.permits_casting_from_top?(card)
          end
        return false unless from_top_of_library || (@flashback ? card.zone.graveyard? : card.zone.hand?)
        return true if mana_cost.zero?

        mana_cost.can_pay?(player)
      end

      def target_choices
        choices = card.method(:target_choices)
        choices = choices.arity == 1 ? card.target_choices(player) : card.target_choices
      end

      def can_target?(target, index = nil)
        if index
          target_choices[index].include?(target)
        else
          target_choices.include?(target)
        end
      end

      def targeting(*targets)
        if card.respond_to?(:multi_target?) && card.multi_target?
          return multi_target(*targets)
        end

        targets.each do |target|
          raise InvalidTarget, "Invalid target for #{card.name}: #{target}" unless can_target?(target)
        end
        @targets = targets
        self
      end

      def multi_target(*targets)
        targets.each_with_index do |target, index|
          raise InvalidTarget, "Invalid target for #{card.name}: #{target}" unless can_target?(target, index)
        end
        @targets = targets
        self
      end

      def pay_mana(payment)
        mana_cost.treat_any_color_as_any! if any_color_for_any_cost?
        mana_cost.pay(player:, payment:)
        self
      end

      def any_color_for_any_cost?
        game.battlefield.static_abilities
          .of_type(Abilities::Static::AnyColorForAnyCost)
          .any? { |ability| ability.controller == player }
      end

      def auto_pay_mana
        mana_cost.auto_pay(player: player)
        self
      end

      def pay_kicker(payment)
        kicker_cost.pay(player:, payment:)
      end

      def pay_sacrifice(target)
        cost = additional_costs.find { |additional_cost| additional_cost.is_a?(Costs::Sacrifice) }
        raise "Unknown additional sacrifice cost" unless cost

        cost.pay(payment: target)
        @paid_additional_costs << cost
        self
      end

      def perform
        missing_costs = additional_costs - @paid_additional_costs
        raise "Additional costs have not been paid" unless missing_costs.empty?

        mana_cost.finalize!(player)
        game.stack.add(self)

        game.notify!(Events::SpellCast.new(
          spell: card,
          player: player,
          x_value: value_for_x,
          flashback: @flashback,
          targets: targets,
        ))
      end

      def choose_mode(mode_class, &)
        mode = Mode.new(mode_class.new(game: game, card: card))
        yield mode if block_given?
        @modes << mode
      end

      def resolve!
        if modes.any?
          modes.each { |mode| mode.resolve! }
        else
          resolve_with_args(card,
            target: targets.first,
            targets: targets,
            kicked: kicker_cost.paid?,
            value_for_x: mana_cost.x,
          )
        end

        if card.sorcery? || card.instant?
          if @flashback
            card.exile!
          else
            card.move_to_graveyard!(player)
          end
        end
      end
    end
  end
end
