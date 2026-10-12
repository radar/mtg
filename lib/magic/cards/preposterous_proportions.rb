module Magic
  module Cards
    PreposterousProportions = Sorcery("Preposterous Proportions") do
      cost generic: 5, green: 2
    end

    class PreposterousProportions < Sorcery
      def resolve!
        battlefield.controlled_by(controller).creatures.each do |creature|
          pump(creature, 10, 10)
          trigger_effect(:grant_keyword, target: creature, keyword: :vigilance)
        end
      end
    end
  end
end
