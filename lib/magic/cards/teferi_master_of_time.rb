module Magic
  module Cards
    class TeferiMasterOfTime < Planeswalker
      NAME = "Teferi, Master of Time"
      TYPE_LINE = "Legendary Planeswalker -- Teferi"
      cost generic: 2, blue: 2
      loyalty 3

      class LoyaltyAbility1 < LoyaltyAbility
        def loyalty_change
          1
        end

        def resolve!
          trigger_effect(:draw_cards)
          add_choice(:discard)
        end
      end

      class LoyaltyAbility2 < LoyaltyAbility
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
