module Magic
  module Cards
    StolenByTheFae = Sorcery("Stolen by the Fae") do
      cost x: 1, blue: 2
    end

    class StolenByTheFae < Sorcery
      FaerieToken = Token.create "Faerie" do
        creature_type "Faerie"
        power 1
        toughness 1
        colors :blue
        keywords :flying
      end

      def target_choices
        battlefield.creatures
      end

      # "Return target creature with mana value X": the X the spell is cast with.
      def target_fits_x?(target, x)
        target.mana_value == x
      end

      def resolve!(target:, value_for_x:)
        trigger_effect(:return_to_owners_hand, target: target)
        trigger_effect(:create_token, token_class: FaerieToken, amount: value_for_x) if value_for_x.positive?
      end
    end
  end
end
