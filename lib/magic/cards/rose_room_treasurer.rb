module Magic
  module Cards
    RoseRoomTreasurer = Creature("Rose Room Treasurer") do
      cost generic: 3, red: 1
      creature_type "Ogre Warrior"
      power 4
      toughness 3
    end

    class RoseRoomTreasurer < Creature
      # "When you do, this creature deals X damage to any target."
      class DamageChoice < Magic::Choice::Targeted
        def initialize(actor:, damage:)
          @damage = damage
          super(actor: actor)
        end

        def choices = game.any_target
        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:deal_damage, damage: @damage, target: target)
        end
      end

      # "you may pay {X}."
      class MayPayChoice < Magic::Choice::May
        # What a UI pays on the player's behalf: X generic mana.
        def payment_cost(x = nil) = { generic: x.to_i }

        def resolve!(x: 0, payment: {})
          controller.pay_mana(payment)
          game.choices.add(DamageChoice.new(actor: actor, damage: x)) if x.positive?
        end
      end

      # Alliance: "Whenever another creature you control enters, create a Treasure token if this is the first or
      # second time this ability has resolved this turn. Otherwise, you may pay {X}. When you do, this creature
      # deals X damage to any target."
      class AllianceTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && under_your_control?
        end

        def call
          if times_resolved_this_turn < 2
            trigger_effect(:create_token, token_class: Tokens::Treasure)
          else
            game.choices.add(MayPayChoice.new(actor: actor))
          end
          record_resolution
        end

        private

        def times_resolved_this_turn
          counts = actor.state[:alliance_resolutions]
          counts && counts[:turn] == game.current_turn.number ? counts[:count] : 0
        end

        def record_resolution
          actor.state[:alliance_resolutions] = { turn: game.current_turn.number, count: times_resolved_this_turn + 1 }
        end
      end

      def event_handlers
        super.merge(Events::EnteredTheBattlefield => AllianceTrigger)
      end
    end
  end
end
