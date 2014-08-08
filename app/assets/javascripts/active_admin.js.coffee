#= require active_admin/base
#= require paloma
#= require dependant_dropdowns
AdminStaffController = Paloma.controller('Admin/Staff');
AdminStaffController.prototype.edit = () ->
  newRoleSelectButtonListener = ->
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
            $('#staff_basic_roles_input').find('#staff_basic_roles_' + data.id).each ->
              found = true
            unless found
              string = '<li class="choice"><label for="staff_basic_roles_:id:"><input checked="checked" id="staff_basic_roles_:id:" name="staff[basic_roles][]" type="checkbox" value=":id:">:name:</label></li>'
              $('#staff_basic_roles_input').find('ol.choices-group').
              append(string.replace(/:id:/g, data.id).replace(/:name:/g, data.name))
            role_dropdown.val('').change()

          error: (jqXHR, textStatus, error) ->
            alert(error)
        })

  $(document).ready newRoleSelectButtonListener
  $(document).ready

AdminStudentController = Paloma.controller('Admin/Students');
AdminStudentController.prototype.edit = () ->
  transferClassButtonListener = ->
    $("#change-classes").each (i) ->
      button = $(this).find("button")
      current_classes_dropdown = $(this).find("#current_school_classes")
      possible_classes_dropdown = $(this).find("#possible_school_classes")
      preserve_current = $(this).find("#preserve_current")
      current_classes_dropdown.on 'change', ->
        if $(this).val() and possible_classes_dropdown.val()
          button.attr('disabled', false)
        else
          button.attr('disabled', true)
      possible_classes_dropdown.on 'change', ->
        if $(this).val() and current_classes_dropdown.val()
          button.attr('disabled', false)
        else
          button.attr('disabled', true)
      button.click ->
        if change_confirm_message($("#current_school_classes option[value="+current_classes_dropdown.val()+"]"),$("#possible_school_classes option[value="+possible_classes_dropdown.val()+"]"))
          url = current_classes_dropdown.val() + '/' + possible_classes_dropdown.val() + '/' + preserve_current.prop('checked')
          $.ajax({
            url: 'change_class/' + url + ".json",
            success: (data, textStatus, jqXHR) ->
              $("#current_school_classes option[value="+data[0]['value']+"]").remove()
              $("#removable_classes option[value="+data[0]['value']+"]").remove()
              $("#possible_school_classes option[value="+data[1]['value']+"]").remove()
              $("#current_school_classes").append("<option value = '"+data[1]['value']+"'>"+data[1]['name']+"</option>")
              $("#removable_classes").append("<option value = '"+data[1]['value']+"'>"+data[1]['name']+"</option>")
              $("#possible_school_classes").append("<option value = '"+data[0]['value']+"'>"+data[0]['name']+"</option>")
              $("#remove-from-class").find("button").attr('disabled', true)
              button.attr('disabled', true)
            error: (jqXHR, textStatus, error) ->
              alert(error)
          })




  removeFromClassButtonListener = ->
    $("#remove-from-class").each (i) ->
      button = $(this).find("button")
      removable_classes_dropdown = $(this).find("#removable_classes")
      delete_data = $(this).find("#delete_data")
      removable_classes_dropdown.on 'change', ->
        if $(this).val()
          button.attr('disabled', false)
        else
          button.attr('disabled', true)
      button.click ->
        if remove_confirm_message()
          url = removable_classes_dropdown.val() + '/'  + delete_data.prop('checked')
          $.ajax({
            url: 'remove_class/' + url + ".json",
            success: (data, textStatus, jqXHR) ->
              $("#current_school_classes option[value="+data[0]['value']+"]").remove()
              $("#removable_classes option[value="+data[0]['value']+"]").remove()
              $("#possible_school_classes").append("<option value = '"+data[0]['value']+"'>"+data[0]['name']+"</option>")
              $("#change-classes").find("button").attr('disabled', true)
              button.attr('disabled', true)
            error: (jqXHR, textStatus, error) ->
              alert(error)
          })

  change_confirm_message = (old_class, new_class) ->
    if $("#change-classes").find("#preserve_current").prop('checked')
      confirm("This will transfer "+$("#student_first_name").val()+" "+$("#student_last_name").val()+" and all of their data from "+ old_class.text()+" to "+ new_class.text()+". If data already exists in "+ new_class.text()+" that conflicts with their data in "+ old_class.text()+" it will be replaced.\n This will occur immediately. Continue?")
    else
      confirm("This will transfer "+$("#student_first_name").val()+" "+$("#student_last_name").val()+" and all of their data from "+ old_class.text()+" to "+ new_class.text()+". If data already exists in "+ new_class.text()+" that conflicts with their data in "+ old_class.text()+", their data in "+ old_class.text()+" will be removed.\n This will occur immediately. Continue?")

  remove_confirm_message = ->
    if $("#remove-from-class").find("#delete_data").prop('checked')
      confirm("This will remove "+$("#student_first_name").val()+" "+$("#student_last_name").val()+" from "+$('#removable_classes option[value='+$("#removable_classes").val()+']').text()+" and their data in it will be PERMANENTLY deleted.\nThis will occur immediately. Continue?")
    else
      confirm("This will remove "+$("#student_first_name").val()+" "+$("#student_last_name").val()+" from "+$('#removable_classes option[value='+$("#removable_classes").val()+']').text()+" but their data will be preserved and recovered if they are added again.\nThis will occur immediately. Continue?");

  $(document).ready transferClassButtonListener
  $(document).ready removeFromClassButtonListener
  $(document).ready