module Magic
  module Cards
    ExquisiteBlood = Enchantment("Exquisite Blood") do
      cost generic: 4, black: 1
    end

    class ExquisiteBlood < Enchantment
      class LifeLossTrigger < TriggeredAbility
        def should_perform?
          event.player != controller
        end

        def call
          controller.gain_life(event.life)
        end
      end

      def event_handlers
        {
          Events::LifeLoss => LifeLossTrigger
        }
      end
    end
  end
end
