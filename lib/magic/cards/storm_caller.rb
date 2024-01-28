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
          source.opponents.each do |opponent|
            source.trigger_effect(:deal_damage, damage: 2, target: opponent)
          end
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
