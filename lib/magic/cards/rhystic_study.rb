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

        def costs
          @costs ||= [Costs::Mana.new(generic: 1)]
        end

        def pay(player:, payment:)
          cost = costs.first
          cost.pay!(player:, payment:)
        end

        def resolve!
          if !costs.all?(&:paid?)
            owner.draw!
          end
        end
      end

      # Whenever an opponent casts a spell,
      # you may draw a card unless that player pays {1}
      def event_handlers
        {
          Events::SpellCast => ->(receiver, event) do
            return if event.player == receiver.controller

            game
              .choices
              .add(
                Magic::Cards::RhysticStudy::Choice.new(owner: receiver.controller,
                  caster: event.player)
              )
          end
        }
      end
    end
  end
end
