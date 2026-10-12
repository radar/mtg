module Magic
  module Cards
    WargTactics = Instant("Warg Tactics") do
      cost generic: 1, green: 1
    end

    class WargTactics < Instant
      class Mode1 < Mode
        def target_choices
          battlefield.creatures.select { _1.has_keyword?(Keywords::FLYING) }
        end

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      class Mode2 < Mode
        def target_choices
          battlefield.controlled_by(controller).creatures
        end

        def resolve!(target:)
          add_counter("+1/+1", to: target)
          give_keyword(target, :trample)
          give_keyword(target, :hexproof)
        end
      end

      modes Mode1, Mode2
      choose_modes 1
    end
  end
end
