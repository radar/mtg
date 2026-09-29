module Magic
  module Cards
    KeepOut = Instant("Keep Out") do
      cost generic: 1, white: 1
    end

    class KeepOut < Instant
      class Mode1 < Mode
        def target_choices
          battlefield.creatures.select(&:tapped?)
        end

        def resolve!(target:)
          trigger_effect(:deal_damage, target: target, damage: 4)
        end
      end

      class Mode2 < Mode
        def target_choices
          battlefield.enchantments
        end

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      modes Mode1, Mode2
      choose_modes 1
    end
  end
end
