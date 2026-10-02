module Magic
  module Cards
    MaalfeldTwins = Creature("Maalfeld Twins") do
      cost generic: 5, black: 1
      creature_type("Zombie")
      power 4
      toughness 4
    end

    class MaalfeldTwins < Creature
      class DiesTrigger < TriggeredAbility::Death
        ZombieToken = Token.create "Zombie" do
          creature_type "Zombie"
          power 2
          toughness 2
          colors :black
        end

        def call
          trigger_effect(:create_token, token_class: ZombieToken, amount: 2)
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
