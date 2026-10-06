module Magic
  module Cards
    DeathbloomThallid = Creature("Deathbloom Thallid") do
      cost generic: 2, black: 1
      creature_type("Fungus")
      power 3
      toughness 2
    end

    class DeathbloomThallid < Creature
      class DiesTrigger < TriggeredAbility::Death
        SaprolingToken = Token.create "Saproling" do
          creature_type "Saproling"
          power 1
          toughness 1
          colors :green
        end

        def call
          trigger_effect(:create_token, token_class: SaprolingToken)
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
