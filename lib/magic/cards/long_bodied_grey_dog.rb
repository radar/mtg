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
        create_token(token:Tokens::Treasure, enters_tapped: true)
      end
    end
  end
end
