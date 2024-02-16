module Magic
  module Cards
    class DireFleetWarmonger < Creature
      card_name "Dire Fleet Warmonger"
      type "Creature -- Orc Pirate"
      cost generic: 1, black: 1, red: 1
      power 3
      toughness 3

      class Choice < Magic::Choice
        def target_choices
          other_creatures_you_control
        end

        def resolve!(choice:)
          trigger_effect(:sacrifice, target: choice)
          trigger_effect(:modify_power_toughness, power: 2, toughness: 2, target: actor)
          trigger_effect(:grant_keyword, keyword: :trample, target: actor)
        end
      end

      def event_handlers
      {
        Events::BeginningOfCombat => -> (receiver, event) do
          return unless event.active_player == owner

          game.choices.add(DireFleetWarmonger::Choice.new(actor: receiver))


        end
      }
    end
  end
end
end
