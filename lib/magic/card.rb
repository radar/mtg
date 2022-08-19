module Magic
  class Card
    extend Forwardable
    def_delegators :@game, :battlefield, :current_turn

    include Cards::Keywords
    attr_reader :game, :name, :cost, :type_line, :countered, :keywords, :attachments, :protections, :delayed_responses, :counters
    attr_accessor :tapped

    attr_accessor :controller, :zone

    COST = {}
    KEYWORDS = []
    PROTECTIONS = []

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
        const_set(:KEYWORDS, Keywords[*keywords])
      end

      def protections(*protections)
        const_set(:PROTECTIONS, *protections)
      end
    end

    def initialize(game: Game.new, controller: Player.new, tapped: false, keywords: [])
      @countered = false
      @name = self.class::NAME
      @type_line = self.class::TYPE_LINE
      @game = game
      @controller = controller
      @zone = controller.library
      cost = Costs::Mana.new(self.class::COST.dup)
      @cost = cost
      @tapped = tapped
      @attachments = []
      @delayed_responses = []
      @keywords = self.class::KEYWORDS
      @protections = self.class::PROTECTIONS
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

    def permanent?
      land? || creature? || planeswalker? || artifact? || enchantment?
    end

    def mana_value
      cost.mana_value
    end
    alias_method :cmc, :mana_value
    alias_method :converted_mana_cost, :mana_value

    def multi_colored?
      colors.count > 1
    end

    def colors
      cost.colors
    end

    def colorless?
      colors.count == 0
    end

    def move_to_hand!(target_controller)
      move_zone!(target_controller.hand)
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

    def controller?(other_controller)
      controller == other_controller
    end

    def resolve!(controller = nil)
      if permanent?
        Magic::Permanent.resolve(game: game, controller: controller, card: self, from_zone: zone)
      end
    end

    alias_method :play!, :resolve!

    def countered!
      move_zone!(controller.graveyard)
    end

    def discard!
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

    def delayed_response(turn:, event_type:, response:)
      @delayed_responses << { turn: turn.number, event_type: event_type, response: response }
    end

    def trigger_delayed_response(event)
      responses = delayed_responses.select { |response| event.is_a?(response[:event_type]) && response[:turn] == game.current_turn.number }
      responses.each do |response|
        response[:response].call
      end
    end

    def died!
    end

    def left_the_battlefield!
    end

    def entered_the_battlefield!
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

    def etb_triggers
      []
    end

    def static_abilities
      []
    end

    def event_handlers
      {}
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
