module Magic
  module Cards
    CelestialEnforcer = Creature("Celestial Enforcer") do
      power 2
      toughness 3
      cost generic: 2, white: 1
      type "Creature -- Human Cleric"
    end

    class CelestialEnforcer < Creature
      def activated_abilities
        [
          ActivatedAbility.new(
            mana_cost: { generic: 1, white: 1 },
            additional_costs: [Costs::Tap.new(self)],
            requirements: [
              -> {
                battlefield.creatures.controlled_by(controller).any?(&:flying?)
              }
            ],
            ability: -> {
              game.add_effect(Effects::TapTarget.new(choices: battlefield.creatures))
            }
          )
        ]
      end
    end
  end
end
