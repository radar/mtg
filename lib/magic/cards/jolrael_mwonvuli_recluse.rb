module Magic
  module Cards
    JolraelMwonvuliRecluse = Creature("Jolrael, Mwonvuli Recluse") do
      legendary_creature_type "Human Druid"
      cost generic: 2, green: 1
      power 2
      toughness 3
    end

    class JolraelMwonvuliRecluse < Creature
      CatToken = Token.create "Cat" do
        creature_type "Cat"
        power 2
        toughness 2
        colors :green
      end

      class SecondCardDrawTrigger < TriggeredAbility
        def should_perform?
          return false unless event.player == controller

          card_draws = game.current_turn.events.select do |e|
            e.is_a?(Events::CardDraw) && e.player == controller
          end
          card_draws.count == 2
        end

        def call
          actor.trigger_effect(:create_token, token_class: CatToken)
        end
      end

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{4}{G}{G}"

        def resolve!
          x = controller.hand.count
          source.controller.creatures.each do |creature|
            creature.modify_base_power(x)
            creature.modify_base_toughness(x)
          end
        end
      end

      def event_handlers
        {
          Events::CardDraw => SecondCardDrawTrigger
        }
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
