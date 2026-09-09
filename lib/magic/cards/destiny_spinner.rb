module Magic
  module Cards
    DestinySpinner = Creature("Destiny Spinner") do
      type T::Enchantment, T::Creature, T::Creatures["Human"]
      cost generic: 1, green: 1
      power 2
      toughness 3
    end

    class DestinySpinner < Creature
      class AnimateLandAbility < Magic::ActivatedAbility
        costs "{3}{G}"

        def target_choices
          controller.lands
        end

        def resolve!(target:)
          target.add_types(T::Creature, T::Creatures["Elemental"])
          target.modify_base_power(controller.permanents.enchantments.count)
          target.modify_base_toughness(controller.permanents.enchantments.count)
          target.grant_trample!
          target.grant_haste!
        end
      end

      def activated_abilities = [AnimateLandAbility]
    end
  end
end