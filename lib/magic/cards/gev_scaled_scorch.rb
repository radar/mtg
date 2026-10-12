module Magic
  module Cards
    GevScaledScorch = Creature("Gev, Scaled Scorch") do
      legendary_creature_type "Lizard Mercenary"
      cost black: 1, red: 1
      power 3
      toughness 2
      ward life: 2
    end

    class GevScaledScorch < Creature
      # Other creatures you control enter with an additional +1/+1 counter on them for each opponent who
      # lost life this turn.
      class ExtraCounters < Abilities::Static::AdditionalCountersForEntering
        def additional_counters_for_entering(permanent)
          return 0 if permanent == source || permanent.controller != controller

          game.opponents(controller).count { game.current_turn.life_lost_by_player(_1).positive? }
        end
      end

      def static_abilities = [ExtraCounters]

      # Whenever you cast a Lizard spell, Gev deals 1 damage to target opponent.
      class LizardCastTrigger < TriggeredAbility::SpellCast
        def should_perform? = event.player == controller && spell.type?("Lizard")

        def call
          opponents.each { |opponent| deal_damage(1, to: opponent) }
        end
      end

      def event_handlers
        handlers = super
        handlers.merge(Events::SpellCast => [*handlers[Events::SpellCast], LizardCastTrigger])
      end
    end
  end
end
