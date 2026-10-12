module Magic
  module Cards
    WakerOfWaves = Creature("Waker of Waves") do
      cost generic: 5, blue: 2
      creature_type "Whale"
      power 7
      toughness 7
    end

    class WakerOfWaves < Creature
      # "Creatures your opponents control get -1/-0."
      class OpponentsShrink < Abilities::Static::PowerAndToughnessModification
        modify power: -1, toughness: 0
        applicable_targets { source.game.opponents(source.controller).flat_map { |opponent| opponent.creatures.to_a } }
      end

      def static_abilities = [OpponentsShrink]

      # "{1}{U}, Discard this card: Look at the top two cards of your library. Put one of them into your hand and the
      # other into your graveyard." Modelled as cycling whose effect is this choice.
      cycling "{1}{U}"

      class LookAtTwoChoice < Magic::Choice
        attr_reader :choices

        def initialize(actor:)
          super
          @choices = controller.library.first(2)
        end

        def resolve!(target:)
          raise ArgumentError, "#{target.name} is not one of the top two cards" unless choices.include?(target)

          target.move_to_hand!
          (choices - [target]).each(&:move_to_graveyard!)
        end
      end

      def cycling_effect!
        game.add_choice(LookAtTwoChoice.new(actor: self))
      end
    end
  end
end
