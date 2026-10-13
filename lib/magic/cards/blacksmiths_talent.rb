module Magic
  module Cards
    class BlacksmithsTalent < ClassEnchantment
      card_name "Blacksmith's Talent"
      cost red: 1
      level_costs 2 => "{2}{R}", 3 => "{3}{R}"

      # When this Class enters, create a colorless Equipment artifact token named Sword with "Equipped
      # creature gets +1/+1" and equip {2}.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          create_token(token:Tokens::Sword)
        end
      end

      def etb_triggers = [EntersTrigger]

      # Level 2: At the beginning of combat on your turn, attach target Equipment you control to up to one
      # target creature you control.
      class CombatTrigger < TriggeredAbility
        class CreatureChoice < Magic::Choice::Targeted
          def initialize(actor:, equipment:)
            @equipment = equipment
            super(actor: actor)
          end

          def choices = battlefield.controlled_by(controller).creatures

          def choice_amount = 0..1

          def resolve!(target:)
            @equipment.attach_to!(target)
          end
        end

        class EquipmentChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).select { _1.type?("Equipment") }

          def choice_amount = 1

          def resolve!(target:)
            choice = CreatureChoice.new(actor: actor, equipment: target)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        def should_perform? = actor.level >= 2 && controllers_turn?

        def call
          choice = EquipmentChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge(Events::BeginningOfCombat => CombatTrigger)

      # Level 3: During your turn, equipped creatures you control have double strike and haste.
      class EquippedKeywords < Abilities::Static::KeywordGrant
        keyword_grants Keywords::DOUBLE_STRIKE, Keywords::HASTE

        def applicable_targets
          return [] unless source.level >= 3 && game.current_turn.active_player == controller

          battlefield.controlled_by(controller).creatures.select { |creature| creature.attachments.any? { _1.type?("Equipment") } }
        end
      end

      def static_abilities = [EquippedKeywords]
    end
  end
end
