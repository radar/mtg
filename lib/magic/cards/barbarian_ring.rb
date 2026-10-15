module Magic
  module Cards
    class BarbarianRing < Land
      NAME = "Barbarian Ring"

      # "{T}: Add {R}. This land deals 1 damage to you."
      class ManaAbility < Magic::TapManaAbility
        choices :red

        def resolve!
          super
          deal_damage 1, to: controller
        end
      end

      # "Threshold -- {R}, {T}, Sacrifice this land: It deals 2 damage to any target. Activate only if there are
      # seven or more cards in your graveyard."
      class ThresholdAbility < Magic::ActivatedAbility
        costs "{R}, {T}, Sacrifice {this}"

        def requirements_met? = controller.graveyard.count >= 7

        def single_target? = true

        def target_choices = game.any_target

        def resolve!(target:)
          deal_damage 2, to: target
        end
      end

      def activated_abilities = [ManaAbility, ThresholdAbility]
    end
  end
end
