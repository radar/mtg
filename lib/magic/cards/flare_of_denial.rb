module Magic
  module Cards
    FlareOfDenial = Instant("Flare of Denial") do
      cost generic: 1, blue: 2
    end

    class FlareOfDenial < Instant
      # "You may sacrifice a nontoken blue creature rather than pay this spell's mana cost."
      def alternative_cost = Costs::SacrificeCreatureAlternativeCost.new(color: :blue)

      def single_target? = true

      def target_choices = game.stack.spells.reject { _1.card == self }

      # "Counter target spell."
      def resolve!(target:)
        counter_spell(target)
      end
    end
  end
end
