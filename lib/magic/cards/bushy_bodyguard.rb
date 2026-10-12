module Magic
  module Cards
    BushyBodyguard = Creature("Bushy Bodyguard") do
      cost generic: 1, green: 1
      creature_type("Squirrel Warrior")
      power 2
      toughness 1
      offspring generic: 2
    end

    class BushyBodyguard < Creature
      # When this creature enters, you may forage. If you do, put two +1/+1 counters on it.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class ForageChoice < Magic::Choice::Forage
          def after_forage
            actor.add_counter("+1/+1", amount: 2)
          end
        end

        class MayChoice < Magic::Choice::May
          def resolve!
            choice = ForageChoice.new(actor: actor)
            game.choices.add(choice) if choice.possible?
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
