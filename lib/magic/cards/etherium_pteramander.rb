module Magic
  module Cards
    EtheriumPteramander = Creature("Etherium Pteramander") do
      cost black: 1
      artifact_creature_type "Salamander Drake"
      power 1
      toughness 1
      keywords :flying
    end

    class EtheriumPteramander < Creature
      # "This creature can block only creatures with flying."
      def can_block?(attacker) = attacker.flying?

      # "{6}{B}: Adapt 4. This ability costs {1} less to activate for each other artifact you control." (If this
      # creature has no +1/+1 counters on it, put four +1/+1 counters on it.)
      class AdaptAbility < Magic::ActivatedAbility
        def costs
          [Costs::Mana.new(generic: 6, black: 1).adjusted_by(generic: -> { -other_artifacts.count })]
        end

        def other_artifacts
          source.controller.permanents.by_any_type("Artifact").reject { _1 == source }
        end

        def resolve!
          return if source.counters.of_type(Counters::Plus1Plus1).any?

          add_counter("+1/+1", to: source, amount: 4)
        end
      end

      def activated_abilities = [AdaptAbility]
    end
  end
end
