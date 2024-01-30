module Magic
  module Cards
    module Shared
      module Characteristics
        def self.included(base)
          base.class_eval do
            def creature_types(types)
              types.split(" ").map { T::Creatures[_1] }.join(" ")
            end

            def creature_type(types)
              type("#{T::Creature} -- #{creature_types(types)}")
            end

            def artifact_creature_type(types)
              type("#{T::Artifact} #{T::Creature} -- #{creature_types(types)}")
            end

            def type(type)
              const_set(:TYPE_LINE, type)
            end

            def cost(cost)
              const_set(:COST, cost)
            end

            def kicker_cost(cost)
              const_set(:KICKER_COST, cost)
            end

            def power(power)
              const_set(:POWER, power)
            end

            def toughness(power)
              const_set(:TOUGHNESS, power)
            end

            def keywords(*keywords)
              const_set(:KEYWORDS, Keywords[*keywords])

              include Cards::KeywordHandlers::Prowess if keywords.include?(:prowess)
            end

            def protections(*protections)
              const_set(:PROTECTIONS, *protections)
            end

          end
        end
      end
    end
  end
end
