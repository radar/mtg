module Magic
  module Cards
    ExtravagantReplication = Enchantment("Extravagant Replication") do
      cost generic: 4, blue: 2
    end

    class ExtravagantReplication < Enchantment
      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        class TargetChoice < Magic::Choice::Targeted
          def choices
            (battlefield.controlled_by(controller).nonland - [actor])
          end

          def choice_amount = 1

          def resolve!(target:)
            Permanent.resolve(game: game, owner: controller, card: target.copiable_card, token: true, copy: true, cast: false)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::BeginningOfUpkeep => UpkeepTrigger }
    end
  end
end
