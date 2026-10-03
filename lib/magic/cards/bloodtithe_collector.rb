module Magic
  module Cards
    BloodtitheCollector = Creature("Bloodtithe Collector") do
      cost generic: 4, black: 1
      creature_type("Vampire Noble")
      keywords :flying
      power 3
      toughness 4
    end

    class BloodtitheCollector < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          super && (game.current_turn.events.any? { |e| e.is_a?(Events::LifeLoss) && e.player != controller })
        end

        def call
          game.opponents(controller).each { |opponent| game.add_choice(Magic::Choice::Discard.new(player: opponent)) }
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
