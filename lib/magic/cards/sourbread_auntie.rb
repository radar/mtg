module Magic
  module Cards
    SourbreadAuntie = Creature("Sourbread Auntie") do
      cost generic: 2, red: 2
      creature_type("Goblin Warrior")
      power 4
      toughness 3
    end

    class SourbreadAuntie < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        GoblinToken = Token.create "Goblin" do
          creature_type "Goblin"
          power 1
          toughness 1
          colors :black, :red
        end

        class MayChoice < Magic::Choice::May
          class BlightChoice < Magic::Choice::Blight
            def resolve!(**args)
              super(**args)
              trigger_effect(:create_token, token_class: GoblinToken, amount: 2)
            end
          end

          def resolve!
            game.choices.add(BlightChoice.new(actor: actor, amount: 2)) if Magic::Choice::Blight.possible?(controller, game)
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
