module Magic
  module Cards
    TroopOfPonies = Creature("Troop of Ponies") do
      cost generic: 2
      creature_type "Horse"
      power 2
      toughness 1
    end

    class TroopOfPonies < Creature
      # "Search your library for up to two basic land cards, reveal them, put one onto the battlefield tapped and
      # the other into your hand, then shuffle." Resolve with the two cards: the first goes to the battlefield.
      class SearchChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :hand, upto: 2, reveal: true, filter: Filter[:basic_lands])
        end

        def resolve!(targets:)
          raise ArgumentError, "can search for at most 2 cards, got #{targets.size}" if targets.size > 2

          trigger_effect(:reveal_cards, target: targets) if targets.any?
          battlefield_land, hand_land = targets
          battlefield_land&.resolve!(enters_tapped: true)
          hand_land&.move_to_hand!
          controller.shuffle!
        end
      end

      class SearchAbility < Magic::ActivatedAbility
        costs "{2}, {T}, Sacrifice {this}"

        def resolve!
          game.choices.add(SearchChoice.new(actor: source))
        end
      end

      def activated_abilities = [SearchAbility]
    end
  end
end
