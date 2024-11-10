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
      :delayed_responses,
      :attachments,
      :protections,
      :modifiers,
      :keyword_grants,
      :counters,
      :activated_abilities,
      :state_triggered_abilities,
      :exiled_cards,
      :cannot_untap_next_turn

    def_delegators :@card, :name, :cmc, :mana_value, :colors, :colorless?, :opponents, :additional_lands_per_turn, :power_modification, :toughness_modification, :type_grants
    def_delegators :@game, :logger

    class Protections < SimpleDelegator
      def player
        select { |protection| protection.protects_player? }
      end
    end

    attr_accessor :zone

    def self.resolve(game:, card:, owner: card.owner, from_zone: nil, enters_tapped: card.enters_tapped?, token: card.token?, cast: true, kicked: false, copy: false)
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
      permanent.move_zone!(from: from_zone, to: game.battlefield)
      permanent
    end

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
      @delayed_responses = []
      @attachments = []
      @modifiers = []
      @tapped = false
      @types = card.types
      @keyword_grants = card.keyword_grants
      @activated_abilities = card.activated_abilities
      @counters = Counters::Collection.new([])
      @damage = 0
      @protections = Protections.new(card.protections.dup)
      @exiled_cards = Magic::CardList.new([])
      @phased_out = false
      @timestamp = timestamp
    end

    def kicked?
      @kicked
    end

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
    end

    def opponents
      game.opponents(controller)
    end

    def token?
      @token
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

    def replacement_effect_for(effect)
      replacement_effect = card.replacement_effects[effect.class]
      if replacement_effect
        replacement = replacement_effect.new(receiver: self)
        replacement if replacement.applies?(effect)
      end
    end

    def receive_event(event)
      trigger_delayed_response(event)
      case event
      when Events::EnteredTheBattlefield
        entered_the_battlefield!(event)
      when Events::LeftTheBattlefield
        left_the_battlefield!(event)
      when Events::CreatureDied
        died!(event)
      end

      handler_class = card.event_handlers[event.class]
      if handler_class
        # TODO: deprecate procs, move to classes
        if handler_class.is_a?(Proc)
          handler_class.call(self, event)
        else
          logger.debug "EVENT HANDLER: #{self} handling #{event}"
          handler = handler_class.new(actor: self, event: event)

          handler.perform!
        end
      end
    end

    def died!(event)
      return unless event.permanent == self
      card.death_triggers.each do |trigger|
        trigger.new(actor: self, event: event).perform
      end
    end

    def left_the_battlefield!(event)
      return unless event.permanent == self
      @attachments.each(&:destroy!)

      card.ltb_triggers.each do |trigger|
        trigger.new(actor: self, event: event).perform
      end
    end

    def entered_the_battlefield!(event)
      return unless event.permanent == self

      card.etb_triggers.each do |trigger|
        trigger.new(actor: self, event: event).perform
      end
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
      tapped_event = Events::PermanentTapped.new(
        permanent: self,
      )
      game.notify!(tapped_event)

      @tapped = true
    end

    def cannot_untap_next_turn!
      @cannot_untap_next_turn = true
    end

    def untap_during_untap_step
      if cannot_untap_next_turn
        @cannot_untap_next_turn = false
        return
      end

      return if attachments.any?(&:does_not_untap_during_untap_step?)

      untap!
    end

    def untap!
      return if untapped?
      untapped_event = Events::PermanentUntapped.new(
        permanent: self,
      )
      game.notify!(untapped_event)

      @tapped = false
    end

    def tapped?
      @tapped
    end

    def untapped?
      !tapped?
    end

    def static_abilities
      card.static_abilities.map { |ability| ability.new(source: self) }
    end

    def alive?
      return true unless creature?
      (toughness - damage).positive? && toughness > 0
    end

    def destroy!
      move_zone!(to: controller.graveyard)
      unless copy?
        card.move_zone!(to: controller.graveyard)
      end
    end
    alias_method :sacrifice!, :destroy!

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
      card.can_block?(permanent) && attachments.all? { |attachment| attachment.can_block?(permanent) }
    end


    def delayed_response(turn:, event_type:, response:)
      @delayed_responses << { turn: turn.number, event_type: event_type, response: response }
    end

    def trigger_delayed_response(event)
      responses = delayed_responses.select { |response| event.is_a?(response[:event_type]) && response[:turn] == game.current_turn.number }
      responses.each do |response|
        response[:response].call
      end
    end

    def cleanup!
      remove_until_eot_keyword_grants!
      remove_until_eot_protections!
      remove_until_eot_modifiers!
      apply_continuous_effects!
    end

    def add_counter(counter_type:, amount: 1)
      @counters = Counters::Collection.new(@counters + [counter_type.new] * amount)
    end

    def remove_counter(counter_type:, amount: 1)
      removable_counters = @counters.select { |counter| counter.is_a?(counter_type) }.first(amount)
      if removable_counters.count < amount
        raise "Not enough #{counter_type} counters to remove"
      end

      events = []
      removable_counters.each do |counter|
        @counters.delete(counter)
        events << Events::CounterRemoved.new(
          permanent: self,
          counter_type: counter_type,
          amount: amount
        )
      end

      game.notify!(events)
    end

    def target_choices
      card.target_choices(self)
    end

    def remove_from_exile(card)
      @exiled_cards -= [card]
      game.exile.remove(card)
    end

    def can_untap_during_upkeep?
      attachments.any?(&:can_untap_during_upkeep?)
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
  end
end
