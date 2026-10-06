module Magic
  module Cards
    ChandrasPyreling = Creature("Chandra's Pyreling") do
      cost generic: 1, red: 1
      creature_type "Elemental Lizard"
      power 1
      toughness 3
    end

    class ChandrasPyreling < Creature
      # "Whenever a source you control deals noncombat damage to an opponent, this creature gets +1/+0 and gains
      # double strike until end of turn."
      class DamageTrigger < TriggeredAbility::NoncombatDamageToOpponent
        def call
          trigger_effect(:modify_power_toughness, target: actor, power: 1, toughness: 0)
          actor.grant_keyword(Keywords::DOUBLE_STRIKE)
        end
      end

      def event_handlers = { Events::DamageDealt => DamageTrigger }
    end
  end
end
