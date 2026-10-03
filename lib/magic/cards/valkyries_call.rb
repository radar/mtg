module Magic
  module Cards
    ValkyriesCall = Enchantment("Valkyrie's Call") do
      cost generic: 3, white: 2
    end

    class ValkyriesCall < Enchantment
      class NontokenNonTribalDiesTrigger < TriggeredAbility
        def should_perform?
          you? && !event.permanent.token? && !event.permanent.type?("Angel")
        end

        def call
          card = event.permanent.card
          if card.zone&.graveyard?
            returned = card.resolve!(controller: card.owner)
            if returned.is_a?(Permanent)
              returned.add_counter(Counters["+1/+1"])
              returned.grant_keyword(Keywords.one(:flying), until_eot: false)
              returned.add_types(T::Creatures["Angel"], until_eot: false)
            end
          end
        end
      end

      def event_handlers = super.merge({ Events::CreatureDied => NontokenNonTribalDiesTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
