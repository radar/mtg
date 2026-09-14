module Magic
  module Cards
    class PyromancersGoggles < Artifact
      card_name "Pyromancer's Goggles"
      type T::Super::Legendary, T::Artifact
      cost generic: 5

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
