module Magic
  module Cards
    SerumVisionary = Creature("Serum Visionary") do
      cost generic: 2, blue: 1
      creature_type "Vedalken Wizard"
      power 2
      toughness 2
    end

    class SerumVisionary < Creature
      # "When this creature enters, draw a card, then scry 2."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          draw_card
          game.choices.add(Magic::Choice::Scry.new(actor: controller, amount: 2))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
