module Magic
  module Cards
    HeroicReinforcements = Sorcery("Heroic Reinforcements") do
      cost generic: 2, red: 1, white: 1
    end

    class HeroicReinforcements < Sorcery
      SoldierToken = Token.create "Soldier" do
        creature_type "Soldier"
        power 1
        toughness 1
        colors :white
      end

      def resolve!
        create_token(token:SoldierToken, amount: 2)
        battlefield.controlled_by(controller).creatures.each do |creature|
          pump(creature, 1, 1)
          give_keyword(creature, :haste)
        end
      end
    end
  end
end
