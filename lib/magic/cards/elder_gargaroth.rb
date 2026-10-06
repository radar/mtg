module Magic
  module Cards
    ElderGargaroth = Creature("Elder Gargaroth") do
      cost generic: 3, green: 2
      creature_type "Beast"
      keywords :reach, :vigilance, :trample
      power 6
      toughness 6
    end

    class ElderGargaroth < Creature
      BeastToken = Token.create("Beast") do
        creature_type "Beast"
        power 3
        toughness 3
        colors :green
      end

      class Choice < Magic::Choice
        def modes
          {
            token: "Create a 3/3 green Beast creature token",
            life: "You gain 3 life",
            draw: "Draw a card"
          }
        end

        def resolve!(mode:)
          case mode
          when :token then trigger_effect(:create_token, token_class: BeastToken)
          when :life then trigger_effect(:gain_life, life: 3)
          when :draw then trigger_effect(:draw_card)
          else raise "Invalid mode chosen for Elder Gargaroth: #{mode}"
          end
        end
      end

      # "Whenever this creature attacks or blocks, choose one -- ..."
      class AttacksOrBlocksTrigger < TriggeredAbility
        def should_perform?
          (event.respond_to?(:blocker) ? event.blocker : event.attacker) == actor
        end

        def call
          game.add_choice(Choice.new(actor: actor))
        end
      end

      def event_handlers
        {
          Events::CreatureAttacked => AttacksOrBlocksTrigger,
          Events::CreatureBlocked => AttacksOrBlocksTrigger
        }
      end
    end
  end
end
