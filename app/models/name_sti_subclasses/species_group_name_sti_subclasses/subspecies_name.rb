# frozen_string_literal: true

class SubspeciesName < SpeciesGroupName
  # TODO: Change this and similar to use `names.cleaned_name`.
  def subspecies_epithet
    name_parts[2]
  end

  def subspecies_epithets
    name_parts[2..].join(' ')
  end

  def short_name
    [genus_epithet[0] + '.', species_epithet[0] + '.', subspecies_epithets].join(' ')
  end
end
