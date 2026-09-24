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
      :cannot_untap_next_turn

    attr_accessor :copied_card, :chosen_creature_type, :exile_cast_permission_turn, :ring_bearer, :prevent_opponent_lifegain_turn, :pending_mana_ability_uses

    def_delegators :@card, :name, :cmc, :mana_value, :colors, :colorless?, :opponents, :additional_lands_per_turn, :power_modification, :toughness_modification, :type_grants
    def_delegators :@game, :logger

    class Protections < SimpleDelegator
      def player
        select { |protection| protection.protects_player? }
      end
    end

    attr_accessor :zone
    # The number of the turn during which the current controller gained control of this permanent.
    attr_accessor :controlled_since_turn

    def self.resolve(game:, card:, owner: card.owner, from_zone: nil, enters_tapped: card.enters_tapped?, token: card.token?, cast: true, kicked: false, copy: false)
      enters_tapped = enters_tapped_after_replacements(game:, card:, enters_tapped:)
      card_zone = card.zone unless token || copy

      permanent = Magic::Permanent.new(
        game: game,
        owner: owner,
        card: card,
        kicked: kicked,
        cast: cast,
        token: token,
        copy: copy,
      )

      permanent.tap! if enters_tapped
      card.entering_counters.each { |counter_type, amount| permanent.add_counter(counter_type, amount:) }
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

    def self.enters_tapped_after_replacements(game:, card:, enters_tapped:)
      return enters_tapped unless enters_tapped && card.land?

      prevented = static_abilities(game, Abilities::Static::LandsEnterUntapped).any? do |ability|
        ability.lands_enter_untapped?(card)
      end

      !prevented
    end

    def self.static_abilities(game, type) = game.battlefield.static_abilities.of_type(type)

    def initialize(game:, owner:, card:, token: false, cast: true, kicked: false, copy: false, timestamp: Time.now)
      @game = game
      @owner = owner
      @controller = owner
      @card = card
      @token = token
      @cast = cast
      @kicked = kicked
      @copy = copy
      @base_types = card.types
      @attachments = []
      @turn_triggers = {}
      @modifiers = []
      @tapped = false
      @types = card.types
      @keyword_grants = card.keyword_grants
      @activated_abilities = card.activated_abilities
      @counters = Counters::Collection.new([])
      @damage = 0
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

    def copiable_card
      copied_card || card
    end

    def name = copiable_card.name
    def cmc = copiable_card.cmc
    def mana_value = copiable_card.mana_value
    def colors = copiable_card.colors
    def colorless? = copiable_card.colorless?

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

    def transform!(card:)
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

    def ring_bearer?
      !!@ring_bearer
    end

    def copy?
      @copy
    end

    def cast?
      @cast
    end

    def move_zone!(from: zone, to:)
      trigger_effect(:move_permanent_zone, target: self, from: from, to: to)
    end

    # Permanents can only exist on the battlefield.
    def zone=(new_zone)
      @zone = new_zone.battlefield? ? new_zone : nil
    end

    def replacement_effect_for(context)
      card.replacement_effects.each do |matcher, replacement_effect|
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
      dispatch_lifecycle_triggers(event)
      dispatch_event_handlers(event)
      dispatch_turn_triggers(event)
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

    def gains_protection_from_color(color, until_eot:)
      @protections << Protection.from_color(color, until_eot: until_eot)
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

    def regenerate!
      @damage = 0
      tap!
    end

    def static_abilities
      card.static_abilities.map { |ability| ability.new(source: self) }
    end

    def alive?
      return true unless creature?
      (toughness - damage).positive? && toughness > 0
    end

    # Rule 701.7: indestructible permanents can't be destroyed. Returns whether it was destroyed.
    def destroy!
      return false if indestructible?

      put_into_graveyard!
      true
    end

    # Moves the permanent to its controller's graveyard whether or not it is indestructible.
    # Use this (not #destroy!) for sacrifice and for state-based actions that aren't "destroy".
    # A token or copy has no card of its own to move (a token copy of a card
    # leaves that card where it is).
    def put_into_graveyard!
      move_zone!(to: controller.graveyard)
      unless copy? || token? || card.zone&.exile?
        card.move_zone!(to: controller.graveyard)
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

    def can_be_targeted_by?(source)
      true
    end

    def can_attack?
      card.can_attack? && attachments.all?(&:can_attack?)
    end

    def can_block?(permanent)
      !prevented_from_blocking? && card.can_block?(permanent) && attachments.all? { |attachment| attachment.can_block?(permanent) }
    end

    def can_be_blocked?(blocker)
      card.can_be_blocked?(blocker)
    end


    def cleanup!
      @turn_triggers = {}
      @modes_chosen_this_turn = []
      @triggered_once_keys_this_turn = []
      remove_until_eot_keyword_grants!
      remove_until_eot_protections!
      remove_until_eot_modifiers!
      apply_continuous_effects!
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

    private

    def dispatch_lifecycle_triggers(event)
      return unless event.respond_to?(:permanent) && event.permanent == self

      lifecycle_triggers_for(event).each do |trigger_class|
        perform_trigger!(trigger_class, event)
      end
    end

    def lifecycle_triggers_for(event)
      case event
      when Events::EnteredTheBattlefield then card.etb_triggers
      when Events::LeftTheBattlefield     then card.ltb_triggers
      when Events::CreatureDied           then card.death_triggers
      else []
      end
    end

    def dispatch_event_handlers(event)
      Array(card.event_handlers[event.class]).each do |handler_class|
        logger.debug "EVENT HANDLER: #{self} handling #{event}"
        perform_trigger!(handler_class, event)
      end
    end

    def perform_trigger!(trigger_class, event)
      additional_triggers = game.battlefield.static_abilities
        .of_type(Abilities::Static::TriggeredAbilityDoubler)
        .count { |doubler| doubler.doubles_trigger_for?(self, event) }

      (1 + additional_triggers).times do
        trigger_class.new(actor: self, event: event).perform!
      end
    end

    def remove_until_eot_keyword_grants!
      until_eot_grants = keyword_grants.select(&:until_eot?)
      until_eot_grants.each do |grant|
        remove_keyword_grant(grant)
      end
    end

    def remove_until_eot_protections!
      until_eot_protections = protections.select(&:until_eot?)
      until_eot_protections.each do |protection|
        protections.delete(protection)
      end
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
