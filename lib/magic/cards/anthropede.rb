module Magic
  module Cards
    Anthropede = Creature("Anthropede") do
      cost generic: 3, green: 1
      creature_type "Insect"
      keywords :reach
      power 3
      toughness 4
    end

    class Anthropede < Creature
      # "...When you do, destroy target Room."
      class DestroyRoomChoice < Magic::Choice::Targeted
        def prompt = "Destroy target Room."

        def choices = battlefield.permanents.select(&:room?)

        def choice_amount = 1

        def resolve!(target:)
          destroy(target)
        end
      end

      # "When this creature enters, you may discard a card or pay {2}." Answer with `discard: card`, or `pay: true` (the
      # mana is paid automatically) or `payment: {...}` (the mana to pay); declining does nothing.
      class CostChoice < Magic::Choice::May
        def prompt = "Discard a card or pay {2}?"

        def choices = hand.cards.to_a

        def resolve!(discard: nil, pay: false, payment: nil)
          if discard
            raise ArgumentError, "#{discard.name} is not in your hand" unless choices.include?(discard)

            discard.discard!
          elsif pay || payment
            cost = Costs::Mana.new(generic: 2)
            raise Costs::Mana::CannotPay.new(cost.cost, chooser) unless cost.can_pay?(chooser)

            if payment
              cost.pay!(player: chooser, payment: payment)
            else
              cost.auto_pay(player: chooser)
              cost.finalize!(chooser)
            end
          else
            return
          end

          destroy = DestroyRoomChoice.new(actor: actor)
          game.add_choice(destroy) if destroy.choices.any?
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          game.choices.add(CostChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
