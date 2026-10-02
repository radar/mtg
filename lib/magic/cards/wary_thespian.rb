module Magic
  module Cards
    WaryThespian = Creature("Wary Thespian") do
      cost generic: 1, green: 1
      creature_type("Cat Druid")
      power 3
      toughness 1
    end

    class WaryThespian < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::Surveil.new(actor: actor, amount: 1))
        end
      end

      def etb_triggers = [EntersTrigger]

      class DiesTrigger < TriggeredAbility::Death
        def call
          game.choices.add(Magic::Choice::Surveil.new(actor: actor, amount: 1))
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
