module Magic
  module Cards
    SporewebWeaver = Creature("Sporeweb Weaver") do
      cost generic: 1, green: 1
      creature_type "Spider"
      power 2
      toughness 4
    end

    class SporewebWeaver < Creature
      KEYWORDS = [Keywords::REACH, Keywords::HexproofFrom.new(:blue)]
      SaprolingToken = Token.create "Saproling" do
        creature_type "Saproling"
        power 1
        toughness 1
        colors :green
      end

      class DamageTrigger < TriggeredAbility
        def should_perform?
          event.target == actor
        end

        def call
          trigger_effect(:gain_life, source: actor, life: 1)
          trigger_effect(:create_token, token_class: SaprolingToken)
        end
      end

      def event_handlers
        {
          Events::DamageDealt => DamageTrigger
        }
      end
    end
  end
end
