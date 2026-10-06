module Magic
  module Cards
    CastleArdenvale = Card("Castle Ardenvale") do
      type "Land"
    end

    class CastleArdenvale < Card
      HumanToken = Token.create "Human" do
        creature_type "Human"
        power 1
        toughness 1
        colors :white
      end

      def enters_tapped?
        controller.lands.by_any_type("Plains").none?
      end

      class ManaAbility < Magic::TapManaAbility
        choices :white
      end

      class CreateTokenAbility < Magic::ActivatedAbility
        costs "{2}{W}{W}, {T}"

        def resolve!
          trigger_effect(:create_token, token_class: HumanToken)
        end
      end

      def activated_abilities = [ManaAbility, CreateTokenAbility]
    end
  end
end
