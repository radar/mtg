module Magic
  module Cards
    class AbhorrentOculus < Creature
      card_name "Abhorrent Oculus"
      creature_type "Eye"
      cost generic: 2, blue: 1
      keywords :flying
      power 5
      toughness 5

      # "As an additional cost to cast this spell, exile six cards from your graveyard."
      def additional_costs = [Costs::ExileFromGraveyard.new(self, count: 6)]

      # "At the beginning of each opponent's upkeep, manifest dread."
      class UpkeepTrigger < TriggeredAbility
        def should_perform?
          opponents.include?(event.player)
        end

        def call
          Magic::Choice::ManifestDread.perform(actor: actor)
        end
      end

      def event_handlers = { Events::BeginningOfUpkeep => UpkeepTrigger }
    end
  end
end
