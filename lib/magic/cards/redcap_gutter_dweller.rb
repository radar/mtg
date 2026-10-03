module Magic
  module Cards
    RedcapGutterDweller = Creature("Redcap Gutter-Dweller") do
      cost generic: 2, red: 2
      creature_type("Goblin Warrior")
      keywords :menace
      power 3
      toughness 3
    end

    class RedcapGutterDweller < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        RatToken = Token.create "Rat" do
          creature_type "Rat"
          power 1
          toughness 1
          colors :black
          def can_block?(_) = false
        end

        def call
          trigger_effect(:create_token, token_class: RatToken, amount: 2)
        end
      end

      def etb_triggers = [EntersTrigger]

      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        class SacrificeChoice < Magic::Choice::SacrificePermanent
          def resolve!(**args)
            super(**args)
            trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: 1)
            if (top = controller.library.first)
              trigger_effect(:exile, target: top)
              game.play_permissions.grant_until_end_of_turn(card: top, player: controller)
            end
          end
        end

        def call
          game.choices.add(SacrificeChoice.new(actor: actor, type: "Creature", other: true)) if Magic::Choice::SacrificePermanent.new(actor: actor, type: "Creature", other: true).candidates.any?
        end
      end

      def event_handlers = super.merge({ Events::BeginningOfUpkeep => UpkeepTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
