module Magic
  module Cards
    CircleOfDreamsDruid = Creature("Circle of Dreams Druid") do
      cost "{G}" * 3
      power 2
      toughness 1
      creature_type "Elf Druid"
    end

    class CircleOfDreamsDruid < Creature
      class ManaAbility < Magic::TapManaAbility
        choices :green

        def mana_produced
          { choice => creatures_you_control.count }
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
