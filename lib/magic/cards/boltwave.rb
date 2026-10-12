module Magic
  module Cards
    Boltwave = Sorcery("Boltwave") do
      cost red: 1
    end

    class Boltwave < Sorcery
      def resolve!
        game.opponents(controller).each { deal_damage(3, to: _1) }
      end
    end
  end
end
