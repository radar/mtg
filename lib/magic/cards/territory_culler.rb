module Magic
  module Cards
    TerritoryCuller = Creature("Territory Culler") do
      cost generic: 4, green: 1
      creature_type "Eldrazi"
      keywords :devoid, :reach
      power 7
      toughness 5
    end

    class TerritoryCuller < Creature
      # "If you don't put the card into your hand, you may put it into your graveyard."
      class GraveyardChoice < Magic::Choice::May
        attr_reader :card

        def initialize(actor:, card:)
          super(actor: actor)
          @card = card
        end

        def resolve!
          card.move_to_graveyard! if card.zone&.library?
        end
      end

      # "If it's a creature card, you may reveal it and put it into your hand."
      class HandChoice < Magic::Choice::May
        attr_reader :card

        def initialize(actor:, card:)
          super(actor: actor)
          @card = card
        end

        def resolve!
          reveal_cards [card]
          card.move_to_hand!
        end

        def decline!
          game.choices.add(GraveyardChoice.new(actor: actor, card: card))
        end
      end

      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform? = event.player == controller

        def call
          top = controller.library.first
          return unless top

          choice_class = top.creature? ? HandChoice : GraveyardChoice
          game.choices.add(choice_class.new(actor: actor, card: top))
        end
      end

      def event_handlers = { Events::Landfall => LandfallTrigger }
    end
  end
end
