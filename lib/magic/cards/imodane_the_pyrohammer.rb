module Magic
  module Cards
    ImodaneThePyrohammer = Creature("Imodane, the Pyrohammer") do
      legendary_creature_type "Human Knight"
      cost "{2}{R}{R}"
      power 4
      toughness 4
    end

    class ImodaneThePyrohammer < Creature
      class DamageTrigger < TriggeredAbility
        def should_perform?
          (instant? || sorcery?) &&
            spell_controlled_by_you? &&
            single_target_spell? &&
            damage_target_creature?
        end

        def call
          opponents.each { |opponent| actor.trigger_effect(:deal_damage, damage: event.damage, target: opponent) }
        end
      end

      def event_handlers
        { Events::DamageDealt => DamageTrigger }
      end
    end
  end
end
