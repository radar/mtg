module Magic
  module Cards
    UndergrowthLeopard = Creature("Undergrowth Leopard") do
      cost generic: 1, green: 1
      creature_type("Cat")
      keywords :vigilance
      power 2
      toughness 2
    end

    class UndergrowthLeopard < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}, Sacrifice {this}"

        def target_choices
          (battlefield.artifacts + battlefield.enchantments)
        end

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
