module Magic
  module BattlefieldFilters
    def game = source.game
    def battlefield = game.battlefield
    def controller = source.controller
    def creatures = battlefield.creatures
    def creatures_you_control = creatures.controlled_by(controller)
    def other_creatures_you_control = creatures_you_control - [source]
  end
end
