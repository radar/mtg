module Magic
  module Cards
    ChandrasMagmutt = Creature("Chandra's Magmutt") do
      cost generic: 1, red: 1
      creature_type "Elemental Dog"
      power 2
      toughness 2
    end

    class ChandrasMagmutt < Creature
      # "{T}: This creature deals 1 damage to target player or planeswalker."
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{T}"

        def target_choices = [*game.players, *battlefield.planeswalkers]

        def single_target? = true

        def resolve!(target:)
          trigger_effect(:deal_damage, target:, damage: 1)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
