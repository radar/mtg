module Magic
  module Cards
    MarinaVendrellsGrimoire = Artifact("Marina Vendrell's Grimoire") do
      legendary_artifact
      cost generic: 5, blue: 1
    end

    class MarinaVendrellsGrimoire < Artifact
      # "You have no maximum hand size and don't lose the game for having 0 or less life."
      def no_maximum_hand_size? = true
      def prevents_losing_at_zero_life? = true

      # "When Marina Vendrell's Grimoire enters, if you cast it, draw five cards."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          this? && actor.cast?
        end

        def call
          draw_cards(5)
        end
      end

      # "Whenever you gain life, draw that many cards."
      class LifeGainTrigger < TriggeredAbility
        def should_perform?
          event.player == controller
        end

        def call
          draw_cards(event.life)
        end
      end

      # "Whenever you lose life, discard that many cards. Then if you have no cards in hand, you lose the game."
      # Discarding the whole hand (or the last of it) leaves it empty; otherwise the player picks the cards.
      class LifeLossTrigger < TriggeredAbility
        def should_perform?
          event.player == controller && event.life.positive?
        end

        def call
          hand = controller.hand
          if hand.count <= event.life
            hand.cards.to_a.dup.each(&:move_to_graveyard!)
            lose_game controller
          else
            game.add_choice(Magic::Choice::Discard.new(player: controller, actor:, amount: event.life))
          end
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers
        {
          Events::LifeGain => LifeGainTrigger,
          Events::LifeLoss => LifeLossTrigger
        }
      end
    end
  end
end
