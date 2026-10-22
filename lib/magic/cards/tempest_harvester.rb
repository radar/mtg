module Magic
  module Cards
    TempestHarvester = Creature("Tempest Harvester") do
      cost generic: 1, blue: 1
      creature_type "Merfolk Wizard"
      power 2
      toughness 1
    end

    class TempestHarvester < Creature
      # When this creature enters, you get {E}{E}.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          gain_energy 2
        end
      end

      # {T}, Pay {E}: Draw a card, then discard a card.
      class LootAbility < Magic::ActivatedAbility
        costs "{T}, Pay {E}"

        def resolve!
          draw_card
          game.add_choice(Magic::Choice::Discard.new(player: controller)) if controller.hand.cards.any?
        end
      end

      def etb_triggers = [EntersTrigger]

      def activated_abilities = [LootAbility]
    end
  end
end
