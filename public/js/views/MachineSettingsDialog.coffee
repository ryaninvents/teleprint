Backbone = require 'backbone'

tpl = require '../../tpl/MachineSettingsDialog.jade'

module.exports =
MachineSettingsDialog = Backbone.View.extend
  render: ->
    model = @model
    @$el.html tpl(machine: @model)
    @$el.addClass 'ui modal'
    @$('.actions .button').one 'click', =>
      @hide()
    @$('[data-field="name"] input').keyup ->
      name = $(@).val()
      model.set name: name

    $delete = @$('[data-action="delete-image"]')
    $editImage = @$('[data-action="change-image"]')
    $fileInput = @$('[data-element="file-input"]')

    $editImage.click -> $fileInput.click()
    $fileInput.change (event) ->
      file = $(@)[0].files[0]
      reader = new FileReader()
      reader.onload = (e) => model.set 'image', e.target.result
      reader.readAsDataURL file
    $delete.click ->
      model.set 'image', ''

    updateImage = =>
      image = @model.get 'image'
      $image = @$('.ui.image')
      if image
        $image.css 'background-image': "url(#{image})"
        $image.removeClass('without-image').addClass('with-image')
      else
        $image.css 'background-image': ''
        $image.removeClass('with-image').addClass('without-image')

    model.on 'change:image', updateImage
    updateImage()

    @

  show: ->
    @render()
    $('#dialog-area').html('').append @$el
    @$el.modal 'show'

  hide: -> @$el.modal 'hide'
