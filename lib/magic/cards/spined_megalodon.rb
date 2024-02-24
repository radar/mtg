module Magic
  module Cards
    class SpinedMegalodon < Creature
      card_name "Spined Megalodon"
      creature_type "Shark"
      cost generic: 5, blue: 2
      power 5
      toughness 7

      keywords :hexproof

      class ScryTrigger < TriggeredAbility::Base
        def should_perform?
          return false if event.attacks.none? { |attack| attack.attacker == actor }
          true
        end

        def call
          actor.add_choice(:scry, actor: actor)
        end
      end


      def event_handlers
        {
          Events::PreliminaryAttackersDeclared => ScryTrigger
        }
      end
    end
  end
end
