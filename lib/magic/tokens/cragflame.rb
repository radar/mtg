module Magic
  module Tokens
    # Mabel, Heir to Cragflame's legendary Equipment token.
    Cragflame = EquipmentToken.build("Cragflame", power: 1, toughness: 1, keywords: %i[vigilance trample haste], equip: "{2}", legendary: true)
  end
end
