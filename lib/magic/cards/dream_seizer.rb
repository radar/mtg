module Magic
  module Cards
    DreamSeizer = Creature("Dream Seizer") do
      cost generic: 3, black: 1
      creature_type("Faerie Rogue")
      keywords :flying
      power 3
      toughness 2
    end

    class DreamSeizer < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class MayChoice < Magic::Choice::May
          class BlightChoice < Magic::Choice::Blight
            def resolve!(**args)
              super(**args)
              game.opponents(controller).each { |opponent| game.add_choice(Magic::Choice::Discard.new(player: opponent)) }
            end
          end

          def resolve!
            game.choices.add(BlightChoice.new(actor: actor, amount: 1)) if Magic::Choice::Blight.possible?(controller, game)
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
