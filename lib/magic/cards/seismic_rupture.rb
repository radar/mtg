module Magic
  module Cards
    SeismicRupture = Sorcery("Seismic Rupture") do
      cost generic: 2, red: 1
    end

    class SeismicRupture < Sorcery
      def resolve!
        battlefield.creatures.reject(&:flying?).each { deal_damage(2, to: _1) }
      end
    end
  end
end
