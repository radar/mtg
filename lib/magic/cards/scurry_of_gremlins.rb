module Magic
  module Cards
    ScurryOfGremlins = Enchantment("Scurry Of Gremlins") do
      cost generic: 2, red: 1, white: 1
    end

    class ScurryOfGremlins < Enchantment
      # When this enchantment enters, create two 1/1 red Gremlin creature tokens. Then you get an amount of {E} equal to
      # the number of creatures you control.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          create_token(token: MidnightMayhem::GremlinToken, amount: 2)
          gain_energy controller.creatures.count
        end
      end

      # Pay {E}{E}{E}{E}: Creatures you control get +1/+0 and gain haste until end of turn.
      class PumpAbility < Magic::ActivatedAbility
        costs "Pay {E}{E}{E}{E}"

        def resolve!
          controller.creatures.each do |creature|
            pump(creature, 1, 0)
            give_keyword(creature, :haste)
          end
        end
      end

      def etb_triggers = [EntersTrigger]

      def activated_abilities = [PumpAbility]
    end
  end
end
