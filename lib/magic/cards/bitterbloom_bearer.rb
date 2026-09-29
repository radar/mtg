module Magic
  module Cards
    class BitterbloomBearer < Creature
      card_name "Bitterbloom Bearer"
      cost black: 2
      creature_type "Faerie Rogue"
      power 1
      toughness 1
      keywords :flash, :flying

      FaerieToken = Token.create "Faerie" do
        creature_type "Faerie"
        power 1
        toughness 1
        colors :blue, :black
        keywords :flying
      end

      # "At the beginning of your upkeep, you lose 1 life and create a 1/1 blue and black Faerie
      # creature token with flying."
      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def call
          trigger_effect(:lose_life, target: controller, life: 1)
          trigger_effect(:create_token, token_class: FaerieToken)
        end
      end

      def event_handlers = { Events::BeginningOfUpkeep => UpkeepTrigger }
    end
  end
end
