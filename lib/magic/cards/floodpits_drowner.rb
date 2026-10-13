module Magic
  module Cards
    FloodpitsDrowner = Creature("Floodpits Drowner") do
      cost generic: 1, blue: 1
      creature_type "Merfolk"
      keywords :flash, :vigilance
      power 2
      toughness 1
    end

    class FloodpitsDrowner < Creature
      # "When this creature enters, tap target creature an opponent controls and put a stun counter on it."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.not_controlled_by(controller).creatures
          end

          def choice_amount = 1

          def resolve!(target:)
            tap_permanent(target)
            add_counter("stun", to: target)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]

      # "{1}{U}, {T}: Shuffle this creature and target creature with a stun counter on it into their owners' libraries."
      class ShuffleAbility < Magic::ActivatedAbility
        costs "{1}{U}, {T}"

        def target_choices
          battlefield.creatures.select { _1.counters.of_type(Counters::Stun).any? }
        end

        def resolve!(target:)
          game.add_effect(Effects::ShuffleIntoLibrary.new(source: source, target: source))
          game.add_effect(Effects::ShuffleIntoLibrary.new(source: source, target: target))
        end
      end

      def activated_abilities = [ShuffleAbility]
    end
  end
end
