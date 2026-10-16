module Magic
  module Cards
    UrzasIncubator = Artifact("Urza's Incubator") do
      cost generic: 3
    end

    class UrzasIncubator < Artifact
      # "As this artifact enters, choose a creature type."
      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::ChooseCreatureTypeForPermanent.new(actor: actor))
        end
      end

      def etb_triggers = [ETB]

      # "Creature spells of the chosen type cost {2} less to cast." Affects every player's spells.
      class ReduceManaCost < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          @source = source
          @adjustment = { generic: -2 }
        end

        def applies_to?(card)
          type = source.chosen_creature_type
          card.is_a?(Card) && type && card.creature? && card.type?(type)
        end
      end

      def static_abilities = [ReduceManaCost]
    end
  end
end
