module Magic
  module Cards
    class LightOfPromise < Aura
      NAME = "Light of Promise"
      TYPE_LINE = "Enchantment -- Aura"
      COST = { generic: 2, white: 1 }

      def resolve!
        enchant_creature
        super
      end

      def receive_notification(event)
        case event
        when Events::LifeGain
          return unless event.player == controller
          attached_to.add_counter(Counters::Plus1Plus1, amount: event.life)
        end
      end
    end
  end
end
