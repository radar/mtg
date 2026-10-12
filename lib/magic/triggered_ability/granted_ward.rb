module Magic
  class TriggeredAbility
    # "Permanents you control with counters on them have ward {1}." / "Other Frogs you control have ward {1}."
    # A card that grants ward to other permanents (its own ward uses the `ward` macro) wires a subclass with
    # `GrantedWardSubclass.handlers` from `event_handlers`. Define `warded?(permanent)` and `ward_generic`.
    class GrantedWard < TriggeredAbility
      def self.handlers
        { Events::SpellCast => self, Events::AbilityActivated => self }
      end

      def ward_generic = 1

      def warded?(_permanent) = false

      def should_perform?
        opponents.include?(event.player) && warded_targets.any?
      end

      def warded_targets
        event.targets.select { _1.is_a?(Permanent) && _1.controller == controller && warded?(_1) }
      end

      def call
        spell = event.spell if event.respond_to?(:spell)
        ability = event.ability if event.respond_to?(:ability)
        warded_targets.each do |permanent|
          game.choices.add(Choice::Ward.new(actor: permanent, payer: event.player, spell: spell, ability: ability, generic: ward_generic))
        end
      end
    end
  end
end
