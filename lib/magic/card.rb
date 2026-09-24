module Magic
  class Card
    include Types
    extend Forwardable
    def_delegators :@game, :logger, :battlefield, :exile, :current_turn

    include BattlefieldFilters

    include Cards::Keywords

    include Cards::Shared::Events
    include Cards::Shared::Types
    attr_reader :game, :controller, :owner, :name, :cost, :kicker_cost, :types, :countered, :keyword_grants, :keywords, :protections, :delayed_responses, :modes
    attr_accessor :chosen_color
    attr_accessor :tapped

    attr_reader :zone
    # True while this card sits in exile as an adventure, from where its owner may cast it later.
    attr_accessor :on_adventure

    COST = {}
    KICKER_COST = {}
    KEYWORDS = []
    PROTECTIONS = []
    MODES = []

    class << self
      def card_name(name)
        const_set(:NAME, name)
      end

      def type(*types)
        const_set(:TYPE_LINE, types)
      end

      def cost(cost)
        const_set(:COST, cost)
      end

      def flashback(cost)
        define_method(:flashback_cost) do
          cost
        end
      end

      def rebound
        define_method(:rebound?) do
          true
        end
      end

      def blitz(cost)
        const_set(:BLITZ_COST, cost)
      end

      def adventure(cost)
        const_set(:ADVENTURE_COST, cost)
      end

      def cycling(cost)
        const_set(:CYCLING_COST, cost)
      end

      def buyback
        define_method(:buyback?) do
          true
        end
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
        etb.define_method(:call, &block)

        define_method(:etb_triggers) do
          [etb]
        end
      end

      def enters_tapped
        define_method(:enters_tapped?) do
          true
        end
      end

      # "~ enters with two +1/+1 counters on it."
      def enters_with_counters(counter_type, amount)
        define_method(:entering_counters) { { counter_type => amount } }
      end

      def additional_lands_per_turn(amount)
        define_method(:additional_lands_per_turn) do
          amount
        end
      end

      def ward(life: nil, generic: nil)
        ward_trigger = Class.new(TriggeredAbility::SpellCast) do
          define_method(:should_perform?) do
            opponents.include?(event.player) && event.targets.include?(actor)
          end
          define_method(:call) do
            if life
              trigger_effect(:lose_life, target: event.player, life: life)
            else
              game.choices.add(Choice::Ward.new(actor: actor, payer: event.player, spell: event.spell, generic: generic))
            end
          end
        end
        const_set(:WARD_TRIGGER, ward_trigger)
      end
    end

    def initialize(game: Game.new, owner:)
      @countered = false
      @revealed = false
      @name = self.class::NAME
      @types = self.class::TYPE_LINE
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

    def color_identity
      colors.dup
    end

    def multi_colored?
      colors.count > 1
    end

    def colorless?
      colors.count == 0
    end

    def can_be_countered?
      !game.battlefield.static_abilities.any? { |ability| ability.respond_to?(:prevents_countering?) && ability.prevents_countering?(self) }
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

    def zone=(zone)
      @on_adventure = false unless zone&.exile?
      @zone = zone
    end

    def move_zone!(to:)
      @revealed = false
      effect = Effects::MoveCardZone.new(
        from: zone,
        to: to,
        target: self,
        source: self,
      )

      game.add_effect(effect)
    end

    def hand
      controller.hand
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
        # A card resolving from the stack has no zone, so Permanent.resolve can't move it.
        move_zone!(to: battlefield) unless zone&.battlefield?
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

    def reveal!(notify: true)
      @revealed = true
      game&.notify!(Events::CardsRevealed.new(player: controller, cards: [self])) if notify
      self
    end

    def conceal!
      @revealed = false
      self
    end

    def revealed?
      !!@revealed
    end

    def enters_tapped?
      false
    end

    # Counters the permanent enters with ({ "+1/+1" => 2 }).
    def entering_counters
      {}
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

    def graveyard_static_abilities
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

    def rebound?
      false
    end

    def blitz_cost
      self.class.const_defined?(:BLITZ_COST, false) ? Costs::Mana.new(self.class::BLITZ_COST.dup) : nil
    end

    def adventure_cost
      self.class.const_defined?(:ADVENTURE_COST, false) ? Costs::Mana.new(self.class::ADVENTURE_COST.dup) : nil
    end

    def cycling_cost
      self.class.const_defined?(:CYCLING_COST, false) ? Costs::Mana.new(self.class::CYCLING_COST.dup) : nil
    end

    def cycling?
      !!cycling_cost
    end

    def buyback?
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
    def can_be_blocked?(_) = true
    # How many attackers this creature can block at once; override for "can block an additional creature".
    def maximum_attackers_blocked = 1
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

    def receive_event(event)
      handler_class = event_handlers[event.class]
      if handler_class
        logger.debug "EVENT HANDLER: #{self} handling #{event}"
        handler = handler_class.new(actor: self, event: event)

        handler.perform!
      end
    end
  end
end
