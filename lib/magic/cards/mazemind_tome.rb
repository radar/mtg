module Magic
  module Cards
    MazemindTome = Artifact("Mazemind Tome") do
      cost generic: 2
    end

    class MazemindTome < Artifact
      class ActivatedAbility < ActivatedAbility
        def costs
          [
            Costs::Tap.new(source),
            Costs::AddCounter.new(counter_type: Counters::Page, target: source)
          ]
        end

        def resolve!
          add_choice(:scry, source: source)
        end
      end

      class ActivatedAbility2 < Magic::ActivatedAbility
        def costs
          [
            Costs::Mana.new(generic: 2),
            Costs::Tap.new(source),
            Costs::AddCounter.new(counter_type: Counters::Page, target: source)
          ]
        end

        def resolve!
          source.controller.draw!
        end
      end

      def activated_abilities = [ActivatedAbility, ActivatedAbility2]

      def event_handlers
        {
          Events::CounterAdded => ->(receiver, event) {
            return unless event.permanent == receiver

            if receiver.counters.of_type(Magic::Counters::Page).count >= 4
              receiver.trigger_effect(:exile, target: receiver)
              receiver.trigger_effect(:gain_life, life: 4)
            end
          }
        }
      end
    end
  end
end
