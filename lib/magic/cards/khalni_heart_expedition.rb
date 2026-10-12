module Magic
  module Cards
    KhalniHeartExpedition = Enchantment("Khalni Heart Expedition") do
      cost generic: 1, green: 1
    end

    class KhalniHeartExpedition < Enchantment
      class ActivatedAbility < Magic::ActivatedAbility
        costs "Remove 3 quest counters from {this}, Sacrifice {this}"

        def resolve!
          game.search_library(source, find: :basic_lands, to: :battlefield, tapped: true, upto: 2)
        end
      end

      def activated_abilities = [ActivatedAbility]

      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform?
          you?
        end

        class MayChoice < Magic::Choice::May
          def prompt = "Put a quest counter on Khalni Heart Expedition?"

          def resolve!
            trigger_effect(:add_counter, counter_type: "quest", target: actor, amount: 1)
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def event_handlers = { Events::Landfall => LandfallTrigger }
    end
  end
end
