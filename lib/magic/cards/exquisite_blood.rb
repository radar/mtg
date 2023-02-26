module Magic
  module Cards
    ExquisiteBlood = Enchantment("Exquisite Blood") do
      cost generic: 4, black: 1
    end

    class ExquisiteBlood < Enchantment
      def event_handlers
        {
          Events::LifeLoss => -> (receiver, event) do
            return if event.player == receiver.controller

            receiver.controller.gain_life(event.life)
          end
        }
      end
    end
  end
end
