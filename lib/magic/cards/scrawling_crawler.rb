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
          game.players.each { trigger_effect(:draw_cards, player: _1) }
        end
      end

      class CardDrawTrigger < TriggeredAbility
        def should_perform?
          opponent?
        end

        def call
          trigger_effect(:lose_life, target: that_player, life: 1)
        end
      end

      def event_handlers = { Events::BeginningOfUpkeep => UpkeepTrigger, Events::CardDraw => CardDrawTrigger }
    end
  end
end
