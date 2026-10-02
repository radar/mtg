module Magic
  module Cards
    PreposterousProportions = Sorcery("Preposterous Proportions") do
      cost generic: 5, green: 2
    end

    class PreposterousProportions < Sorcery
      def resolve!
        battlefield.controlled_by(controller).creatures.each do |creature|
          trigger_effect(:modify_power_toughness, target: creature, power: 10, toughness: 10)
          trigger_effect(:grant_keyword, target: creature, keyword: :vigilance)
        end
      end
    end
  end
end
