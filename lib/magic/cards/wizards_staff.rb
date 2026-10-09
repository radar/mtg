module Magic
  module Cards
    WizardsStaff = Equipment("Wizard's Staff") do
      cost generic: 1, blue: 1
    end

    class WizardsStaff < Equipment
      # "Equipped creature has prowess."
      class GrantProwess < Abilities::Static::KeywordGrant
        keyword_grants Keywords::PROWESS
        applies_to_target
      end

      # "If a triggered ability of equipped creature triggers, that ability triggers an additional time."
      class EquippedCreatureTriggersAgain < Abilities::Static::TriggeredAbilityDoubler
        def doubles_trigger_for?(permanent, _event)
          permanent == @source.attached_to
        end
      end

      def static_abilities = [GrantProwess, EquippedCreatureTriggersAgain]

      # The prowess a granted keyword stands for: "Whenever you cast a noncreature spell, this creature gets +1/+1 until
      # end of turn." It is a triggered ability of the equipped creature, so the Staff's own doubling applies to it.
      class ProwessTrigger < TriggeredAbility::SpellCast
        def should_perform?
          creature = actor.attached_to
          creature&.creature? && you? && !spell.creature?
        end

        def call
          creature = actor.attached_to
          times = 1 + game.battlefield.static_abilities.of_type(Abilities::Static::TriggeredAbilityDoubler).count { _1.doubles_trigger_for?(creature, event) }
          times.times do
            actor.trigger_effect(:modify_power_toughness, source: creature, target: creature, power: 1, toughness: 1)
          end
        end
      end

      def event_handlers = super.merge({ Events::SpellCast => ProwessTrigger }) { |_, old, new| [*old, *new] }

      # "Equip Wizard {1}" and "Equip {3}"
      class EquipWizardAbility < Magic::ActivatedAbility
        costs "{1}"
        activate_only_as_sorcery

        def target_choices = controller.creatures.select { _1.type?("Wizard") }

        def resolve!(target:)
          source.attach_to!(target)
        end
      end

      class EquipAbility < Magic::ActivatedAbility
        costs "{3}"
        activate_only_as_sorcery

        def target_choices = controller.creatures

        def resolve!(target:)
          source.attach_to!(target)
        end
      end

      def activated_abilities = [EquipWizardAbility, EquipAbility]
    end
  end
end
