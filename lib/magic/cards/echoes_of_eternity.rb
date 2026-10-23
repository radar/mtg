module Magic
  module Cards
    EchoesOfEternity = Enchantment("Echoes of Eternity") do
      cost generic: 3, colorless: 3
      type T::Kindred, T::Enchantment, T::Creatures["Eldrazi"]
    end

    class EchoesOfEternity < Enchantment
      # "If a triggered ability of a colorless spell you control or another colorless permanent you control triggers, that
      # ability triggers an additional time." Only permanents are consulted by `Permanent#perform_trigger!`.
      class TriggersAdditionalTime < Abilities::Static::TriggeredAbilityDoubler
        def doubles_trigger_for?(permanent, _event)
          permanent != source && permanent.controller == controller && permanent.colorless?
        end
      end

      # "Whenever you cast a colorless spell, copy it. You may choose new targets for the copy."
      class ColorlessSpellTrigger < TriggeredAbility::SpellCast
        def should_perform? = you? && spell.colorless?

        def call
          if spell.permanent?
            Permanent.token_copy(game: game, owner: controller, card: spell)
          else
            Magic::CopyEffect.resolve_with_choice!(actor: actor, receiver: spell, targets: event.targets)
          end
        end
      end

      def static_abilities = [TriggersAdditionalTime]

      def event_handlers = { Events::SpellCast => ColorlessSpellTrigger }
    end
  end
end
