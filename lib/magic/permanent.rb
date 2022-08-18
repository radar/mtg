module Magic
  class Permanent
    include Keywords

    extend Forwardable
    attr_reader :game, :controller, :card,:types, :delayed_responses, :attachments, :modifiers, :counters, :keywords, :activated_abilities

    # TODO: Move to permanent / creature sub-type


    def_delegators :@card, :name

    class Counters < SimpleDelegator
      def of_type(type)
        select { |counter| counter.is_a?(type) }
      end
    end

    attr_accessor :zone

    def self.resolve(game:, controller:, card:, from_zone: controller.library)
      if card.planeswalker?
        permanent = Magic::Permanents::Planeswalker.new(game: game, controller: controller, card: card)
      elsif card.creature?
        permanent = Magic::Permanents::Creature.new(game: game, controller: controller, card: card)
      elsif card.permanent?
        permanent = Magic::Permanent.new(game: game, controller: controller, card: card)
      end

      permanent.move_zone!(from: from_zone, to: game.battlefield)
      permanent
    end

    def initialize(game:, controller:, card:)
      @game = game
      @controller = controller
      @card = card
      @base_types = card.types
      @delayed_responses = []
      @attachments = []
      @modifiers = []
      @tapped = false
      @keywords = card.keywords
      @counters = Counters.new([])
      @activated_abilities = card.activated_abilities
      @damage = 0
      super
    end

    def inspect
      "#<Magic::Permanent name:#{card.name} controller:#{controller.name}>"
    end

    alias_method :to_s, :inspect

    def move_zone!(from: zone, to:)
      game.notify!(
        Events::LeavingZoneTransition.new(
          self,
          from: from,
          to: to
        )
      )

      from.remove(self)
      to.add(self)

      game.notify!(
        Events::EnteredZoneTransition.new(
          self,
          from: from,
          to: to
        )
      )
    end

    def receive_notification(event)
      case event
      when Events::DamageDealt
        return unless event.target == self

        take_damage(event.damage)
      when Events::LeavingZone
        died! if event.card == self && event.death?
        left_the_battlefield! if event.card == self && event.from.battlefield?
      when Events::EnteredTheBattlefield
        entered_the_battlefield! if event.card == self
      end

      trigger_delayed_response(event)
    end

    def died!
    end

    def left_the_battlefield!
    end

    def entered_the_battlefield!
      card.etb_triggers.each do |trigger|
        trigger.new(game: game, permanent: self).perform
      end
    end

    def type?(type)
      types.include?(type)
    end

    def types
      @base_types + attachments.flat_map(&:type_grants)
    end

    def land?
      type?("Land")
    end

    def basic_land?
      type?("Basic")
    end

    def planeswalker?
      type?("Planeswalker")
    end

    def artifact?
      type?("Artifact")
    end

    def enchantment?
      type?("Enchantment")
    end

    def creature?
      type?("Creature")
    end

    def permanent?
      true
    end

    def tap!
      @tapped = true
    end

    def untap!
      @tapped = false
    end

    def tapped?
      @tapped
    end

    def static_abilities
      []
    end

    def alive?
      (toughness - damage).positive?
    end

    def colors
      @card.colors
    end

    def destroy!
      move_zone!(to: controller.graveyard)
    end

    def exile!
      move_zone!(to: controller.exile)
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
  end
end
