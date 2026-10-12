module Magic
  module Cards
    # Bloomburrow's Class enchantments. The permanent starts at level 1 and gains each next level for
    # that level's cost, as a sorcery (`level_costs 2 => "{2}{R}", 3 => "{3}{R}"`). Abilities written for a
    # later level check `actor.level` (triggers) or `source.level` (static and activated abilities); the
    # card's own text above any "Level N" line is level 1.
    class ClassEnchantment < Card
      type T::Enchantment, "Class"

      LEVEL_COSTS = {}.freeze

      def self.level_costs(costs)
        const_set(:LEVEL_COSTS, costs.freeze)
      end

      # "{cost}: Level N" -- the cost of the next level, activated only as a sorcery.
      class LevelUp < Magic::ActivatedAbility
        def next_level = source.level + 1

        def level_costs = source.card.class::LEVEL_COSTS

        def costs
          Costs::Parser.parse(source:, costs: level_costs.fetch(next_level))
        end

        def requirements_met?
          level_costs.key?(next_level) && game.can_cast_sorcery?(controller)
        end

        def resolve!
          source.level_up!
        end
      end

      def activated_abilities = [LevelUp]
    end
  end
end
