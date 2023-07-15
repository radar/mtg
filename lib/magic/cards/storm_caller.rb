module Magic
  module Cards
    StormCaller = Creature("Storm Caller") do
      creature_type("Ogre Shaman")
      cost red: 1, generic: 2
      power 3
      toughness 2
    end

    class StormCaller < Creature
      class ETB < TriggeredAbility::EnterTheBattlefield

        def perform
          effect = Effects::DealDamage.new(
            source: permanent,
            choices: game.opponents(controller),
            targets: game.opponents(controller),
            damage: 2,
          )
          game.add_effect(effect)
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
