module Magic
  module Cards
    BilbosRing = Equipment("Bilbo's Ring") do
      legendary_artifact
      cost generic: 3
    end

    class BilbosRing < Equipment
      # "Equip Halfling {1}": only a Halfling you control is a legal target.
      class EquipHalfling < Magic::ActivatedAbility
        costs "{1}"
        activate_only_as_sorcery

        def target_choices = creatures_you_control.select { _1.type?("Halfling") }

        # So "Equip abilities you activate cost {1} less" can tell it apart.
        def equip? = true

        def resolve!(target:)
          source.attach_to!(target)
        end
      end

      # "Equip {4}"
      class EquipAny < Magic::ActivatedAbility
        costs "{4}"
        activate_only_as_sorcery

        def target_choices = creatures_you_control

        def equip? = true

        def resolve!(target:)
          source.attach_to!(target)
        end
      end

      def activated_abilities = [EquipHalfling, EquipAny]

      # "During your turn, equipped creature has hexproof and can't be blocked."
      module DuringYourTurn
        def applicable_targets
          creature = source.attached_to
          return [] unless creature && game.current_turn.active_player == source.controller

          [creature]
        end
      end

      class Hexproof < Abilities::Static::KeywordGrant
        include DuringYourTurn
        keyword_grants Keywords::HEXPROOF
      end

      class Unblockable < Abilities::Static::KeywordGrant
        include DuringYourTurn
        keyword_grants Keywords::CANT_BE_BLOCKED
      end

      def static_abilities = [Hexproof, Unblockable]

      # "Whenever equipped creature attacks alone, you draw a card and you lose 1 life." The creature comes from the event.
      class AttacksAloneTrigger < TriggeredAbility
        def should_perform?
          event.attacks.size == 1 && event.attacks.first.attacker == actor.attached_to
        end

        def call
          draw_card
          lose_life controller, 1
        end
      end

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => AttacksAloneTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
