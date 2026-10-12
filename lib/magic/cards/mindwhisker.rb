module Magic
  module Cards
    Mindwhisker = Creature("Mindwhisker") do
      cost generic: 2, blue: 1
      creature_type("Rat Wizard")
      power 3
      toughness 2
    end

    class Mindwhisker < Creature
      # At the beginning of your upkeep, surveil 1.
      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def call
          game.choices.add(Magic::Choice::Surveil.new(actor: actor, amount: 1))
        end
      end

      def event_handlers = super.merge(Events::BeginningOfUpkeep => UpkeepTrigger)

      # Threshold -- As long as there are seven or more cards in your graveyard, creatures your opponents control
      # get -1/-0.
      class ThresholdShrink < Abilities::Static::PowerAndToughnessModification
        modify power: -1, toughness: 0

        def applicable_targets
          return [] unless source.controller.graveyard.count >= 7

          battlefield.not_controlled_by(source.controller).creatures
        end
      end

      def static_abilities = [ThresholdShrink]
    end
  end
end
