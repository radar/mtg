module Magic
  module Cards
    TamMindfulFirstYear = Creature("Tam, Mindful First-Year") do
      cost generic: 1, blue_or_green: 1
      legendary_creature_type("Gorgon Wizard")
      power 2
      toughness 2
    end

    class TamMindfulFirstYear < Creature
      # "Each other creature you control has hexproof from each of its colors."
      class HexproofFromItsColors < Abilities::Static::KeywordGrant
        applicable_targets { source.controller.creatures - [source] }

        def keyword_grants_for(permanent)
          permanent.colors.map { Keywords::HexproofFrom.new(_1) }
        end
      end

      def static_abilities = [HexproofFromItsColors]

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{T}"

        def target_choices
          battlefield.controlled_by(controller).creatures
        end

        def resolve!(target:)
          target.change_colors!([:white, :blue, :black, :red, :green])
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
