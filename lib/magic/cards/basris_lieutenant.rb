module Magic
  module Cards
    BasrisLieutenant = Creature("Basri's Lieutenant") do
      type "Creature -- Human Knight"
      cost generic: 3, white: 1
      power 3
      toughness 4
      keywords :vigilance
    end

    class BasrisLieutenant < Creature
      def protected_from?(card)
        card.multi_colored?
      end

      def entered_the_battlefield!
        add_effect(
          "AddCounter",
          counter_type: Counters::Plus1Plus1,
          choices: controller.creatures,
        )
      end

      def receive_notification(event)
        super

        case event
        when Events::LeavingZone
          return unless event.death?
          return unless event.card.controller == controller

          if event.card.counters.any? { |counter| counter.is_a?(Counters::Plus1Plus1) }
            token = Tokens::Knight.new(game: game, controller: controller)
            token.resolve!
          end
        end

      end
    end
  end
end
