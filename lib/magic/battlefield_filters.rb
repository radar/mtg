module Magic
  module BattlefieldFilters
    def game = source.game
    def battlefield = game.battlefield
    def controller = source.controller
    def creatures = battlefield.creatures
    def creatures_you_control = creatures.controlled_by(controller)
  end
end
