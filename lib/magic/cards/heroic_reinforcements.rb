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
        trigger_effect(:create_token, token_class: SoldierToken, amount: 2)
        battlefield.controlled_by(controller).creatures.each do |creature|
          trigger_effect(:modify_power_toughness, target: creature, power: 1, toughness: 1)
          trigger_effect(:grant_keyword, target: creature, keyword: :haste)
        end
      end
    end
  end
end
