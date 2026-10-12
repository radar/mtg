module Magic
  module Cards
    StormfistCrusader = Creature("Stormfist Crusader") do
      cost black: 1, red: 1
      creature_type "Human Knight"
      keywords :menace
      power 2
      toughness 2
    end

    class StormfistCrusader < Creature
      # "At the beginning of your upkeep, each player draws a card and loses 1 life."
      class UpkeepTrigger < TriggeredAbility
        def should_perform? = event.player == controller

        def call
          game.players.each do |player|
            player.draw!
            actor.trigger_effect(:lose_life, target: player, life: 1)
          end
        end
      end

      def event_handlers = { Events::BeginningOfUpkeep => UpkeepTrigger }
    end
  end
end
