module Magic
  module Cards
    MoltenGatekeeper = Creature("Molten Gatekeeper") do
      cost generic: 2, red: 1
      artifact_creature_type "Golem"
      power 2
      toughness 3
    end

    class MoltenGatekeeper < Creature
      # "Whenever another creature you control enters, this creature deals 1 damage to each opponent."
      class CreatureEnteredTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && under_your_control?
        end

        def call
          opponents.each { |opponent| actor.trigger_effect(:deal_damage, damage: 1, target: opponent) }
        end
      end

      def event_handlers
        super.merge(Events::EnteredTheBattlefield => CreatureEnteredTrigger)
      end

      # "Unearth {R}: Return this card from your graveyard to the battlefield. It gains haste. Exile it at the beginning
      # of the next end step or if it would leave the battlefield. Unearth only as a sorcery."
      class ExileAtEndStep < TriggeredAbility::BeginningOfEndStep
        def call = actor.exile!
      end

      class UnearthAbility < Magic::ActivatedAbility
        costs "{R}"

        activate_from_graveyard_as_sorcery

        def resolve!
          permanent = source.resolve!
          return unless permanent.is_a?(Permanent)

          permanent.grant_haste!
          permanent.register_turn_trigger(Events::BeginningOfEndStep, ExileAtEndStep)
          permanent.register_turn_replacement(Effects::MovePermanentZone, ReplacementEffect::ExileInsteadOfDying)
        end
      end

      def graveyard_abilities = [UnearthAbility.new(source: self)]
    end
  end
end
