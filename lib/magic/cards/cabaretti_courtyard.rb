module Magic
  module Cards
    CabarettiCourtyard = Card("Cabaretti Courtyard") do
      type "Land"

      enters_the_battlefield do
        actor.trigger_effect(:sacrifice, target: actor)
      end
    end

    class CabarettiCourtyard < Card
      class LandChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :battlefield, enters_tapped: true, filter: Filter[:basic_lands])
        end

        def choices
          super.by_any_type("Mountain", "Forest", "Plains")
        end

        def resolve!(targets:)
          super
          controller.gain_life(1)
        end
      end

      class LeavesTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor && event.to.graveyard?
        end

        def call
          game.add_choice(LandChoice.new(actor: actor))
        end
      end

      def ltb_triggers = [LeavesTrigger]
    end
  end
end