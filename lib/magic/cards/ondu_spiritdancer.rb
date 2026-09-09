module Magic
  module Cards
    OnduSpiritdancer = Creature("Ondu Spiritdancer") do
      cost generic: 4, white: 1
      creature_type "Kor Cleric"
      power 3
      toughness 3
    end

    class OnduSpiritdancer < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          enchantment? && under_your_control? &&
            !game.current_turn.events.any? { |event| event.is_a?(Events::OnduSpiritdancerCopied) }
        end

        def call
          game.current_turn.events << Events::OnduSpiritdancerCopied.new
          Permanent.resolve(
            game: game,
            owner: controller,
            card: event.permanent.card,
            token: true,
          )
        end
      end

      def event_handlers
        { Events::EnteredTheBattlefield => EntersTrigger }
      end
    end
  end
end