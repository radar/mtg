module Magic
  module Cards
    MoonlitLamenter = Creature("Moonlit Lamenter") do
      cost generic: 2, white: 1
      creature_type("Treefolk Cleric")
      power 2
      toughness 5
    end

    class MoonlitLamenter < Creature
      enters_with_counters "-1/-1", 1

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}{W}, Remove 1 -1/-1 counters from {this}"

        def requirements_met? = game.can_cast_sorcery?(controller)

        def resolve!
          trigger_effect(:draw_card)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
