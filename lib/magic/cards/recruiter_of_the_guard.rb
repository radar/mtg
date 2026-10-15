module Magic
  module Cards
    RecruiterOfTheGuard = Creature("Recruiter of the Guard") do
      cost generic: 2, white: 1
      creature_type("Human Soldier")
      power 1
      toughness 1
    end

    class RecruiterOfTheGuard < Creature
      # "When this creature enters, you may search your library for a creature card with toughness 2 or less, reveal it,
      # put it into your hand, then shuffle."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class MayChoice < Magic::Choice::May
          def resolve!
            game.search_library(
              actor,
              find: ->(card) { card.creature? && card.respond_to?(:base_toughness) && card.base_toughness <= 2 },
              to: :hand,
              reveal: true,
              prompt: "Search your library for a creature card with toughness 2 or less. Put it into your hand.",
            )
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
