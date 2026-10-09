module Magic
  module Actions
    class Cast < Action
      extend Forwardable

      class InvalidTarget < StandardError; end
      class InvalidModes < StandardError; end

      def_delegators :@card, :enchantment?, :artifact?, :multi_target?
      attr_reader :card, :targets, :value_for_x, :controller, :modes, :additional_costs

      # @param flashback [Boolean] When true, allows casting from graveyard and exiles after resolution
      # @param blitz [Boolean] When true, pays the card's blitz cost instead of its mana cost
      # @param by_effect [Boolean] When true, the spell is being cast because an effect instructed it (rebound,
      #   "you may cast it" during resolution), so its zone and timing restrictions are ignored (rule 608.2g)
      # @param adventure [Boolean] When true, pays the card's adventure cost, resolves via
      #   #adventure_resolve! instead of #resolve!, and exiles the card afterward
      # @param alternative [Boolean] When true, pays the card's alternative_cost instead of its mana cost
      # @param harmonize [Boolean] When true, casts from the graveyard for the card's harmonize cost
      #   (see #harmonize_tap) and exiles the spell after it resolves
      # @param pay_life [Boolean] When true, pays life equal to the card's mana value rather than its mana cost, if a
      #   static ability allows that for this card (`may_pay_life_for?`: Demon of Fate's Design)
      def initialize(card:, value_for_x: nil, controller: card.controller, flashback: false, blitz: false, evoked: false, adventure: false, alternative: false, by_effect: false, harmonize: false, pay_life: false, **args)
        super(**args)
        @card = card
        @pay_life = pay_life
        @stack_size_at_start = game.stack.count
        @targets = []
        @modes = []
        @additional_costs = (card.respond_to?(:additional_costs) ? card.additional_costs : []) + granted_additional_costs
        @paid_additional_costs = []
        @flashback = flashback
        @harmonize = harmonize
        @blitz = blitz
        @evoked = evoked
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
        kicker_cost.reset! if kicker_cost.is_a?(Costs::OptionalBehold) || kicker_cost.is_a?(Costs::Gift)
        game.notify!(Events::SpellCountered.new(spell: card, player: player))
        @harmonize ? card.exile! : card.move_to_graveyard!(card.owner)
      end

      def return_to_hand!
        card.move_to_hand!(player)
      end

      def exile!
        card.exile!
      end

      def mana_cost=(cost)
        @mana_cost = Costs::Mana.new(cost).tap { |mana_cost| mana_cost.for_use = card }
      end

      def mana_cost
        @mana_cost ||= begin
          if @flashback && card.zone.graveyard?
            cost = card.flashback_cost_now
          elsif @harmonize && card.zone.graveyard? && card.harmonize_cost
            cost = card.harmonize_cost
          elsif @blitz
            cost = card.blitz_cost
          elsif @evoked
            cost = card.evoke_cost
          elsif @adventure
            cost = card.adventure_cost
          elsif @alternative
            cost = card.alternative_cost
          elsif free_from_exile? || pays_life_instead?
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
          cost.for_use = card if cost.is_a?(Costs::Mana)
          cost
        end
      end

      def auto_pay
        mana_cost.auto_pay(player)
      end

      def kicker_cost
        card.kicker_cost
      end

      # "You may pay life equal to a spell's mana value rather than pay its mana cost" (Bolas's Citadel), for a spell
      # cast from the top of the library. Static abilities answer `pays_life_for?(card, player)`.
      def pays_life_instead?
        return false if @flashback || @harmonize || @blitz || @evoked || @adventure || @alternative
        return true if @pay_life && static_ability_allows?(:may_pay_life_for?)

        card.zone&.library? ? static_ability_allows?(:pays_life_for?) : false
      end

      # Whether this spell could be cast by paying life (an optional alternative cost, unlike Bolas's Citadel's).
      def may_pay_life?
        !@flashback && !@harmonize && !@blitz && !@evoked && !@adventure && !@alternative && static_ability_allows?(:may_pay_life_for?)
      end

      def life_payment
        pays_life_instead? ? card.mana_value : 0
      end

      def can_perform?
        return false if already_on_stack?
        return false if player.life < life_payment
        return false unless castable_from_current_zone?
        return false unless modes_satisfiable?
        return true if mana_cost.zero?

        mana_cost.can_pay?(player)
      end

      def illegal_reason
        unless @by_effect
          return "#{card.name} is a land, and lands are played, not cast" if card.land? && !@adventure
          return "#{card.name} is already on the stack" if already_on_stack?
          return "#{card.name} is not in a zone it can be cast from" unless castable_from_current_zone?
          return "#{card.name} has no harmonize cost" if @harmonize && !card.harmonize_cost
          return "#{card.name} has no flashback cost" if @flashback && !card.flashback_cost_now
          return "#{card.name}'s flashback requirements aren't met" if @flashback && card.respond_to?(:flashback_requirements_met?) && !card.flashback_requirements_met?(player)

          if !instant_speed? && (reason = sorcery_speed_reason)
            return "#{card.name} can only be cast at sorcery speed, but #{reason}"
          end
        end

        return "#{player.inspect} cannot pay #{life_payment} life for #{card.name}" if player.life < life_payment

        "#{player.inspect} cannot cast any more spells this turn" if player.spell_cast_limit_reached?
      end

      # Triggers that paying a cost sets off (a creature sacrificed as a cost dying) go on the stack before the spell does,
      # but they don't stop it being cast at sorcery speed: only what was on the stack to begin with does.
      def sorcery_speed_reason
        reason = super
        reason == "the stack is not empty" && @stack_size_at_start.zero? ? nil : reason
      end

      # Instants and spells with flash can be cast any time the player has priority.
      def instant_speed?
        card.instant? || card.flash? || (kicker_cost.respond_to?(:grants_flash?) && kicker_cost.grants_flash?)
      end

      def target_choices
        choices = card.method(:target_choices)
        choices = choices.arity == 1 ? card.target_choices(player) : card.target_choices
      end

      def can_target?(target, index = nil)
        choices = index ? target_choices[index] : target_choices
        # "target creature with mana value X" (Stolen by the Fae): the card says whether a target fits the X it is cast with.
        return false if card.respond_to?(:target_fits_x?) && !card.target_fits_x?(target, value_for_x || mana_cost.x || 0)

        choices.include?(target) && Targetable.targetable_by?(target, source: card, controller: player)
      end

      def targeting(*targets)
        if card.respond_to?(:multi_target?) && card.multi_target?
          return multi_target(*targets)
        end

        targets.each do |target|
          raise InvalidTarget, "Invalid target for #{card.name}: #{target}" unless can_target?(target)
        end
        # "X target creatures" (Thrive): the number of targets depends on X, which only the cast knows.
        if card.respond_to?(:number_of_targets) && card.number_of_targets(value_for_x || mana_cost.x || 0) != targets.size
          raise InvalidTarget, "#{card.name} needs #{card.number_of_targets(value_for_x || mana_cost.x || 0)} targets, got #{targets.size}"
        end
        if card.respond_to?(:distinct_targets?) && card.distinct_targets? && targets.uniq.size != targets.size
          raise InvalidTarget, "#{card.name} needs different targets"
        end
        @targets = targets
        apply_target_cost_increases!
        self
      end

      # "Spells your opponents cast that target this creature cost {3} more to cast" (Pursued Whale): a static ability
      # answering `cost_increase_for_targeting(card, targets, player)` with the extra generic mana. Only known once the
      # targets are, so the extra must be paid after `targeting` (`pay_mana` again), or the spell can't be cast.
      def apply_target_cost_increases!
        extra = game.battlefield.static_abilities
          .select { |ability| ability.respond_to?(:cost_increase_for_targeting) }
          .sum { |ability| ability.cost_increase_for_targeting(card, targets, player) }
        # The card's own "costs {N} less if it targets ..." (Uneasy Partings): a negative generic change.
        extra += card.cost_change_for_targets(targets) if card.respond_to?(:cost_change_for_targets)
        change = extra - (@target_cost_increase || 0)
        return if change.zero?

        mana_cost.increase_generic!(change)
        @target_cost_increase = extra
      end

      def multi_target(*targets)
        targets.each_with_index do |target, index|
          raise InvalidTarget, "Invalid target for #{card.name}: #{target}" unless can_target?(target, index)
        end
        if card.respond_to?(:distinct_targets?) && card.distinct_targets? && targets.uniq.size != targets.size
          raise InvalidTarget, "#{card.name} needs different targets"
        end
        if card.respond_to?(:targets_legal?) && !card.targets_legal?(targets)
          raise InvalidTarget, "Invalid targets for #{card.name}: #{targets.map(&:name).join(', ')}"
        end

        @targets = targets
        apply_target_cost_increases!
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
        card.zone&.exile? && (static_ability_allows?(:free_cast_from_exile?) || game.play_permissions.free_cast?(card, player))
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
        raise "#{card.name} does not have convoke" unless card.convoke? || static_ability_allows?(:grants_convoke?)
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

      # Rule 702.180 (harmonize): tap an untapped creature you control to reduce the harmonize cost
      # by an amount of generic mana equal to its power (no more than the generic mana left).
      # Like #convoke it reduces the cost itself, so call it before any mana payment.
      def harmonize_tap(creature)
        raise "#{card.name} is not being cast with harmonize" unless @harmonize
        raise "#{creature.name} is tapped" if creature.tapped?
        raise "#{player.inspect} does not control #{creature.name}" unless creature.controller == player

        reduction = [creature.power, mana_cost.balance[:generic].to_i].min
        mana_cost.adjusted_by(generic: -reduction) if reduction.positive?
        creature.tap!
        self
      end

      # Rule 702.78 (conspire): as you cast it, tap two untapped creatures you control that share a
      # color with it; when you do, copy it. A card has conspire itself or is granted it by a
      # static ability that defines `grants_conspire?(card, player)` (Raiding Schemes).
      def conspire(first, second)
        unless card.respond_to?(:conspire?) && card.conspire? || static_ability_allows?(:grants_conspire?)
          raise "#{card.name} does not have conspire"
        end
        raise "conspire needs two different creatures" if first.equal?(second)

        [first, second].each do |creature|
          raise "#{creature.name} is tapped" if creature.tapped?
          raise "#{player.inspect} does not control #{creature.name}" unless creature.controller == player
          raise "#{creature.name} doesn't share a color with #{card.name}" if (creature.colors & card.colors).empty?
        end

        [first, second].each(&:tap!)
        @conspired = true
        self
      end

      def pay_kicker(payment)
        kicker_cost.pay(player:, payment:)
        self
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

      # Pays +cost+ (one of #offspring_costs: the card's own or a granted one), or the next
      # unpaid one in #offspring_costs order when none is given. Any subset can be paid.
      def pay_offspring(payment, cost = nil)
        # By identity: two equal grants (two Zinnias) are still separate costs.
        unpaid = offspring_costs.reject { |c| paid_offspring_costs.any? { |paid| paid.equal?(c) } }
        cost ||= unpaid.first
        raise "#{card.name} has no unpaid offspring cost" unless cost
        raise "#{card.name} offspring cost is not available" unless unpaid.any? { |c| c.equal?(cost) }

        cost.pay(player:, payment:)
        paid_offspring_costs << cost
        self
      end

      def paid_offspring_costs
        @paid_offspring_costs ||= []
      end

      # Additional costs a static ability attaches to casting this card (Dawnhand Dissident:
      # "...by removing three counters from among creatures you control in addition to paying
      # their other costs"). The ability answers `additional_cost_for(card, player)`.
      def granted_additional_costs
        game.battlefield.static_abilities
          .select { |ability| ability.respond_to?(:additional_cost_for) }
          .filter_map { |ability| ability.additional_cost_for(card, player) }
      end

      # "Remove N counters from among creatures you control" additional cost: `payment` is
      # an Array of `[creature, counter_class]` pairs.
      def pay_remove_counters(payment)
        cost = additional_costs.find { |additional_cost| additional_cost.is_a?(Costs::RemoveCountersFromCreatures) }
        raise "Unknown additional remove-counters cost" unless cost

        cost.pay(player:, payment:)
        @paid_additional_costs << cost
        self
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

      # Pays whichever additional cost is a `cost_class` through its own `pay(player:, payment:)`
      # (Stir Up Trouble's `Costs::SacrificeOrMana`).
      def pay_additional_cost(cost_class, payment)
        cost = additional_costs.find { |additional_cost| additional_cost.is_a?(cost_class) }
        raise "Unknown additional #{cost_class} cost" unless cost

        cost.pay(player:, payment: payment)
        @paid_additional_costs << cost
        self
      end

      # "Behold a <type> [and exile it] [or pay {M}]" as an additional cost: `payment` is the
      # permanent or card to behold, or a mana payment hash for the "or pay" alternative.
      def pay_behold(payment)
        cost = additional_costs.find { |additional_cost| additional_cost.is_a?(Costs::Behold) }
        raise "Unknown additional behold cost" unless cost

        cost.pay(player:, payment:)
        @paid_additional_costs << cost
        self
      end

      # "Blight X" as an additional cost: put X -1/-1 counters on `creature` (X up to the greatest
      # toughness among your creatures).
      def pay_blight_x(creature, x)
        cost = additional_costs.find { |additional_cost| additional_cost.is_a?(Costs::BlightX) }
        raise "Unknown additional blight-X cost" unless cost

        cost.pay(player:, payment: [creature, x])
        @paid_additional_costs << cost
        self
      end

      # "Pay N life" as an additional cost (Demonic Embrace from the graveyard): the life is lost as the spell is cast.
      def pay_additional_life
        cost = additional_costs.find { |additional_cost| additional_cost.is_a?(Costs::PayLife) }
        raise "Unknown additional life cost" unless cost
        raise "#{player.inspect} can't pay #{cost.amount} life" unless cost.can_pay?(player)

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
        validate_modes!

        missing_costs = additional_costs - @paid_additional_costs
        raise "Additional costs have not been paid" unless missing_costs.empty?

        # Casting a card you don't own (from an opponent's exile) makes you its controller.
        card.controller = player

        # Settled before the life is paid: "once each turn" permissions stop applying afterwards.
        mana_cost
        if pays_life_instead?
          player.lose_life(life_payment)
          if @pay_life
            game.battlefield.static_abilities.each { _1.paid_life_for_spell!(card, player) if _1.respond_to?(:paid_life_for_spell!) }
          end
        end
        mana_cost.finalize!(player)
        @paid_additional_costs.each { |cost| cost.finalize!(player) if cost.is_a?(Costs::PayLife) }
        paid_offspring_costs.each { |cost| cost.finalize!(player) }
        player.consume_spell_cast!
        if card.zone&.graveyard?
          game.battlefield.static_abilities.each { _1.cast_from_graveyard!(card, player) if _1.respond_to?(:cast_from_graveyard!) }
        end
        game.stack.add(self)

        game.notify!(Events::SpellCast.new(
          spell: card,
          player: player,
          mana_cost: mana_cost,
          x_value: value_for_x,
          flashback: @flashback,
          targets: targets,
        ))

        copy_for_conspire if @conspired
      end

      # "Whenever you cast an Elf spell, it gains haste until end of turn" (Tyvar Kell's emblem): the
      # permanent this spell resolves into gets haste.
      def gain_haste_on_resolve!
        @gains_haste = true
      end

      def choose_mode(mode_class, &)
        raise InvalidModes, "#{mode_class} is not a mode of #{card.name}" unless card.modes.include?(mode_class)
        raise InvalidModes, "#{mode_class} was already chosen" if @modes.any? { |mode| mode.mode.instance_of?(mode_class) }
        raise InvalidModes, "#{card.name} allows at most #{max_modes} modes" if max_modes && @modes.size >= max_modes

        mode = Mode.new(mode_class.new(game: game, card: card), source: card, controller: player)
        yield mode if block_given?
        @modes << mode
      end

      # Rule 700.2: the number of modes is fixed when the spell is cast. Only cards that declare
      # `choose_modes` are checked.
      def validate_modes!
        return unless card.respond_to?(:modes_to_choose)

        allowed = card.modes_to_choose
        return if allowed === @modes.size

        raise InvalidModes, "#{card.name} needs #{allowed} modes chosen, got #{@modes.size}"
      end

      # The mode classes that currently have something to target (or need no target).
      def available_modes
        card.modes.select { |mode_class| mode_targetable?(mode_class) }
      end

      def min_modes
        return 0 unless card.respond_to?(:modes_to_choose)

        allowed = card.modes_to_choose
        allowed.is_a?(Range) ? allowed.min : allowed
      end

      # Advisory, like #can_perform?: could enough modes be chosen right now?
      def modes_satisfiable?
        available_modes.size >= min_modes
      end

      def max_modes
        return unless card.respond_to?(:modes_to_choose)

        allowed = card.modes_to_choose
        allowed.is_a?(Range) ? allowed.max : allowed
      end

      def mode_targetable?(mode_class)
        mode = mode_class.new(game: game, card: card)
        return true unless mode.respond_to?(:target_choices)

        pools = mode.target_choices
        pools = [pools] unless mode.respond_to?(:multi_target?) && mode.multi_target?
        pools.all? { |pool| pool.any? }
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
            mana_spent: mana_cost.is_a?(Costs::Mana) ? mana_cost.mana_spent : {},
            evoked: @evoked,
            flashback: @flashback,
            value_for_x: mana_cost.x,
            controller: player,
          )
        end

        resolved.grant_haste! if @gains_haste && resolved.is_a?(Permanent)

        if @blitz && resolved.is_a?(Permanent)
          resolved.grant_haste!
          resolved.register_turn_trigger(Events::CreatureDied, Blitz::DeathDrawTrigger)
          resolved.register_turn_trigger(Events::BeginningOfEndStep, Blitz::EndStepSacrificeTrigger)
        end

        # The card's own optional behold or gift cost outlives this cast: forget it was paid.
        kicker_cost.reset! if kicker_cost.is_a?(Costs::OptionalBehold) || kicker_cost.is_a?(Costs::Gift)

        if resolved.is_a?(Permanent)
          @paid_additional_costs.each { |cost| cost.resolved!(resolved) if cost.respond_to?(:resolved!) }
        end

        queue_offspring_triggers(resolved) if paid_offspring_costs.any?

        if @adventure
          card.exile!
          card.on_adventure = true
        elsif card.sorcery? || card.instant?
          if @flashback || @harmonize
            card.exile!
          elsif card.zone&.graveyard? && game.emblems.any? { |emblem| emblem.owner == player && emblem.respond_to?(:exiles_after_graveyard_cast?) && emblem.exiles_after_graveyard_cast?(card) }
            card.exile!
          elsif card.exile_with_dream_counter
            card.exile_with_dream_counter = false
            card.exile!
            card.dream_counter = true
          elsif card.rebound? && card.zone.hand?
            card.exile!
          elsif card.exile_as_it_resolves?
            card.exile!
          elsif card.buyback? && kicker_cost.paid?
            card.move_to_hand!(card.owner)
          else
            card.move_to_graveyard!(card.owner)
          end
        end
      end

      # \"When you do, copy it\": a copy of a permanent spell becomes a token; any other copy may
      # choose new targets.
      def copy_for_conspire
        if card.permanent?
          Permanent.resolve(game:, owner: player, card:, token: true, copy: true, cast: false, from_zone: nil)
        else
          Magic::CopyEffect.resolve_with_choice!(actor: card, receiver: card, targets:, copies: 1)
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
        in_permitted_zone?(card, flashback: @flashback || @harmonize)
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
