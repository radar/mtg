module Magic
  module Cards
    UnexpectedWindfall = Instant("Unexpected Windfall") do
      cost "{2}{R}{R}"
    end

    class UnexpectedWindfall < Instant
      TreasureToken = Token.create("Treasure") do
        type T::Artifact, "Treasure"
        power 0
        toughness 0

        class ManaAbility < Magic::ManaAbility
          costs "{T}, Sacrifice {this}"
          choices :all
        end

        def activated_abilities = [ManaAbility]
      end

      def additional_costs
        [Costs::Discard.new(controller)]
      end

      def resolve!
        trigger_effect(:draw_cards, number_to_draw: 2)
        trigger_effect(:create_token, token_class: TreasureToken, amount: 2)
      end
    end
  end
end
