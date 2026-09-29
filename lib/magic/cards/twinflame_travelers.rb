module Magic
  module Cards
    TwinflameTravelers = Creature("Twinflame Travelers") do
      cost generic: 2, blue: 1, red: 1
      creature_type("Elemental Sorcerer")
      power 3
      toughness 3
      keywords :flying
    end

    class TwinflameTravelers < Creature
      # If a triggered ability of another Elemental you control triggers, it triggers an
      # additional time.
      class TriggersAdditionalTime < Abilities::Static::TriggeredAbilityDoubler
        def doubles_trigger_for?(permanent, _event)
          permanent != source && permanent.controller == controller && permanent.type?("Elemental")
        end
      end

      def static_abilities = [TriggersAdditionalTime]
    end
  end
end
