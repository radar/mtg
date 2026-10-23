module Magic
  module Cards
    class BristlebaneOutrider < Creature
      card_name "Bristlebane Outrider"
      cost generic: 3, green: 1
      creature_type "Kithkin Knight"
      power 3
      toughness 5

      # "This creature can't be blocked by creatures with power 2 or less."
      def can_be_blocked?(blocker) = blocker.power > 2

      # "As long as another creature entered the battlefield under your control this turn, this
      # creature gets +2/+0."
      class EnteredThisTurnBuff < Abilities::Static::PowerAndToughnessModification
        def applicable_targets = [source]

        def power_modification = creature_entered_this_turn?(except: source) ? 2 : 0

        def toughness_modification = 0
      end

      def static_abilities = [EnteredThisTurnBuff]
    end
  end
end
