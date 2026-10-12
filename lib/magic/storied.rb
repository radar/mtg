module Magic
  # Storied: "If you control three or more artifacts, legendaries, and/or Sagas, you have an enduring story for the
  # rest of the game." A permanent with the keyword calls `Storied.check(controller)` from its static-ability
  # condition: once met, the player's `enduring_story` stays set even if the permanents leave.
  #
  #   conditions { Magic::Storied.enduring_story?(controller) }
  module Storied
    def self.check(player)
      return if player.enduring_story

      qualifying = player.game.battlefield.controlled_by(player).select do |permanent|
        permanent.artifact? || permanent.legendary? || permanent.type?("Saga")
      end
      player.enduring_story = true if qualifying.count >= 3
    end

    def self.enduring_story?(player)
      check(player)
      player.enduring_story == true
    end
  end
end
