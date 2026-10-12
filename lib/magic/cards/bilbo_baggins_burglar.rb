module Magic
  module Cards
    BilboBagginsBurglar = Creature("Bilbo Baggins, Burglar") do
      cost generic: 2, blue: 1
      legendary_creature_type("Halfling Rogue")
      power 2
      toughness 1
    end

    class BilboBagginsBurglar < Creature
      # "When Bilbo Baggins enters, draw a card."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      def etb_triggers = [EntersTrigger]

      # Take a Glance {U}, Sorcery -- Adventure: "Scry 2."
      adventure blue: 1

      def adventure_resolve!(**)
        game.choices.add(Magic::Choice::Scry.new(actor: self, amount: 2))
      end
    end
  end
end
