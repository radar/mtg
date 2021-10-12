module Magic
  module Cards
    DaybreakCharger = Creature("Daybreak Charger") do
      cost generic: 1, white: 1
      type "Creature -- Unicorn"

      power 3
      toughness 1
    end

    class DaybreakCharger < Creature
      def entered_the_battlefield!
        apply_buff_effect = Effects::ApplyBuff.new(power: 2, choices: game.battlefield.creatures)
        game.add_effect(apply_buff_effect)
      end
    end
  end
end
