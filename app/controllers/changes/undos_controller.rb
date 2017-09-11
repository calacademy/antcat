module Changes
  class UndosController < ApplicationController
    before_action :authenticate_editor
    before_action :set_change

    def show
      @undo_items = @change.undo_items
    end

    # TODO handle error, if any.
    def create
      @change.undo
      redirect_to changes_path, notice: "Undid the change ##{@change.id}."
    end

    private
      def set_change
        @change = Change.find params[:change_id]
      end
  end
end
