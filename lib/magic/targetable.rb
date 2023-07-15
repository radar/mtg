module Magic
  module Targetable
    def player?
      self.is_a?(Player)
    end
  end
end
