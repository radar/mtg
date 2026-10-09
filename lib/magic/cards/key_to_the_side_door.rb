module Magic
  module Cards
    KeyToTheSideDoor = Artifact("Key to the Side-Door") do
      cost generic: 1
    end

    class KeyToTheSideDoor < Artifact
      # "{2}, {T}: Target creature can't be blocked this turn."
      class UnblockableAbility < Magic::ActivatedAbility
        costs "{2}, {T}"

        def target_choices = battlefield.creatures

        def resolve!(target:)
          target.grant_keyword(Keywords::CANT_BE_BLOCKED)
        end
      end

      # Discard cost: a legendary card with the same name as a legendary permanent you control.
      class DiscardLegendaryCost < Costs::Discard
        def initialize(player)
          super(player, lambda { |card|
            card.legendary? && player.permanents.any? { |permanent| permanent.legendary? && permanent.name == card.name }
          })
        end

        def can_pay?(_player = nil) = valid_targets.any?
      end

      # "{1}, {T}, Discard a legendary card with the same name as a legendary permanent you control: Draw two cards."
      class DrawAbility < Magic::ActivatedAbility
        def costs = Costs::Parser.parse(source:, costs: "{1}, {T}") + [DiscardLegendaryCost.new(controller)]

        def resolve!
          trigger_effect(:draw_cards, number_to_draw: 2)
        end
      end

      def activated_abilities = [UnblockableAbility, DrawAbility]
    end
  end
end
