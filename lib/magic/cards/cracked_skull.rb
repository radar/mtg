module Magic
  module Cards
    CrackedSkull = Aura("Cracked Skull") do
      cost generic: 2, black: 1
    end

    class CrackedSkull < Aura
      enchant "Creature"

      def target_choices
        battlefield.creatures
      end

      # "You may choose a nonland card from it. That player discards that card."
      class DiscardChoice < Magic::Choice::May
        class CardChoice < Magic::Choice
          def initialize(actor:, player:)
            super(actor:)
            @player = player
          end

          def choices = @player.hand.cards.reject(&:land?)

          def resolve!(target:) = target.discard!
        end

        def initialize(actor:, player:)
          super(actor:)
          @player = player
        end

        def resolve!
          game.choices.add(CardChoice.new(actor:, player: @player))
        end
      end

      # "When this Aura enters, look at target player's hand. You may choose a nonland card from it. That player
      # discards that card."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class PlayerChoice < Magic::Choice::Targeted
          def choices = game.players

          def choice_amount = 1

          def resolve!(target:)
            reveal_cards(target.hand.cards)
            return if target.hand.cards.all?(&:land?)

            game.choices.add(DiscardChoice.new(actor:, player: target))
          end
        end

        def call
          game.add_choice(PlayerChoice.new(actor:))
        end
      end

      def etb_triggers = [EntersTrigger]

      # "When enchanted creature is dealt damage, destroy it."
      class DamagedTrigger < TriggeredAbility
        def should_perform?
          event.target == actor.attached_to && event.damage.positive?
        end

        def call
          destroy(actor.attached_to)
        end
      end

      def event_handlers = { Events::DamageDealt => DamagedTrigger }
    end
  end
end
