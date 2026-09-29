module Magic
  module Costs
    # "Remove N counters from among creatures you control" as an additional cost. The
    # payer names each counter: `payment` is an Array of N `[creature, counter_class]`
    # pairs. Applies as soon as it's paid, like the other additional costs `Actions::Cast`
    # takes (it never calls `finalize!` on them).
    class RemoveCountersFromCreatures
      attr_reader :amount

      def initialize(amount)
        @amount = amount
      end

      def can_pay?(player)
        player.creatures.sum { |creature| creature.counters.count } >= amount
      end

      def pay(player:, payment:)
        raise "Remove exactly #{amount} counters" unless payment.size == amount

        payment.each do |creature, counter_type|
          raise "#{creature.name} isn't a creature #{player.inspect} controls" unless creature.creature? && creature.controller == player
        end

        payment.group_by { |creature, counter_type| [creature, counter_type] }.each do |(creature, counter_type), entries|
          raise "#{creature.name} doesn't have #{entries.size} #{counter_type} counters" if creature.counters.of_type(counter_type).size < entries.size
        end

        payment.group_by { |creature, counter_type| [creature, counter_type] }.each do |(creature, counter_type), entries|
          creature.remove_counter(counter_type: counter_type, amount: entries.size)
        end
      end

      def finalize!(_player)
      end
    end
  end
end
