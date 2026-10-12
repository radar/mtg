module Magic
  module Cards
    DourPortMage = Creature("Dour Port-Mage") do
      cost generic: 1, blue: 1
      creature_type("Frog Wizard")
      power 1
      toughness 3
    end

    class DourPortMage < Creature
      # Whenever one or more other creatures you control leave the battlefield without dying, draw a card.
      class LeavesTrigger < TriggeredAbility
        def should_perform?
          event.permanent != actor && event.permanent.creature? && event.permanent.controller == controller && !event.to.graveyard?
        end

        def call
          draw_card
        end
      end

      def event_handlers = super.merge(Events::LeftTheBattlefield => LeavesTrigger)

      # {1}{U}, {T}: Return another target creature you control to its owner's hand.
      class BounceAbility < Magic::ActivatedAbility
        costs "{1}{U}, {T}"

        def target_choices = battlefield.controlled_by(controller).creatures - [source]

        def resolve!(target:)
          trigger_effect(:return_to_owners_hand, target: target)
        end
      end

      def activated_abilities = [BounceAbility]
    end
  end
end
