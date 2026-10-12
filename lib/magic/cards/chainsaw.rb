module Magic
  module Cards
    Chainsaw = Equipment("Chainsaw") do
      cost generic: 1, red: 1
      equip [Costs::Mana.new(generic: 3)]
    end

    class Chainsaw < Equipment
      # "When this Equipment enters, it deals 3 damage to up to one target creature."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices = battlefield.creatures

          def choice_amount = 0..1

          def resolve!(target:)
            deal_damage(3, to: target)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]

      # "Whenever one or more creatures die, put a rev counter on this Equipment." Creatures that die at the same time
      # each put a counter on it, since the engine reports deaths one event at a time.
      class CreatureDiesTrigger < TriggeredAbility
        def call
          add_counter("rev", to: actor)
        end
      end

      # "Equipped creature gets +X/+0, where X is the number of rev counters on this Equipment."
      class RevBuff < Abilities::Static::PowerAndToughnessModification
        applies_to_target

        def power_modification = @source.counters.of_type(Counters::Rev).count

        def toughness_modification = 0
      end

      def static_abilities = [RevBuff]

      def event_handlers = { Events::CreatureDied => CreatureDiesTrigger }
    end
  end
end
