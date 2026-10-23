module Magic
  module Cards
    class KozilekTheBrokenReality < Creature
      card_name "Kozilek, the Broken Reality"
      cost generic: 9
      legendary_creature_type "Eldrazi"
      power 9
      toughness 9

      # The chosen player manifests two cards from their hand; Kozilek's controller draws a card for each.
      class ManifestChoice < Choice::Targeted
        attr_reader :player

        def initialize(actor:, player:)
          super(actor: actor)
          @player = player
        end

        def chooser = player

        def choices = player.hand.cards.to_a

        def choice_amount = [2, choices.size].min

        def resolve!(targets:)
          # Copy: callers may pass the live hand array, which shrinks as cards are manifested.
          cards = Array(targets).dup
          raise ArgumentError, "Manifest exactly #{choice_amount} cards" unless cards.size == choice_amount

          cards.each { game.manifest!(_1, controller: player) }
          draw_cards(cards.size, player: controller)
        end
      end

      # "When you cast this spell, up to two target players each manifest two cards from their hands."
      class PlayersChoice < Choice::Targeted
        def choices = game.players

        def choice_amount = 0..2

        def resolve!(targets:)
          Array(targets).each do |player|
            choice = ManifestChoice.new(actor: actor, player: player)
            game.add_choice(choice) if choice.choices.any?
          end
        end
      end

      class CastTrigger < TriggeredAbility::CastThisSpell
        def call = game.add_choice(PlayersChoice.new(actor: actor))
      end

      # "Other colorless creatures you control get +3/+2."
      class ColorlessBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 3, toughness: 2

        applicable_targets { source.controller.creatures.select(&:colorless?) - [source] }
      end

      def cast_triggers = [CastTrigger]
      def static_abilities = [ColorlessBuff]
    end
  end
end
