# frozen_string_literal: true

class ProtonymsController < ApplicationController
  TAXON_COUNT_ORDER = "taxon_count"

  before_action :ensure_user_is_at_least_helper, except: [:index, :show]

  # TODO: Fix.
  def index
    protonyms =
      if current_user
        scope = Protonym.select("protonyms.*, COUNT(taxa.id) AS taxa_count").
                  left_outer_joins(:taxa).group(:id).references('taxa_count').
                  preload(:name, authorship: :reference)
        scope = scope.joins(:name).where('names.name LIKE ?', "%#{params[:q]}%") if params[:q].present?
        if params[:order] == TAXON_COUNT_ORDER
          scope.order("taxa_count DESC")
        else
          scope.order_by_name
        end
      else
        Protonym.includes(:name, authorship: :reference).order_by_name
      end
    @protonyms = protonyms.paginate(page: params[:page], per_page: 50)
  end

  def show
    @protonym = Protonym.eager_load(:name, :authorship).find(params[:id])
  end

  def new
    @protonym = Protonym.new
    @protonym.build_name
    @protonym.build_authorship
  end

  def create
    @protonym = Protonym.new(protonym_params)
    @protonym.name = Names::BuildNameFromString[params[:protonym_name_string]]

    if @protonym.save
      @protonym.create_activity :create, current_user, edit_summary: params[:edit_summary]
      redirect_to @protonym, notice: 'Protonym was successfully created.'
    else
      render :new
    end
  rescue Names::BuildNameFromString::UnparsableName => e
    @protonym.errors.add :base, "Could not parse name #{e.message}"
    @protonym.build_name(name: params[:protonym_name_string]) # Maintain entered name.
    render :new
  end

  def edit
    @protonym = find_protonym
  end

  def update
    @protonym = find_protonym

    if @protonym.update(protonym_params)
      @protonym.create_activity :update, current_user, edit_summary: params[:edit_summary]
      redirect_to @protonym, notice: 'Protonym was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    protonym = find_protonym

    if protonym.destroy
      protonym.create_activity :destroy, current_user
      redirect_to protonyms_path, notice: "Successfully deleted protonym."
    else
      redirect_to protonym, alert: protonym.errors.full_messages.to_sentence
    end
  end

  private

    def find_protonym
      Protonym.find(params[:id])
    end

    def protonym_params
      params.require(:protonym).permit(
        :biogeographic_region,
        :fossil,
        :locality,
        :uncertain_locality,
        :primary_type_information_taxt,
        :secondary_type_information_taxt,
        :sic,
        :type_notes_taxt,
        authorship_attributes: [
          :id,
          :forms,
          :notes_taxt,
          :pages,
          :reference_id
        ]
      )
    end
end
