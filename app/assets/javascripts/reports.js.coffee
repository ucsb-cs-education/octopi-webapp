# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ReportsController = Paloma.controller('Reports');

ReportsController.prototype.new = () ->
   debug = (stuff) ->
      $('#foo').append(stuff)

   setupUI = () ->
      $('#school-list > .panel-header').append('<input type="checkbox" id="allschools-checkbox">')
      $('#school-list > .panel-body > ul > li > .panel > .panel-header').each(->
         $(this).append('<input type="checkbox" class="school-checkbox">')
      )


      $('#module-list > .panel-header').append('<input type="checkbox" id="allmodules-checkbox">')
      $('.module.panel > .panel-header').each(->
         $(this).append('<input type="checkbox" class="module-checkbox">')
      )

      $('.module.panel .activity.panel > .panel-header').each(->
         $(this).append('<input type="checkbox" class="activity-checkbox">')
      )

      

      user_clicked = true

      updateSchoolHeirarchy =  (e) ->
         user_clicked = false
         found = $(e.parentNode.parentNode).find('input[name="selected_school_classes[]"]:not(:checked)').length
         if found != 0
            e.checked = false
         else
            e.checked = true
            
         user_clicked = true

      updateModuleHeirarchy =  (e) ->
         user_clicked = false
         found = $(e.parentNode.parentNode).find('input[name="selected_tasks[]"]:not(:checked)').length
         if found != 0
            e.checked = false
         else
            e.checked = true
            
         user_clicked = true

            
      $('#allschools-checkbox').change( ->
         if user_clicked
            state = this.checked
            $('input[name="selected_school_classes[]"]').prop('checked', state)
            $(this.parentNode.parentNode).find('.school-checkbox').each((i,e) -> updateSchoolHeirarchy(e))
      )

      $('.school-checkbox').change( ->
         state = this.checked
         
         if user_clicked
            $(this.parentNode.parentNode).find('input[type="checkbox"]').prop('checked', state)

         $('#allschools-checkbox').each((i,e) -> updateSchoolHeirarchy(e))
      )

      $('input[name="selected_school_classes[]"]').change( ->
         $('.school-checkbox').each((i,e) -> updateSchoolHeirarchy(e))
         $('#allschools-checkbox').each((i,e) -> updateSchoolHeirarchy(e))
      )

      $('#allmodules-checkbox').change( ->
         if user_clicked
            state = this.checked
            $('input[name="selected_tasks[]"]').prop('checked', state)
            
         $(this.parentNode.parentNode).find('.module-checkbox').each((i,e) -> updateModuleHeirarchy(e))
         $(this.parentNode.parentNode).find('.activity-checkbox').each((i,e) -> updateModuleHeirarchy(e))
      )

      $('.module-checkbox').change(->
         if user_clicked
            state = this.checked
            $(this.parentNode.parentNode).find('input[name="selected_tasks[]"]').prop('checked', state)
            
         $(this.parentNode.parentNode).find('.activity-checkbox').each((i,e) -> updateModuleHeirarchy(e))
         $('#allmodules-checkbox').each((i,e) -> updateModuleHeirarchy(e))
      )


      $('.activity-checkbox').change(->
         if user_clicked
            state = this.checked
            $(this.parentNode.parentNode).find('input[name="selected_tasks[]"]').prop('checked', state)

         $('.module-checkbox').each((i,e) -> updateModuleHeirarchy(e))
         $('#allmodules-checkbox').each((i,e) -> updateModuleHeirarchy(e))
      )


      $('input[name="selected_tasks[]"]').change( ->
         $('.activity-checkbox').each((i,e) -> updateModuleHeirarchy(e))
         $('.module-checkbox').each((i,e) -> updateModuleHeirarchy(e))
         $('#allmodules-checkbox').each((i,e) -> updateModuleHeirarchy(e))

      )
      


      $('.school-classes > .panel-header').prepend('<a href="#" class="expander">+</a><a href="#" class="compressor">-</a> ')
      $('.school-classes > .panel-body').slideUp()
      
      $('.school-classes > .panel-header > a.compressor').hide()
      
      $('.school-classes > .panel-header > a.expander').click( ->
         $(this.parentNode.parentNode).find('.panel-body').slideDown()
         $(this).hide()
         $(this.parentNode).find('.compressor').show()
      )

      $('.school-classes > .panel-header > a.compressor').click( ->
         $(this.parentNode.parentNode).find('.panel-body').slideUp()
         $(this).hide()
         $(this.parentNode).find('.expander').show()

      )


      $('.activity.panel > .panel-header').prepend('<a href="" class="expander">+</a><a href="" class="compressor">-</a> ')
      $('.activity.panel > .panel-body').slideUp()
      
      $('.activity.panel > .panel-header > a.compressor').hide()
      
      $('.activity.panel > .panel-header > a.expander').click( ->
         $(this.parentNode.parentNode).find('.panel-body').slideDown()
         $(this).hide()
         $(this.parentNode).find('.compressor').show()
         false
      )

      $('.activity.panel > .panel-header > a.compressor').click( ->
         $(this.parentNode.parentNode).find('.panel-body').slideUp()
         $(this).hide()
         $(this.parentNode).find('.expander').show()
         false
      )

      $('.module.panel > .panel-header').prepend('<a href="" class="expander">+</a><a href="" class="compressor">-</a> ')
      $('.module.panel > .panel-body').slideUp()
      
      $('.module.panel > .panel-header > a.compressor').hide()
      
      $('.module.panel > .panel-header > a.expander').click( ->
         $(this.parentNode.parentNode).find('> .panel-body').slideDown()
         $(this).hide()
         $(this.parentNode).find('.compressor').show()
         false
      )

      $('.module.panel > .panel-header > a.compressor').click( ->
         $(this.parentNode.parentNode).find('> .panel-body').slideUp()
         $(this).hide()
         $(this.parentNode).find('.expander').show()
         false
      )

      
   $(document).ready(setupUI)
