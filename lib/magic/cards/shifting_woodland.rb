module Magic
  module Cards
    ShiftingWoodland = Card("Shifting Woodland") do
      type "Land"
    end

    class ShiftingWoodland < Card
      # "This land enters tapped unless you control a Forest."
      def enters_tapped? = controller.permanents.by_any_type("Forest").none?

      # "{T}: Add {G}."
      class ManaAbility < Magic::TapManaAbility
        choices :green
      end

      # "Delirium -- {2}{G}{G}: This land becomes a copy of target permanent card in your graveyard until end of turn.
      # Activate only if there are four or more card types among cards in your graveyard."
      class CopyAbility < Magic::ActivatedAbility
        costs "{2}{G}{G}"

        def requirements_met?
          controller.graveyard.delirium?
        end

        def target_choices
          controller.graveyard.cards.select do |card|
            card.creature? || card.artifact? || card.enchantment? || card.land? || card.planeswalker?
          end
        end

        def resolve!(target:)
          source.become_copy_until_eot!(target)
        end
      end

      def activated_abilities = [ManaAbility, CopyAbility]
    end
  end
end
