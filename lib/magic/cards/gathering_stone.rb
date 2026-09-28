module Magic
  module Cards
    GatheringStone = Artifact("Gathering Stone") do
      cost generic: 4
    end

    class GatheringStone < Artifact
      # "Look at the top card of your library. If it's a card of the chosen type, you may reveal
      # it and put it into your hand. If you don't put the card into your hand, you may put it
      # into your graveyard."
      class TopCardChoice < Magic::Choice
        attr_reader :card

        def initialize(actor:, card:)
          super(actor: actor)
          @card = card
        end

        def choices = [:hand, :graveyard, :nothing]

        def resolve!(destination:)
          raise ArgumentError, "#{destination} is not one of #{choices.join(", ")}" unless choices.include?(destination)
          return unless controller.library.first.equal?(card)

          case destination
          when :hand
            raise ArgumentError, "#{card.name} is not of the chosen type" unless card.type?(actor.chosen_creature_type)

            trigger_effect(:reveal_cards, target: [card])
            card.move_to_hand!
          when :graveyard
            card.discard!
          end
        end
      end

      def self.look_at_top_card(actor:, game:)
        card = actor.controller.library.first
        game.choices.add(TopCardChoice.new(actor: actor, card: card)) if card
      end

      # The look happens after the type is chosen, so it hangs off the same choice.
      class TypeChoice < Magic::Choice::ChooseCreatureTypeForPermanent
        def resolve!(creature_type:)
          super
          GatheringStone.look_at_top_card(actor: actor, game: game)
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(TypeChoice.new(actor: actor))
        end
      end

      def etb_triggers = [ETB]

      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def call
          GatheringStone.look_at_top_card(actor: actor, game: game)
        end
      end

      def event_handlers = { Events::BeginningOfUpkeep => UpkeepTrigger }

      # Spells you cast of the chosen type cost {1} less to cast.
      class ReduceManaCost < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          @source = source
          @adjustment = { generic: -1 }
        end

        def applies_to?(card)
          type = source.chosen_creature_type
          card.is_a?(Card) && type && card.owner == source.controller && card.type?(type)
        end

        # Only generic mana can be reduced.
        def apply(cost)
          cost.adjusted_by(adjustment) if cost.cost[:generic].to_i.positive?
          cost
        end
      end

      def static_abilities = [ReduceManaCost]
    end
  end
end
