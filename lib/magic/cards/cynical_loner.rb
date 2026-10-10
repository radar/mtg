module Magic
  module Cards
    CynicalLoner = Creature("Cynical Loner") do
      cost generic: 1, black: 1
      creature_type "Human Survivor"
      power 3
      toughness 1
    end

    class CynicalLoner < Creature
      # "This creature can't be blocked by Glimmers."
      def can_be_blocked?(blocker) = !blocker.type?("Glimmer")

      # "Survival — At the beginning of your second main phase, if this creature is tapped, you may search your library
      # for a card, put it into your graveyard, then shuffle."
      class SurvivalTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && actor.tapped?
        end

        def call
          game.search_library(actor, find: ->(_card) { true }, to: :graveyard)
        end
      end

      def event_handlers = { Events::SecondMainPhase => SurvivalTrigger }
    end
  end
end
