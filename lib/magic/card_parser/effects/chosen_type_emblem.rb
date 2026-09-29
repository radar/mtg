# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Choose a creature type. You get an emblem with 'Creatures you control of the chosen type get
      # +3/+3 and have vigilance and hexproof.'"
      class ChosenTypeEmblem < Data.define(:power, :toughness, :keywords)
        include Effect

        LINE = %r{\AChoose a creature type\. You get an emblem with "Creatures you control of the chosen type get (?<power>[+-]\d+)/(?<toughness>[+-]\d+) and have (?<keywords>[\w ,]+?)\.?"\.?\z}i

        def self.parse(text)
          return unless (m = LINE.match(text))

          keywords = Rules::Keywords.phrase(m[:keywords]) or return
          new(power: m[:power].to_i, toughness: m[:toughness].to_i, keywords:)
        end

        def choice_base = "Magic::Choice::EmblemForChosenType"
        def choice_class_name = "ChooseTypeChoice"
        def choice_args = "emblem_class: TypeEmblem"

        def definitions
          grants = keywords.map { "Magic::Cards::Keywords::#{_1.upcase}" }.join(", ")
          <<~RUBY
            class TypeEmblem < Magic::Emblem
              attr_reader :creature_type

              def initialize(game:, owner:, creature_type:)
                super(game:, owner:)
                @creature_type = creature_type
              end

              class Buff < Abilities::Static::PowerAndToughnessModification
                modify power: #{power}, toughness: #{toughness}

                def applicable_targets = source.controller.creatures.select { _1.type?(source.creature_type) }
              end

              class Grants < Abilities::Static::KeywordGrant
                keyword_grants #{grants}

                def applicable_targets = source.controller.creatures.select { _1.type?(source.creature_type) }
              end

              def static_abilities = [Buff, Grants]
            end
          RUBY
        end

        def resolve_call = "nil"
      end
    end
  end
end
