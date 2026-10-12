module Magic
  module Abilities
    module Static
      # "Creatures you control attack each combat if able" (Pursued Whale's Pirate token). Subclass and implement
      # `applies_to?(permanent)`; `Permanent#must_attack?` asks every such ability on the battlefield.
      class MustAttack < StaticAbility
        def applies_to?(_permanent) = false
      end
    end
  end
end
