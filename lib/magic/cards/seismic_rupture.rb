module Magic
  module Cards
    SeismicRupture = Sorcery("Seismic Rupture") do
      cost generic: 2, red: 1
    end

    class SeismicRupture < Sorcery
      def resolve!
        battlefield.creatures.reject(&:flying?).each { trigger_effect(:deal_damage, target: _1, damage: 2) }
      end
    end
  end
end
