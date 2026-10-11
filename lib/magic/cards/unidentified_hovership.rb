module Magic
  module Cards
    class UnidentifiedHovership < Vehicle
      card_name "Unidentified Hovership"
      cost generic: 1, white: 2
      keywords :flying
      power 2
      toughness 2
      crew 1

      class ExileChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures.select { _1.toughness <= 5 }

        def choice_amount = 0..1

        def resolve!(target:)
          game.add_effect(Effects::ExilePermanent.new(source: actor, target: target))
          actor.exiled_cards << target.card
        end
      end

      # "When this Vehicle enters, exile up to one target creature with toughness 5 or less."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          choice = ExileChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # "When this Vehicle leaves the battlefield, the exiled card's owner manifests dread."
      class LeavesTrigger < TriggeredAbility::LeaveTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          actor.exiled_cards.map(&:owner).uniq.each do |owner|
            Magic::Choice::ManifestDread.perform(actor: actor, player: owner)
          end
        end
      end

      def etb_triggers = [EntersTrigger]
      def ltb_triggers = [LeavesTrigger]
    end
  end
end
