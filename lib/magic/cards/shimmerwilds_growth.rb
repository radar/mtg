module Magic
  module Cards
    class ShimmerwildsGrowth < Aura
      card_name "Shimmerwilds Growth"
      cost generic: 1, green: 1
      enchant "Land"

      def target_choices = battlefield.lands

      class ColorChoice < Magic::Choice::Color
        def resolve!(color:)
          actor.card.chosen_color = color
        end
      end

      # "As this Aura enters, choose a color."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(ColorChoice.new(actor:))
        end
      end

      # "Enchanted land is the chosen color."
      class LandColor < Abilities::Static::CharacteristicSetting
        applies_to_target

        def set_colors = source.card.chosen_color ? [source.card.chosen_color] : nil
      end

      # "Whenever enchanted land is tapped for mana, its controller adds an additional one mana of
      # the chosen color."
      class ExtraMana < StaticAbility
        def additional_mana(land, _mana)
          return unless land == @source.attached_to && @source.card.chosen_color

          land.controller.add_mana(@source.card.chosen_color => 1)
        end
      end

      def etb_triggers = [EntersTrigger]

      def static_abilities = [LandColor, ExtraMana]
    end
  end
end
