module Magic
  module Cards
    GrimServant = Creature("Grim Servant") do
      cost generic: 3, black: 1
      creature_type "Zombie Warlock"
      power 3
      toughness 2
      keywords :menace
    end

    class GrimServant < Creature
      # "When this creature enters, search your library for a card with mana value less than or equal to your devotion
      # to black, reveal it, put it into your hand, then shuffle. You lose 3 life."
      class SearchChoice < Magic::Choice::SearchLibrary
        def resolve!(**args)
          super(**args)
          lose_life(controller, 3)
        end

        def decline!
          super
          lose_life(controller, 3)
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          devotion = controller.devotion(:black)
          game.add_choice(
            SearchChoice.new(
              actor: actor, to_zone: :hand, reveal: true, upto: 1,
              filter: ->(card) { card.mana_value <= devotion },
              prompt: "Search for a card with mana value #{devotion} or less."
            )
          )
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
