module Magic
  module Cards
    ThermoAlchemist = Creature("Thermo-Alchemist") do
      cost generic: 1, red: 1
      creature_type "Human Shaman"
      power 0
      toughness 3
      keywords :defender
    end

    class ThermoAlchemist < Creature
      class PingAbility < Magic::ActivatedAbility
        costs "{T}"

        def resolve!
          game.opponents(controller).each { |opponent| trigger_effect(:deal_damage, damage: 1, target: opponent) }
        end
      end

      class UntapTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && (spell.instant? || spell.sorcery?)
        end

        def call
          actor.untap!
        end
      end

      def activated_abilities = [PingAbility]

      def event_handlers
        { Events::SpellCast => UntapTrigger }
      end
    end
  end
end
