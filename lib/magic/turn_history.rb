module Magic
  # Questions about what has happened so far this turn ("if a creature died this turn", "if you attacked this turn"),
  # for anything with a `game` and a `controller` (abilities, triggered abilities, static abilities):
  #
  #   event_this_turn?(Events::LifeGain) { |e| e.player == controller }   # any matching event
  #   creature_died_this_turn?                                            # any creature died
  #   creature_died_this_turn?(except_type: "Zombie")                     # a non-Zombie creature died
  #   creature_entered_this_turn?                                         # a creature entered under your control
  #   creature_entered_this_turn?(except: actor)                          # ... other than this one
  #   attacked_this_turn?                                                 # you attacked with a creature
  #   declared_attackers_this_turn?                                       # you declared at least one attacker
  #   opponent_lost_life_this_turn?
  module TurnHistory
    def event_this_turn?(event_class, &block)
      game.current_turn.events.any? { |e| e.is_a?(event_class) && (block.nil? || block.call(e)) }
    end

    def creature_died_this_turn?(except_type: nil)
      event_this_turn?(Events::CreatureDied) { |e| except_type.nil? || !e.permanent.type?(except_type) }
    end

    def creature_entered_this_turn?(by: controller, except: nil)
      event_this_turn?(Events::EnteredTheBattlefield) do |e|
        e.permanent.creature? && e.permanent.controller == by && !e.permanent.equal?(except)
      end
    end

    def attacked_this_turn?(by: controller)
      event_this_turn?(Events::CreatureAttacked) { |e| e.attacker.controller == by }
    end

    def declared_attackers_this_turn?(by: controller)
      event_this_turn?(Events::FinalAttackersDeclared) { |e| e.active_player == by && e.attacks.any? }
    end

    def opponent_lost_life_this_turn?
      event_this_turn?(Events::LifeLoss) { |e| e.player != controller }
    end
  end
end
