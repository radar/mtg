module Magic
  module Cards
    HeapedHarvest = Card("Heaped Harvest") do
      type T::Artifact, "Food"
      cost generic: 2, green: 1
    end

    class HeapedHarvest < Card
      # When this artifact enters and when you sacrifice it, you may search your library for a basic land card,
      # put it onto the battlefield tapped, then shuffle.
      class SearchTrigger < TriggeredAbility
        def call
          game.choices.add(Magic::Choice::SearchLibrary.new(actor: actor, filter: Filter[:basic_lands], to_zone: :battlefield, enters_tapped: true))
        end
      end

      class SacrificedTrigger < SearchTrigger
        def should_perform? = event.permanent == actor
      end

      def etb_triggers = [SearchTrigger]

      def event_handlers = super.merge(Events::PermanentSacrificed => SacrificedTrigger)

      def activated_abilities = [Tokens::Food::GainLife]
    end
  end
end
