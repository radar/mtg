module Magic
  class Permanent
    include Permanents::Creature
    include Permanents::Planeswalker
    include Permanents::Enchantment
    include Permanents::Modifications
    include Keywords
    include Types
    include Targetable

    extend Forwardable
    attr_reader :game,
      :owner,
      :controller,
      :card,
      :types,
      :power,
      :toughness,
      :keywords,
      :attachments,
      :protections,
      :modifiers,
      :keyword_grants,
      :counters,
      :activated_abilities,
      :state_triggered_abilities,
      :exiled_cards,
      :cannot_untap_next_turn,
      :timestamp

    # The card exiled to pay a "behold ... and exile it" cost, returned when this leaves (Costs::Behold).
    attr_accessor :beheld_card

    attr_accessor :copied_card, :chosen_creature_type, :exile_cast_permission_turn, :ring_bearer, :prevent_opponent_lifegain_turn, :pending_mana_ability_uses

    # Set by ContinuousEffects from Abilities::Static::CharacteristicSetting.
    attr_accessor :color_override, :lost_all_abilities_by_effect

    def_delegators :@card, :name, :cmc, :mana_value, :colors, :colorless?, :opponents, :additional_lands_per_turn, :power_modification, :toughness_modification, :type_grants
    def_delegators :@game, :logger

    class Protections < SimpleDelegator
      def player
        select { |protection| protection.protects_player? }
      end
    end

    attr_accessor :zone
    # The mana it was cast with, as { color => amount } ("if {W}{W} was spent to cast it"), and whether
    # it was cast for its evoke cost (sacrificed when it enters).
    attr_writer :mana_spent
    attr_accessor :evoked
    # "You may have this enter as a copy of ...": a not-yet-copied 0/0 mustn't die to state-based
    # actions while its enters trigger is still asking (cleared once that's answered).
    attr_writer :copy_choice_pending
    # The zone the card was in when it entered the battlefield (nil for tokens and copies).
    # A spell cast from a graveyard keeps its graveyard zone until it resolves.
    attr_accessor :entered_from_zone
    # The number of the turn during which the current controller gained control of this permanent.
    attr_accessor :controlled_since_turn

    def self.resolve(game:, card:, owner: card.owner, from_zone: nil, enters_tapped: card.enters_tapped?, token: card.token?, cast: true, kicked: false, copy: false, attach_to: nil, controller: owner, mana_spent: {}, evoked: false)
      enters_tapped = enters_tapped_after_replacements(game:, card:, enters_tapped:, controller:)
      card_zone = card.zone unless token || copy

      permanent = Magic::Permanent.new(
        game: game,
        owner: owner,
        controller: controller,
        card: card,
        kicked: kicked,
        cast: cast,
        token: token,
        copy: copy,
      )
      permanent.mana_spent = mana_spent
      permanent.copy_choice_pending = card.enters_as_copy?
      permanent.evoked = evoked

      permanent.entered_from_zone = card_zone
      permanent.tap! if enters_tapped
      permanent.attach_to!(attach_to) if attach_to
      card.entering_counters.each { |counter_type, amount| permanent.add_counter(counter_type, amount:) }
      if cast && card_zone&.hand?
        card.entering_counters_if_cast_from_hand.each { |counter_type, amount| permanent.add_counter(counter_type, amount:) }
      end
      permanent.move_zone!(from: from_zone, to: game.battlefield)
      add_additional_counters_for_entering(game:, permanent:) if card.creature?
      move_card_to_battlefield(game:, card:, permanent:, from: card_zone)
      permanent
    end

    # The card leaves the zone it was in (exile, graveyard, hand, ...) along with the
    # permanent entering, unless something else already moved it: a replaced entry
    # (Containment Priest), or the permanent leaving again as it entered. Tokens and
    # copies made from a card leave that card be (`from` is nil for them).
    def self.move_card_to_battlefield(game:, card:, permanent:, from:)
      return if from.nil? || from.battlefield?
      return unless card.zone == from && permanent.zone&.battlefield?

      card.move_zone!(to: game.battlefield)
    end

    def self.add_additional_counters_for_entering(game:, permanent:)
      static_abilities(game, Abilities::Static::AdditionalCountersForEntering).each do |ability|
        amount = ability.additional_counters_for_entering(permanent)
        permanent.add_counter("+1/+1", amount: amount) if amount.positive?
      end
    end

    def self.enters_tapped_after_replacements(game:, card:, enters_tapped:, controller: nil)
      # "Creatures your opponents control enter tapped" (Authority of the Consuls): a static ability
      # answering `forces_creature_to_enter_tapped?(card, player)`.
      if !enters_tapped && card.creature? && controller &&
         game.battlefield.static_abilities.any? { _1.respond_to?(:forces_creature_to_enter_tapped?) && _1.forces_creature_to_enter_tapped?(card, controller) }
        return true
      end
      return enters_tapped unless enters_tapped && card.land?

      prevented = static_abilities(game, Abilities::Static::LandsEnterUntapped).any? do |ability|
        ability.lands_enter_untapped?(card)
      end

      !prevented
    end

    def self.static_abilities(game, type) = game.battlefield.static_abilities.of_type(type)

    def initialize(game:, owner:, card:, controller: owner, token: false, cast: true, kicked: false, copy: false, timestamp: Permanents::ContinuousEffect.next_timestamp)
      @game = game
      @owner = owner
      @controller = controller
      @card = card
      @token = token
      @cast = cast
      @kicked = kicked
      @copy = copy
      @base_types = card.types
      @attachments = []
      @turn_triggers = {}
      @turn_replacements = []
      @modifiers = []
      @tapped = false
      @types = card.types
      @keyword_grants = card.keyword_grants
      @keywords = card.keywords.dup
      @activated_abilities = card.activated_abilities
      @counters = Counters::Collection.new([])
      @damage = 0
      @regeneration_shields = 0
      @protections = Protections.new(card.protections.dup)
      @exiled_cards = Magic::CardList.new([])
      @pending_mana_ability_uses = 0
      @phased_out = false
      @prepared = false
      @timestamp = timestamp
      @controlled_since_turn = game.current_turn&.number
    end

    def kicked?
      @kicked
    end

    # The face of a double-faced card that's currently up (the card itself when it isn't
    # double-faced or hasn't transformed). Its characteristics and abilities are the permanent's.
    def face
      @transformed ? card.back_face : card
    end

    def transformed? = @transformed || false

    # Free-form per-permanent state for cards that level up or remember something (Figure of Fable).
    def state = (@state ||= {})

    def mana_spent = @mana_spent || {}
    def evoked? = !!@evoked
    def copy_choice_pending? = !!@copy_choice_pending

    # "If {W}{W} was spent to cast it": at least `amount` mana of `color` went into casting this.
    def mana_spent?(color, amount = 1) = mana_spent.fetch(color, 0) >= amount

    def copiable_card
      copied_card || face
    end

    def name = copiable_card.name
    def cmc = copiable_card.cmc
    def mana_value = copiable_card.mana_value
    # A color set by continuous effects (layer 5 -- ContinuousEffects resolves any competing
    # Modifications::Color/CharacteristicSetting#set_colors by timestamp), else the card's colors.
    def colors
      color_override || copiable_card.colors
    end

    def colorless? = colors.empty?
    def multi_colored? = colors.count > 1

    def apply_continuous_effects!
      Magic::Permanents::ContinuousEffects.new(game: game, permanent: self).apply!
    end

    def types=(types)
      @types = types
    end

    def power=(power)
      @power = power
    end

    def toughness=(toughness)
      @toughness = toughness
    end

    def keywords=(keywords)
      @keywords = keywords
    end

    def activated_abilities=(abilities)
      @activated_abilities = abilities
    end

    # With no `card:`, turns a double-faced card over (rule 701.28): the other face's
    # characteristics and abilities take over, the physical card stays the same (so it still
    # goes to the graveyard as the front face) and `Events::PermanentTransformed` fires.
    # With `card:`, swaps in another card object outright (Fable of the Mirror-Breaker).
    def transform!(card: nil)
      unless card
        raise "#{name} is not a double-faced card" unless self.card.back_face

        @transformed = !@transformed
        @keyword_grants = face.keyword_grants
        apply_continuous_effects!
        game.notify!(Events::PermanentTransformed.new(permanent: self))
        return self
      end

      @card = card
      @base_types = card.types
      @types = card.types
      @keyword_grants = card.keyword_grants
      @activated_abilities = card.activated_abilities.map { |ability| ability.new(source: self) }
      apply_continuous_effects!
      self
    end

    def keyword_grant_modifiers
      modifiers.select { |modifier| modifier.is_a?(Permanents::Modifications::KeywordGrant) }
    end

    def inspect
      "#<Magic::Permanent name:#{card.name} controller:#{controller.name}>"
    end

    def state_triggered_abilities
      @state_triggered_abilities ||= card.state_triggered_abilities.map { |ability| ability.new(source: self) }
    end

    alias_method :to_s, :inspect

    def controller?(other_controller)
      controller == other_controller
    end

    def controller=(other_controller)
      @controller = other_controller
      @controlled_since_turn = game.current_turn&.number
    end

    # "Gain control of target creature until end of turn": control returns to the
    # previous controller at cleanup. Layer 2 (613): stacked as an ordered list of
    # ControlChangeEffects rather than a single slot, so two such effects on the
    # same permanent in one turn revert correctly instead of the second clobbering
    # the first's memory of who to revert to.
    def gain_control_until_eot!(player)
      control_change_effects << Permanents::ControlChangeEffect.new(controller: player, previous_controller: controller, until_eot: true)
      self.controller = player
    end

    def control_change_effects
      @control_change_effects ||= []
    end

    # Rule 302.6: a creature's {T} abilities and its ability to attack need it to have been under its
    # controller's control continuously since their most recent turn began, unless it has haste.
    def summoning_sick?
      return false unless creature?
      return false if haste?
      return false unless @controlled_since_turn

      latest_turn = game.latest_turn_number_of(controller)
      latest_turn.nil? || @controlled_since_turn >= latest_turn
    end

    def opponents
      game.opponents(controller)
    end

    def token?
      @token
    end

    def all_creature_types?
      return false if lost_creature_types?

      @gained_all_creature_types || copiable_card.all_creature_types? || attachments.any? { _1.card.grants_all_creature_types? }
    end

    def ring_bearer?
      !!@ring_bearer
    end

    def copy?
      @copy
    end

    def cast?
      @cast
    end

    def entered_from_graveyard? = entered_from_zone&.graveyard? || false

    def move_zone!(from: zone, to:)
      trigger_effect(:move_permanent_zone, target: self, from: from, to: to)
    end

    # Permanents can only exist on the battlefield.
    def zone=(new_zone)
      @zone = new_zone.battlefield? ? new_zone : nil
    end

    def replacement_effect_for(context)
      return nil if lost_all_abilities?

      (card.replacement_effects.to_a + @turn_replacements).each do |matcher, replacement_effect|
        next unless replacement_matcher_applies?(matcher, context.effect)

        replacement_key = [object_id, replacement_effect]
        next if context.applied_replacement_keys.include?(replacement_key)

        replacement = replacement_effect.new(receiver: self)
        return replacement if replacement.applies_with_context?(context)
      end

      nil
    end

    def replacement_matcher_applies?(matcher, effect)
      case matcher
      when nil
        true
      when Class
        effect.is_a?(matcher)
      else
        matcher == effect.class
      end
    end

    def receive_event(event)
      expire_protections_until_turn_of(event.player) if event.is_a?(Events::BeginningOfUpkeep)
      dispatch_lifecycle_triggers(event)
      dispatch_event_handlers(event)
      dispatch_turn_triggers(event)
    end

    # A replacement effect that lasts until end of turn ("if it would die this turn, exile it instead").
    def register_turn_replacement(matcher, replacement_effect)
      @turn_replacements << [matcher, replacement_effect]
    end

    def register_turn_trigger(event_class, trigger_class)
      @turn_triggers[event_class] = Array(@turn_triggers[event_class]) + [trigger_class]
    end

    def entered_the_battlefield!(event)
      dispatch_lifecycle_triggers(event)
    end

    def protected_from?(card)
      @protections.any? { |protection| protection.protected_from?(card) }
    end

    # "Target creature gets -2/-0 until your next turn."
    def modify_power_until_turn_of!(player, power)
      modify_power(power, until_eot: false)
      modifiers.last.until_turn_of = player
    end

    # "Target creature gets -2/-0 until your next turn" (either or both of power and toughness).
    def modify_power_toughness_until_turn_of!(player, power, toughness)
      modify_power(power, until_eot: false)
      modifiers.last.until_turn_of = player
      modify_toughness(toughness, until_eot: false)
      modifiers.last.until_turn_of = player
    end

    # "Gains all creature types. (This effect doesn't end.)"
    def gain_all_creature_types!
      @gained_all_creature_types = true
    end

    def gains_protection_from_color(color, until_eot: false, until_turn_of: nil)
      @protections << Protection.from_color(color, until_eot: until_eot, until_turn_of: until_turn_of)
    end

    # "Gains protection from each color until your next turn" (`player`'s next turn begins).
    def gains_protection_from_each_color_until_turn_of!(player)
      %i[white blue black red green].each { gains_protection_from_color(_1, until_turn_of: player) }
    end

    def permanent?
      true
    end

    def tap!
      @tapped = true

      tapped_event = Events::PermanentTapped.new(
        permanent: self,
      )
      game.notify!(tapped_event)
    end

    def cannot_untap_next_turn!
      @cannot_untap_next_turn = true
    end

    def mode_chosen_this_turn?(mode)
      modes_chosen_this_turn.include?(mode)
    end

    def choose_mode_this_turn!(mode)
      modes_chosen_this_turn << mode
    end

    def modes_chosen_this_turn
      @modes_chosen_this_turn ||= []
    end

    def triggered_once_this_turn?(key)
      triggered_once_keys_this_turn.include?(key)
    end

    def trigger_once_this_turn!(key)
      triggered_once_keys_this_turn << key
    end

    def triggered_once_keys_this_turn
      @triggered_once_keys_this_turn ||= []
    end

    # For "activate only once each turn": the ability classes activated this turn.
    def activated_this_turn?(ability_class)
      abilities_activated_this_turn.include?(ability_class)
    end

    def activated_this_turn!(ability_class)
      abilities_activated_this_turn << ability_class
    end

    # For "activate only once": never reset, since this permanent is the object that was activated.
    def activated_ever?(ability_class)
      (@abilities_activated_ever ||= []).include?(ability_class)
    end

    def activated_ever!(ability_class)
      (@abilities_activated_ever ||= []) << ability_class
    end

    def abilities_activated_this_turn
      @abilities_activated_this_turn ||= []
    end

    def untap_during_untap_step
      if @counters.of_type(Counters::Stun).any?
        @counters.remove_first(Counters::Stun)
        return
      end

      if cannot_untap_next_turn
        @cannot_untap_next_turn = false
        return
      end

      return if attachments.any?(&:does_not_untap_during_untap_step?)

      untap!
    end

    def untap!
      return if untapped?
      return if attachments.any? { _1.card.prevents_untapping? }
      @tapped = false

      untapped_event = Events::PermanentUntapped.new(
        permanent: self,
      )
      game.notify!(untapped_event)
    end

    def tapped?
      @tapped
    end

    def untapped?
      !tapped?
    end

    # Rule 701.19: creates a regeneration shield, a replacement effect for the next time this
    # permanent would be destroyed this turn (see #destroy!). Shields expire in the cleanup step.
    def regenerate!
      @regeneration_shields += 1
    end

    def regeneration_shield?
      @regeneration_shields.positive?
    end

    # Uses a shield: instead of being destroyed, the permanent is tapped, has all damage removed
    # from it and is removed from combat.
    def regenerated!
      @regeneration_shields -= 1
      @damage = 0
      @marked_for_death = false
      tap!
      game.current_turn&.combat&.remove_from_combat(self)
      game.notify!(Events::Regenerated.new(permanent: self))
    end

    def static_abilities
      return [] if lost_all_abilities?

      face.static_abilities.map { |ability| ability.new(source: self) }
    end

    # "It loses all abilities": its own keywords, activated, triggered, static and
    # replacement abilities stop working for as long as it stays on the battlefield.
    # Abilities other effects grant it still apply.
    def lose_all_abilities!
      @lost_all_abilities = true
      apply_continuous_effects!
    end

    def lost_all_abilities?
      !!(@lost_all_abilities || lost_all_abilities_by_effect)
    end

    def alive?
      return true unless creature?
      (toughness - damage).positive? && toughness > 0
    end

    # Rule 701.7: indestructible permanents can't be destroyed. Returns whether it was destroyed.
    def destroy!
      return false if indestructible?

      if regeneration_shield?
        regenerated!
        return false
      end

      put_into_graveyard!
      true
    end

    # Moves the permanent to its controller's graveyard whether or not it is indestructible.
    # Use this (not #destroy!) for sacrifice and for state-based actions that aren't "destroy".
    # A token or copy has no card of its own to move (a token copy of a card
    # leaves that card where it is).
    def put_into_graveyard!
      move_zone!(to: owner.graveyard)
      # (A replacement effect may have sent the card elsewhere already: exile, or shuffled into the library.)
      unless copy? || token? || card.zone&.exile? || card.zone&.library?
        card.move_zone!(to: owner.graveyard)
      end
    end

    def sacrifice!
      game.notify!(Events::PermanentSacrificed.new(permanent: self))
      put_into_graveyard!
    end

    def exile!
      move_zone!(to: game.exile)
      card.move_zone!(to: game.exile) unless copy? || token? || card.zone&.exile?
    end

    def return_to_hand
      move_zone!(to: owner.hand)
      card.move_zone!(to: owner.hand)
    end

    def can_activate_ability?(ability)
      card.can_activate_ability?(ability) && attachments.all? { |attachment| attachment.can_activate_ability?(ability) }
    end

    # Can `source` (a card, permanent or token) target this permanent when `controller` is the
    # player casting the spell or controlling the ability? Every targeting path asks this, so
    # shroud, hexproof, "hexproof from" and protection are enforced in one place.
    def can_be_targeted_by?(source, controller: source.controller)
      return true if source.nil?
      return false if shroud?

      opposing = opponents.include?(controller)
      return false if opposing && hexproof?
      return false if opposing && source.colors.any? { hexproof_from?(_1) }

      !protected_from?(source)
    end

    def can_attack?
      (lost_all_abilities? || card.can_attack?) && attachments.all?(&:can_attack?)
    end

    def can_block?(permanent)
      !prevented_from_blocking? && (lost_all_abilities? || face.can_block?(permanent)) &&
        attachments.all? { |attachment| attachment.can_block?(permanent) }
    end

    # What a creature's combat damage is based on: normally its power, but its toughness while
    # something says so (Bark of Doran).
    def combat_damage_amount
      attachments.any? { _1.card.assigns_toughness_damage?(self) } ? toughness : power
    end

    def can_be_blocked?(blocker)
      lost_all_abilities? || face.can_be_blocked?(blocker)
    end

    def maximum_blockers
      lost_all_abilities? ? nil : face.maximum_blockers
    end

    def must_be_blocked?
      !lost_all_abilities? && face.must_be_blocked?
    end

    def maximum_attackers_blocked
      lost_all_abilities? ? 1 : face.maximum_attackers_blocked
    end


    def cleanup!
      @turn_triggers = {}
      @turn_replacements = []
      @regeneration_shields = 0
      @modes_chosen_this_turn = []
      @triggered_once_keys_this_turn = []
      @abilities_activated_this_turn = []
      remove_until_eot_protections!
      remove_until_eot_modifiers!
      expire_control_change_effects!
      apply_continuous_effects!
    end

    def can_have_counters?
      attachments.none? { _1.card.prevents_counters? }
    end

    def add_counter(counter_type, amount: 1)
      trigger_effect(:add_counter, counter_type: counter_type, target: self, amount: amount)
    end

    def remove_counter(counter_type:, amount: 1)
      trigger_effect(:remove_counter, counter_type: counter_type, target: self, amount: amount)
    end

    # Raw mutation, with no event/replacement-effect pipeline. Only for
    # Effects::AddCounterToPermanent/RemoveCounterFromPermanent to call as part of
    # resolving those effects -- everywhere else should go through add_counter/
    # remove_counter above so replacement effects (e.g. Doubling Season) apply.
    def put_counters!(counter_type, amount: 1)
      resolved = Counters[counter_type]
      @counters = Counters::Collection.new(@counters + Array.new(amount) { resolved.new })
    end

    def take_counters!(counter_type, amount: 1)
      removable_counters = @counters.first_of_type(counter_type, amount)
      if removable_counters.count < amount
        raise "Not enough #{counter_type} counters to remove"
      end

      removable_counters.each { |counter| @counters.delete(counter) }
    end

    def target_choices
      card.target_choices(self)
    end

    # "Exile target permanent until ~ leaves the battlefield" (rule 610.3). Does nothing if
    # this permanent has already left; a token exiled this way is gone for good.
    def exile_until_leaves!(target)
      return unless zone&.battlefield?

      target.exile!
      cards_exiled_until_leaves << target.card unless target.token?
    end

    def cards_exiled_until_leaves
      @cards_exiled_until_leaves ||= []
    end

    # Called as this permanent leaves the battlefield: the cards come back under their
    # owners' control.
    def return_cards_exiled_until_leaves!
      cards, @cards_exiled_until_leaves = cards_exiled_until_leaves, []
      cards.select { _1.zone&.exile? }.each do |card|
        Permanent.resolve(game:, card:, owner: card.owner, from_zone: card.zone, cast: false)
      end
    end

    # Exiles a card "with" this permanent, remembering the turn ("cards exiled with
    # Maralen this turn").
    def exile_with_this!(card)
      trigger_effect(:exile, target: card)
      exiled_cards << card
      turns_cards_were_exiled[card] = game.current_turn.number
    end

    def exiled_with_this_this_turn?(card)
      exiled_cards.include?(card) && card.zone&.exile? && turns_cards_were_exiled[card] == game.current_turn.number
    end

    def turns_cards_were_exiled
      @turns_cards_were_exiled ||= {}.compare_by_identity
    end

    def remove_from_exile(card)
      @exiled_cards -= [card]
      game.exile.remove(card)
    end

    def trigger_effect(effect, source: self, **args)
      card.trigger_effect(effect, source: source, **args)
    end

    def create_token(token_class:, amount: 1, controller: self.controller)
      trigger_effect(:create_token, token_class: token_class, amount: amount, controller: controller)
    end

    def add_choice(choice, **args)
      card.add_choice(choice, **args)
    end

    def phased_out?
      @phased_out
    end

    def prepared?
      @prepared
    end

    def prepare!
      @prepared = true
    end

    def unprepare!
      @prepared = false
    end

    def phase_out!
      @phased_out = true
    end

    def phase_in!
      @phased_out = false
    end

    def devotion(color)
      card.cost.send(color) || 0
    end

    # Fires +trigger_class+ for this permanent (queued or run at once), counting
    # trigger doublers. Public for triggers the engine adds itself (offspring).
    def perform_trigger!(trigger_class, event)
      additional_triggers = game.battlefield.static_abilities
        .of_type(Abilities::Static::TriggeredAbilityDoubler)
        .count { |doubler| doubler.doubles_trigger_for?(self, event) }

      (1 + additional_triggers).times do
        ability = trigger_class.new(actor: self, event: event)
        next unless ability.trigger!

        if game.queue_triggers?
          game.queue_trigger!(ability)
        else
          ability.call
        end
      end
    end

    private

    def dispatch_lifecycle_triggers(event)
      return if lost_all_abilities?
      return unless event.respond_to?(:permanent) && event.permanent == self

      lifecycle_triggers_for(event).each do |trigger_class|
        perform_trigger!(trigger_class, event)
      end
    end

    def lifecycle_triggers_for(event)
      case event
      when Events::EnteredTheBattlefield then face.etb_triggers + (evoked? ? [TriggeredAbility::EvokeSacrifice] : [])
      when Events::LeftTheBattlefield     then face.ltb_triggers
      when Events::CreatureDied           then face.death_triggers + (has_keyword?(Keywords::PERSIST) ? [TriggeredAbility::Persist] : [])
      else []
      end
    end

    def dispatch_event_handlers(event)
      return if lost_all_abilities?

      Array(face.event_handlers[event.class]).each do |handler_class|
        logger.debug "EVENT HANDLER: #{self} handling #{event}"
        perform_trigger!(handler_class, event)
      end
    end

    def expire_protections_until_turn_of(player)
      protections.reject! { |protection| protection.until_turn_of == player }
      modifiers.reject! { |modifier| modifier.until_turn_of == player }
    end

    def remove_until_eot_protections!
      until_eot_protections = protections.select(&:until_eot?)
      until_eot_protections.each do |protection|
        protections.delete(protection)
      end
    end

    def expire_control_change_effects!
      return if control_change_effects.empty?

      expiring, remaining = control_change_effects.partition(&:until_eot?)
      @control_change_effects = remaining
      return if expiring.empty?

      self.controller = remaining.max_by(&:timestamp)&.controller || expiring.min_by(&:timestamp).previous_controller
    end

    def remove_until_eot_modifiers!
      until_eot_modifiers = modifiers.select(&:until_eot?)
      until_eot_modifiers.each { |modifier| modifiers.delete(modifier) }
    end

    def dispatch_turn_triggers(event)
      Array(@turn_triggers[event.class]).each do |handler_class|
        handler_class.new(actor: self, event: event).perform!
      end
    end
  end
end
