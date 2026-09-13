module Magic
  module Abilities
    module Static
      class LandsEnterUntapped < StaticAbility
        attr_reader :source

        def lands_enter_untapped?(_card)
          false
        end
      end
    end
  end
end
