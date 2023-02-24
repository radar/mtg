module Magic
  class Permanent
    include Keywords
    include Types

    extend Forwardable
    attr_reader :game, :owner, :controller, :card,:types, :delayed_responses, :attachments, :protections, :modifiers, :counters, :keywords, :activated_abilities, :exiled_cards, :cannot_untap_next_turn

    def_delegators :@card, :name, :cmc, :mana_value, :colors, :colorless?

    class Protections < SimpleDelegator
      def player
        select { |protection| protection.protects_player? }
      end
    end

    attr_accessor :zone

    def self.resolve(game:, owner:, card:, from_zone: owner.library, enters_tapped: false, token: false)
      if card.planeswalker?
        permanent = Magic::Permanents::Planeswalker.new(game: game, owner: owner, card: card)
      elsif card.creature?
        permanent = Magic::Permanents::Creature.new(game: game, owner: owner, card: card, token: token)
      elsif card.enchantment?
        permanent = Magic::Permanents::Enchantment.new(game: game, owner: owner, card: card)
      elsif card.permanent?
        permanent = Magic::Permanent.new(game: game, owner: owner, card: card)
      end

      permanent.tap! if enters_tapped
      permanent.move_zone!(from: from_zone, to: game.battlefield)
      permanent
    end

    def initialize(game:, owner:, card:, token: false)
      @game = game
      @owner = owner
      @controller = owner
      @card = card
      @token = token
      @base_types = card.types
      @delayed_responses = []
      @attachments = []
      @modifiers = []
      @tapped = false
      @keywords = card.keywords
      @counters = Counters::Collection.new([])
      @activated_abilities = card.activated_abilities
      @damage = 0
      @protections = Protections.new(card.protections.dup)
      @exiled_cards = Magic::CardList.new([])
      super
    end

    def types
      @base_types + attachments.flat_map(&:type_grants)
    end

    def inspect
      "#<Magic::Permanent name:#{card.name} controller:#{controller.name}>"
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

    def move_zone!(from: zone, to:)
      if from
        game.notify!(
          Events::PermanentLeavingZoneTransition.new(
            self,
            from: from,
            to: to
          )
        )

        if from.battlefield?
          from.remove(self)
        else
          from.remove(card)
        end
      end

      if to.battlefield?
        to.add(self)
      else
        self.zone = nil
        if to.graveyard?
          to.add(card) if !token?
        else
          to.add(card)
        end
      end

      game.notify!(
        Events::PermanentEnteredZoneTransition.new(
          self,
          from: from,
          to: to
        )
      )

      if land?
        game.notify!(
          Events::Landfall.new(
            self,
          )
        )
      end
    end

    def has_replacement_effect?(event)
      !!card.replacement_effects[event.class]
    end

    def handle_replacement_effect(event)
      card.replacement_effects[event.class].call(self, event)
    end

    def receive_notification(event)
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
        puts "EVENT HANDLER: #{self} handling #{event}"
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
      (toughness - damage).positive?
    end

    def destroy!
      move_zone!(to: controller.graveyard)
    end
    alias_method :sacrifice!, :destroy!

    def exile!
      move_zone!(to: game.exile)
    end

    def return_to_hand(player)
      move_zone!(to: player.hand)
    end

    def can_activate_ability?(ability)
      attachments.all? { |attachment| attachment.can_activate_ability?(ability) }
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
  end
end
