module Magic
  module Cards
    LongBodiedGreyDog = Creature("Long-Bodied Grey Dog") do
      cost generic: 3
      creature_type "Dog"
      power 2
      toughness 2
      keywords :flash, :reach

      # "When this creature enters, create a tapped Treasure token."
      enters_the_battlefield do
        trigger_effect(:create_token, token_class: Tokens::Treasure, enters_tapped: true)
      end
    end
  end
end
