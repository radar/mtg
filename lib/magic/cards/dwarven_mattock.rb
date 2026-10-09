module Magic
  module Cards
    DwarvenMattock = Equipment("Dwarven Mattock") do
      cost generic: 2
      equip [Costs::Mana.new(generic: 3)]
    end

    class DwarvenMattock < Equipment
      WARD_COST = 1

      class EquippedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 2
        applies_to_target
      end

      def static_abilities = [EquippedCreatureBuff]

      # "When this Equipment enters, attach it to target Dwarf you control."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures.by_any_type("Dwarf")

          def choice_amount = 1

          def resolve!(target:)
            actor.attach_to!(target)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]

      # "Equipped creature ... has ward {1}." A granted triggered ability has no other home yet, so the Equipment
      # watches for an opponent targeting the creature it is attached to (as Hexing Squelcher does).
      module GrantedWard
        def should_perform?
          creature = actor.attached_to
          creature && opponents.include?(event.player) && event.targets.include?(creature)
        end

        def call
          game.choices.add(
            Choice::Ward.new(actor: actor, payer: event.player, generic: WARD_COST, spell: ward_spell, ability: ward_ability)
          )
        end
      end

      class WardSpellTrigger < TriggeredAbility::SpellCast
        include GrantedWard

        def ward_spell = event.spell
        def ward_ability = nil
      end

      class WardAbilityTrigger < TriggeredAbility
        include GrantedWard

        def ward_spell = nil
        def ward_ability = event.ability
      end

      def event_handlers
        handlers = super
        handlers.merge(
          Events::SpellCast => [*handlers[Events::SpellCast], WardSpellTrigger],
          Events::AbilityActivated => [*handlers[Events::AbilityActivated], WardAbilityTrigger],
        )
      end
    end
  end
end
