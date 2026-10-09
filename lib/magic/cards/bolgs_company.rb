module Magic
  module Cards
    BolgsCompany = Creature("Bolg's Company") do
      cost black: 1, red: 1
      creature_type("Goblin Soldier")
      power 2
      toughness 2
    end

    class BolgsCompany < Creature
      # "This creature has haste as long as you control another Goblin."
      class ConditionalHaste < Abilities::Static::KeywordGrant
        keyword_grants Keywords::HASTE
        applicable_targets { [source] }
        conditions { controller.creatures.by_type("Goblin").except(source).any? }
      end

      def static_abilities = [ConditionalHaste]

      # "{T}, Sacrifice another Goblin: Add {B}{R}."
      class ManaAbility < Magic::ManaAbility
        costs "{T}, Sacrifice another Goblin"

        def mana_produced = { black: 1, red: 1 }
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
