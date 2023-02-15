module Magic
  module Cards
    class SanctumOfTranquilLight < Card
      NAME = "Sanctum of Tranquil Light"
      TYPE_LINE = "Legendary Enchantment -- Shrine"
      COST = { white: 1 }

      class ActivatedAbility < Magic::ActivatedAbility
        def costs
          [Costs::Mana.new(generic: 5, white: 1)
            .reduced_by(generic: -> { source.controller.permanents.by_any_type("Shrine").count })]
        end

        def single_target?
          true
        end

        def target_choices
          battlefield.creatures
        end

        def resolve!(target:)
          target.tap!
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
