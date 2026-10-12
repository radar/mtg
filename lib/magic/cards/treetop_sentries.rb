module Magic
  module Cards
    TreetopSentries = Creature("Treetop Sentries") do
      cost generic: 3, green: 1
      creature_type("Squirrel Archer")
      keywords :reach
      power 2
      toughness 4
    end

    class TreetopSentries < Creature
      # When this creature enters, you may forage. If you do, draw a card.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class ForageChoice < Magic::Choice::Forage
          def after_forage
            trigger_effect(:draw_cards, number_to_draw: 1)
          end
        end

        class MayChoice < Magic::Choice::May
          def resolve!
            choice = ForageChoice.new(actor: actor)
            game.choices.add(choice) if choice.possible?
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
