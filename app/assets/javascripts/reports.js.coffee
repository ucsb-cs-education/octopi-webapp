# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ReportsController = Paloma.controller('Reports');

ReportsController.prototype.new = () ->

   addCheckboxes = () ->
      $('#school-list > .panel-header').append('<input type="checkbox" id="all-schools-select">')
      $('#school-list > .panel-body > ul > li > .panel > .panel-header').each(->
         $(this).append('<input type="checkbox" >')
      )

   $(document).ready(addCheckboxes)
