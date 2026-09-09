module Magic
  module Cards
    class CalixDestinysHand < Planeswalker
      card_name "Calix, Destiny's Hand"
      planeswalker "Calix"
      cost generic: 2, green: 1, white: 1
      loyalty 4

      class LoyaltyAbility1 < LoyaltyAbility
        def loyalty_change = 1

        def resolve!
          cards = controller.library.first(4)
          target = cards.find(&:enchantment?)
          controller.library.remove(target) if target
          controller.hand.add(target) if target
        end
      end

      class LoyaltyAbility2 < LoyaltyAbility
        def loyalty_change = -3

        def target_choices
          game.battlefield.not_controlled_by(controller).by_any_type(T::Creature, T::Enchantment)
        end

        def resolve!(target:)
          target.exile!
        end
      end

      class LoyaltyAbility3 < LoyaltyAbility
        def loyalty_change = -7

        def resolve!
          controller.graveyard.cards.enchantments.each(&:resolve!)
        end
      end

      def loyalty_abilities = [LoyaltyAbility1, LoyaltyAbility2, LoyaltyAbility3]
    end
  end
end