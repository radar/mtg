module Magic
  module Cards
    DarknessDescends = Sorcery("Darkness Descends") do
      cost generic: 2, black: 2
    end

    class DarknessDescends < Sorcery
      def resolve!
        battlefield.creatures.each { trigger_effect(:add_counter, counter_type: "-1/-1", target: _1, amount: 2) }
      end
    end
  end
end
