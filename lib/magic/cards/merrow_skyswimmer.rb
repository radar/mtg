module Magic
  module Cards
    MerrowSkyswimmer = Creature("Merrow Skyswimmer") do
      cost generic: 3, blue_or_white: 2
      creature_type("Merfolk Soldier")
      keywords :flying, :vigilance
      convoke
      power 2
      toughness 2
    end

    class MerrowSkyswimmer < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        MerfolkToken = Token.create "Merfolk" do
          creature_type "Merfolk"
          power 1
          toughness 1
          colors :white, :blue
        end

        def call
          trigger_effect(:create_token, token_class: MerfolkToken)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
