module Magic
  module Cards
    class DoublingSeason < Enchantment
      card_name "Doubling Season"
      cost generic: 4, green: 1

      class CounterDoubler < ReplacementEffect
        # If an effect would put one or more counters on a permanent you control ...
        def applies?(effect)
          effect.target.controller == receiver.controller
        end

        def call(effect)
          Effects::AddCounterToPermanent.new(
            source: receiver,
            counter_type: effect.counter_type,
            target: effect.target,
            amount: effect.amount * 2,
          )
        end
      end

      def replacement_effects
        {
          Effects::CreateToken => ReplacementEffect::TokenDoubler,
          Effects::AddCounterToPermanent => CounterDoubler,
        }
      end
    end
  end
end
