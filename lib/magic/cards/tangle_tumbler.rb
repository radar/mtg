module Magic
  module Cards
    class TangleTumbler < Card
      card_name "Tangle Tumbler"
      type T::Artifact, "Vehicle"
      cost generic: 3
      keywords :vigilance
      power 6
      toughness 6

      # {3}, {T}: Put a +1/+1 counter on target creature.
      class CounterAbility < Magic::ActivatedAbility
        costs "{3}, {T}"

        def target_choices = battlefield.creatures

        def resolve!(target:)
          trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 1)
        end
      end

      # Tap two untapped tokens you control: This Vehicle becomes an artifact creature until end of turn.
      class CrewAbility < Magic::ActivatedAbility
        def costs = [Costs::MultiTap.new(2) { controller.permanents.select(&:token?).reject(&:tapped?) }]

        def resolve!
          source.become_creature!(power: 6, toughness: 6, types: [T::Creature])
        end
      end

      def activated_abilities = [CounterAbility, CrewAbility]
    end
  end
end
