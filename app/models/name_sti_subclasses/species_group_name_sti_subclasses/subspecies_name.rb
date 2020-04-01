# frozen_string_literal: true

class SubspeciesName < SpeciesGroupName
  def subspecies_epithets
    name_parts[2..-1].join ' '
  end
end