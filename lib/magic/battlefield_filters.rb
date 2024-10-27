module Magic
  module BattlefieldFilters
    def game = actor.game
    def battlefield = game.battlefield
    def controller = actor.controller
    def creatures = battlefield.creatures
    def creatures_you_control = creatures.controlled_by(controller)
    def creatures_opponents_control = creatures.not_controlled_by(controller)
    def other_creatures_you_control = creatures_you_control - [actor]
  end
end
