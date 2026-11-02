module Magic
  module Cards
    FrodoDeterminedHero = Creature("Frodo, Determined Hero") do
      cost generic: 1, white: 1
      legendary_creature_type "Halfling Warrior"
      power 2
      toughness 2
    end

    class FrodoDeterminedHero < Creature
      # "...attach target Equipment you control with mana value 2 or 3 to Frodo."
      class AttachChoice < Magic::Choice::Targeted
        def choices
          controller.permanents.select { _1.card.is_a?(Cards::Equipment) && [2, 3].include?(_1.mana_value) }
        end

        def choice_amount = 1

        def resolve!(target:)
          target.attach_to!(actor)
        end

        def decline! = nil
      end

      # "you may"
      class MayAttach < Magic::Choice::May
        def resolve!
          choice = AttachChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      module MayAttachEquipment
        def call
          choice = AttachChoice.new(actor: actor)
          game.add_choice(MayAttach.new(actor: actor)) if choice.choices.any?
        end
      end

      # "Whenever Frodo enters..."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        include MayAttachEquipment

        def should_perform? = event.permanent == actor
      end

      # "...or attacks..."
      class AttacksTrigger < TriggeredAbility
        include MayAttachEquipment

        def should_perform? = event.attacker == actor
      end

      def event_handlers
        {
          Events::EnteredTheBattlefield => EntersTrigger,
          Events::CreatureAttacked => AttacksTrigger
        }
      end

      # "During your turn, prevent all damage that would be dealt to Frodo."
      class PreventDamage < StaticAbility
        def prevents_damage_to?(target)
          target == @source && game.current_turn.active_player == controller
        end
      end

      def static_abilities = [PreventDamage]
    end
  end
end
