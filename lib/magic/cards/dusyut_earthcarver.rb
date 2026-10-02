module Magic
  module Cards
    DusyutEarthcarver = Creature("Dusyut Earthcarver") do
      cost generic: 5, green: 1
      creature_type("Elephant Druid")
      keywords :reach
      power 4
      toughness 4
    end

    class DusyutEarthcarver < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::Endure.new(actor: actor, amount: 3))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
