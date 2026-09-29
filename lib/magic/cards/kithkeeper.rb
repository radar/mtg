module Magic
  module Cards
    Kithkeeper = Creature("Kithkeeper") do
      creature_type "Elemental"
      cost generic: 6, white: 1
      power 3
      toughness 3
    end

    class Kithkeeper < Creature
      KithkinToken = Token.create "Kithkin" do
        creature_type "Kithkin"
        power 1
        toughness 1
        colors :green, :white
      end

      # Vivid -- When this creature enters, create X 1/1 green and white Kithkin creature tokens.
      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:create_token, token_class: KithkinToken, amount: controller.colors_among_permanents)
        end
      end

      def etb_triggers = [ETB]

      class TapThreeAbility < Magic::ActivatedAbility
        def costs = [Costs::MultiTap.new(3) { controller.creatures.untapped }]

        def resolve!
          source.modify_power(3)
          source.grant_flying!
        end
      end

      def activated_abilities = [TapThreeAbility]
    end
  end
end
