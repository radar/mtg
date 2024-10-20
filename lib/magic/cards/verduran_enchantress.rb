module Magic
  module Cards
    VerduranEnchantress = Creature("Verduran Enchantress") do
      cost green: 2, white: 1
      power 0
      toughness 2
      creature_type "Human Druid"
    end

    class VerduranEnchantress < Creature
      class Choice < Magic::Choice::May
        attr_reader :owner

        def initialize(owner:)
          @owner = owner
        end

        def resolve!
          owner.draw!
        end
      end

      def event_handlers
        {
          Events::SpellCast => ->(receiver, event) do
            return if event.player != receiver.controller
            return unless event.spell.type?("Enchantment")

            game
              .choices
              .add(
                self.class::Choice.new(owner: receiver.controller)
              )
          end
        }
      end


    end
  end
end
