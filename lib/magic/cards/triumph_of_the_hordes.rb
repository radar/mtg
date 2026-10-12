module Magic
  module Cards
    TriumphOfTheHordes = Sorcery("Triumph of the Hordes") do
      cost generic: 2, green: 2
    end

    class TriumphOfTheHordes < Sorcery
      def resolve!
        battlefield.controlled_by(controller).creatures.each do |creature|
          pump(creature, 1, 1)
          trigger_effect(:grant_keyword, target: creature, keyword: :trample)
          trigger_effect(:grant_keyword, target: creature, keyword: :infect)
        end
      end
    end
  end
end
