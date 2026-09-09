module Magic
  module Cards
    EumidianWastewaker = Creature("Eumidian Wastewaker") do
      cost generic: 2, black: 2
      creature_type "Insect Cleric"
      power 3
      toughness 3
    end

    class EumidianWastewaker < Creature
      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { |attack| attack.attacker == actor }
        end

        def call
          [controller, event.attacks.find { |attack| attack.attacker == actor }.target].compact.each do |player|
            if player.hand.any?
              player.hand.last.discard!
            elsif player.permanents.any?
              player.permanents.first.sacrifice!
            end
          end
        end
      end

      def event_handlers
        { Events::FinalAttackersDeclared => AttackTrigger }
      end
    end
  end
end