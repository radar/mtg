module Magic
  module Cards
    DragonFodder = Sorcery("Dragon Fodder") do
      cost generic: 1, red: 1
    end

    class DragonFodder < Sorcery
      GoblinToken = Token.create "Goblin" do
        creature_type "Goblin"
        power 1
        toughness 1
        colors :red
      end

      def resolve!
        create_token(token:GoblinToken, amount: 2)
      end
    end
  end
end
