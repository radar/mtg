module Magic
  module Cards
    ShoreLurker = Creature("Shore Lurker") do
      cost generic: 3, white: 1
      creature_type("Merfolk Scout")
      keywords :flying
      power 3
      toughness 3
    end

    class ShoreLurker < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::Surveil.new(actor: actor, amount: 1))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
