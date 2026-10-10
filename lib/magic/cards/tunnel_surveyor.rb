module Magic
  module Cards
    TunnelSurveyor = Creature("Tunnel Surveyor") do
      cost generic: 2, blue: 1
      creature_type "Human Detective"
      power 2
      toughness 2
    end

    class TunnelSurveyor < Creature
      # "When this creature enters, create a 1/1 white Glimmer enchantment creature token."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:create_token, token_class: GlimmerSeeker::GlimmerToken)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
