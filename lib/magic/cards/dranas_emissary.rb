module Magic
  module Cards
    DranasEmissary = Creature("Drana's Emissary") do
      creature_type("Vampire Cleric Ally")
      cost generic: 1, white: 1, black: 1
      keywords :flying
      power 2
      toughness 2
    end

    class DranasEmissary < Creature
      def target_choices(permanent)
        permanent.game.opponents(permanent.controller)
      end

      def event_handlers
        {
          Events::BeginningOfUpkeep => -> (receiver, event) do
            controller = receiver.controller
            return unless game.current_turn.active_player == controller

            controller.gain_life(1)

            effect = Effects::DealDamageToOpponents.new(source: receiver, damage: 1)
            effect.resolve(game.opponents(receiver.controller))

          end
        }
      end
    end
  end
end
