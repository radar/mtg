module Magic
  module Cards
    MornsongAria = Enchantment("Mornsong Aria") do
      type T::Super::Legendary, T::Enchantment
      cost generic: 1, black: 2
    end

    class MornsongAria < Enchantment
      # Players can't draw cards or gain life.
      class NoDrawingOrLifeGain < StaticAbility
        def prevents_drawing?(_player) = true

        def prevents_life_gain?(_player) = true
      end

      def static_abilities = [NoDrawingOrLifeGain]

      # "... searches their library for a card, puts it into their hand, then shuffles." The
      # searching player is whoever's draw step it is, not Mornsong Aria's controller.
      class SearchChoice < Magic::Choice
        attr_reader :player

        def initialize(actor:, player:)
          super(actor: actor)
          @player = player
        end

        def controller = player

        def choices = player.library.to_a

        # targets: the card to take, or none if the library is empty.
        def resolve!(targets: [])
          Array(targets).first(1).each do |card|
            raise ArgumentError, "#{card.name} is not in #{player.name}'s library" unless choices.include?(card)

            card.move_to_hand!(player)
          end
          player.shuffle!
        end
      end

      # At the beginning of each player's draw step, that player loses 3 life, searches their
      # library for a card, puts it into their hand, then shuffles.
      class DrawStepTrigger < TriggeredAbility
        def call
          player = event.player
          trigger_effect(:lose_life, target: player, life: 3)
          game.add_choice(SearchChoice.new(actor: actor, player: player))
        end
      end

      def event_handlers = { Events::DrawStep => DrawStepTrigger }
    end
  end
end
