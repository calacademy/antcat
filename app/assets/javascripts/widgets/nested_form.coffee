window.AntCat or= {}

$.fn.nested_form = (options = {}) ->
  this.each -> AntCat.NestedForm $(this), options

class AntCat.NestedForm
  constructor: ($element, @options = {}) ->
    @options.button_container or= '> .buttons'
    @initialize $element

  initialize: ($element) =>
    @element = $element
    @element
      .addClass('nested_form')
      .find(@options.button_container)
        .find(':button').button().end()
        .find(':button.submit').click(@submit).end()
        .find(':button.cancel').click(@cancel).end()
        .end()

  open: =>
    @element.find('input[type=text]:visible:first').focus()
    @options.on_open() if @options.on_open

  close: => @options.on_close() if @options.on_close

  submit: =>
    @start_spinning()
    $form = @convert_to_form()
    $form.ajaxSubmit
      beforeSerialize: @before_serialize
      success: @update
      error: @handle_error
      dataType: 'json'
    false

  cancel: =>
    @options.on_cancel() if @options.on_cancel
    @close()
    false

  update: (data, statusText, xhr, $form) =>
    @stop_spinning()
    @options.on_update data if @options.on_update
    if data.success
      @options.on_done data if @options.on_done
      @close()

  handle_error: (jq_xhr, text_status, error_thrown) =>
    @stop_spinning()
    alert "Oh, shoot. It looks like a bug prevented this item from being saved.\n\nPlease report this situation to Mark Wilden (mark@mwilden.com) and we'll fix it.\n\n#{error_thrown}" unless AntCat.testing

  start_spinning: =>
    @element.find(':button')
      .disable()
      .parent().spinner position: 'left', leftOffset: 1, img: AntCat.spinner_path

  stop_spinning: =>
    @element.find('.spinner').spinner 'remove'
    @element.find('.buttons :button').undisable()

  convert_to_form: =>
    $textareas = @element.find 'textarea'
    $nested_form = @element.clone()
    $nested_textareas = $nested_form.find 'textarea'
    for i in [0...$textareas.length]
      $($nested_textareas[i]).val $($textareas[i]).val()

    $nested_form.find('.nested_form').remove()
    $form = $('<form/>')
    $form.html $nested_form
    $form.attr 'action', $nested_form.data 'action'
    $form.attr 'method', $nested_form.data 'method'
    $form

  before_serialize: ($form, options) =>
    return @options.before_serialize($form, options) if @options.before_serialize
    true
