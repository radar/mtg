module Magic
  module Cards
    BioengineeredFuture = Enchantment("Bioengineered Future") do
      cost generic: 1, green: 2
    end

    class BioengineeredFuture < Enchantment
      LanderToken = Token.create("Lander") do
        type T::Artifact
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          actor.create_token(token_class: LanderToken)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end