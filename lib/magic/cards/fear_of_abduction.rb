module Magic
  module Cards
    class FearOfAbduction < Creature
      card_name "Fear of Abduction"
      enchantment_creature_type("Nightmare")
      cost generic: 4, white: 2
      keywords :flying
      power 5
      toughness 5

      # "As an additional cost to cast this spell, exile a creature you control."
      def additional_costs = [Costs::ExileCreature.new(self)]

      class ExileChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures.not_controlled_by(controller)

        def choice_amount = 1

        def resolve!(target:)
          card = target.card
          game.add_effect(Effects::ExilePermanent.new(source: actor, target: target))
          actor.exiled_cards << card unless target.token?
        end
      end

      # "When this creature enters, exile target creature an opponent controls."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          choice = ExileChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # "When this creature leaves the battlefield, put each card exiled with it into its owner's hand."
      class LeavesTrigger < TriggeredAbility::LeaveTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          actor.exiled_cards.to_a.each { |card| card.move_to_hand!(card.owner) if card.zone&.exile? }
        end
      end

      def etb_triggers = [EntersTrigger]
      def ltb_triggers = [LeavesTrigger]
    end
  end
end
