module Magic
  module Cards
    class ChandraHeartOfFire < Planeswalker
      card_name "Chandra, Heart of Fire"
      planeswalker "Chandra"
      cost generic: 3, red: 2
      loyalty 5

      # "+1: Discard your hand, then exile the top three cards of your library. Until end of turn, you may play
      # cards exiled this way."
      class LoyaltyAbility1 < LoyaltyAbility
        def loyalty_change = 1

        def resolve!
          [*controller.hand.cards].each(&:discard!)
          controller.library.cards.first(3).each do |card|
            card.exile!
            game.play_permissions.grant_until_end_of_turn(card:, player: controller)
          end
        end
      end

      # "+1: Chandra deals 2 damage to any target."
      class LoyaltyAbility2 < LoyaltyAbility
        def loyalty_change = 1

        def target_choices = game.any_target

        def single_target? = true

        def resolve!(target:)
          trigger_effect(:deal_damage, target:, damage: 2)
        end
      end

      # "-9: Search your graveyard and library for any number of red instant and/or sorcery cards, exile them, then
      # shuffle. You may cast them this turn. Add six {R}." Takes every one, which is never worse than taking fewer.
      class LoyaltyAbility3 < LoyaltyAbility
        def loyalty_change = -9

        def resolve!
          cards = [*controller.graveyard.cards, *controller.library.cards].select do |card|
            card.colors.include?(:red) && (card.instant? || card.sorcery?)
          end
          cards.each do |card|
            card.exile!
            game.play_permissions.grant_until_end_of_turn(card:, player: controller)
          end
          controller.shuffle!
          controller.add_mana(red: 6)
        end
      end

      def loyalty_abilities = [LoyaltyAbility1, LoyaltyAbility2, LoyaltyAbility3]
    end
  end
end
