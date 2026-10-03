module Magic
  module Cards
    DrakeHatcher = Creature("Drake Hatcher") do
      cost generic: 1, blue: 1
      creature_type("Human Wizard")
      keywords :vigilance, :prowess
      power 1
      toughness 3
    end

    class DrakeHatcher < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "Remove 3 incubation counters from {this}"

        DrakeToken = Token.create "Drake" do
          creature_type "Drake"
          power 2
          toughness 2
          colors :blue
          keywords :flying
        end

        def resolve!
          trigger_effect(:create_token, token_class: DrakeToken)
        end
      end

      def activated_abilities = [ActivatedAbility]

      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          event.source == actor && event.target.is_a?(Magic::Player)
        end

        def call
          trigger_effect(:add_counter, counter_type: "incubation", target: actor, amount: event.damage)
        end
      end

      def event_handlers = super.merge({ Events::CombatDamageDealt => CombatDamageTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
