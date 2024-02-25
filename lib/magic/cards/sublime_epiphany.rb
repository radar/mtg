module Magic
  module Cards
    class SublimeEpiphany < Instant
      card_name "Sublime Epiphany"
      cost generic: 5, blue: 1

      class CounterTargetSpell < Mode
        def target_choices
          game.stack.spells
        end

        def resolve!(target:)
          trigger_effect(:counter_spell, target: target)
        end
      end

      class CounterTargetActivatedOrTriggeredAbility < Mode
        def target_choices
          game.stack.abilities
        end

        def resolve!(target:)
          trigger_effect(:counter_ability, target: target)
        end
      end

      class ReturnTargetNonlandPermanentToItsOwnersHand < Mode
        def target_choices
          game.battlefield.nonland
        end

        def resolve!(target:)
          trigger_effect(:return_to_owners_hand, target: target)
        end
      end

      class CreateCopyToken < Mode
        def target_choices
          game.battlefield.creatures.controlled_by(controller)
        end

        def resolve!(target:)
          Permanent.resolve(
            game: game,
            owner: controller,
            card: target.card,
            token: true,
          )
        end
      end

      class DrawsCard < Mode
        def target_choices
          game.players
        end

        def resolve!(target:)
          trigger_effect(:draw_cards, player: target)
        end
      end

      modes CounterTargetSpell,
        CounterTargetActivatedOrTriggeredAbility,
        ReturnTargetNonlandPermanentToItsOwnersHand,
        CreateCopyToken,
        DrawsCard
    end
  end
end
