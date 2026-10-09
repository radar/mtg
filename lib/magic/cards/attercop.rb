module Magic
  module Cards
    Attercop = Creature("Attercop") do
      cost generic: 1, green: 1
      creature_type("Spider")
      keywords :reach, :deathtouch
      power 2
      toughness 1
    end

    class Attercop < Creature
      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform?
          you?
        end

        def call
          trigger_effect(:modify_power_toughness, target: actor, power: 1, toughness: 1)
        end
      end

      def event_handlers = super.merge({ Events::Landfall => LandfallTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
