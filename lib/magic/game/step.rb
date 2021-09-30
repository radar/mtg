module Magic
  class Game
    class Step
      include AASM

      aasm do
        state :untap, initial: true, after_enter: -> { game.untap_active_player_permanents }
        state :upkeep
        state :draw, after_enter: -> { game.active_player.draw! }
        state :first_main
        state :beginning_of_combat, after_enter: -> { game.begin_combat! }
        state :declare_attackers
        state :declare_blockers
        state :first_strike
        state :combat_damage
        state :end_of_combat
        state :second_main
        state :end_of_turn
        state :cleanup

        event :next do
          transitions from: :untap, to: :upkeep
          transitions from: :upkeep, to: :draw
          transitions from: :draw, to: :first_main
          transitions from: :first_main, to: :beginning_of_combat
          transitions from: :beginning_of_combat, to: :declare_attackers
          transitions from: :declare_attackers, to: :declare_blockers
          transitions from: :declare_blockers, to: :first_strike, after: [
            -> { game.deal_first_strike_damage },
            -> { game.move_dead_creatures_to_graveyard },
          ]
          transitions from: :first_strike, to: :combat_damage, after: [
            -> { game.deal_combat_damage },
            -> { game.move_dead_creatures_to_graveyard },
          ]

          transitions from: :combat_damage, to: :end_of_combat
          transitions from: :end_of_combat, to: :second_main
          transitions from: :second_main, to: :end_of_turn
          transitions from: :end_of_turn, to: :cleanup
          transitions from: :cleanup, to: :untap, after: -> { game.change_active_player }
        end
      end

      attr_reader :game

      def initialize(game:)
        @game = game
      end

      def force_state!(state)
        if aasm.states.map(&:name).include?(state)
          aasm.current_state = state
        else
          raise "#{state} is an invalid game state"
        end
      end
    end
  end
end
