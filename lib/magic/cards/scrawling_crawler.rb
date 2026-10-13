module Magic
  module Cards
    ScrawlingCrawler = Creature("Scrawling Crawler") do
      cost generic: 3
      artifact_creature_type("Phyrexian Construct")
      power 3
      toughness 2
    end

    class ScrawlingCrawler < Creature
      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def call
          game.players.each { draw_card(player: _1) }
        end
      end

      class CardDrawTrigger < TriggeredAbility
        def should_perform?
          opponent?
        end

        def call
          lose_life(that_player, 1)
        end
      end

      def event_handlers = { Events::BeginningOfUpkeep => UpkeepTrigger, Events::CardDraw => CardDrawTrigger }
    end
  end
end
