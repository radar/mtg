module Magic
  class LoyaltyAbility < Ability
    def instant_speed?
      false
    end

    # What the ability does, as the card prints it ("Create three 1/1 white Soldier creature tokens."), for a UI to show.
    # nil when the card doesn't say.
    def description = nil
  end
end
