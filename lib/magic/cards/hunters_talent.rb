module Magic
  module Cards
    class HuntersTalent < ClassEnchantment
      card_name "Hunter's Talent"
      cost generic: 1, green: 1
      level_costs 2 => "{1}{G}", 3 => "{3}{G}"

      # When this Class enters, target creature you control deals damage equal to its power to target
      # creature you don't control.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class VictimChoice < Magic::Choice::Targeted
          def initialize(actor:, biter:)
            @biter = biter
            super(actor: actor)
          end

          def choices = battlefield.not_controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            @biter.bite!(target)
          end
        end

        class BiterChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            choice = VictimChoice.new(actor: actor, biter: target)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        def call
          choice = BiterChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any? && battlefield.not_controlled_by(controller).creatures.any?
        end
      end

      def etb_triggers = [EntersTrigger]

      # Level 2: Whenever you attack, target attacking creature gets +1/+0 and gains trample until end of turn.
      class AttackTrigger < TriggeredAbility::YouAttack
        class PumpChoice < Magic::Choice::Targeted
          def initialize(actor:, attackers:)
            @attackers = attackers
            super(actor: actor)
          end

          def choices = @attackers

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:modify_power_toughness, power: 1, toughness: 0, target: target, until_eot: true)
            trigger_effect(:grant_keyword, target: target, keyword: :trample)
          end
        end

        def should_perform? = actor.level >= 2 && super

        def call
          game.add_choice(PumpChoice.new(actor: actor, attackers: attackers))
        end
      end

      # Level 3: At the beginning of your end step, if you control a creature with power 4 or greater, draw a card.
      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          actor.level >= 3 && controllers_end_step? && battlefield.controlled_by(controller).creatures.any? { _1.power >= 4 }
        end

        def call
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      def event_handlers
        super.merge(AttackTrigger.handlers).merge(Events::BeginningOfEndStep => EndStepTrigger)
      end
    end
  end
end
