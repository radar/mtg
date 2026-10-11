module Magic
  module Actions
    class Cast
      # Casts the adventure side: pays its cost, resolves via #adventure_resolve! instead of #resolve!, and exiles the
      # card "on an adventure" afterward.
      class Adventure < Cast
        def adventure? = true

        private

        def base_cost = card.adventure_cost

        def plain_cost? = false

        def resolve_method = :adventure_resolve!

        def adventure_instant? = card.respond_to?(:adventure_instant?) && card.adventure_instant?

        def printed_additional_costs
          card.respond_to?(:adventure_additional_costs) ? card.adventure_additional_costs : super
        end

        def move_after_resolving
          card.exile!
          card.on_adventure = true
        end
      end
    end
  end
end
