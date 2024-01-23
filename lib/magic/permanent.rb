module Magic
  class Permanent
    include Permanents::Creature
    include Permanents::Planeswalker
    include Permanents::Enchantment
    include Permanents::Modifications
    include Keywords
    include Types

    extend Forwardable
    attr_reader :game, :owner, :controller, :card, :types, :delayed_responses, :attachments, :protections, :modifiers, :counters, :keywords, :keyword_grants, :activated_abilities, :exiled_cards, :cannot_untap_next_turn

    def_delegators :@card, :name, :cmc, :mana_value, :colors, :colorless?
    def_delegators :@game, :logger

    class Protections < SimpleDelegator
      def player
        select { |protection| protection.protects_player? }
      end
    end

    attr_accessor :zone

    def self.resolve(game:, card:, owner: card.owner, from_zone: owner.library, enters_tapped: false, token: false, cast: true, kicked: false)
      permanent = Magic::Permanent.new(
        game: game,
        owner: owner,
        card: card,
        kicked: kicked,
        cast: cast,
        token: token
      )

      permanent.tap! if enters_tapped
      permanent.move_zone!(from: from_zone, to: game.battlefield)
      permanent
    end

    def initialize(game:, owner:, card:, token: false, cast: true, kicked: false, timestamp: Time.now)
      @game = game
      @owner = owner
      @controller = owner
      @card = card
      @token = token
      @cast = cast
      @kicked = kicked
      @base_types = card.types
      @delayed_responses = []
      @attachments = []
      @modifiers = []
      @tapped = false
      @keywords = card.keywords
      @keyword_grants = card.keyword_grants
      @counters = Counters::Collection.new([])
      @damage = 0
      @protections = Protections.new(card.protections.dup)
      @exiled_cards = Magic::CardList.new([])
      @timestamp = timestamp
    end

    def kicked?
      @kicked
    end

    def types
      @base_types + attachments.flat_map(&:type_grants) + modifiers.flat_map(&:type_grants)
    end

    def inspect
      "#<Magic::Permanent name:#{card.name} controller:#{controller.name}>"
    end

    def activated_abilities
      @activated_abilities ||= card.activated_abilities.map { |ability| ability.new(source: self) }
    end

    alias_method :to_s, :inspect

    def controller?(other_controller)
      controller == other_controller
    end

    def controller=(other_controller)
      @controller = other_controller
    end

    def token?
      @token
    end

    def cast?
      @cast
    end

    def move_zone!(from: zone, to:)
      card.zone = to
      game.notify!(*leaving_zone_notifications(from: from, to: to))

      if from&.battlefield?
        self.zone = nil
        from.remove(self)
        to.add(card) unless token?
      elsif to.battlefield?
        to.add(self)
        from&.remove(card)
      end

      game.notify!(*entering_zone_notifications(from: from, to: to))
    end

    def has_replacement_effect?(event)
      !!card.replacement_effects[event.class]
    end

    def handle_replacement_effect(event)
      card.replacement_effects[event.class].call(self, event)
    end

    def receive_notification(event)
      super

      trigger_delayed_response(event)

      case event
      when Events::PermanentWillDie
        died! if event.permanent == self
      when Events::PermanentLeavingZone
        left_the_battlefield! if event.permanent == self && event.from.battlefield?
      when Events::EnteredTheBattlefield
        entered_the_battlefield! if event.permanent == self
      end

      handler = card.event_handlers[event.class]
      if handler
        logger.debug "EVENT HANDLER: #{self} handling #{event}"
        handler.call(self, event)
      end
    end

    def died!
      card.death_triggers.each do |trigger|
        trigger.new(game: game, permanent: self).perform
      end
      left_the_battlefield!
    end

    def left_the_battlefield!
      @attachments.each(&:destroy!)

      card.ltb_triggers.each do |trigger|
        trigger.new(game: game, permanent: self).perform
      end
    end

    def entered_the_battlefield!
      card.etb_triggers.each do |trigger|
        trigger.new(game: game, permanent: self).perform
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
      (toughness - damage).positive?
    end

    def destroy!
      move_zone!(to: controller.graveyard)
    end
    alias_method :sacrifice!, :destroy!

    def exile!
      move_zone!(to: game.exile)
    end

    def return_to_hand
      move_zone!(to: owner.hand)
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

    def can_block?
      card.can_block? && attachments.all?(&:can_block?)
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
    end

    def add_counter(counter_type, amount: 1)
      @counters = Counters::Collection.new(@counters + [counter_type.new] * amount)
      counter_added = Events::CounterAdded.new(
        permanent: self,
        counter_type: counter_type,
        amount: amount
      )

      game.notify!(counter_added)
    end

    def remove_counter(counter_type, amount: 1)
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

    def trigger(effect, source: self, **args)
      card.trigger(effect, source: source, **args)
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

    def leaving_zone_notifications(from:, to:)
      Events::PermanentLeavingZoneTransition.new(
        self,
        from: from,
        to: to
      )
    end

    def entering_zone_notifications(from:, to:)
      Events::PermanentEnteredZoneTransition.new(
        self,
        from: from,
        to: to
      )
    end
  end
end
