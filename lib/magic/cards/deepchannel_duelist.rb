module Magic
  module Cards
    DeepchannelDuelist = Creature("Deepchannel Duelist") do
      cost white: 1, blue: 1
      creature_type("Merfolk Soldier")
      power 2
      toughness 2
    end

    class DeepchannelDuelist < Creature
      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        other_creatures "Merfolk"
      end

      def static_abilities = [PowerAndToughnessModification]

      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step?
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.controlled_by(controller).creatures.by_any_type("Merfolk")
          end

          def choice_amount = 1

          def resolve!(target:)
            target.untap!
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::BeginningOfEndStep => EndStepTrigger }
    end
  end
end
