# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "Renew -- {4}{G}, Exile this card from your graveyard: <effects> Activate only as a
      # sorcery." (the "Renew -- " ability word is dropped before parsing). An activated ability
      # the card has in its owner's graveyard: the `:graveyard_abilities` hook generates a
      # `GraveyardAbility` class and `def graveyard_abilities`, like Goldmeadow Nomad.
      class Renew < Data.define(:cost, :effect_list)
        include Rule

        LINE = /\A(?<cost>(?:\{[^}]+\})+), Exile ~ from your graveyard: (?<effects>.+?) Activate only as a sorcery\.\z/

        def self.parse(line)
          return unless (m = LINE.match(line))

          effect_list = EffectList.parse(m[:effects]) or return
          new(cost: m[:cost], effect_list:)
        end

        def kinds = [:creature]
        def hook = :graveyard_abilities
        def class_base_name = "GraveyardAbility"

        def class_source(name)
          body = ["costs #{"#{cost}, Exile {this}".inspect}\n", "activate_from_graveyard_as_sorcery\n", effect_list.spell_source(this: "source")]
          "class #{name} < Magic::ActivatedAbility\n#{body.join("\n").gsub(/^(?=.)/, '  ')}end\n"
        end
      end
    end
  end
end
