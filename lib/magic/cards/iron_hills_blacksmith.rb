module Magic
  module Cards
    IronHillsBlacksmith = Creature("Iron Hills Blacksmith") do
      cost generic: 1, white: 1
      creature_type "Dwarf Artificer"
      power 1
      toughness 1
      keywords :double_strike

      # "When this creature enters, create a colorless Equipment artifact token named Axe ..."
      enters_the_battlefield do
        trigger_effect(:create_token, token_class: Tokens::Axe)
      end
    end
  end
end
