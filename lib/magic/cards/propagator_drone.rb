module Magic
  module Cards
    PropagatorDrone = Creature("Propagator Drone") do
      cost generic: 1, green: 1
      creature_type "Eldrazi Drone"
      power 2
      toughness 2
      keywords :devoid
    end

    class PropagatorDrone < Creature
      # "Creature tokens you control have evolve." Evolve: "Whenever a creature you control enters, if that creature
      # has greater power or toughness than this creature, put a +1/+1 counter on this creature."
      # Each token with evolve triggers on its own, so this one trigger puts a counter on every creature token that
      # you control which the entering creature out-sizes. The Drone's own entry does not count, as it is not a token.
      class TokenEvolveTrigger < TriggeredAbility::EnterTheBattlefield
        def evolving_tokens
          entering = event.permanent
          return [] unless entering.creature? && entering.controller == controller

          controller.creatures.select do |creature|
            creature.token? && creature != entering && (entering.power > creature.power || entering.toughness > creature.toughness)
          end
        end

        def should_perform? = evolving_tokens.any?

        def call
          evolving_tokens.each { |token| add_counter("+1/+1", to: token) }
        end
      end

      # "{3}{G}: Create a 0/1 colorless Eldrazi Spawn creature token with 'Sacrifice this token: Add {C}.'"
      class SpawnAbility < Magic::ActivatedAbility
        costs "{3}{G}"

        def resolve!
          create_eldrazi_spawn
        end
      end

      def event_handlers = super.merge(Events::EnteredTheBattlefield => TokenEvolveTrigger)

      def activated_abilities = [SpawnAbility]
    end
  end
end
