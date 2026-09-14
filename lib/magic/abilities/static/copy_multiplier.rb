module Magic
  module Abilities
    module Static
      # "If you would copy a spell one or more times, instead copy it that
      # many times plus an additional time." Subclass and override
      # additional_copies for anything other than +1.
      class CopyMultiplier < StaticAbility
        def additional_copies
          1
        end
      end
    end
  end
end
