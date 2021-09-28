module Magic
  class Game
    class Step
      include AASM
      attr_reader :game

      aasm do
        state :untap, initial: true, after_enter: :untap_active_player_permanents
        state :upkeep
        state :draw, after_enter: -> { game.active_player.draw! }
        state :first_main
        state :beginning_of_combat
        state :combat
        state :end_of_combat
        state :second_main
        state :end_of_turn
        state :cleanup

        event :next do
          transitions from: :untap, to: :upkeep
          transitions from: :upkeep, to: :draw
          transitions from: :draw, to: :first_main
          transitions from: :first_main, to: :beginning_of_combat
          transitions from: :beginning_of_combat, to: :combat
          transitions from: :combat, to: :end_of_combat
          transitions from: :end_of_combat, to: :second_main
          transitions from: :second_main, to: :end_of_turn
          transitions from: :end_of_turn, to: :cleanup
          transitions from: :cleanup, to: :untap, after: -> { game.change_active_player }
        end
      end

      def initialize(game:)
        @game = game
      end

      def untap_active_player_permanents
        game.battlefield.untap { |cards| cards.controlled_by(game.active_player) }
      end

    end
  end
end
