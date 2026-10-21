module Magic
  module Cards
    ReefWorm = Creature("Reef Worm") do
      creature_type "Worm"
      cost generic: 3, blue: 1
      power 0
      toughness 1
    end

    class ReefWorm < Creature
      KrakenToken = Token.create("Kraken") do
        creature_type "Kraken"
        power 9
        toughness 9
        colors :blue
      end

      WhaleToken = Token.create("Whale") do
        creature_type "Whale"
        power 6
        toughness 6
        colors :blue

        def death_triggers = [WhaleToken::DiesTrigger]
      end

      FishToken = Token.create("Fish") do
        creature_type "Fish"
        power 3
        toughness 3
        colors :blue

        def death_triggers = [FishToken::DiesTrigger]
      end

      class WhaleToken
        # "When this token dies, create a 9/9 blue Kraken creature token."
        class DiesTrigger < TriggeredAbility::Death
          def call
            create_token(token: KrakenToken)
          end
        end
      end

      class FishToken
        # "When this token dies, create a 6/6 blue Whale creature token with 'When this token dies, ...'"
        class DiesTrigger < TriggeredAbility::Death
          def call
            create_token(token: WhaleToken)
          end
        end
      end

      # "When this creature dies, create a 3/3 blue Fish creature token with ..."
      class DiesTrigger < TriggeredAbility::Death
        def call
          create_token(token: FishToken)
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
