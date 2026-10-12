module Magic
  module Cards
    class MolderingGymWeightRoom < Room
      class MolderingGym < Room::Door
        card_name "Moldering Gym"
        cost generic: 2, green: 1

        # "When you unlock this door, search your library for a basic land card, put it onto the battlefield tapped, then
        # shuffle."
        when_unlocked do
          game.search_library(actor, find: :basic_lands, to: :battlefield, tapped: true)
        end
      end

      class WeightRoom < Room::Door
        card_name "Weight Room"
        cost generic: 5, green: 1

        # Manifests dread, then puts three +1/+1 counters on that creature.
        class ManifestChoice < Magic::Choice::ManifestDread
          def manifested(permanent)
            add_counter("+1/+1", to: permanent, amount: 3)
          end
        end

        # "When you unlock this door, manifest dread, then put three +1/+1 counters on that creature."
        class UnlockedTrigger < Room::UnlockTrigger
          def call
            ManifestChoice.perform(actor: actor)
          end
        end

        def unlock_triggers = [UnlockedTrigger]
      end

      doors MolderingGym, WeightRoom
    end
  end
end
