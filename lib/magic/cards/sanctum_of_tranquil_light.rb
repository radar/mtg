module Magic
  module Cards
    SanctumOfTranquilLight = Enchantment("Sanctum of Tranquil Light") do
      type "Legendary Enchantment -- Shrine"
      cost white: 1
    end

    class SanctumOfTranquilLight < Enchantment
      class ActivatedAbility < Magic::ActivatedAbility
        def costs
          [Costs::Mana.new(generic: 5, white: 1)
            .reduced_by(generic: -> { source.controller.permanents.by_any_type("Shrine").count })]
        end

        def tap_choices
          battlefield.creatures
        end

        def single_target?
          true
        end

        def resolve!(target:)
          target.tap!
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
