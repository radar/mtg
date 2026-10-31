module Magic
  module Cards
    WizardsRockets = Artifact("Wizard's Rockets") do
      cost generic: 1
    end

    class WizardsRockets < Artifact
      # "This artifact enters tapped."
      def enters_tapped? = true

      # "{X}, {T}, Sacrifice this artifact: Add X mana in any combination of colors."
      #
      # `choose` takes the combination: a color (all X mana that color), an array of colors or a
      # { color => count } hash totalling X.
      class AddXMana < Magic::ManaAbility
        costs "{X}, {T}, Sacrifice {this}"
        choices :all

        def choose(colors)
          @mix = case colors
          when Symbol then { colors => nil }
          when Array then colors.tally
          else colors.to_h
          end
        end

        def resolve!(x:)
          mix = (@mix || {}).transform_values { |count| count || x }
          raise ArgumentError, "choose #{x} mana in any combination of colors" unless mix.values.sum == x
          raise ArgumentError, "invalid colors #{mix.keys.inspect}" unless (mix.keys - choices).empty?

          mix.each { |color, count| source.controller.add_mana(color => count) if count.positive? }
        end
      end

      # "When this artifact is put into a graveyard from the battlefield, draw a card."
      class PutIntoGraveyardTrigger < TriggeredAbility::LeaveTheBattlefield
        def should_perform? = this? && event.to.graveyard?

        def call
          draw_card
        end
      end

      def activated_abilities = [AddXMana]

      def ltb_triggers = [PutIntoGraveyardTrigger]
    end
  end
end
