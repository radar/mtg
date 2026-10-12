module Magic
  module Cards
    DarknessDescends = Sorcery("Darkness Descends") do
      cost generic: 2, black: 2
    end

    class DarknessDescends < Sorcery
      def resolve!
        battlefield.creatures.each { add_counter("-1/-1", to: _1, amount: 2) }
      end
    end
  end
end
