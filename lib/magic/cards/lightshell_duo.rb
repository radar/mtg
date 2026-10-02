module Magic
  module Cards
    LightshellDuo = Creature("Lightshell Duo") do
      cost generic: 3, blue: 1
      creature_type("Rat Otter")
      keywords :prowess
      power 3
      toughness 4
    end

    class LightshellDuo < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::Surveil.new(actor: actor, amount: 2))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
