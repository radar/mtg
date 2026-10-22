module Magic
  module Cards
    # The land back face of Stump Stomp. It has no mana cost.
    BurnwillowClearing = Card("Burnwillow Clearing") do
      type "Land"
    end

    class BurnwillowClearing < Card
      def enters_tapped? = true

      class ManaAbility < Magic::TapManaAbility
        choices :red, :green
      end

      def activated_abilities = [ManaAbility]
    end

    StumpStomp = Sorcery("Stump Stomp") do
      cost "{1}{R/G}"
      back_face BurnwillowClearing
    end

    class StumpStomp < Sorcery
      def multi_target? = true

      def target_choices
        [
          battlefield.controlled_by(controller).creatures,
          battlefield.not_controlled_by(controller).by_any_type("Creature", "Planeswalker")
        ]
      end

      # "Target creature you control deals damage equal to its power to target creature or planeswalker you
      # don't control." Only the creature you control deals damage.
      def resolve!(targets:)
        mine, theirs = targets
        return unless mine.zone&.battlefield? && theirs.zone&.battlefield?

        mine.apply_continuous_effects!
        mine.deal_damage(mine.power, to: theirs) if mine.power.positive?
      end
    end
  end
end
