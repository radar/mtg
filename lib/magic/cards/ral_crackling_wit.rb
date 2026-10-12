module Magic
  module Cards
    class RalCracklingWit < Planeswalker
      card_name "Ral, Crackling Wit"
      planeswalker "Ral"
      cost generic: 2, blue: 1, red: 1
      loyalty 4

      # Whenever you cast a noncreature spell, put a loyalty counter on Ral.
      class CastTrigger < TriggeredAbility::SpellCast
        def should_perform? = event.player == controller && !spell.creature?

        def call
          actor.change_loyalty!(1)
        end
      end

      def event_handlers = super.merge(Events::SpellCast => CastTrigger)

      # +1: Create a 1/1 blue and red Otter creature token with prowess.
      class LoyaltyAbility1 < LoyaltyAbility
        def loyalty_change = 1
        def description = "Create a 1/1 blue and red Otter creature token with prowess."

        def resolve!
          trigger_effect(:create_token, token_class: Tokens::Otter)
        end
      end

      # -3: Draw three cards, then discard two cards.
      class LoyaltyAbility2 < LoyaltyAbility
        class DiscardTwo < Magic::Choice
          def choices = controller.hand

          def resolve!(discarded:)
            raise ArgumentError, "discard exactly two cards" unless discarded.size == [2, controller.hand.count].min

            discarded.each(&:discard!)
          end
        end

        def loyalty_change = -3
        def description = "Draw three cards, then discard two cards."

        def resolve!
          draw_cards(3)
          game.choices.add(DiscardTwo.new(actor: source))
        end
      end

      # -10: Draw three cards. You get an emblem with "Instant and sorcery spells you cast have storm."
      class StormEmblem < Magic::Emblem
        def receive_event(event)
          return unless event.is_a?(Events::SpellCast) && event.player == owner && (event.spell.instant? || event.spell.sorcery?)

          copies = game.current_turn.spells_cast.count - 1
          return unless copies.positive?

          Magic::CopyEffect.resolve_with_choice!(actor: self, receiver: event.spell, targets: event.targets, copies: copies)
        end
      end

      class LoyaltyAbility3 < LoyaltyAbility
        def loyalty_change = -10
        def description = "Draw three cards. You get an emblem with \"Instant and sorcery spells you cast have storm.\""

        def resolve!
          draw_cards(3)
          game.add_emblem(StormEmblem.new(game: game, owner: controller))
        end
      end

      def loyalty_abilities = [LoyaltyAbility1, LoyaltyAbility2, LoyaltyAbility3]
    end
  end
end
