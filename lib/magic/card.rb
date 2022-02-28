module Magic
  class Card
    extend Forwardable
    def_delegators :@game, :battlefield, :current_turn

    include Keywords
    attr_reader :game, :name, :cost, :type_line, :countered, :keywords, :attachments, :protections, :delayed_responses
    attr_accessor :tapped

    attr_accessor :controller, :zone

    COST = {}
    KEYWORDS = []

    class << self
      def type(type)
        const_set(:TYPE_LINE, type)
      end

      def cost(cost)
        const_set(:COST, cost)
      end

      def power(power)
        const_set(:POWER, power)
      end

      def toughness(power)
        const_set(:TOUGHNESS, power)
      end

      def keywords(*keywords)
        const_set(:KEYWORDS, Card::Keywords[*keywords])
      end
    end

    def initialize(game: Game.new, controller: Player.new, tapped: false, keywords: [])
      @countered = false
      @name = self.class::NAME
      @type_line = self.class::TYPE_LINE
      @game = game
      @controller = controller
      @zone = controller.library
      cost = self.class::COST.dup
      cost.default = 0
      @cost = cost
      @tapped = tapped
      @attachments = []
      @protections = []
      @delayed_responses = []
      super
    end

    def inspect
      "#<Card name:#{name} controller:#{controller.name}>"
    end

    def to_s
      name
    end

    def type?(type)
      types.include?(type)
    end

    def types
      type_line.split(" ") + attachments.flat_map(&:type_grants)
    end

    def land?
      type?("Land")
    end

    def basic_land?
      type?("Basic")
    end

    def creature?
      type?("Creature")
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

    def converted_mana_cost
      cost.values.sum
    end

    def multi_colored?
      colors.count > 1
    end

    def colors
      cost.keys.reject { |k| k == :generic || k == :colorless }
    end

    def colorless?
      colors.count == 0
    end

    alias_method :cmc, :converted_mana_cost

    def move_to_hand!(target_controller)
      move_zone!(target_controller.hand)
    end

    def cast!
      game.stack.add(self)
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

    def untapped?
      !tapped?
    end

    def countered?
      countered
    end

    def protected_from?(card)
      @protections.any? { |protection| protection.protected_from?(card) }
    end

    def gains_protection_from_color(color, until_eot:)
      @protections << Protection.from_color(color, until_eot: until_eot)
    end

    def controller?(other_controller)
      controller == other_controller
    end

    def resolve!
      move_zone!(game.battlefield)
    end

    alias_method :play!, :resolve!

    def counter!
      @countered = true
      move_zone!(controller.graveyard)
    end

    def destroy!
      move_zone!(controller.graveyard)
    end

    def exile!
      move_zone!(controller.exile)
    end

    def cleanup!
      remove_until_eot_keyword_grants!
      remove_until_eot_protections!
    end

    def notify!(event)
      game.current_turn.notify!(event)
    end

    def receive_notification(event)
      case event
      when Events::LeavingZone
        died! if event.card == self && event.death?
        left_the_battlefield! if event.card == self && event.from.battlefield?
      when Events::EnteredTheBattlefield
        entered_the_battlefield! if event.card == self
      end

      trigger_delayed_response(event)
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

    def left_the_battlefield!
      static_abilities = game.remove_static_abilities_from(self)
      static_abilities.each { |ability| game.battlefield.static_abilities.remove(ability) }
    end

    def died!
    end

    def entered_the_battlefield!
      applicable_abilities = game.battlefield.static_abilities.select do |ability|
        ability.applies_to?(self) && ability.applies_while_entering_the_battlefield?
      end
      applicable_abilities.each { |ability| ability.apply(self) }
    end

    def activated_abilities
      []
    end

    def can_activate_ability?(ability)
      @attachments.all? { |attachment| attachment.can_activate_ability?(ability) }
    end

    def can_be_targeted_by?(source)
      true
    end

    def add_effect(klass, **args)
      game.add_effect(Effects.const_get(klass).new(**args.merge(source: self)))
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

    def move_zone!(new_zone)
      old_zone = zone

      game.notify!(
        Events::LeavingZoneTransition.new(
          self,
          from: old_zone,
          to: new_zone
        )
      )

      old_zone.remove(self)

      new_zone.add(self)

      game.notify!(
        Events::EnteredZoneTransition.new(
          self,
          from: old_zone,
          to: new_zone
        )
      )

    end
  end
end
