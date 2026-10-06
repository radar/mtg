module Magic
  module Cards
    TetsukoUmezawaFugitive = Creature("Tetsuko Umezawa, Fugitive") do
      cost generic: 1, blue: 1
      legendary_creature_type "Human Rogue"
      power 1
      toughness 3
    end

    class TetsukoUmezawaFugitive < Creature
      # "Creatures you control with power or toughness 1 or less can't be blocked."
      class SmallCreaturesUnblockable < Abilities::Static::KeywordGrant
        keyword_grants Keywords::CANT_BE_BLOCKED
        applicable_targets do
          source.controller.creatures.select { |creature| creature.power.to_i <= 1 || creature.toughness.to_i <= 1 }
        end
      end

      def static_abilities = [SmallCreaturesUnblockable]
    end
  end
end
