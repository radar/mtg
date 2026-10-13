module Magic
  module Cards
    class OverlordOfTheMistmoors < Overlord
      card_name "Overlord of the Mistmoors"
      cost generic: 5, white: 2
      impending 4, Costs::Mana.new(generic: 2, white: 2)
      power 6
      toughness 6

      InsectToken = Token.create "Insect" do
        creature_type "Insect"
        colors :white
        keywords :flying
        power 2
        toughness 1
      end

      # "Whenever this permanent enters or attacks, create two 2/1 white Insect creature tokens with flying."
      enters_or_attacks do
        create_token(token:OverlordOfTheMistmoors::InsectToken, amount: 2)
      end
    end
  end
end
