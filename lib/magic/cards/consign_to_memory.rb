module Magic
  module Cards
    ConsignToMemory = Instant("Consign to Memory") do
      cost blue: 1
      replicate_mana generic: 1
    end

    class ConsignToMemory < Instant
      def single_target? = true

      def target_choices
        game.stack.abilities.grep(Magic::TriggeredAbility) + game.stack.spells.select { _1.card != self && _1.card.colorless? }
      end

      # "Counter target triggered ability or colorless spell."
      def resolve!(target:)
        target.is_a?(Magic::Actions::Cast) ? counter_spell(target) : counter_ability(target)
      end
    end
  end
end
