module Magic
  module Cards
    WinterMisanthropicGuide = Creature("Winter, Misanthropic Guide") do
      cost "{1}{B}{R}{G}"
      legendary_creature_type "Human Warlock"
      ward generic: 2
      power 3
      toughness 4
    end

    class WinterMisanthropicGuide < Creature
      # "At the beginning of your upkeep, each player draws two cards."
      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def call
          game.players.each { trigger_effect(:draw_cards, player: _1, number_to_draw: 2) }
        end
      end

      # "Delirium — As long as there are four or more card types among cards in your graveyard, each opponent's maximum
      # hand size is equal to seven minus the number of those card types." (`Player#maximum_hand_size` asks the
      # opponents' permanents.)
      def opponents_maximum_hand_size_reduction
        graveyard = controller.graveyard
        graveyard.delirium? ? graveyard.card_type_count : 0
      end

      def event_handlers
        { Events::BeginningOfUpkeep => UpkeepTrigger }
      end
    end
  end
end
