module Magic
  class Game
    # Rule 704: state-based actions.
    #
    # `perform!` runs a single pass over every rule and returns true if any of them
    # changed the game. `Game#check_state_based_actions!` repeats passes until one changes nothing.
    class StateBasedActions
      attr_reader :game

      def initialize(game:)
        @game = game
      end

      def perform!
        [
          put_zero_toughness_creatures_into_graveyard,
          destroy_lethally_damaged_creatures,
        ].any?
      end

      private

      # Rule 704.5f: toughness 0 or less. Indestructible does not help here.
      def put_zero_toughness_creatures_into_graveyard
        creatures = game.battlefield.creatures.select { |creature| creature.toughness <= 0 }
        creatures.each(&:destroy!)
        creatures.any?
      end

      # Rules 704.5g and 704.5h: lethal damage, or damage from a deathtouch source.
      # Indestructible creatures survive both.
      def destroy_lethally_damaged_creatures
        creatures = game.battlefield.creatures.select do |creature|
          creature.lethally_damaged? && !creature.indestructible?
        end
        creatures.each(&:destroy!)
        creatures.any?
      end
    end
  end
end
