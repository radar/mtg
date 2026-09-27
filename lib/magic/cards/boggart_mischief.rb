module Magic
  module Cards
    BoggartMischief = Enchantment("Boggart Mischief") do
      cost generic: 2, black: 1
      type T::Kindred, T::Enchantment, T::Creatures["Goblin"]
    end

    class BoggartMischief < Enchantment
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
            game.choices.add(BlightChoice.new(actor: actor, amount: 1)) if Magic::Choice::Blight.possible?(controller, game)
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]

      class TribalCreatureDiesTrigger < TriggeredAbility
        def should_perform?
          you? && event.permanent.type?("Goblin")
        end

        def call
          game.opponents(controller).each { trigger_effect(:lose_life, target: _1, life: 1) }
          trigger_effect(:gain_life, target: controller, life: 1)
        end
      end

      def event_handlers = { Events::CreatureDied => TribalCreatureDiesTrigger }
    end
  end
end
