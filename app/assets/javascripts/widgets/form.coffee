window.AntCat or= {}

class AntCat.Form
  constructor: ($element, @options = {}) -> @initialize $element

  initialize: ($element) =>
    @element = $element
    @element
      .addClass('antcat_form')
      .find('.submit')
        .button()
        .click(@submit)
        .end()
      .find('.cancel')
        .button()
        .click(@cancel)
        .end()

  submit: =>
    @start_spinning()
    @element.ajaxSubmit
      beforeSerialize: @before_serialize
      success: @update
      error: @handle_error
      dataType: 'json'
    false

  before_serialize: ($form, options) => true

  update: (data, statusText, xhr, $form) =>
    @stop_spinning()
    @options.on_update data
    @options.on_done if data.success

  cancel: =>
    @options.on_cancel() if @options.on_cancel
    false

  handle_error: (jq_xhr, text_status, error_thrown) =>
    @stop_spinning()
    alert "Oh, shoot. It looks like a bug prevented this item from being saved.\n\nPlease report this situation to Mark Wilden (mark@mwilden.com) and we'll fix it.\n\n#{error_thrown}" unless AntCat.testing

  start_spinning: =>
    @element.find(':button')
      .disable()
      .parent().spinner position: 'left', leftOffset: 1, img: AntCat.spinner_path

  stop_spinning: =>
    @element.find('.spinner')
      .enable()
      .spinner 'remove'
