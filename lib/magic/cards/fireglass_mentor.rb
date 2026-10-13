module Magic
  module Cards
    FireglassMentor = Creature("Fireglass Mentor") do
      cost black: 1, red: 1
      creature_type("Lizard Warlock")
      power 2
      toughness 1
    end

    class FireglassMentor < Creature
      # At the beginning of your second main phase, if an opponent lost life this turn, exile the top two
      # cards of your library. Choose one of them. Until end of turn, you may play that card.
      class SecondMainTrigger < TriggeredAbility
        class PlayChoice < Magic::Choice::Targeted
          def initialize(actor:, cards:)
            @cards = cards
            super(actor: actor)
          end

          def choices = @cards

          def choice_amount = 1

          def resolve!(target:)
            game.play_permissions.grant_until_end_of_turn(card: target, player: controller)
          end
        end

        def should_perform?
          event.active_player == controller && game.current_turn.opponent_lost_life?(controller)
        end

        def call
          cards = controller.library.first(2)
          cards.each { exile_target(_1) }
          game.choices.add(PlayChoice.new(actor: actor, cards: cards)) if cards.any?
        end
      end

      def event_handlers = super.merge(Events::SecondMainPhase => SecondMainTrigger)
    end
  end
end
