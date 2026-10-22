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
      # you control which the entering creature out-sizes. Tokens already on the battlefield evolve when the Drone
      # itself enters (it is a creature entering after they gained evolve). Qualifying tokens are recorded when the
      # trigger fires; each is re-checked on resolution (evolve's intervening "if"), so a token created while the
      # trigger waits on the stack gets no counter.
      class TokenEvolveTrigger < TriggeredAbility::EnterTheBattlefield
        def evolving_tokens
          entering = event.permanent
          return [] unless entering.creature? && entering.controller == controller

          controller.creatures.select do |creature|
            creature.token? && creature != entering && outsized_by?(entering, creature)
          end
        end

        def outsized_by?(entering, creature)
          entering.power > creature.power || entering.toughness > creature.toughness
        end

        def should_perform? = evolving_tokens.any?

        def trigger!
          @triggered_tokens = evolving_tokens
          @triggered_tokens.any?
        end

        def call
          entering = event.permanent
          (@triggered_tokens || evolving_tokens).each do |token|
            next unless game.battlefield.permanents.include?(token) && outsized_by?(entering, token)

            add_counter("+1/+1", to: token)
          end
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
