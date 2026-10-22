module Magic
  module Cards
    # The land back face of Sink into Stupor. It has no mana cost.
    SoporificSprings = Card("Soporific Springs") do
      type "Land"
    end

    class SoporificSprings < Card
      # "As this land enters, you may pay 3 life. If you don't, it enters tapped."
      def shock_life = 3

      class ManaAbility < Magic::TapManaAbility
        choices :blue
      end

      def activated_abilities = [ManaAbility]
    end

    SinkIntoStupor = Instant("Sink into Stupor") do
      cost generic: 1, blue: 2
      back_face SoporificSprings
    end

    class SinkIntoStupor < Instant
      def target_choices
        spells = game.stack.spells.reject { |spell| spell.card == self || spell.player == controller }
        [*spells, *battlefield.not_controlled_by(controller).reject(&:land?)]
      end

      # "Return target spell or nonland permanent an opponent controls to its owner's hand."
      def resolve!(target:)
        if target.is_a?(Magic::Permanent)
          bounce(target)
        else
          game.stack.remove(target)
          target.card.move_to_hand!(target.card.owner)
        end
      end
    end
  end
end
