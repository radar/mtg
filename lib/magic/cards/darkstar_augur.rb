module Magic
  module Cards
    DarkstarAugur = Creature("Darkstar Augur") do
      cost generic: 2, black: 1
      creature_type("Bat Warlock")
      keywords :flying
      power 2
      toughness 3
      offspring black: 1
    end

    class DarkstarAugur < Creature
      # At the beginning of your upkeep, reveal the top card of your library and put that card into your
      # hand. You lose life equal to its mana value.
      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def call
          top = controller.library.first or return

          trigger_effect(:reveal_cards, target: [top])
          top.move_to_hand!
          lose_life(controller, top.mana_value) if top.mana_value.positive?
        end
      end

      def event_handlers = super.merge(Events::BeginningOfUpkeep => UpkeepTrigger)
    end
  end
end
