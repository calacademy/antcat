# coding: UTF-8
class WidgetTestsController < ApplicationController

  def name_picker
  end

  def reference_picker
    @reference = Reference.first if params[:id]
  end

  def reference_field
  end

  def name_field
  end

  def taxt_editor
    @taxon = Family.first
  end

end
