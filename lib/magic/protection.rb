module Magic
  class Protection
    attr_reader :condition, :until_eot, :until_turn_of

    # `until_turn_of`: a player -- lasts until that player's next turn begins ("until your next turn").
    def initialize(condition:, until_eot: false, protects_player: false, until_turn_of: nil, from_spells: false)
      @condition = condition
      @from_spells = from_spells
      @until_eot = until_eot
      @protects_player = protects_player
      @until_turn_of = until_turn_of
    end

    def protects_player?
      @protects_player
    end

    def until_eot?
      @until_eot
    end

    def self.from_color(color, until_eot: false, until_turn_of: nil)
      new(condition: -> (card) { card.colors.include?(color) }, until_eot: until_eot, until_turn_of: until_turn_of)
    end

    # "Protection from spells" (Emrakul, the World Anew): protects from a card only while it is a spell. `spell:` is the
    # caller's answer when it knows (a spell being cast is still in its hand while its targets are chosen); left out, a
    # card is a spell when it is on the stack or in no zone, and a card in a hand or graveyard is not.
    def self.from_spells
      new(condition: nil, from_spells: true)
    end

    def from_spells?
      @from_spells
    end

    def protected_from?(card, spell: nil)
      return condition.call(card) unless from_spells?
      return spell unless spell.nil?

      card.is_a?(Magic::Card) && (card.zone.nil? || card.zone.stack?)
    end
  end
end
