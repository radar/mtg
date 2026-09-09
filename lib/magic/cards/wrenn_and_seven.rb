module Magic
  module Cards
    class WrennAndSeven < Planeswalker
      card_name "Wrenn and Seven"
      planeswalker "Wrenn"
      cost generic: 3, green: 2
      loyalty 4

      class LoyaltyAbility1 < LoyaltyAbility
        def loyalty_change = 1

        def resolve!
          controller.library.first(4).each do |card|
            if card.land?
              controller.library.remove(card)
              controller.hand.add(card)
            end
          end
        end
      end

      class LoyaltyAbility2 < LoyaltyAbility
        def loyalty_change = 0
      end

      class TreefolkToken < Token
      end

      class LoyaltyAbility3 < LoyaltyAbility
        def loyalty_change = -3

        def resolve!
          actor.trigger_effect(:create_token, token_class: TreefolkToken)
        end
      end

      class LoyaltyAbility4 < LoyaltyAbility
        def loyalty_change = -8
      end

      def loyalty_abilities = [LoyaltyAbility1, LoyaltyAbility2, LoyaltyAbility3, LoyaltyAbility4]
    end
  end
end