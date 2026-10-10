module Magic
  module Cards
    RootwiseSurvivor = Creature("Rootwise Survivor") do
      cost generic: 3, green: 2
      creature_type "Human Survivor"
      power 3
      toughness 4
      keywords :haste
    end

    class RootwiseSurvivor < Creature
      # "Survival — At the beginning of your second main phase, if this creature is tapped, put three +1/+1 counters on
      # up to one target land you control. That land becomes a 0/0 Elemental creature in addition to its other types.
      # It gains haste until your next turn."
      class SurvivalTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && actor.tapped?
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            controller.lands
          end

          def choice_amount = 0..1

          def resolve!(target:)
            target.become_creature!(power: 0, toughness: 0, types: [T::Creatures["Elemental"]], until_eot: false)
            target.add_counter(Counters::Plus1Plus1, amount: 3)
            target.grant_keyword(Keywords::HASTE, until_eot: false)
            target.modifiers.last.until_turn_of = controller
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::SecondMainPhase => SurvivalTrigger }
    end
  end
end
