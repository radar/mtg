# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "~ costs {1} less to cast for each color among permanents you control." / "~ costs
      # {2} less to cast if you control a Kithkin." -> `self_mana_cost_adjustment`, which
      # `Actions::Cast` reads when it builds the cost. The lambda is called then, so the
      # count or condition sees the battlefield as it is at that moment. (A card in hand
      # has no controller yet, so its owner stands in for it.)
      class SelfCostReduction < Data.define(:amount, :count, :condition)
        include Rule

        LINE = /\A~ costs \{(?<amount>\d+)\} less to cast (?:for each (?<count>[^.]+)|if (?<condition>[^.]+))\.?\z/i

        # "Affinity for Gates" (Gate Colossus) is "~ costs {1} less to cast for each Gate you control."
        AFFINITY = /\AAffinity for (?<type>[A-Za-z]+)\z/

        def self.parse(line)
          line = "~ costs {1} less to cast for each #{$~[:type].delete_suffix('s')} you control." if AFFINITY.match(line)
          return unless (m = LINE.match(line))

          if m[:count]
            count = Count.parse(m[:count], this: "self") or return
            new(amount: m[:amount].to_i, count:, condition: nil)
          else
            condition = Condition.parse(m[:condition]) or return
            new(amount: m[:amount].to_i, count: nil, condition: condition.gsub(/\bsource\b/, "self"))
          end
        end

        def body_source
          expression = count ? "-#{amount == 1 ? '' : "#{amount} * "}#{count}" : "(#{condition}) ? -#{amount} : 0"
          <<~RUBY
            def self_mana_cost_adjustment
              controller = self.controller || owner
              { generic: -> { #{expression} } }
            end
          RUBY
        end
      end
    end
  end
end
