module Magic
  module Cards
    LlanowarVisionary = Creature("Llanowar Visionary") do
      cost generic: 1, green: 1
      creature_type "Elf Druid"
      power 2
      toughness 2

      enters_the_battlefield do
        actor.trigger_effect(:draw_cards)
      end
    end

    class LlanowarVisionary < Creature
      class ManaAbility < Magic::TapManaAbility
        choices :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
