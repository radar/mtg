module Magic
  class Card
    include Keywords
    attr_reader :game, :name, :cost, :type_line, :countered, :keywords, :attachments
    attr_accessor :tapped

    attr_accessor :controller, :zone

    COST = {}
    KEYWORDS = []

    def initialize(game: Game.new, controller: Player.new, tapped: false, keywords: [], card_event: CardState.new(self))
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

    def artifact?
      type?("Artifact")
    end

    def enchantment?
      type?("Enchantment")
    end

    def converted_mana_cost
      cost.values.sum
    end

    def colors
      cost.keys.reject { |k| k == :generic || k == :colorless }.count
    end

    alias_method :cmc, :converted_mana_cost

    def move_to_hand!(target_controller)
      move_zone!(target_controller.hand)
    end

    def cast!
      if skip_stack?
        move_zone!(game.battlefield)
      else
        game.stack.add(self)
      end
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

    def protected_from?(_card)
      false
    end

    def controller?(other_controller)
      controller == other_controller
    end

    def resolve!
      move_zone!(game.battlefield)
    end

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
    end

    def resolution_effects
      []
    end

    def skip_stack?
      false
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

    private

    def remove_until_eot_keyword_grants!
      until_eot_grants = keyword_grants.select(&:until_eot?)
      until_eot_grants.each do |grant|
        remove_keyword_grant(grant)
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
