module Magic
  module Cards
    SanctumOfShatteredHeights = Enchantment("Sanctum of Shattered Heights") do
      type T::Super::Legendary, T::Enchantment, "Shrine"
      cost generic: 2, red: 1
    end

    class SanctumOfShatteredHeights < Enchantment
      # "{1}, Discard a land card or Shrine card: This enchantment deals X damage to target creature or
      # planeswalker, where X is the number of Shrines you control."
      class ActivatedAbility < Magic::ActivatedAbility
        def costs
          [
            Costs::Mana.new(generic: 1),
            Costs::Discard.new(controller, ->(card) { card.land? || card.type?("Shrine") })
          ]
        end

        def target_choices = battlefield.by_any_type(T::Creature, T::Planeswalker)

        def single_target? = true

        def resolve!(target:)
          trigger_effect(:deal_damage, target:, damage: controller.permanents.by_any_type("Shrine").count)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
