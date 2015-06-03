# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

addCompressExpand = (panel) ->
   header = $(panel).find('.panel-header:first').get(0)
   body = $(panel).find('.panel-body:first').get(0)
   $(header).prepend('<a href="" class="expander">+</a><a href="" class="compressor">-</a> ')
   $(body).slideUp()
      
   $(header).find('a.compressor:first').hide()
   
   $(header).find('a.expander:first').click( ->
      $(body).slideDown()
      $(this).hide()
      $(header).find('a.compressor:first').show()
      false
   )
   
   $(header).find('a.compressor:first').click( ->
      $(body).slideUp()
      $(this).hide()
      $(header).find('a.expander:first').show()
      false
   )


setupFormUI = () ->
   user_action = true
   
   $('#school-list > .panel-header').append('<input type="checkbox" id="select-all-schools-checkbox">')
   
   $('.school-class-list').each(->
      $(this).find('.school-name.panel-header').append('<input type="checkbox" class="select-school-checkbox">')
   )

   updateClassAncestors = (box) ->
      user_action = false

      #update the all schools checkbox
      all_school_checkbox = $('#select-all-schools-checkbox').get(0)
      found = $('#school-list').find('input[name="selected_school_classes[]"]:not(:checked)').length
      if found != 0
         all_school_checkbox.checked = false
      else
         all_school_checkbox.checked = true

      #update the school's checkbox
      school_klass_list = $('.school-class-list').has(box).get(0)
      school_checkbox = $(school_klass_list).find('.select-school-checkbox').get(0)
      found = $(school_klass_list).find('input[name="selected_school_classes[]"]:not(:checked)').length
      if found != 0
         school_checkbox.checked = false
      else
         school_checkbox.checked = true
         
      user_action = true


   $('#select-all-schools-checkbox').change(->
      state = this.checked
      if user_action
         $('#school-list').find('input[name="selected_school_classes[]"]').each(->
            this.checked = state
            updateClassAncestors(this)
         )
   )

   $('.select-school-checkbox').change(->
      state = this.checked
      if user_action
         $('#school-list').find('.school-class-list').has(this).find('input[name="selected_school_classes[]"]').each(->
            this.checked = state
            updateClassAncestors(this)
         )
   )
   
   #specify the onChange and the initial values of ancestor checkboxes
   $('input[name="selected_school_classes[]"]').change( ->
      updateClassAncestors(this)
   )

   $('input[name="selected_school_classes[]"]').each( ->
      updateClassAncestors(this)
   )

   $('.school-class-list').each( ->
      addCompressExpand(this)
   )

      
   
   $('.module-activity-list').each(->
      $(this).find('.panel-header:first > .module-options').prepend('<li>All activities: <input type="checkbox" class="select-all-module-activities-checkbox">')
      module_panel = this
      $(this).find('.select-all-module-activities-checkbox').change(->
         state = this.checked
         if user_action
            $(module_panel).find('input[name="selected_tasks[]"]').each( ->
               this.checked = state
               updateTaskAncestors(this)
            )
      )

      addCompressExpand(this)
   )

   $('.module-activity-task-list').each(->
      $(this).find('.panel-header:first').append('<input type="checkbox" class="select-all-activity-tasks-checkbox">')
      activity_panel = this
      $(this).find('.select-all-activity-tasks-checkbox').change(->
         state = this.checked
         if user_action
            $(activity_panel).find('input[name="selected_tasks[]"]').each( ->
               this.checked = state
               updateTaskAncestors(this)
            )
      )
      addCompressExpand(this)
   )

   updateTaskAncestors = (box) ->
      user_action = false
      
      #update the module's checkbox
      module_activity_list = $('.module-activity-list').has(box).get(0)
      module_checkbox = $(module_activity_list).find('.select-all-module-activities-checkbox').get(0)
      found = $(module_activity_list).find('input[name="selected_tasks[]"]:not(:checked)').length
      if found != 0
         module_checkbox.checked = false
      else
         module_checkbox.checked = true
      
      #update the activitie's checkbox
      activity_task_list = $('.module-activity-task-list').has(box).get(0)
      activity_checkbox = $(activity_task_list).find('.select-all-activity-tasks-checkbox').get(0)
      found = $(activity_task_list).find('input[name="selected_tasks[]"]:not(:checked)').length
      if found != 0
         activity_checkbox.checked = false
      else
         activity_checkbox.checked = true
         
      user_action = true


   $('input[name="selected_tasks[]"]').change( ->
      updateTaskAncestors(this)
   )

   $('input[name="selected_tasks[]"]').each( ->
      updateTaskAncestors(this)
   )


ReportsController = Paloma.controller('Reports');

ReportsController.prototype.index = () ->
   $(document).ready( ->   
      $('.panel.report').each(->
         addCompressExpand(this)
      )
   )

ReportsController.prototype.new = () ->     
   $(document).ready(setupFormUI)

ReportsController.prototype.clone = () ->     
   $(document).ready(setupFormUI)

ReportsController.prototype.create = () ->     
   $(document).ready(setupFormUI)
