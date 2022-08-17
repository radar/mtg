module Magic
  module Cards
    class SanctumOfTranquilLight < Card
      NAME = "Sanctum of Tranquil Light"
      TYPE_LINE = "Legendary Enchantment -- Shrine"
      COST = { white: 1 }

      def activated_abilities
        [
          ActivatedAbility.new(
            costs: [
              Costs::Mana.new(generic: 5, white: 1)
                .reduced_by(generic: -> { controller.permanents.by_any_type("Shrine").count })
            ],
            ability: -> (targets:) {
              Effects::TapTarget.new(source: self, choices: tap_choices, targets: targets).resolve
            }
          )
        ]
      end

      private

      def tap_choices
        battlefield.creatures
      end
    end
  end
end
