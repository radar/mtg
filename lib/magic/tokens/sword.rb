module Magic
  module Tokens
    # "Equipped creature gets +1/+1" and equip {2} (Blacksmith's Talent).
    Sword = EquipmentToken.build("Sword", power: 1, toughness: 1, equip: "{2}")
  end
end
