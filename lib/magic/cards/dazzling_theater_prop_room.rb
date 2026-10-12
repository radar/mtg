module Magic
  module Cards
    class DazzlingTheaterPropRoom < Room
      class DazzlingTheater < Room::Door
        card_name "Dazzling Theater"
        cost generic: 3, white: 1

        # "Creature spells you cast have convoke."
        class GrantConvoke < StaticAbility
          def grants_convoke?(card, player)
            card.creature? && player == controller
          end
        end

        def static_abilities = [GrantConvoke]
      end

      class PropRoom < Room::Door
        card_name "Prop Room"
        cost generic: 2, white: 1

        # "Untap each creature you control during each other player's untap step."
        class UntapDuringOtherUntapSteps < StaticAbility
          def untaps_during_untap_step_of?(permanent, active_player)
            active_player != controller && permanent.creature? && permanent.controller == controller
          end
        end

        def static_abilities = [UntapDuringOtherUntapSteps]
      end

      doors DazzlingTheater, PropRoom
    end
  end
end
