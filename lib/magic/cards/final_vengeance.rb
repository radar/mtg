module Magic
  module Cards
    class FinalVengeance < Sorcery
      card_name "Final Vengeance"
      cost black: 1

      # "As an additional cost to cast this spell, sacrifice a creature or enchantment."
      def additional_costs
        [Costs::Sacrifice.new(self, battlefield.controlled_by(controller).select { _1.creature? || _1.enchantment? })]
      end

      def single_target? = true

      def target_choices = battlefield.creatures

      # "Exile target creature."
      def resolve!(target:)
        exile_target(target)
      end
    end
  end
end
