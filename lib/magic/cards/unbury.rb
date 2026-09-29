module Magic
  module Cards
    class Unbury < Instant
      card_name "Unbury"
      cost generic: 1, black: 1

      # Return target creature card from your graveyard to your hand.
      class ReturnOne < Mode
        def target_choices = controller.graveyard.creatures

        def resolve!(target:)
          target.move_to_hand!
        end
      end

      # Return two target creature cards that share a creature type from your graveyard to your hand.
      class ReturnTwo < Mode
        def multi_target? = true

        def distinct_targets? = true

        def target_choices = [controller.graveyard.creatures, controller.graveyard.creatures]

        def targets_legal?(targets)
          targets.size == 2 && Magic::Types::Creatures.values.any? { |type| targets.all? { _1.type?(type) } }
        end

        def resolve!(targets:)
          targets.each(&:move_to_hand!)
        end
      end

      modes ReturnOne, ReturnTwo
      choose_modes 1
    end
  end
end
