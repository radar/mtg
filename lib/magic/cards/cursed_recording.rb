module Magic
  module Cards
    CursedRecording = Artifact("Cursed Recording") do
      cost generic: 2, red: 2
    end

    class CursedRecording < Artifact
      class CopyNextSpell < ActivatedAbility
        costs "{T}"

        def resolve!
          source.pending_mana_ability_uses += 1
        end
      end

      def activated_abilities = [CopyNextSpell]

      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && (spell.instant? || spell.sorcery?)
        end

        def call
          actor.add_counter(Counters::Time)
          time_counters = actor.counters.of_type(Counters::Time).count
          if time_counters >= 7
            actor.remove_counter(counter_type: Counters::Time, amount: time_counters)
            trigger_effect(:deal_damage, source: actor, target: controller, damage: 20)
          end
        end
      end

      class CopyTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && actor.pending_mana_ability_uses.positive? && (spell.instant? || spell.sorcery?)
        end

        def call
          actor.pending_mana_ability_uses -= 1
          Magic::CopyEffect.resolve_with_choice!(actor: actor, receiver: spell, targets: event.targets)
        end
      end

      def event_handlers
        { Events::SpellCast => [SpellCastTrigger, CopyTrigger] }
      end
    end
  end
end
