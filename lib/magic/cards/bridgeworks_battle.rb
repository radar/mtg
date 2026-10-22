module Magic
  module Cards
    # The land back face of Bridgeworks Battle. It has no mana cost.
    TanglespanBridgeworks = Card("Tanglespan Bridgeworks") do
      type "Land"
    end

    class TanglespanBridgeworks < Card
      # "As this land enters, you may pay 3 life. If you don't, it enters tapped."
      def shock_life = 3

      class ManaAbility < Magic::TapManaAbility
        choices :green
      end

      def activated_abilities = [ManaAbility]
    end

    BridgeworksBattle = Sorcery("Bridgeworks Battle") do
      cost generic: 2, green: 1
      back_face TanglespanBridgeworks
    end

    class BridgeworksBattle < Sorcery
      def multi_target? = true

      def target_choices
        [battlefield.controlled_by(controller).creatures, battlefield.not_controlled_by(controller).creatures]
      end

      # "Target creature you control gets +2/+2 until end of turn. It fights up to one target creature you
      # don't control."
      def resolve!(targets:)
        mine, theirs = targets
        pump(mine, 2, 2)
        mine.fights!(theirs) if theirs
      end
    end
  end
end
