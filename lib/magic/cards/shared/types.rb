module Magic
  module Cards
    module Shared
      module Types
        def self.included(base)
          base.class_eval do
            class << self
              def type(type)
                const_set(:TYPE_LINE, type)
              end

              def creature_types(types)
                types.split(" ").map { T::Creatures[_1] }.join(" ")
              end

              def creature_type(types)
                type("#{T::Creature} -- #{creature_types(types)}")
              end

              def artifact_creature_type(types)
                type("#{T::Artifact} #{T::Creature} -- #{creature_types(types)}")
              end
            end
          end
        end
      end
    end
  end
end
