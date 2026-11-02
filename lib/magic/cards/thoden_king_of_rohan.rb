module Magic
  module Cards
    ThodenKingOfRohan =Creature("Théoden, King of Rohan") do
      cost "{1}{R}{W}"
      legendary_creature_type "Human Noble"
      power 2
      toughness 3
    end

    class ThodenKingOfRohan <Creature
      # "...target creature gains double strike until end of turn."
      class DoubleStrikeChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures

        def choice_amount = 1

        def resolve!(target:)
          give_keyword target, :double_strike
        end

        # The target is mandatory (CR 603.3d): declining picks a legal creature.
        def decline!
          target = choices.first
          resolve!(target: target) if target
        end
      end

      # "Whenever Théoden or another Human you control enters, ..." Théoden is a Human, so his own entry matches.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent.type?("Human") && under_your_control?
        end

        def call
          choice = DoubleStrikeChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => EntersTrigger }
    end
  end
end
