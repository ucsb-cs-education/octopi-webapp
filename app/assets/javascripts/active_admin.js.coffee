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
          success: (data, textSTatus, jqXHR) ->
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
