module Magic
  module Cards
    CurseOfThePiercedHeart = Aura("Curse of the Pierced Heart") do
      type T::Enchantment, "Aura", "Curse"
      cost generic: 1, red: 1
    end

    class CurseOfThePiercedHeart < Aura
      enchant :player

      def target_choices
        game.players
      end

      class DamageChoice < Magic::Choice::Targeted
        def choice_amount
          1
        end

        def choices
          [actor.attached_to, *game.battlefield.controlled_by(actor.attached_to).planeswalkers]
        end

        def resolve!(target:)
          trigger_effect(:deal_damage, target: target, damage: 1)
        end
      end

      class DamageTrigger < TriggeredAbility
        def should_perform?
          event.player == actor.attached_to
        end

        def call
          game.add_choice(DamageChoice.new(actor: actor))
        end
      end

      def event_handlers
        { Events::BeginningOfUpkeep => DamageTrigger }
      end
    end
  end
end
