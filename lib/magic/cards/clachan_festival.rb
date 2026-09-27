module Magic
  module Cards
    ClachanFestival = Enchantment("Clachan Festival") do
      cost generic: 2, white: 1
      type T::Kindred, T::Enchantment, T::Creatures["Kithkin"]
    end

    class ClachanFestival < Enchantment
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{4}{W}"

        KithkinToken = Token.create "Kithkin" do
          creature_type "Kithkin"
          power 1
          toughness 1
          colors :green, :white
        end

        def resolve!
          trigger_effect(:create_token, token_class: KithkinToken)
        end
      end

      def activated_abilities = [ActivatedAbility]

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        KithkinToken = Token.create "Kithkin" do
          creature_type "Kithkin"
          power 1
          toughness 1
          colors :green, :white
        end

        def call
          trigger_effect(:create_token, token_class: KithkinToken, amount: 2)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
