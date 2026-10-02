module Magic
  module Cards
    InfestationSage = Creature("Infestation Sage") do
      cost black: 1
      creature_type("Elf Warlock")
      power 1
      toughness 1
    end

    class InfestationSage < Creature
      class DiesTrigger < TriggeredAbility::Death
        InsectToken = Token.create "Insect" do
          creature_type "Insect"
          power 1
          toughness 1
          colors :black, :green
          keywords :flying
        end

        def call
          trigger_effect(:create_token, token_class: InsectToken)
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
