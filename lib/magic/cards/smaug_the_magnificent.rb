module Magic
  module Cards
    SmaugTheMagnificent = Creature("Smaug the Magnificent") do
      cost generic: 2, red: 2
      legendary_creature_type "Dragon"
      keywords :flying, :haste
      power 4
      toughness 3
    end

    class SmaugTheMagnificent < Creature
      # "Whenever Smaug attacks, he deals damage equal to the number of Treasures you control to any target."
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices = game.any_target

          def choice_amount = 1

          def resolve!(target:)
            treasures = controller.permanents.count { _1.type?("Treasure") }
            trigger_effect(:deal_damage, target: target, damage: treasures) if treasures.positive?
          end
        end

        def call
          game.add_choice(TargetChoice.new(actor: actor))
        end
      end

      # "At the beginning of your upkeep, create a Treasure token."
      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def call
          trigger_effect(:create_token, token_class: Tokens::Treasure)
        end
      end

      def event_handlers
        super.merge({
          Events::FinalAttackersDeclared => AttacksTrigger,
          Events::BeginningOfUpkeep => UpkeepTrigger,
        }) { |_, old, new| [*old, *new] }
      end
    end
  end
end
