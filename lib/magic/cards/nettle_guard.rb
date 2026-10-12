module Magic
  module Cards
    NettleGuard = Creature("Nettle Guard") do
      cost generic: 1, white: 1
      creature_type("Mouse Soldier")
      power 3
      toughness 1
    end

    class NettleGuard < Creature
      # Valiant -- it gets +0/+2 until end of turn.
      class ValiantTrigger < TriggeredAbility::Valiant
        def call
          pump(actor, 0, 2)
        end
      end

      def event_handlers = super.merge(ValiantTrigger.handlers)

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}, Sacrifice {this}"

        def target_choices
          battlefield.artifacts + battlefield.enchantments
        end

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
