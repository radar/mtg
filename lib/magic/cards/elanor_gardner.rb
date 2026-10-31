module Magic
  module Cards
    ElanorGardner = Creature("Elanor Gardner") do
      cost generic: 3, green: 1
      legendary_creature_type "Halfling Scout"
      power 2
      toughness 4
    end

    class ElanorGardner < Creature
      # "When Elanor enters, create a Food token."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          create_token(token: Tokens::Food)
        end
      end

      # "At the beginning of your end step, if you sacrificed a Food this turn, you may search your library for a basic
      # land card, put that card onto the battlefield tapped, then shuffle." Declining (`game.skip_choice!`) still
      # shuffles.
      class LandChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :battlefield, enters_tapped: true, upto: 1, filter: Filter[:basic_lands],
                prompt: "Search your library for a basic land card. It enters the battlefield tapped.")
        end
      end

      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform? = controllers_end_step? && sacrificed_food?

        def call
          game.add_choice(LandChoice.new(actor: actor))
        end

        private

        def sacrificed_food?
          game.current_turn.events.any? do |event|
            event.is_a?(Events::PermanentSacrificed) && event.permanent.controller == controller &&
              event.permanent.type?("Food")
          end
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers = { Events::BeginningOfEndStep => EndStepTrigger }
    end
  end
end
