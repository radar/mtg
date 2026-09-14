module Magic
  module Cards
    ValakutExploration = Enchantment("Valakut Exploration") do
      cost generic: 2, red: 1
    end

    class ValakutExploration < Enchantment
      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform?
          you?
        end

        def call
          card = controller.library.first
          return unless card

          actor.trigger_effect(:exile, target: card)
          actor.exiled_cards << card
        end
      end

      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step? && actor.exiled_cards.any?
        end

        def call
          count = actor.exiled_cards.count

          actor.exiled_cards.each do |card|
            actor.remove_from_exile(card)
            card.move_to_graveyard!(card.owner)
          end

          opponents.each { |opponent| actor.trigger_effect(:deal_damage, damage: count, target: opponent) }
        end
      end

      def event_handlers
        {
          Events::Landfall => LandfallTrigger,
          Events::BeginningOfEndStep => EndStepTrigger
        }
      end
    end
  end
end
