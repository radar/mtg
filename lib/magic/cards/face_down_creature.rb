module Magic
  module Cards
    # What a face-down permanent is (rule 708.2): a 2/2 creature with no name, no mana cost, no colour, no abilities and
    # no subtypes. A `Permanent` that is face down uses one of these as its `face`; the real card stays its `card`.
    class FaceDownCreature < Creature
      card_name "Face-down creature"
      type T::Creature
      power 2
      toughness 2
    end
  end
end
