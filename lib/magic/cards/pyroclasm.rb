module Magic
  module Cards
    Pyroclasm = Sorcery("Pyroclasm") do
      cost generic: 1, red: 1
    end

    class Pyroclasm < Sorcery
      def resolve!
        battlefield.creatures.each { trigger_effect(:deal_damage, target: _1, damage: 2) }
      end
    end
  end
end
