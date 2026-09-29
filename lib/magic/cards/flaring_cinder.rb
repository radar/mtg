module Magic
  module Cards
    class FlaringCinder < Creature
      card_name "Flaring Cinder"
      cost "{1}{U/R}{U/R}"
      creature_type "Elemental Sorcerer"
      power 3
      toughness 2

      class DiscardChoice < Magic::Choice::Discard
        def resolve!(card:)
          super
          trigger_effect(:draw_card)
        end
      end

      class MayDiscardChoice < Magic::Choice::May
        def resolve!
          game.choices.add(DiscardChoice.new(actor:, player: controller)) if hand.any?
        end
      end

      # "When this creature enters ..., you may discard a card. If you do, draw a card."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(MayDiscardChoice.new(actor:))
        end
      end

      # "... and whenever you cast a spell with mana value 4 or greater, you may discard a card. If
      # you do, draw a card."
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform? = you? && spell.mana_value >= 4

        def call
          game.choices.add(MayDiscardChoice.new(actor:))
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers = { Events::SpellCast => SpellCastTrigger }
    end
  end
end
