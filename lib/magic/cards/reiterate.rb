module Magic
  module Cards
    Reiterate = Instant("Reiterate") do
      cost generic: 1, red: 2
      kicker_cost generic: 3
      buyback
    end

    class Reiterate < Instant
      def single_target?
        true
      end

      def target_choices
        game.stack.spells.select { |spell| spell.card.instant? || spell.card.sorcery? }
      end

      def resolve!(target:)
        Magic::CopyEffect.resolve_with_choice!(actor: self, receiver: target.card, targets: target.targets)
      end
    end
  end
end
