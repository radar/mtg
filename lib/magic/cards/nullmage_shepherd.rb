module Magic
  module Cards
    NullmageShepherd = Creature("Nullmage Shepherd") do
      cost generic: 3, green: 1
      creature_type "Elf Shaman"
      power 2
      toughness 4
    end

    class NullmageShepherd < Creature
      class DestroyAbility < Magic::ActivatedAbility
        def costs = [Costs::MultiTap.new(4) { controller.creatures.untapped }]

        def target_choices
          game.battlefield.cards.by_any_type("Artifact", "Enchantment")
        end

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      def activated_abilities = [DestroyAbility]
    end
  end
end
