module Magic
  module Cards
    HexingSquelcher = Creature("Hexing Squelcher") do
      creature_type "Goblin Sorcerer"
      cost generic: 1, red: 1
      power 2
      toughness 2
      cant_be_countered
      ward life: 2
    end

    class HexingSquelcher < Creature
      # Spells you control can't be countered.
      class PreventCountering < StaticAbility
        def prevents_countering?(card) = card.controller == controller
      end

      def static_abilities = [PreventCountering]

      # Other creatures you control have "Ward--Pay 2 life." Modelled as Squelcher's own
      # triggers watching for an opponent targeting one of those creatures (one ward trigger
      # per warded creature targeted), since a granted triggered ability has no other home yet.
      module GrantedWard
        WARD_LIFE = 2

        def warded_targets
          event.targets.select do |target|
            target != actor && target.respond_to?(:creature?) && target.creature? && target.controller == controller
          end
        end

        def should_perform?
          opponents.include?(event.player) && warded_targets.any?
        end

        def call
          warded_targets.each do
            game.choices.add(
              Choice::Ward.new(actor: actor, payer: event.player, life: WARD_LIFE, spell: ward_spell, ability: ward_ability)
            )
          end
        end
      end

      class OtherCreaturesWardSpellTrigger < TriggeredAbility::SpellCast
        include GrantedWard

        def ward_spell = event.spell
        def ward_ability = nil
      end

      class OtherCreaturesWardAbilityTrigger < TriggeredAbility
        include GrantedWard

        def ward_spell = nil
        def ward_ability = event.ability
      end

      def event_handlers
        handlers = super
        handlers.merge(
          Events::SpellCast => [*handlers[Events::SpellCast], OtherCreaturesWardSpellTrigger],
          Events::AbilityActivated => [*handlers[Events::AbilityActivated], OtherCreaturesWardAbilityTrigger],
        )
      end
    end
  end
end
