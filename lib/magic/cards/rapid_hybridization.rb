module Magic
  module Cards
    RapidHybridization = Instant("Rapid Hybridization") do
      cost blue: 1
    end

    class RapidHybridization < Instant
      FrogLizardToken = Token.create "Frog Lizard" do
        creature_type "Frog Lizard"
        power 3
        toughness 3
        colors :green
      end

      def target_choices
        battlefield.creatures
      end

      # "Destroy target creature. It can't be regenerated. That creature's controller creates a 3/3 green Frog
      # Lizard creature token." The token comes even if the creature was indestructible.
      def resolve!(target:)
        creature_controller = target.controller
        target.destroy!(regenerate: false)
        trigger_effect(:create_token, token_class: FrogLizardToken, controller: creature_controller)
      end
    end
  end
end
