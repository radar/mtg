module Magic
  module Cards
    CryptLurker = Creature("Crypt Lurker") do
      cost generic: 3, black: 1
      creature_type "Horror"
      power 3
      toughness 4
    end

    class CryptLurker < Creature
      # "You may sacrifice a creature or discard a creature card. If you do, draw a card." Declining is
      # `game.skip_choice!`; the answer is the creature to sacrifice or the creature card in hand to discard.
      class SacrificeOrDiscardChoice < Magic::Choice::Targeted
        def choices = [*controller.creatures, *controller.hand.cards.select(&:creature?)]

        def choice_amount = 1

        def targets? = false

        def resolve!(target:)
          target.is_a?(Magic::Permanent) ? target.sacrifice! : target.discard!
          trigger_effect(:draw_card)
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.add_choice(SacrificeOrDiscardChoice.new(actor:))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
