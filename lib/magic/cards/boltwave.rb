module Magic
  module Cards
    Boltwave = Sorcery("Boltwave") do
      cost red: 1
    end

    class Boltwave < Sorcery
      def resolve!
        game.opponents(controller).each { trigger_effect(:deal_damage, target: _1, damage: 3) }
      end
    end
  end
end
