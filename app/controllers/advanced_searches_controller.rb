class AdvancedSearchesController < ApplicationController
  def show
    if params[:rank].present?
      get_taxa
      set_is_author_search
    end

    respond_to do |format|
      format.json { send_author_name_picklist }
      format.html { send_html }
      format.text { send_text }
    end
  end

  private
    def send_author_name_picklist
      render json: AuthorName.search(params[:term])
    end

    def send_html
      @taxa = @taxa.paginate(page: params[:page]) if @taxa
    end

    def send_text
      text = Exporters::AdvancedSearchExporter.new.export @taxa
      send_data text, filename: @filename, type: 'text/plain'
    end

    def get_taxa
      @taxa = Taxa::Search.advanced_search(
        author_name:              params[:author_name],
        rank:                     params[:rank],
        year:                     params[:year],
        locality:                 params[:locality],
        valid_only:               params[:valid_only],
        verbatim_type_locality:   params[:verbatim_type_locality],
        type_specimen_repository: params[:type_specimen_repository],
        type_specimen_code:       params[:type_specimen_code],
        biogeographic_region:     params[:biogeographic_region],
        genus:                    params[:genus],
        forms:                    params[:forms])

      @taxa_count = @taxa.count
      @filename = "#{params[:author_name]}-#{params[:rank]}-#{params[:year]}-#{params[:locality]}-#{params[:valid_only]}".parameterize + '.txt'
    end

    def set_is_author_search
      @is_author_search = params[:author_name].present? && no_matching_authors?(params[:author_name])
    end

    def no_matching_authors? name
      AuthorName.find_by_name(name).nil?
    end
end
