module Magic
  module Cards
    ConstrictorSage = Creature("Constrictor Sage") do
      cost generic: 4, blue: 1
      creature_type("Snake Wizard")
      power 4
      toughness 4
    end

    class ConstrictorSage < Creature
      class GraveyardAbility < Magic::ActivatedAbility
        costs "{2}{U}, Exile {this}"

        activate_from_graveyard_as_sorcery

        def target_choices
          battlefield.not_controlled_by(controller).creatures
        end

        def resolve!(target:)
          tap_permanent(target)
          add_counter("stun", to: target)
        end
      end

      def graveyard_abilities = [GraveyardAbility.new(source: self)]

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
    end
  end
end
