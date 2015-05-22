# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ReportsController = Paloma.controller('Reports');

ReportsController.prototype.new = () ->
   debug = (stuff) ->
      $('#foo').append(stuff)

   addCheckboxes = () ->
      $('#school-list > .panel-header').append('<input type="checkbox" id="allschools-checkbox">')
      $('#school-list > .panel-body > ul > li > .panel > .panel-header').each(->
         $(this).append('<input type="checkbox" class="school-checkbox">')
      )

      user_clicked = true

      updateToMatchChildren =  (e) ->
         user_clicked = false
         found = $(e.parentNode.parentNode).find('input[name="selected_school_classes[]"]:not(:checked)').length
         if found != 0
            e.checked = false
         else
            e.checked = true
            
         user_clicked = true

      
      $('#allschools-checkbox').change( ->
         if user_clicked
            state = this.checked
            $('input[name="selected_school_classes[]"]').prop('checked', state)
            $(this.parentNode.parentNode).find('.school-checkbox').each((i,e) -> updateToMatchChildren(e))
      )

      $('.school-checkbox').change( ->
         state = this.checked
         
         if user_clicked
            $(this.parentNode.parentNode).find('input[type="checkbox"]').prop('checked', state)

         $('#allschools-checkbox').each((i,e) -> updateToMatchChildren(e))
      )

      $('input[name="selected_school_classes[]"]').change( ->
         $('.school-checkbox').each((i,e) -> updateToMatchChildren(e))
         $('#allschools-checkbox').each((i,e) -> updateToMatchChildren(e))
      )

   
   $(document).ready(addCheckboxes)
