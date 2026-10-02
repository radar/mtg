module Magic
  module Cards
    Overrun = Sorcery("Overrun") do
      cost generic: 2, green: 3
    end

    class Overrun < Sorcery
      def resolve!
        battlefield.controlled_by(controller).creatures.each do |creature|
          trigger_effect(:modify_power_toughness, target: creature, power: 3, toughness: 3)
          trigger_effect(:grant_keyword, target: creature, keyword: :trample)
        end
      end
    end
  end
end
