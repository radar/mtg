module Magic
  module Cards
    class NineLives < Card
      NAME = "Nine Lives"
      TYPE_LINE = "Enchantment"
      COST = { generic: 1, white: 2 }
      KEYWORDS = [Keywords::HEXPROOF]

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
