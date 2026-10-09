module Magic
  module Cards
    DinIronfoot = Creature("Dáin Ironfoot") do
      cost generic: 2, red: 1
      legendary_creature_type("Dwarf Warrior")
      power 1
      toughness 4
    end

    class DinIronfoot < Creature
      # "When Dáin enters, create a colorless Equipment artifact token named Axe ... When you do, attach it to
      # target creature you control."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class AttachChoice < Magic::Choice::Targeted
          def initialize(actor:, axe:)
            @axe = axe
            super(actor: actor)
          end

          def choices = battlefield.controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            @axe.attach_to!(target)
          end
        end

        def call
          axe = Array(trigger_effect(:create_token, token_class: Tokens::Axe, controller: controller)).flatten.first
          return unless axe

          choice = AttachChoice.new(actor: actor, axe: axe)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]

      # "Whenever Dáin attacks, each equipped attacking creature gains double strike until end of turn."
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        def call
          battlefield.controlled_by(controller).attacking.each do |creature|
            next unless creature.attachments.any? { _1.type?("Equipment") }

            trigger_effect(:grant_keyword, target: creature, keyword: :double_strike)
          end
        end
      end

      def event_handlers = super.merge(Events::FinalAttackersDeclared => AttacksTrigger)
    end
  end
end
