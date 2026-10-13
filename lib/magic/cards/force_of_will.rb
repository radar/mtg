module Magic
  module Cards
    ForceOfWill = Instant("Force of Will") do
      cost "{3}{U}{U}"
    end

    class ForceOfWill < Instant
      def alternative_cost
        Costs::ExileCardAndLifeAlternativeCost.new(
          card: self,
          predicate: ->(card) { card.colors.include?(:blue) },
          life: 1,
        )
      end

      def single_target?
        true
      end

      def target_choices
        game.stack.spells
      end

      def resolve!(target:)
        counter_spell(target)
      end
    end
  end
end
