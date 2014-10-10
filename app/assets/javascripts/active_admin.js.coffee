#= require active_admin/base
#= require paloma
#= require dependant_dropdowns
AdminStaffController = Paloma.controller('Admin/Staff');
AdminStaffController.prototype.edit = () ->
  addActionListeners = ->
    $("#new-role-select").each (i) ->
      button = $(this).find("button")
      role_dropdown = $(this).find("#new_roles")
      resource_dropdown = $(this).find("#new_role_resources")
      resource_dropdown.on 'change', ->
        if $(this).val()
          button.attr('disabled', false)
        else
          button.attr('disabled', true)
      button.click ->
        url = role_dropdown.val() + '/' + resource_dropdown.val()
        $.ajax({
          url: '/admin/staff/roles/' + url + '.json',
          success: (data, textStatus, jqXHR) ->
            found = false
            for role in data
              $('#staff_basic_roles_input').find('#staff_basic_roles_' + role.id).each ->
                found = true
              unless found
                string = '<li class="choice"><label for="staff_basic_roles_:id:"><input checked="checked" id="staff_basic_roles_:id:" name="staff[basic_roles][]" type="checkbox" value=":id:">:name:</label></li>'
                $('#staff_basic_roles_input').find('ol.choices-group').
                append(string.replace(/:id:/g, role.id).replace(/:name:/g, role.name))
            role_dropdown.val('').change()
            role_dropdown.focus()

          error: (jqXHR, textStatus, error) ->
            alert(error)
        })

    $('#staff_assign_a_random_password').change( ->
      fields = $('#staff_password_input,#staff_password_confirmation_input')
      console.log('change')
      if $(this).prop('checked')
         fields.each(->
           $(this).hide()
         )
      else
        fields.each(->
          $(this).show()
        )
    )

  $(document).ready addActionListeners
  $(document).ready

AdminStudentController = Paloma.controller('Admin/Students');
AdminStudentController.prototype.edit = () ->

  change_confirm_message = (student_name, old_class_name, new_class_name, preserve) ->
    text = "This will transfer #{student_name} and all of their data from #{old_class_name} to #{new_class_name}."
    if preserve
      text += " Any existing data will take priority over new data and will be preserved."
    else
      text += " Any existing data will be overwritten if necessary."
    text += " No data will remain in #{old_class_name} for #{student_name}."
    text += "\nContinue?"
    confirm(text)

  remove_confirm_message = (student_name, class_name, delete_data) ->
    text = "This will remove #{student_name} from #{class_name}."
    if delete_data
      text += " Their data for this class will be permanently deleted."
    else
      text += " Their data for this class will be preserved and recovered if they are added back ot the class."
    text += "\nContinue?"
    confirm(text)

  setupStudentFunctions = ->
    student_name = $("#student_first_name").val() + " " + $("#student_last_name").val()
    change_classes = $('#change-classes').find('form')
    remove_class = $('#remove-from-class').find('form')
    current_classes_dropdown = change_classes.find("select#current_class")
    possible_classes_dropdown = change_classes.find("select#new_class")
    change_class_dropdowns = change_classes.find('select')
    removeable_classes_dropdown = remove_class.find("select#class")
    preserve_current = change_classes.find("#preserve_current")
    delete_data = remove_class.find("#delete_data")
    change_class_button = change_classes.find('button')
    remove_class_button = remove_class.find('button')

    #Toggle the state of the transfer button based on selected vals for both classes
    setTransferSubmitButtonState = ->
      if current_classes_dropdown.val() and possible_classes_dropdown.val()
        change_class_button.removeAttr('disabled')
      else
        change_class_button.attr('disabled', '')
    #add the event listener for the dropdowns
    change_class_dropdowns.change setTransferSubmitButtonState

    change_classes.submit (e) ->
      current_class_text = current_classes_dropdown.find('option:selected').text()
      new_class_test = possible_classes_dropdown.find('option:selected').text()
      preserve = preserve_current.prop('checked')
      unless change_confirm_message(student_name, current_class_text, new_class_test, preserve)
        e.preventDefault()

    setRemoveSubmitButtonState = ->
      if removeable_classes_dropdown.val()
        remove_class_button.removeAttr('disabled')
      else
        remove_class_button.attr('disabled', '')

    removeable_classes_dropdown.change setRemoveSubmitButtonState
    remove_class.submit (e) ->
      class_text = removeable_classes_dropdown.find('option:selected').text()
      delete_data = delete_data.prop('checked')
      unless remove_confirm_message(student_name, class_text, delete_data)
        e.preventDefault()

  $(document).ready setupStudentFunctions
  $(document).ready