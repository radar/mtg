module Magic
  module Cards
    SarkhansResolve = Instant("Sarkhan's Resolve") do
      cost generic: 1, green: 1
    end

    class SarkhansResolve < Instant
      class Mode1 < Mode
        def target_choices
          battlefield.creatures
        end

        def resolve!(target:)
          trigger_effect(:modify_power_toughness, target: target, power: 3, toughness: 3)
        end
      end

      class Mode2 < Mode
        def target_choices
          battlefield.creatures.select { _1.has_keyword?(Keywords::FLYING) }
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
