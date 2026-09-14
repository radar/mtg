module Magic
  module Cards
    BattlemagesBracers = Equipment("Battlemage's Bracers") do
      cost generic: 2, red: 1
    end

    class BattlemagesBracers < Equipment
      # Not using the `equip [Costs::Mana.new(...)]` DSL macro here: it
      # captures a single Costs::Mana instance shared across every
      # activation of every permanent for the life of the process, so a
      # second equip anywhere in the same test run overpays into an
      # already-zeroed balance (Overpayment). Building the cost fresh on
      # every `costs` call sidesteps it, same reasoning as blitz_cost/
      # adventure_cost in CLAUDE.md.
      class EquipAbility < ActivatedAbility
        def costs = [Costs::Mana.new(generic: 2)]

        def target_choices
          creatures_you_control
        end

        def resolve!(target:)
          source.attach_to!(target)
        end
      end

      def activated_abilities = [EquipAbility]

      class HasteGrant < Abilities::Static::KeywordGrant
        keyword_grants Keywords::HASTE
        applies_to_target
      end

      def static_abilities = [HasteGrant]

      class MayPayChoice < Magic::Choice::May
        def initialize(actor:, ability:, targets:)
          @ability = ability
          @targets = targets
          super(actor: actor)
        end

        def resolve!(payment: {})
          controller.pay_mana(payment)
          Magic::CopyEffect.resolve_with_choice!(actor: actor, receiver: @ability, targets: @targets)
        end
      end

      class AbilityActivatedTrigger < TriggeredAbility
        def should_perform?
          event.ability.source == actor.attached_to && !event.ability.is_a?(Magic::ManaAbility)
        end

        def call
          game.choices.add(MayPayChoice.new(actor: actor, ability: event.ability, targets: event.targets))
        end
      end

      def event_handlers
        { Events::AbilityActivated => AbilityActivatedTrigger }
      end
    end
  end
end
