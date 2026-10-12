module Magic
  module Cards
    ThreatsAroundEveryCorner = Enchantment("Threats Around Every Corner") do
      cost generic: 3, green: 1
    end

    class ThreatsAroundEveryCorner < Enchantment
      # "When this enchantment enters, manifest dread."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          Magic::Choice::ManifestDread.perform(actor: actor)
        end
      end

      # "Whenever a face-down permanent you control enters, search your library for a basic land card, put it onto the
      # battlefield tapped, then shuffle."
      class FaceDownEntersTrigger < TriggeredAbility
        def should_perform?
          event.permanent.face_down? && event.permanent.controller == controller
        end

        def call
          game.search_library(actor, find: :basic_lands, to: :battlefield, tapped: true)
        end
      end

      def etb_triggers = [EntersTrigger]
      def event_handlers = { Events::EnteredTheBattlefield => FaceDownEntersTrigger }
    end
  end
end
