module Magic
  module Cards
    FontOfFertility = Enchantment("Font of Fertility") do
      type "Enchantment"
      cost green: 1
    end

    class FontOfFertility < Enchantment
      def target_choices(receiver)
        receiver.controller.library.basic_lands
      end

      class Effect < Effects::TargetedEffect
        def resolve(target)
          target.resolve!(source.controller, enters_tapped: true)
          source.controller.shuffle!
        end
      end

      class ActivatedAbility < Magic::ActivatedAbility
        def costs = [Costs::Mana.new(green: 1), Costs::Sacrifice.new(source)]

        def resolve!
          game.add_effect(Effect.new(source: source))
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
