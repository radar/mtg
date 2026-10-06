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
    # The other face of a double-faced card / the front face a back-face card belongs to.
    attr_accessor :front_face
    attr_accessor :tapped

    attr_reader :zone
    # True while this card sits in exile as an adventure, from where its owner may cast it later.
    attr_accessor :on_adventure
    # A dream counter (Goliath Daydreamer) on a card in exile; lost when it leaves exile.
    # `exile_with_dream_counter` marks a spell that will go to exile with one as it resolves.
    attr_accessor :dream_counter, :exile_with_dream_counter

    COST = {}
    KICKER_COST = {}
    BACK_FACE = nil
    KEYWORDS = []
    PROTECTIONS = []
    MODES = []

    class << self
      def card_name(name)
        const_set(:NAME, name)
      end

      # A double-faced card: `back_face SomeBackFaceCard` on the front face's class.
      def back_face(card_class)
        const_set(:BACK_FACE, card_class)
      end

      # A back face has no mana cost, so its colours come from a colour indicator.
      def color_indicator(*colors)
        define_method(:colors) { colors }
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

      # "Harmonize {cost}": castable from the graveyard for this cost (a Costs::Mana), exiled after.
      # `Actions::Cast.new(card:, harmonize: true)`; `Cast#harmonize_tap` taps a creature to reduce it.
      def harmonize(cost)
        define_method(:harmonize_cost) do
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

      # "Evoke {cost}": an alternative cost; the permanent is sacrificed when it enters (cast with
      # `evoked: true`, see `Permanent#evoked?`).
      def evoke(cost)
        const_set(:EVOKE_COST, cost)
      end

      # "You may have this enter as a copy of a creature": Permanent.resolve then holds off state-based
      # actions until the card's enters trigger clears `copy_choice_pending`.
      def enters_as_copy
        define_method(:enters_as_copy?) { true }
      end

      def offspring(cost)
        const_set(:OFFSPRING_COST, cost)
      end

      def adventure(cost)
        const_set(:ADVENTURE_COST, cost)
      end

      def cycling(cost)
        const_set(:CYCLING_COST, cost)
      end

      # "Basic landcycling {1}{R}": cycling that searches for a basic land card instead of drawing.
      # `filter` names a `Filter[...]` (`:basic_lands`).
      def landcycling(cost, filter: :basic_lands)
        cycling(cost)
        const_set(:CYCLING_SEARCH, filter)
      end

      # "This spell can't be countered."
      def cant_be_countered
        define_method(:can_be_countered?) { false }
      end

      def buyback
        define_method(:buyback?) do
          true
        end
      end

      # "Convoke (Your creatures can help cast this spell. Each creature you tap while
      # casting this spell pays for {1} or one mana of that creature's color.)"
      def convoke
        define_method(:convoke?) do
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

      # "Choose two —": how many modes the caster must pick (an Integer, or a Range for "one or more"). Unset = not enforced.
      def choose_modes(count)
        define_method(:modes_to_choose) { count }
      end

      def enters_the_battlefield(&block)
        etb = Class.new(TriggeredAbility::EnterTheBattlefield)
        etb.define_method(:call, &block)
        # Named, so a game holding a Permanent that uses this trigger can be Marshal-dumped.
        const_set(:GeneratedEnterTheBattlefieldTrigger, etb)

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
      # "~ enters with a divinity counter on it if you cast it from your hand." (`if_cast_from_hand: true`:
      # Permanent.resolve adds it only for a spell cast from the hand.)
      def enters_with_counters(counter_type, amount, if_cast_from_hand: false)
        define_method(if_cast_from_hand ? :entering_counters_if_cast_from_hand : :entering_counters) { { counter_type => amount } }
      end

      def additional_lands_per_turn(amount)
        define_method(:additional_lands_per_turn) do
          amount
        end
      end

      # "Whenever this becomes the target of a spell or ability an opponent controls, counter it
      # unless that player pays the ward cost." One trigger for spells, one for abilities.
      def ward(life: nil, generic: nil)
        ward_call = lambda do |trigger, spell: nil, ability: nil|
          trigger.game.choices.add(
            Choice::Ward.new(actor: trigger.actor, payer: trigger.event.player, spell: spell, ability: ability, generic: generic, life: life)
          )
        end

        spell_trigger = Class.new(TriggeredAbility::SpellCast) do
          define_method(:should_perform?) { opponents.include?(event.player) && event.targets.include?(actor) }
          define_method(:call) { ward_call.call(self, spell: event.spell) }
        end
        ability_trigger = Class.new(TriggeredAbility) do
          define_method(:should_perform?) { opponents.include?(event.player) && event.targets.include?(actor) }
          define_method(:call) { ward_call.call(self, ability: event.ability) }
        end
        const_set(:WARD_TRIGGER, spell_trigger)
        const_set(:WARD_ABILITY_TRIGGER, ability_trigger)
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
      game.zone_replacement_cards << self if zone_replacement_effects.any?
    end

    def inspect
      "#<Card name:#{name}>"
    end

    def to_s
      name
    end

    # A back face has the mana value of its front face (rule 711.4c).
    def mana_value
      front_face ? front_face.mana_value : cost.mana_value
    end
    alias_method :cmc, :mana_value
    alias_method :converted_mana_cost, :mana_value

    def colors
      cost.colors
    end

    def back_face
      return unless (face_class = self.class::BACK_FACE)

      @back_face ||= face_class.new(game:, owner:).tap { _1.front_face = self }
    end

    def double_faced? = !self.class::BACK_FACE.nil?

    # "This spell costs {1} less to cast for each ..." -- a change for `Costs::Mana#adjusted_by`
    # (values may be callables), applied by `Actions::Cast` while this card is being cast.
    # Static abilities on the battlefield can't do this: the card is in hand.
    def self_mana_cost_adjustment = nil

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

    # Keywords a spell has only while it's on the stack ("those spells gain wither").
    def gain_keyword_as_spell!(keyword)
      (@spell_keywords ||= []) << keyword
    end

    def keywords
      @spell_keywords ? [*@keywords, *@spell_keywords] : @keywords
    end

    def zone=(zone)
      @spell_keywords = nil
      @on_adventure = false unless zone&.exile?
      @dream_counter = false unless zone&.exile?
      @exile_with_dream_counter = false
      # Only a spell (or a permanent's card) can be controlled by someone other than its owner.
      @controller = owner unless zone&.battlefield?
      @zone = zone
    end

    # Set as the card is cast (Actions::Cast#perform), for a player casting a card they don't own.
    attr_writer :controller

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

    # Puts the card onto the battlefield without casting it (back from exile, say), under its owner's control. An Aura
    # needs something to enchant, so its owner is asked (see Choice::AttachReturningAura); with nothing legal it stays put.
    def return_to_battlefield!
      return resolve! unless is_a?(Cards::Aura)

      choice = Choice::AttachReturningAura.new(actor: self)
      game.add_choice(choice) if choice.choices.any?
    end

    def resolve!(enters_tapped: enters_tapped?, kicked: false, attach_to: nil, controller: owner, mana_spent: {}, evoked: false, value_for_x: nil)
      if permanent?
        permanent = Magic::Permanent.resolve(
          game: game,
          owner: owner,
          controller: controller,
          card: self,
          from_zone: zone,
          enters_tapped: enters_tapped,
          kicked: kicked,
          attach_to: attach_to,
          mana_spent: mana_spent,
          evoked: evoked,
          value_for_x: value_for_x,
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

    # Counters it enters with because of the X it was cast with (Jacked Rabbit: X +1/+1 counters).
    def entering_counters_for_x(_x)
      {}
    end

    # Counters it enters with only when cast from the hand (Myojin of Night's Reach).
    def entering_counters_if_cast_from_hand
      {}
    end

    def activated_abilities
      []
    end

    # Harmonize granted by an effect until end of turn, its cost being the card's mana cost
    # (Songcrafter Mage). A card with its own `harmonize` macro overrides `harmonize_cost`.
    def grant_harmonize_until_end_of_turn!
      @harmonize_granted_turn = game.current_turn.number
    end

    # Flashback granted by an effect until end of turn, its cost being the card's mana cost
    # (Sphinx of Forgotten Lore). A card with its own `flashback` macro uses that cost instead.
    def grant_flashback_until_end_of_turn!
      @flashback_granted_turn = game.current_turn.number
    end

    # The flashback cost this card has right now (its own, or a granted one), or nil.
    def flashback_cost_now
      return flashback_cost if respond_to?(:flashback_cost)

      cost if @flashback_granted_turn && @flashback_granted_turn == game.current_turn.number
    end

    # The cost to cast this card from the graveyard with harmonize, or nil when it has none now.
    def harmonize_cost
      cost if @harmonize_granted_turn && @harmonize_granted_turn == game.current_turn.number
    end

    # Abilities a card activates from its owner's graveyard (Renew, "Exile this card from your
    # graveyard: ..."), as instances: `[GraveyardAbility.new(source: self)]`.
    def graveyard_abilities
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

    # Rule 702.73a: changeling is a characteristic-defining ability, so a card with the keyword is
    # every creature type in every zone, not just on the battlefield. (Abilities::Static::Changeling
    # does the same for a source that is all creature types without the keyword.)
    def types
      return @types unless changeling? || static_abilities.include?(Abilities::Static::Changeling)

      (@types + Types::Creatures.values).uniq
    end

    def graveyard_static_abilities
      []
    end

    def replacement_effects
      {}
    end

    # Replacement effects the card applies to itself while in a zone other than the battlefield (hand,
    # library, graveyard, exile, the stack): "If ~ would be put into a graveyard from anywhere, ... instead"
    # (Darksteel Colossus). Same shape as #replacement_effects; the receiver is the Card.
    def zone_replacement_effects
      {}
    end

    def replacement_effect_for(context)
      zone_replacement_effects.each do |matcher, replacement_effect|
        next unless matcher.nil? || context.effect.is_a?(matcher)
        next if context.applied_replacement_keys.include?([object_id, replacement_effect])

        replacement = replacement_effect.new(receiver: self)
        return replacement if replacement.applies_with_context?(context)
      end

      nil
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

    def all_creature_types?
      changeling?
    end

    def rebound?
      false
    end

    def enters_as_copy? = false
    # "Exile ~" as the last instruction of a spell (Morningtide's Light): it isn't put into the graveyard.
    def exile_as_it_resolves? = false
    # X paid for a "blight X" additional cost (Costs::BlightX).
    attr_accessor :x_blighted

    def evoke_cost
      self.class.const_defined?(:EVOKE_COST, false) ? Costs::Mana.new(self.class::EVOKE_COST.dup) : nil
    end

    def blitz_cost
      self.class.const_defined?(:BLITZ_COST, false) ? Costs::Mana.new(self.class::BLITZ_COST.dup) : nil
    end

    # The card's own offspring cost as a raw cost (Actions::Cast wraps it), or nil.
    def offspring_cost
      self.class.const_defined?(:OFFSPRING_COST, false) ? self.class::OFFSPRING_COST.dup : nil
    end

    def adventure_cost
      self.class.const_defined?(:ADVENTURE_COST, false) ? Costs::Mana.new(self.class::ADVENTURE_COST.dup) : nil
    end

    def cycling_cost
      self.class.const_defined?(:CYCLING_COST, false) ? Costs::Mana.new(self.class::CYCLING_COST.dup) : nil
    end

    # The `Filter[...]` name a landcycling card searches for, or nil for plain cycling.
    def cycling_search
      self.class.const_defined?(:CYCLING_SEARCH, false) ? self.class::CYCLING_SEARCH : nil
    end

    def cycling?
      !!cycling_cost
    end

    # What cycling does once the card is discarded: draw a card, or search for a land (landcycling). A card whose
    # discard-from-hand ability does something else (Waker of Waves) overrides it.
    def cycling_effect!
      if cycling_search
        game.add_choice(Magic::Choice::SearchLibrary.new(actor: self, to_zone: :hand, upto: 1, reveal: true, filter: Filter[cycling_search]))
      else
        trigger_effect(:draw_cards, number_to_draw: 1)
      end
    end

    # "You may cast this card from your graveyard" (Demonic Embrace): castable from its owner's graveyard, with whatever
    # additional costs the card asks for (`additional_costs`).
    def may_cast_from_graveyard? = false

    def buyback?
      false
    end

    def convoke?
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
    # "Can't be blocked by more than one creature": the most creatures that may block it (nil: no limit).
    def maximum_blockers = nil
    # "This creature must be blocked if able."
    def must_be_blocked? = false
    # "This creature attacks each combat if able."
    def must_attack? = false
    # An Aura that goads the creature it enchants (Ghoulish Impetus).
    def goads_enchanted? = false
    # An Aura that makes the creature it enchants attack each combat if able (Furor of the Bitten).
    def forces_enchanted_to_attack? = false
    # How many attackers this creature can block at once; override for "can block an additional creature".
    def maximum_attackers_blocked = 1
    def can_activate_ability?(_) = true
    # "You have no maximum hand size."
    def no_maximum_hand_size? = false
    # "Each opponent's maximum hand size is reduced by N." (Locust Miser)
    def opponents_maximum_hand_size_reduction = 0

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
      # On the battlefield the Permanent dispatches event handlers itself (with itself as the actor); a card that
      # is still subscribed from an earlier zone must not handle the event a second time, as a bare card.
      return if zone&.battlefield?
      return if zone&.graveyard? && !handler_class.respond_to?(:works_from_graveyard?)
      # Likewise, an exiled card only handles events its handler says work from exile.
      return if zone&.exile? && !handler_class.respond_to?(:works_from_exile?)

      if handler_class
        logger.debug "EVENT HANDLER: #{self} handling #{event}"
        handler = handler_class.new(actor: self, event: event)

        handler.perform!
      end
    end
  end
end
