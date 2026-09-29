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

        def power_modification = another_creature_entered? ? 2 : 0

        def toughness_modification = 0

        private

        def another_creature_entered?
          game.current_turn.events.any? do |event|
            event.is_a?(Events::EnteredTheBattlefield) && event.permanent.creature? &&
              event.permanent != source && event.permanent.controller == controller
          end
        end
      end

      def static_abilities = [EnteredThisTurnBuff]
    end
  end
end
