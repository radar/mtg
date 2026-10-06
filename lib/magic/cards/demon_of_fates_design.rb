module Magic
  module Cards
    DemonOfFatesDesign = Creature("Demon of Fate's Design") do
      type T::Enchantment, T::Creature, T::Creatures["Demon"]
      cost generic: 4, black: 2
      power 6
      toughness 6
      keywords :flying, :trample
    end

    class DemonOfFatesDesign < Creature
      # Once during each of your turns, you may cast an enchantment spell by paying life equal to its mana value rather
      # than paying its mana cost. Cast with `pay_life: true` to use it.
      class PayLifeForEnchantments < StaticAbility
        def may_pay_life_for?(card, player)
          player == controller && card.enchantment? && !@source.activated_this_turn?(self.class) && player.life >= card.mana_value
        end

        def paid_life_for_spell!(card, player)
          @source.activated_this_turn!(self.class) if player == controller && card.enchantment?
        end
      end

      # {2}{B}, Sacrifice another enchantment: This creature gets +X/+0 until end of turn, where X is the sacrificed
      # enchantment's mana value.
      class ActivatedAbility < Magic::ActivatedAbility
        def costs
          [Costs::Mana.new("{2}{B}"), Costs::Sacrifice.new(source, controller.permanents.enchantments.reject { _1 == source })]
        end

        def resolve!(sacrificed:)
          source.modify_power(sacrificed.sum(&:mana_value))
        end
      end

      def static_abilities = [PayLifeForEnchantments]
      def activated_abilities = [ActivatedAbility]
    end
  end
end
