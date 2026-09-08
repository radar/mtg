module Magic
  module Cards
    FelidarRetreat = Enchantment("Felidar Retreat") do
      cost generic: 3, white: 1
    end

    class FelidarRetreat < Enchantment
      CatBeastToken = Token.create("Cat Beast") do
        creature_type "Cat Beast"
        power 2
        toughness 2
        colors :white
      end

      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform?
          event.player == controller
        end

        def call
          game.add_choice(Choice.new(actor: actor))
        end
      end

      class Choice < Magic::Choice
        def resolve!(mode:)
          case mode
          when :token
            actor.trigger_effect(:create_token, token_class: CatBeastToken)
          when :counter
            controller.creatures.each do |creature|
              actor.trigger_effect(:add_counter, target: creature, counter_type: "+1/+1")
              creature.grant_keyword(Cards::Keywords::VIGILANCE)
            end
          else
            raise "Invalid mode chosen for Felidar Retreat: #{mode}"
          end
        end
      end

      def event_handlers
        { Events::Landfall => LandfallTrigger }
      end
    end
  end
end