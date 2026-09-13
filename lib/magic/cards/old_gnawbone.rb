module Magic
  module Cards
    OldGnawbone = Creature("Old Gnawbone") do
      legendary_creature_type "Dragon"
      cost "{5}{G}{G}"
      power 7
      toughness 7
      keywords :flying
    end

    class OldGnawbone < Creature
      TreasureToken = Token.create("Treasure") do
        type T::Artifact, "Treasure"
        power 0
        toughness 0

        class ManaAbility < Magic::ManaAbility
          costs "{T}, Sacrifice {this}"
          choices :all
        end

        def activated_abilities = [ManaAbility]
      end

      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          event.target.player? && event.source.controller == controller
        end

        def call
          actor.trigger_effect(:create_token, token_class: TreasureToken, amount: event.damage)
        end
      end

      def event_handlers
        { Events::CombatDamageDealt => CombatDamageTrigger }
      end
    end
  end
end
