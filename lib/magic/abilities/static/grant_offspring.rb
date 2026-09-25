module Magic
  module Abilities
    module Static
      # "Creature spells you cast gain offspring {2} as you cast them." Subclasses return
      # the offspring mana cost for a spell +player+ is casting, or nil.
      class GrantOffspring < StaticAbility
        def offspring_cost_for(_card, _player)
          raise NotImplementedError, "#{self.class} must implement #offspring_cost_for"
        end
      end
    end
  end
end
