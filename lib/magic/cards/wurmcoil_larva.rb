module Magic
  module Cards
    WurmcoilLarva = Creature("Wurmcoil Larva") do
      artifact_creature_type "Phyrexian Wurm"
      cost generic: 3, black: 2
      power 3
      toughness 3
      keywords :deathtouch, :lifelink
    end

    class WurmcoilLarva < Creature
      DeathtouchWurmToken = Token.create("Phyrexian Wurm") do
        artifact_creature_type "Phyrexian Wurm"
        power 1
        toughness 2
        colors :black
        keywords :deathtouch
      end

      LifelinkWurmToken = Token.create("Phyrexian Wurm") do
        artifact_creature_type "Phyrexian Wurm"
        power 2
        toughness 1
        colors :black
        keywords :lifelink
      end

      # "When this creature dies, create a 1/2 ... token with deathtouch and a 2/1 ... token with lifelink."
      class DiesTrigger < TriggeredAbility::Death
        def call
          create_token(token: DeathtouchWurmToken)
          create_token(token: LifelinkWurmToken)
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
