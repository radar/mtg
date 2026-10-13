module Magic
  module Cards
    VampiricRites = Enchantment("Vampiric Rites") do
      cost black: 1
    end

    class VampiricRites < Enchantment
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}{B}, Sacrifice a creature"

        def resolve!
          gain_life(1)
          draw_card
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
