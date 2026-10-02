module Magic
  module Cards
    KrenkoMobBoss = Creature("Krenko, Mob Boss") do
      cost generic: 2, red: 2
      legendary_creature_type("Goblin Warrior")
      power 3
      toughness 3
    end

    class KrenkoMobBoss < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{T}"

        GoblinToken = Token.create "Goblin" do
          creature_type "Goblin"
          power 1
          toughness 1
          colors :red
        end

        def resolve!
          trigger_effect(:create_token, token_class: GoblinToken, amount: controller.permanents.by_type("Goblin").count)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
