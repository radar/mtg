module Magic
  module Cards
    Meltdown = Sorcery("Meltdown") do
      cost x: 1, red: 1
    end

    class Meltdown < Sorcery
      # "Destroy each artifact with mana value X or less."
      def resolve!(value_for_x: 0)
        battlefield.artifacts.select { _1.mana_value <= value_for_x }.each { destroy(_1) }
      end
    end
  end
end
