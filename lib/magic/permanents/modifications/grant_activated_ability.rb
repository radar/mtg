module Magic
  module Permanents
    module Modifications
      # "It has '{2}, {T}, Sacrifice this artifact: You gain 3 life.'": an activated ability class added to one
      # permanent (Supper for Spiders). Read by ContinuousEffects#calculate_activated_abililities.
      class GrantActivatedAbility < ContinuousEffect
        layer 6

        attr_reader :ability_class

        def initialize(ability_class:, **args)
          @ability_class = ability_class
          super(**args)
        end
      end
    end
  end
end
