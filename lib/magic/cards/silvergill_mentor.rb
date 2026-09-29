module Magic
  module Cards
    SilvergillMentor = Creature("Silvergill Mentor") do
      cost generic: 1, blue: 1
      creature_type("Merfolk Wizard")
      power 2
      toughness 1
    end

    class SilvergillMentor < Creature
      # As an additional cost to cast this spell, behold a Merfolk or pay {2}.
      def additional_costs
        [Costs::Behold.new(self, type: "Merfolk", or_mana: { generic: 2 })]
      end

      # When this creature enters, create a 1/1 white and blue Merfolk creature token.
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
