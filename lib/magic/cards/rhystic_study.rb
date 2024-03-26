module Magic
  module Cards
    RhysticStudy = Enchantment("Rhystic Study") do
      type "Enchantment"
      cost generic: 2, blue: 1
    end

    class RhysticStudy < Enchantment
      class Choice < Magic::Choice
        attr_reader :owner, :caster

        def initialize(owner:, caster:)
          @owner = owner
          @caster = caster
        end

        def choose(mana:)
          ensure_paying_correct_cost(mana: mana)
          owner.draw! unless mana && caster.pay_mana(mana)
        end

        private

        def cost = 1

        def ensure_paying_correct_cost(mana:)
          raise "Must only pay 1 mana if paying" if mana && Magic::Costs::Mana.new(mana).mana_value != cost
        end
      end

      # Whenever an opponent casts a spell,
      # you may draw a card unless that player pays {1}
      def event_handlers
        {
          Events::SpellCast => ->(receiver, event) do
            if event.player != receiver.controller
              game
                .choices
                .add(
                  Magic::Cards::RhysticStudy::Choice.new(owner: receiver.controller,
                    caster: event.player)
                )
            end
          end
        }
      end
    end
  end
end
