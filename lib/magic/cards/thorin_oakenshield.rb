module Magic
  module Cards
    ThorinOakenshield = Creature("Thorin Oakenshield") do
      cost red: 1, white: 1
      legendary_creature_type "Dwarf Noble"
      keywords :trample
      power 3
      toughness 2
    end

    class ThorinOakenshield < Creature
      # "Storied (...)  As long as you have an enduring story, artifacts and creatures you control have ward {1}."
      # Ward is a triggered ability of the warded permanent; Thorin watches for a targeting spell or ability instead,
      # which is equivalent for the controller's permanents.
      module WardGrant
        def warded_target
          return unless Magic::Storied.enduring_story?(controller)

          event.targets.find do |target|
            target.is_a?(Magic::Permanent) && target.controller == controller && (target.artifact? || target.creature?)
          end
        end
      end

      class SpellWardTrigger < TriggeredAbility::SpellCast
        include WardGrant

        def should_perform?
          opponents.include?(event.player) && warded_target
        end

        def call
          game.choices.add(Choice::Ward.new(actor: warded_target, payer: event.player, spell: event.spell, generic: 1))
        end
      end

      class AbilityWardTrigger < TriggeredAbility
        include WardGrant

        def should_perform?
          opponents.include?(event.player) && warded_target
        end

        def call
          game.choices.add(Choice::Ward.new(actor: warded_target, payer: event.player, ability: event.ability, generic: 1))
        end
      end

      def event_handlers
        super.merge({ Events::SpellCast => SpellWardTrigger, Events::AbilityActivated => AbilityWardTrigger }) { |_, old, new| [*old, *new] }
      end
    end
  end
end
