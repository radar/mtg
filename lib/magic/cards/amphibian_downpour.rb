module Magic
  module Cards
    AmphibianDownpour = Aura("Amphibian Downpour") do
      cost generic: 2, blue: 1
      keywords :flash
    end

    class AmphibianDownpour < Aura
      enchant "Creature"

      def target_choices
        battlefield.creatures
      end

      # "Enchanted creature loses all abilities and is a blue Frog creature with base power and toughness 1/1."
      class Transformation < Abilities::Static::CharacteristicSetting
        applies_to_target
        sets_types T::Creature, T::Creatures["Frog"]
        sets_colors :blue
        sets_base_power_and_toughness 1, 1
        loses_all_abilities
      end

      def static_abilities = [Transformation]

      # One copy of the spell: a token Aura that enters attached to the creature chosen for it (the original's target by
      # default; the player may pick a new one).
      class CopyChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures

        def choice_amount = 1

        def resolve!(target:)
          token = Permanent.token_copy(game:, owner: controller, card: actor)
          token.attach_to!(target)
        end
      end

      # "Storm (When you cast this spell, copy it for each spell cast before it this turn. You may choose new targets for
      # the copies. Copies become tokens.)"
      class StormTrigger < TriggeredAbility::CastThisSpell
        def call
          copies = game.current_turn.spells_cast.count - 1
          copies.times { game.add_choice(CopyChoice.new(actor: actor)) }
        end
      end

      def cast_triggers = [StormTrigger]
    end
  end
end
