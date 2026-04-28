module Magic
  module Actions
    class Cast < Action
      extend Forwardable

      class InvalidTarget < StandardError; end

      def_delegators :@card, :enchantment?, :artifact?, :multi_target?
      attr_reader :card, :targets, :value_for_x, :controller, :modes

      # @param flashback [Boolean] When true, allows casting from graveyard and exiles after resolution
      def initialize(card:, value_for_x: nil, controller: card.controller, flashback: false, **args)
        super(**args)
        @card = card
        @targets = []
        @modes = []
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
        return false unless @flashback ? card.zone.graveyard? : card.zone.hand?
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
        treat_any_color_as_any! if any_color_for_controller?
        mana_cost.pay(player:, payment:)
        self
      end

      def auto_pay_mana
        mana_cost.auto_pay(player: player)
        self
      end

      def pay_kicker(payment)
        kicker_cost.pay(player:, payment:)
      end

      def perform
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

      private

      def treat_any_color_as_any!
        mana_cost.treat_any_color_as_any!
      end

      def any_color_for_controller?
        game.battlefield.static_abilities
          .of_type(Abilities::Static::AnyColorForController)
          .any? { |ability| ability.applies_to_player?(player) }
      end
    end
  end
end
