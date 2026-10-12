module Magic
  module Abilities
    module Static
      # "You may cast <some spells> as though they had flash": answers `grants_flash?(card, player)`, which
      # Actions::Cast consults (via static_ability_allows?) when deciding whether a spell may be cast at instant speed.
      class GrantFlash < StaticAbility
        attr_reader :source

        def grants_flash?(_card, _player) = false
      end
    end
  end
end
