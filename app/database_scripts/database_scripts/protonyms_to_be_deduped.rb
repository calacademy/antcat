module DatabaseScripts
  class ProtonymsToBeDeduped < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def results
      grouped = Protonym.
        joins(:name, authorship: :reference).
        group('names.name, references.id, protonyms.locality').
        having("COUNT(protonyms.id) > 1")

      # This does not work with NULLs, but let's start easy.
      Protonym.joins(:name, authorship: :reference).
        where(
          locality: grouped.select('protonyms.locality'),
          names: { name: grouped.select('names.name') },
          citations: {
            reference_id: grouped.select('references.id')
          }
        ).includes(:name).order('names.name')
    end

    def render
      as_table do |t|
        t.header :id, :protonym, :orphaned
        t.rows do |protonym|
          [
            protonym.id,
            link_to(protonym.decorate.format_name, protonym_path(protonym)),
            protonym.taxa.exists? ? "" : 'Yes'
          ]
        end
      end
    end
  end
end

__END__
description: >
  Version 2


  These must be fixed manually. After that the script will be refined again and will be populated with
  new candidates for merging by script.


  Same:


  * `names.name`

  * `references.id`

  * `protonyms.locality`


  Most probably same (not checked as they were fixed in the first batch of this script):


  * `protonyms.fossil`

  * `protonyms.sic`


  Different:


  * `citations.pages`

  * `citations.forms`


tags: [new!, slow]
topic_areas: [protonyms]
