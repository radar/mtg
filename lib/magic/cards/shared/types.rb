module Magic
  module Cards
    module Shared
      module Types
        def self.included(base)
          base.class_eval do
            class << self
              def set_types(*types)
                const_set(:TYPE_LINE, types)
              end

              def types
                const_get(:TYPE_LINE)
              end

              def creature_types(types)
                types.split(/(?<!Time) (?!Lord)/).map { T::Creatures[_1] }.join(" ")
              end

              def creature_type(types)
                set_types(T::Creature, *creature_types(types))
              end

              def artifact_creature_type(types)
                set_types(T::Artifact, T::Creature, *creature_types(types))
              end

              def type(*types)
                set_types(*types)
              end
            end
          end
        end
      end
    end
  end
end
