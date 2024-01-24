module Magic
  module Cards
    SanctumOfCalmWaters = Enchantment("Sanctum of Calm Waters") do
      type "Legendary Enchantment -- Shrine"
      cost generic: 3, blue: 1

      def event_handlers
        {
          Events::FirstMainPhase => -> (receiver, event) do
            return unless event.active_player == receiver.controller

            game.choices.add(SanctumOfCalmWaters::Choice.new(source: receiver))
          end
        }
      end
    end

    class SanctumOfCalmWaters < Enchantment
      class Choice < Magic::Choice

        def resolve!
          shrines = player.permanents.by_type("Shrine").count
          source.trigger_effect(:draw_cards, number_to_draw: shrines)

          source.add_choice(:discard)
        end
      end
    end
  end
end
