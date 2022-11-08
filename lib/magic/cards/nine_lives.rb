module Magic
  module Cards
    NineLives = Enchantment("Nine Lives") do
      type "Legendary Enchantment -- Shrine"
      cost generic: 1, white: 2
      keywords :hexproof
    end

    class NineLives < Enchantment
      def prevent_damage!(event)
        puts "Nine Lives preventing damage: #{event}"

        self.counters << Counters::Incarnation.new

        if counters.of_type(Counters::Incarnation).count >= 9
          Effects::Exile.new(source: self).resolve(target: self)
        end

        true
      end

      def receive_notification(event)
        case event
        when Events::LeavingZone
          return unless event.from.battlefield?

          controller.lose!
        end

      end
    end
  end
end
