# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

PagesController = Paloma.controller('StudentPortal/Students');
PagesController.prototype.show = () ->
  addCallbacks = ->
    $('#password_modal').on('hidden.bs.modal', ->
      $('form.edit_student')[0].reset()
    )

  $(document).ready(addCallbacks);
  $(document).ready();

