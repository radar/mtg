module Magic
  module Cards
    SiegeStriker = Creature("Siege Striker") do
      power 1
      toughness 1
      cost white: 1, generic: 2
      type "Creature -- Human Soldier"
      keywords :indestructible
    end

    class SiegeStriker < Creature
      def receive_notification(event)
        case event
        when Events::PermanentTapped
          # TODO: Only apply if within attack phase of controller's turn
          return unless game.current_turn.active_player == controller
          return unless game.current_turn.step?(:declare_attackers)
          return unless event.permanent.creature?

          self.modifiers << Buff.new(power: 1, toughness: 1, until_eot: true)
        end
      end
    end
  end
end
