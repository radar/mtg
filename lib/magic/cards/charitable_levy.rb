module Magic
  module Cards
    CharitableLevy = Enchantment("Charitable Levy") do
      cost generic: 1, white: 1
    end

    class CharitableLevy < Enchantment
      # "Noncreature spells cost {1} more to cast." Affects every player's spells.
      class IncreaseManaCost < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          @source = source
          @adjustment = { generic: 1 }
        end

        def applies_to?(card) = !card.creature?
      end

      # Counters["collection"] would clash with the Counters::Collection container class, so the counter type is
      # card-local (Counters[] passes classes straight through).
      class CollectionCounter
        def power_modification = 0
        def toughness_modification = 0
      end

      # "Whenever a player casts a noncreature spell, put a collection counter on this enchantment. Then if there are
      # three or more collection counters on it, sacrifice it. If you do, draw a card, then you may search your library
      # for a Plains card, put it onto the battlefield tapped, then shuffle."
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform? = !spell.creature?

        def call
          return unless actor.zone&.battlefield?

          add_counter(CollectionCounter, to: actor)
          return if actor.counters.of_type(CollectionCounter).count < 3

          owner_of_control = controller
          sacrifice(actor)
          draw_cards(1, player: owner_of_control)
          game.search_library(actor, find: "Plains", to: :battlefield, tapped: true)
        end
      end

      def static_abilities = [IncreaseManaCost]
      def event_handlers = { Events::SpellCast => SpellCastTrigger }
    end
  end
end
