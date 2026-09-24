# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "{2}{R}, {T}: ~ deals 1 damage to any target." / "{1}, Sacrifice ~: Draw a
      # card. Activate only as a sorcery." Costs are any Costs::Parser understands;
      # the effects are anything EffectList parses, rendered like a spell's.
      class ActivatedAbility < Data.define(:costs, :effect_list, :sorcery_speed)
        include Rule

        COST = /(?:\{(?:\d+|[WUBRGC])\})+|\{T\}|Sacrifice ~|Sacrifice a creature|Exile ~|Discard a card|Remove (?:\d+|\w+) [\w+\/-]+ counters? from ~(?: and sacrifice it)?/
        LINE = /\A(?<costs>#{COST}(?:, #{COST})*): (?<effects>.+?)(?<sorcery> Activate only as a sorcery\.)?\z/

        def self.parse(line)
          return unless (m = LINE.match(line))

          effect_list = EffectList.parse(m[:effects]) or return
          m[:costs].scan(/Remove \w+ ([\w+\/-]+) counters? from/) { Magic::Counters[$1.downcase] } # raises for an unknown counter type
          new(costs: costs(m[:costs]), effect_list:, sorcery_speed: !m[:sorcery].nil?)
        rescue RuntimeError => e
          raise unless e.message.start_with?("Unknown counter type")
        end

        # "Remove three quest counters from ~ and sacrifice it" is two costs.
        def self.costs(text)
          text.gsub(" and sacrifice it", ", Sacrifice ~")
              .gsub(/Remove (\w+) ([\w+\/-]+) counters? from/) { "Remove #{Number.parse($1)} #{$2} counters from" }
              .gsub("~", "{this}")
        end

        def kinds = PERMANENT_KINDS
        def hook = :activated_abilities
        def class_base_name = "ActivatedAbility"

        def class_source(name)
          body = ["costs #{costs.inspect}\n"]
          body << "def requirements_met? = game.can_cast_sorcery?(controller)\n" if sorcery_speed
          body << effect_list.spell_source(this: "source")
          "class #{name} < Magic::ActivatedAbility\n#{body.join("\n").gsub(/^(?=.)/, '  ')}end\n"
        end
      end
    end
  end
end
