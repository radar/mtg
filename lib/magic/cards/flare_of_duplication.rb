module Magic
  module Cards
    FlareOfDuplication = Instant("Flare of Duplication") do
      cost generic: 1, red: 2
    end

    class FlareOfDuplication < Instant
      # "You may sacrifice a nontoken red creature rather than pay this spell's mana cost."
      def alternative_cost = Costs::SacrificeCreatureAlternativeCost.new(color: :red)

      def single_target? = true

      def target_choices = game.stack.spells.reject { _1.card == self }.select { _1.card.instant? || _1.card.sorcery? }

      # "Copy target instant or sorcery spell. You may choose new targets for the copy."
      def resolve!(target:)
        Magic::CopyEffect.resolve_with_choice!(actor: self, receiver: target.card, targets: target.targets)
      end
    end
  end
end
