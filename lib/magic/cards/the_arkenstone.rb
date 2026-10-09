module Magic
  module Cards
    TheArkenstone = Artifact("The Arkenstone") do
      legendary_artifact
      cost generic: 5
    end

    class TheArkenstone < Artifact
      # Seek the Heart {2}{W}, Sorcery -- Adventure
      adventure generic: 2, white: 1

      # "Search your library for a legendary creature card, reveal it, put it into your hand, then shuffle."
      class SearchChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :hand, upto: 1, reveal: true, filter: ->(card) { card.creature? && card.legendary? })
        end
      end

      def adventure_resolve!(**)
        game.choices.add(SearchChoice.new(actor: self))
      end

      # "Creatures you control get +1/+1."
      class Buff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        applicable_targets { your.creatures }
      end

      def static_abilities = [Buff]

      # "At the beginning of your end step, draw a card."
      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform? = controllers_end_step?

        def call
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      def event_handlers = super.merge({ Events::BeginningOfEndStep => EndStepTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
