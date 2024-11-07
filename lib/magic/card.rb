module Magic
  class Card
    include Types
    extend Forwardable
    def_delegators :@game, :logger, :battlefield, :exile, :current_turn, :creatures

    include Cards::Keywords
    include Cards::Shared::Events
    include Cards::Shared::Types
    attr_reader :game, :controller, :owner, :name, :cost, :kicker_cost, :type_line, :countered, :keyword_grants, :keywords, :protections, :delayed_responses, :counters, :modes
    attr_accessor :tapped

    attr_accessor :zone

    COST = {}
    KICKER_COST = {}
    KEYWORDS = []
    PROTECTIONS = []
    MODES = []

    class << self
      def card_name(name)
        const_set(:NAME, name)
      end

      def type(type)
        const_set(:TYPE_LINE, type)
      end

      def cost(cost)
        const_set(:COST, cost)
      end

      def kicker_cost(cost)
        const_set(:KICKER_COST, cost)
      end

      def power(power)
        const_set(:POWER, power)
      end

      def toughness(power)
        const_set(:TOUGHNESS, power)
      end

      def keywords(*keywords)
        const_set(:KEYWORDS, Keywords.list(*keywords))

        include Cards::KeywordHandlers::Prowess if keywords.include?(:prowess)
      end

      def protections(*protections)
        const_set(:PROTECTIONS, *protections)
      end

      def modes(*modes)
        const_set(:MODES, modes)
      end

      def enters_the_battlefield(&block)
        etb = Class.new(TriggeredAbility::EnterTheBattlefield)
        etb.define_method(:perform, &block)

        define_method(:etb_triggers) do
          [etb]
        end
      end

      def enters_tapped
        define_method(:enters_tapped?) do
          true
        end
      end

      def additional_lands_per_turn(amount)
        define_method(:additional_lands_per_turn) do
          amount
        end
      end
    end

    def initialize(game: Game.new, owner:)
      @countered = false
      @name = self.class::NAME
      @type_line = self.class::TYPE_LINE
      @game = game
      @cost = Costs::Mana.new(self.class::COST.dup)
      @kicker_cost = Costs::Kicker.new(self.class::KICKER_COST.dup)
      @tapped = tapped
      @delayed_responses = []
      @keywords = self.class::KEYWORDS
      @keyword_grants = []
      @protections = self.class::PROTECTIONS
      @modes = self.class::MODES
      @controller = @owner = owner
    end

    def inspect
      "#<Card name:#{name}>"
    end

    def to_s
      name
    end

    def mana_value
      cost.mana_value
    end
    alias_method :cmc, :mana_value
    alias_method :converted_mana_cost, :mana_value

    def colors
      cost.colors
    end

    def multi_colored?
      colors.count > 1
    end

    def colorless?
      colors.count == 0
    end

    def return_to_hand
      move_to_hand!
    end

    def move_to_hand!(target_controller = controller)
      move_zone!(to: target_controller.hand)
    end

    def move_to_graveyard!(target_controller = controller)
      move_zone!(to: target_controller.graveyard)
    end

    def move_zone!(to:)
      effect = Effects::MoveCardZone.new(
        from: zone,
        to: to,
        target: self,
        source: self,
      )

      game.add_effect(effect)
    end

    def resolve!(enters_tapped: enters_tapped?, kicked: false)
      if permanent?
        permanent = Magic::Permanent.resolve(
          game: game,
          owner: owner,
          card: self,
          from_zone: zone,
          enters_tapped: enters_tapped,
          kicked: kicked
        )
        move_zone!(to: battlefield)
        permanent
      end
    end

    alias_method :play!, :resolve!

    def discard!
      move_zone!(to: zone.owner.graveyard)
    end

    def exile!
      move_zone!(to: exile)
    end

    def notify!(event)
      game.current_turn.notify!(event)
    end

    def enters_tapped?
      false
    end

    def activated_abilities
      []
    end

    def etb_triggers
      []
    end

    def ltb_triggers
     []
    end

    def death_triggers
      []
    end

    def static_abilities
      []
    end

    def replacement_effects
      {}
    end

    def state_triggered_abilities
      []
    end

    def additional_lands_per_turn
      0
    end

    def token?
      false
    end

    def prowess_trigger
      -> (permanent, event) do
        Cards::KeywordHandlers::Prowess.trigger(permanent: permanent, event: event)
      end
    end

    def choose_mode(mode)
      mode.new(source: self)
    end

    def can_attack? = !defender?
    def can_block?(_) = true
    def can_activate_ability?(_) = true

    def add_choice(choice, **args)
      case choice
      when :discard
        game.add_choice(Magic::Choice::Discard.new(player: controller, **args))
      when :scry
        game.add_choice(Magic::Choice::Scry.new(**args))
      else
        raise "Unknown choice: #{choice.inspect}"
      end
    end

    def opponents
      game.opponents(controller)
    end
  end
end
