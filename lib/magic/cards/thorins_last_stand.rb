module Magic
  module Cards
    ThorinsLastStand = Instant("Thorin's Last Stand") do
      cost generic: 2, white: 2
    end

    class ThorinsLastStand < Instant
      class Mode1 < Mode
        def resolve!
          battlefield.controlled_by(controller).creatures.each { |creature| trigger_effect(:modify_power_toughness, target: creature, power: 2, toughness: 1) }
        end
      end

      class Mode2 < Mode
        def target_choices
          (battlefield.artifacts + battlefield.enchantments)
        end

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
          trigger_effect(:gain_life, target: controller, life: 2)
        end
      end

      modes Mode1, Mode2
      choose_modes 1
    end
  end
end
