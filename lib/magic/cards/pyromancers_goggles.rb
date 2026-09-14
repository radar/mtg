module Magic
  module Cards
    PyromancersGoggles = Artifact("Pyromancer's Goggles") do
      legendary_artifact
      cost generic: 5
    end

    class PyromancersGoggles < Artifact
      class TapForRed < Magic::TapManaAbility
        choices :red

        def resolve!
          super
          source.pending_mana_ability_uses += 1
        end
      end

      def activated_abilities = [TapForRed]

      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && actor.pending_mana_ability_uses.positive? && spell.colors.include?(:red) && (spell.instant? || spell.sorcery?)
        end

        def call
          actor.pending_mana_ability_uses -= 1
          Magic::CopyEffect.resolve_with_choice!(actor: actor, receiver: spell, targets: event.targets)
        end
      end

      def event_handlers
        { Events::SpellCast => SpellCastTrigger }
      end
    end
  end
end
