module Magic
  module Cards
    MazemindTome = Artifact("Mazemind Tome") do
      cost generic: 2
    end

    class MazemindTome < Artifact
      class ActivatedAbility < ActivatedAbility
        def costs
          [
            Costs::SelfTap.new(source),
            Costs::AddCounter.new(counter_type: Counters::Page, target: source)
          ]
        end

        def resolve!
          add_choice(:scry, actor: source)
        end
      end

      class ActivatedAbility2 < Magic::ActivatedAbility
        def costs
          [
            Costs::Mana.new(generic: 2),
            Costs::SelfTap.new(source),
            Costs::AddCounter.new(counter_type: Counters::Page, target: source)
          ]
        end

        def resolve!
          source.controller.draw!
        end
      end

      def activated_abilities = [ActivatedAbility, ActivatedAbility2]

      def state_triggered_abilities = [StateTriggeredAbility]

      class StateTriggeredAbility
        attr_reader :source
        def initialize(source:)
          @source = source
        end

        def name
          self.class
        end

        def condition_met?
          source.counters.of_type(Magic::Counters::Page).count >= 4
        end

        def resolve!
          if source.zone.battlefield?
            source.trigger_effect(:exile, target: source)
            source.trigger_effect(:gain_life, life: 4)
          end
        end
      end
    end
  end
end
