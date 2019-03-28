class AuthorDecorator < Draper::Decorator
  delegate :references, :described_taxa

  def published_between
    first_year, most_recent_year = references.pluck('MIN(references.year), MAX(references.year)').flatten

    return first_year if first_year == most_recent_year
    "#{first_year}&ndash;#{most_recent_year}".html_safe
  end

  def taxon_descriptions_between
    first_year, most_recent_year = described_taxa.pluck('MIN(references.year), MAX(references.year)').flatten
    return unless first_year || most_recent_year

    return first_year if first_year == most_recent_year
    "#{first_year}&ndash;#{most_recent_year}".html_safe
  end
end
