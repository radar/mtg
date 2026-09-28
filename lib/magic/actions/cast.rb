module Magic
  module Actions
    class Cast < Action
      extend Forwardable

      class InvalidTarget < StandardError; end

      def_delegators :@card, :enchantment?, :artifact?, :multi_target?
      attr_reader :card, :targets, :value_for_x, :controller, :modes, :additional_costs

      # @param flashback [Boolean] When true, allows casting from graveyard and exiles after resolution
      # @param blitz [Boolean] When true, pays the card's blitz cost instead of its mana cost
      # @param by_effect [Boolean] When true, the spell is being cast because an effect instructed it (rebound,
      #   "you may cast it" during resolution), so its zone and timing restrictions are ignored (rule 608.2g)
      # @param adventure [Boolean] When true, pays the card's adventure cost, resolves via
      #   #adventure_resolve! instead of #resolve!, and exiles the card afterward
      # @param alternative [Boolean] When true, pays the card's alternative_cost instead of its mana cost
      def initialize(card:, value_for_x: nil, controller: card.controller, flashback: false, blitz: false, adventure: false, alternative: false, by_effect: false, **args)
        super(**args)
        @card = card
        @targets = []
        @modes = []
        @additional_costs = card.respond_to?(:additional_costs) ? card.additional_costs : []
        @paid_additional_costs = []
        @flashback = flashback
        @blitz = blitz
        @adventure = adventure
        @alternative = alternative
        @by_effect = by_effect

        @value_for_x = value_for_x
      end

      def inspect
        "#<Actions::Cast card: #{card.name}, player: #{player.inspect}>"
      end
      alias_method :name, :inspect

      def countered!
        game.notify!(Events::SpellCountered.new(spell: card, player: player))
        card.move_to_graveyard!(card.owner)
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
          elsif @blitz
            cost = card.blitz_cost
          elsif @adventure
            cost = card.adventure_cost
          elsif @alternative
            cost = card.alternative_cost
          elsif free_from_exile?
            cost = Costs::Mana.new({})
          else
            cost = card.cost
          end

          mana_cost_adjustment_abilities = game.battlefield.static_abilities
          .of_type(Abilities::Static::ManaCostAdjustment)
          .applies_to(card)

          # `cost` (from `card.cost`, at least) is a `Costs::Mana` that lives as long as the
          # card does and is shared by every `Cast` action built for it over the card's
          # life (cast, resolve, bounced back to hand, cast again, ...). `Costs::Mana#dup`
          # is `Object#dup`'s default shallow copy: it shares @balance/@payments (by
          # reference) with the original instead of giving each cast its own, so paying
          # this "fresh" cost mutates the card's cost for every future cast of it too.
          # Building a new Costs::Mana from the face-value cost hash instead keeps that
          # hash the only thing carried over, with balance/payments starting clean. Other
          # alternative-cost objects (Costs::SacrificeAlternativeCost,
          # Costs::ExileCardAndLifeAlternativeCost, ...) don't have this problem the same
          # way and don't share `Costs::Mana`'s `#cost`/`#adjusted_by` shape, so they're
          # just `dup`'d as before.
          fresh_cost = cost.is_a?(Costs::Mana) ? Costs::Mana.new(cost.cost.dup) : cost.dup
          cost = mana_cost_adjustment_abilities.each_with_object(fresh_cost) { |ability, cost| ability.apply(cost) }
          cost.adjusted_by(card.self_mana_cost_adjustment) if cost.is_a?(Costs::Mana) && card.self_mana_cost_adjustment
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
        return false if already_on_stack?
        return false unless castable_from_current_zone?
        return true if mana_cost.zero?

        mana_cost.can_pay?(player)
      end

      def illegal_reason
        unless @by_effect
          return "#{card.name} is a land, and lands are played, not cast" if card.land? && !@adventure
          return "#{card.name} is already on the stack" if already_on_stack?
          return "#{card.name} is not in a zone it can be cast from" unless castable_from_current_zone?

          if !instant_speed? && (reason = sorcery_speed_reason)
            return "#{card.name} can only be cast at sorcery speed, but #{reason}"
          end
        end

        "#{player.inspect} cannot cast any more spells this turn" if player.spell_cast_limit_reached?
      end

      # Instants and spells with flash can be cast any time the player has priority.
      def instant_speed?
        card.instant? || card.flash?
      end

      def target_choices
        choices = card.method(:target_choices)
        choices = choices.arity == 1 ? card.target_choices(player) : card.target_choices
      end

      def can_target?(target, index = nil)
        choices = index ? target_choices[index] : target_choices
        choices.include?(target) && Targetable.targetable_by?(target, source: card, controller: player)
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
        if card.respond_to?(:distinct_targets?) && card.distinct_targets? && targets.uniq.size != targets.size
          raise InvalidTarget, "#{card.name} needs different targets"
        end

        @targets = targets
        self
      end

      # Pays the spell's cost: a mana hash for a mana cost, or the card/permanent
      # for a non-mana (flashback/alternative) cost.
      def pay_cost(payment)
        mana_cost.treat_any_color_as_any! if any_color_for_any_cost?
        mana_cost.pay(player:, payment:)
        self
      end
      alias_method :pay_mana, :pay_cost

      def any_color_for_any_cost?
        game.battlefield.static_abilities
          .of_type(Abilities::Static::AnyColorForAnyCost)
          .any? { |ability| ability.controller == player && ability.any_color_for?(card) } ||
          static_ability_allows?(:any_mana_type_for?)
      end

      # "Mana of any type can be spent to cast that spell" / "cast it without paying its
      # mana cost": static abilities answering for this card and player.
      def static_ability_allows?(method)
        game.battlefield.static_abilities.any? { _1.respond_to?(method) && _1.public_send(method, card, player) }
      end

      def free_from_exile?
        card.zone&.exile? && static_ability_allows?(:free_cast_from_exile?)
      end

      def auto_pay_mana
        mana_cost.auto_pay(player: player)
        self
      end

      # Rule 702.51: tap an untapped creature you control to pay for {1} (`pay: :generic`)
      # or one mana of `pay` (one of the creature's own colors) toward this spell's cost.
      # Reduces the cost itself (`Costs::Mana#adjusted_by`, the same mechanism a static
      # cost-reduction ability uses) rather than paying from the mana pool, so this must
      # be called before any real mana payment (`pay_mana`/`auto_pay_mana`) -- paying
      # first and convoking after would reset the balance those payments already reduced,
      # since `adjusted_by` rebuilds `balance` from the (now smaller) cost.
      def convoke(creature, pay: :generic)
        raise "#{card.name} does not have convoke" unless card.convoke?
        raise "#{creature.name} is tapped" if creature.tapped?
        raise "#{player.inspect} does not control #{creature.name}" unless creature.controller == player

        if pay == :generic
          raise "#{card.name}'s cost has no generic mana left to convoke" unless mana_cost.balance[:generic].to_i.positive?

          mana_cost.adjusted_by(generic: -1)
        else
          raise "#{creature.name} is not #{pay}" unless creature.colors.include?(pay)
          raise "#{card.name}'s cost has no #{pay} mana left to convoke" unless mana_cost.balance[pay].to_i.positive?

          mana_cost.adjusted_by(pay => -1)
        end

        creature.tap!
        self
      end

      def pay_kicker(payment)
        kicker_cost.pay(player:, payment:)
      end

      # Offspring costs: the card's own, then any a static ability grants as it's cast
      # (Zinnia, Valley's Voice). Each is a separate additional cost, and each one
      # paid makes its own token copy.
      def offspring_costs
        @offspring_costs ||= begin
          granted = game.battlefield.static_abilities
            .of_type(Abilities::Static::GrantOffspring)
            .filter_map { |ability| ability.offspring_cost_for(card, player) }
          own = card.offspring_cost if card.respond_to?(:offspring_cost)
          [own, *granted].compact.map { |cost| Costs::Kicker.new(cost) }
        end
      end

      # Pays the next unpaid offspring cost, in #offspring_costs order.
      def pay_offspring(payment)
        # By identity: two equal grants (two Zinnias) are still separate costs.
        cost = offspring_costs.find { |c| paid_offspring_costs.none? { |paid| paid.equal?(c) } }
        raise "#{card.name} has no unpaid offspring cost" unless cost

        cost.pay(player:, payment:)
        paid_offspring_costs << cost
        self
      end

      def paid_offspring_costs
        @paid_offspring_costs ||= []
      end

      def pay_sacrifice(target)
        cost = additional_costs.find { |additional_cost| additional_cost.is_a?(Costs::Sacrifice) }
        raise "Unknown additional sacrifice cost" unless cost

        cost.pay(payment: target)
        @paid_additional_costs << cost
        self
      end

      # "Blight N or pay {M}" as an additional cost: `payment` is a creature (to blight)
      # or a mana payment hash (to pay the extra mana instead).
      def pay_blight_or_mana(payment)
        cost = additional_costs.find { |additional_cost| additional_cost.is_a?(Costs::BlightOrMana) }
        raise "Unknown additional blight-or-mana cost" unless cost

        cost.pay(player:, payment: payment)
        @paid_additional_costs << cost
        self
      end

      def pay_discard(payment)
        if payment.is_a?(Array)
          cost = additional_costs.find { |additional_cost| additional_cost.is_a?(Costs::DiscardCards) }
          raise "Unknown additional discard cost" unless cost

          cost.pay(payment: payment)
        else
          cost = additional_costs.find { |additional_cost| additional_cost.is_a?(Costs::Discard) }
          raise "Unknown additional discard cost" unless cost

          cost.pay(player: player, payment: payment)
        end
        @paid_additional_costs << cost
        self
      end

      def perform
        missing_costs = additional_costs - @paid_additional_costs
        raise "Additional costs have not been paid" unless missing_costs.empty?

        # Casting a card you don't own (from an opponent's exile) makes you its controller.
        card.controller = player

        mana_cost.finalize!(player)
        paid_offspring_costs.each { |cost| cost.finalize!(player) }
        player.consume_spell_cast!
        game.stack.add(self)

        game.notify!(Events::SpellCast.new(
          spell: card,
          player: player,
          mana_cost: mana_cost,
          x_value: value_for_x,
          flashback: @flashback,
          targets: targets,
        ))
      end

      def choose_mode(mode_class, &)
        mode = Mode.new(mode_class.new(game: game, card: card), source: card, controller: player)
        yield mode if block_given?
        @modes << mode
      end

      def resolve!
        if modes.any?
          modes.each { |mode| mode.resolve! }
        else
          resolved = resolve_with_args(card,
            method: @adventure ? :adventure_resolve! : :resolve!,
            target: targets.first,
            targets: targets,
            kicked: kicker_cost.paid?,
            value_for_x: mana_cost.x,
            controller: player,
          )
        end

        if @blitz && resolved.is_a?(Permanent)
          resolved.grant_haste!
          resolved.register_turn_trigger(Events::CreatureDied, Blitz::DeathDrawTrigger)
          resolved.register_turn_trigger(Events::BeginningOfEndStep, Blitz::EndStepSacrificeTrigger)
        end

        queue_offspring_triggers(resolved) if paid_offspring_costs.any?

        if @adventure
          card.exile!
          card.on_adventure = true
        elsif card.sorcery? || card.instant?
          if @flashback
            card.exile!
          elsif card.zone&.graveyard? && game.emblems.any? { |emblem| emblem.owner == player && emblem.respond_to?(:exiles_after_graveyard_cast?) && emblem.exiles_after_graveyard_cast?(card) }
            card.exile!
          elsif card.rebound? && card.zone.hand?
            card.exile!
          elsif card.buyback? && kicker_cost.paid?
            card.move_to_hand!(card.owner)
          else
            card.move_to_graveyard!(card.owner)
          end
        end
      end

      private

      # "If you do, when that creature enters, create a 1/1 token copy of it."
      def queue_offspring_triggers(resolved)
        return unless resolved.is_a?(Permanent) && resolved.zone&.battlefield?

        entered = game.current_turn.events.reverse.find do |event|
          event.is_a?(Events::EnteredTheBattlefield) && event.permanent == resolved
        end
        return unless entered

        paid_offspring_costs.size.times { resolved.perform_trigger!(Offspring::TokenCopyTrigger, entered) }
      end

      def castable_from_current_zone?
        in_permitted_zone?(card, flashback: @flashback)
      end

      # Rule 405.2: once a spell is on the stack it isn't in any zone it could be cast
      # from again. `card.zone` doesn't track "on the stack" as its own state (it's still
      # whatever zone it was cast from until the spell resolves and moves it elsewhere),
      # so this is checked against the stack directly instead of folded into
      # `in_permitted_zone?`. Without this, asking twice whether the same still-unresolved
      # spell is castable says yes both times -- harmless for a caller that only ever
      # asks once, but a legality query built to be asked repeatedly (`Game#legal_actions`,
      # roadmap C2b) would offer it again and a caller that acted on that would re-pay its
      # cost against the same Costs::Mana object `card.cost`'s already at (a shallow `dup`
      # away from `Costs::Mana#auto_pay`/`#pay` mutating `@balance` in place), overpaying it.
      def already_on_stack?
        game.stack.spells.any? { |spell| spell.card == card }
      end
    end
  end
end
