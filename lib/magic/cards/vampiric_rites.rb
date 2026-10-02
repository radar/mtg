module Magic
  module Cards
    VampiricRites = Enchantment("Vampiric Rites") do
      cost black: 1
    end

    class VampiricRites < Enchantment
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}{B}, Sacrifice a creature"

        def resolve!
          trigger_effect(:gain_life, target: controller, life: 1)
          trigger_effect(:draw_card)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
