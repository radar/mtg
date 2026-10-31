module Magic
  module Cards
    EasterlingVanguard = Creature("Easterling Vanguard") do
      cost generic: 1, black: 1
      creature_type "Human Warrior"
      power 2
      toughness 1
    end

    class EasterlingVanguard < Creature
      # "When this creature dies, amass Orcs 1."
      class DiesTrigger < TriggeredAbility::Death
        def call
          Magic::Amass.call(source: actor, controller: controller, amount: 1, subtype: "Orc")
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
