module Magic
  module Targetable
    def player?
      self.is_a?(Player)
    end

    def creature?
      self.is_a?(Permanent) && super
    end
  end
end
