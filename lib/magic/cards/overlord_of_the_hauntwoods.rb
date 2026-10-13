module Magic
  module Cards
    class OverlordOfTheHauntwoods < Overlord
      card_name "Overlord of the Hauntwoods"
      cost generic: 3, green: 2
      impending 4, Costs::Mana.new(generic: 1, green: 2)
      power 6
      toughness 5

      # A colorless land that is every basic land type, so it taps for any color.
      EverywhereToken = Token.create "Everywhere" do
        type T::Land, T::Lands::Plains, T::Lands::Island, T::Lands::Swamp, T::Lands::Mountain, T::Lands::Forest
        power 0
        toughness 0
      end

      # "Whenever this permanent enters or attacks, create a tapped colorless land token named Everywhere that is every
      # basic land type."
      enters_or_attacks do
        create_token(token:OverlordOfTheHauntwoods::EverywhereToken, enters_tapped: true)
      end
    end
  end
end
