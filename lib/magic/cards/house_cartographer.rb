module Magic
  module Cards
    HouseCartographer = Creature("House Cartographer") do
      cost generic: 1, green: 1
      creature_type "Human Scout Survivor"
      power 2
      toughness 2
    end

    class HouseCartographer < Creature
      # "Survival — At the beginning of your second main phase, if this creature is tapped, reveal cards from the top
      # of your library until you reveal a land card. Put that card into your hand and the rest on the bottom of your
      # library in a random order."
      class SurvivalTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && actor.tapped?
        end

        def call
          library = controller.library
          found = library.find { _1.type?("Land") }
          revealed = library.take_while { !_1.equal?(found) }
          trigger_effect(:reveal_cards, target: [*revealed, found].compact)
          found&.move_to_hand!
          revealed.shuffle.each do |card|
            library.remove(card)
            library.push(card)
          end
        end
      end

      def event_handlers = { Events::SecondMainPhase => SurvivalTrigger }
    end
  end
end
