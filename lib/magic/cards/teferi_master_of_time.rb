module Magic
  module Cards
    class TeferiMasterOfTime < Planeswalker
      card_name "Teferi, Master of Time"
      planeswalker "Teferi"
      cost generic: 2, blue: 2
      loyalty 3

      class LoyaltyAbility1 < LoyaltyAbility
        def instant_speed? = true

        def loyalty_change
          1
        end

        def resolve!
          trigger_effect(:draw_cards)
          add_choice(:discard)
        end
      end

      class LoyaltyAbility2 < LoyaltyAbility
        def instant_speed? = true

        def loyalty_change
          -3
        end

        def target_choices
          battlefield.creatures.not_controlled_by(controller)
        end

        def resolve!(target:)
          trigger_effect(:phase_out, target: target)
        end
      end

      class LoyaltyAbility3 < LoyaltyAbility
        def instant_speed? = true

        def loyalty_change
          -10
        end

        def resolve!
          2.times { game.take_additional_turn }
        end
      end

      def loyalty_abilities = [LoyaltyAbility1, LoyaltyAbility2, LoyaltyAbility3]
    end
  end
end
