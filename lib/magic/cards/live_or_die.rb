module Magic
  module Cards
    LiveOrDie = Instant("Live or Die") do
      cost generic: 3, black: 2
    end

    class LiveOrDie < Instant
      class Mode1 < Mode
        def target_choices
          controller.graveyard.cards.select { _1.type?("Creature") }
        end

        def resolve!(target:)
          reanimate target, controller: target.owner
        end
      end

      class Mode2 < Mode
        def target_choices
          battlefield.creatures
        end

        def resolve!(target:)
          destroy(target)
        end
      end

      modes Mode1, Mode2
      choose_modes 1
    end
  end
end
