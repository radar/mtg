module Magic
  module Cards
    Overrun = Sorcery("Overrun") do
      cost generic: 2, green: 3
    end

    class Overrun < Sorcery
      def resolve!
        battlefield.controlled_by(controller).creatures.each do |creature|
          pump(creature, 3, 3)
          give_keyword(creature, :trample)
        end
      end
    end
  end
end
