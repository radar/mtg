module Magic
  module Cards
    ThoughtweftLieutenant = Creature("Thoughtweft Lieutenant") do
      cost green: 1, white: 1
      creature_type("Kithkin Soldier")
      power 2
      toughness 2
    end

    class ThoughtweftLieutenant < Creature
      class TribalEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          under_your_control? && (event.permanent == actor || event.permanent.type?("Kithkin"))
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.controlled_by(controller).creatures
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:modify_power_toughness, target: target, power: 1, toughness: 1)
            trigger_effect(:grant_keyword, target: target, keyword: :trample)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => TribalEntersTrigger }
    end
  end
end
