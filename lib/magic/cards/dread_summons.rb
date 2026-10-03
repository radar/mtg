module Magic
  module Cards
    DreadSummons = Sorcery("Dread Summons") do
      cost x: 1, black: 2
    end

    class DreadSummons < Sorcery
      ZombieToken = Token.create "Zombie" do
        creature_type "Zombie"
        power 2
        toughness 2
        colors :black
      end

      def resolve!(value_for_x: 0)
        milled = game.players.flat_map { _1.mill([value_for_x, _1.library.count].min) }
        trigger_effect(:create_token, token_class: ZombieToken, amount: milled.count { _1.type?("Creature") }, enters_tapped: true)
      end
    end
  end
end
