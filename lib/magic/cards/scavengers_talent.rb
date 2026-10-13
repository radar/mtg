module Magic
  module Cards
    class ScavengersTalent < ClassEnchantment
      card_name "Scavenger's Talent"
      cost black: 1
      level_costs 2 => "{1}{B}", 3 => "{2}{B}"

      # Whenever one or more creatures you control die, create a Food token. This ability triggers
      # only once each turn.
      class DiesTrigger < TriggeredAbility
        def should_perform?
          event.controller == controller && !actor.triggered_once_this_turn?(self.class)
        end

        def trigger!
          return false unless should_perform?

          actor.trigger_once_this_turn!(self.class)
          true
        end

        def call
          create_token(token:Tokens::Food)
        end
      end

      # Level 2: Whenever you sacrifice a permanent, target player mills two cards.
      class SacrificeTrigger < TriggeredAbility
        class MillChoice < Magic::Choice::Targeted
          def choices = game.players

          def choice_amount = 1

          def resolve!(target:)
            target.mill(2)
          end
        end

        def should_perform? = actor.level >= 2 && event.permanent.controller == controller

        def call
          game.add_choice(MillChoice.new(actor: actor))
        end
      end

      # Level 3: At the beginning of your end step, you may sacrifice three other nonland permanents.
      # If you do, return a creature card from your graveyard to the battlefield with a finality counter.
      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        class ReturnChoice < Magic::Choice::Targeted
          def choices = controller.graveyard.creatures

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:return_target_from_graveyard_to_battlefield, target: target, controller: controller, counters: { "finality" => 1 })
          end
        end

        class SacrificeChoice < Magic::Choice
          def choices = battlefield.controlled_by(controller).reject { _1.land? || _1 == actor }

          def resolve!(permanents:)
            raise ArgumentError, "sacrifice exactly three other nonland permanents" unless permanents.uniq.size == 3 && (permanents - choices).empty?

            permanents.each(&:sacrifice!)
            choice = ReturnChoice.new(actor: actor)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        class MayChoice < Magic::Choice::May
          def resolve!
            choice = SacrificeChoice.new(actor: actor)
            game.choices.add(choice) if choice.choices.size >= 3
          end
        end

        def should_perform? = actor.level >= 3 && controllers_end_step?

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def event_handlers
        super.merge(
          Events::CreatureDied => DiesTrigger,
          Events::PermanentSacrificed => SacrificeTrigger,
          Events::BeginningOfEndStep => EndStepTrigger
        )
      end
    end
  end
end
