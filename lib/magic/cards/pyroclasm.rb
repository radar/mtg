module Magic
  module Cards
    Pyroclasm = Sorcery("Pyroclasm") do
      cost generic: 1, red: 1
    end

    class Pyroclasm < Sorcery
      def resolve!
        battlefield.creatures.each { deal_damage(2, to: _1) }
      end
    end
  end
end
