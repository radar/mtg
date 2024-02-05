module Magic
  module Cards
    NiambiEsteemedSpeaker = Creature("Niambi, Esteemed Speaker") do
      type "Legendary Creature -- Human Cleric"
      cost white: 1, blue: 1
      power 2
      toughness 1
      keywords :flash

      enters_the_battlefield do
        valid_targets = creatures_you_control.except(permanent)
        game.choices.add(NiambiEsteemedSpeaker::Choice.new(source: permanent, choices: valid_targets))
      end
    end

    class NiambiEsteemedSpeaker < Creature
      class Choice < Magic::Choice
        attr_reader :source

        def initialize(source:, choices:)
          @source = source
          @choices = choices
        end

        def optional? = true

        def choose(target:)
          target.return_to_hand
          source.controller.gain_life(target.mana_value)
        end
      end

      class ActivatedAbility < Magic::ActivatedAbility
        def costs
          [
            Costs::Mana.new(generic: 1, white: 1, blue: 1),
            Costs::SelfTap.new(source),
            Costs::Discard.new(source.controller, -> (c) { c.legendary? })
          ]
        end

        def resolve!
          2.times { source.controller.draw! }
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
