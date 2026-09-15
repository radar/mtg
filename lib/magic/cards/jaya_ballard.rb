module Magic
  module Cards
    class JayaBallard < Planeswalker
      card_name "Jaya Ballard"
      planeswalker "Jaya"
      cost "{2}{R}{R}{R}"
      loyalty 5

      class DiscardDrawChoice < Magic::Choice
        def choices = controller.hand

        def resolve!(discarded: [])
          discarded.each(&:discard!)
          trigger_effect(:draw_cards, number_to_draw: discarded.size) if discarded.any?
        end
      end

      class LoyaltyAbility1 < LoyaltyAbility
        def loyalty_change = 1

        def resolve!
          # "Spend this mana only to cast instant or sorcery spells" is not
          # enforced -- matches this codebase's existing looseness around
          # restricted-use mana (e.g. PlazaOfHeroes).
          controller.add_mana(red: 3)
        end
      end

      class LoyaltyAbility2 < LoyaltyAbility
        def loyalty_change = 1

        def resolve!
          game.choices.add(DiscardDrawChoice.new(actor: source))
        end
      end

      class Emblem < Magic::Emblem
        def permits_casting_from_graveyard?(card) = card.instant? || card.sorcery?
        def exiles_after_graveyard_cast?(_card) = true
      end

      class LoyaltyAbility3 < LoyaltyAbility
        def loyalty_change = -8

        def resolve!
          game.add_emblem(Emblem.new(game: game, owner: controller))
        end
      end

      def loyalty_abilities = [LoyaltyAbility1, LoyaltyAbility2, LoyaltyAbility3]
    end
  end
end
