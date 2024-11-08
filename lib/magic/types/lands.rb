
module Magic
  module Types
    module Lands
      class BasicLand
        def self.==(other)
          self.name.split("::").last == other
        end
      end

      class Plains < BasicLand
        ManaAbility = Class.new(Magic::ManaAbility) do
          costs "{T}"
          choices :white
        end
      end

      class Island < BasicLand
        ManaAbility = Class.new(Magic::ManaAbility) do
          costs "{T}"
          choices :blue
        end
      end

      class Swamp < BasicLand
        ManaAbility = Class.new(Magic::ManaAbility) do
          costs "{T}"
          choices :black
        end
      end

      class Mountain < BasicLand
        ManaAbility = Class.new(Magic::ManaAbility) do
          costs "{T}"
          choices :red
        end
      end

      class Forest < BasicLand
        ManaAbility = Class.new(Magic::ManaAbility) do
          costs "{T}"
          choices :green
        end
      end
    end
  end
end
