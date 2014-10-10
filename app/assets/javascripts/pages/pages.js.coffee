# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

PagesController = Paloma.controller('Pages/Pages');
PagesController.prototype.enableSubmitButton = () ->
  $('.page-form input[type=submit]').removeAttr('disabled');

PagesController.prototype.ckeditor_inline = (element) ->
  $(element).attr("contenteditable", true)
  resource_type = $('#main-body').find('div.page').attr('data-resource-type')
  resource_id = $('#main-body').find('div.page').attr('data-resource-id')
  config = {
    toolbar: 'Pure',
    on: { blur: PagesController.prototype.enableSubmitButton
    }
  }
  if resource_id and resource_type
    params = "?resource[type]=#{resource_type}&resource[id]=#{resource_id}"
    attachment_files = "/ckeditor/attachment_files#{params}"
    pictures = "/ckeditor/pictures#{params}"
    config.filebrowserBrowseUrl = attachment_files
    config.filebrowserFlashBrowseUrl = attachment_files
    config.filebrowserFlashUploadUrl = attachment_files
    config.filebrowserImageBrowseLinkUrl = pictures
    config.filebrowserImageBrowseUrl = pictures
    config.filebrowserImageUploadUrl = pictures
    config.filebrowserUploadUrl = attachment_files
  CKEDITOR.inline(element, config);

PagesController.prototype.show = () ->

  $(".delete-all-responses-form").submit (e) ->
    currentForm = this
    prompt = "This will delete all student responses to this task in ALL schools."
    email = $(currentForm).find("input[type=submit]").attr("data-email")
    errorMessage = "You must enter your email to continue, or press cancel to quit."
    e.preventDefault()
    confirmationPrompt prompt, email, {success: ->
      currentForm.submit()
    }, errorMessage

  enableSubmitButton = PagesController.prototype.enableSubmitButton
  $('#page-title').blur(enableSubmitButton)
  $('#visibility-select').change(enableSubmitButton)

  addPageViewSelectorCallback = () ->
    CKEDITOR.disableAutoInline = true;

    inline = PagesController.prototype.ckeditor_inline

    $("div.octopieditable").each(() ->
      inline(this)
    )

    $("#tabs").tabs({
      activate: (event, ui) ->
        if ui.newPanel.attr("contenteditable") is "false"
          for name of CKEDITOR.instances
            instance = CKEDITOR.instances[name]
            instance.destroy()  if ui.newPanel and ui.newPanel.is($(instance.element.$))
          ui.newPanel.attr("contenteditable", true)
          ui.newPanel.each(() ->
            editor = inline(this)
          )
    });

    $("#children.octopisortable").each(() ->
      $(this).sortable({
        placeholder: "ui-state-highlight",
        axis: 'y',
        update: enableSubmitButton
      });
      $(this).disableSelection();
    )

    disableLaplayaChild = () ->
      $(this).find('input,select,a,abbr').attr('disabled', '')
      $(this).addClass('demo-disabled')

    enableLaplayaChild = () ->
      $(this).find('input,select,a,abbr').removeAttr('disabled')
      $(this).removeClass('demo-disabled')

    demoCheckboxListener = () ->
      method = if this.checked then disableLaplayaChild else enableLaplayaChild
      $('#child-pages').find('#base-file, #analysis-file').each(method)

    submitFunction = () ->
      teacher_body = $('#teacher-body').html()
      student_body = $('#student-body').html()
      designer_note = $('#designer-note').html()

      title = $('#page-title').html()
      children = $("#children")

      if title isnt ""
        if (children.length)
          $(this).find('.children_order').val(children.sortable('serialize'))
        $(this).find('.teacher_body').val(teacher_body)
        $(this).find('.student_body').val(student_body)
        $(this).find('.designer_note').val(designer_note)
        $(this).find('.title').val(title)
        $(this).find('.btn-primary').val('Saving...').prop('disabled', true)
        return true
      else
        alert "Title cannot be blank"
        return false

    $('#laplaya_task_demo').each(demoCheckboxListener)
    $('#laplaya_task_demo').change(demoCheckboxListener)
    $('form.page-form').submit(submitFunction)
    $('#laplaya_task_demo').change(enableSubmitButton)

    addAlert = (alert, success = true) ->
      $('div.ajax-page-alert').each ->
        $(this).remove();
      a = $(alert).prependTo($('#main-body-container'))
      if success
        a.delay(4000).fadeOut('2', ->
          $(this).remove()
        )

    $(".page-form").bind "ajax:success", ->
      alert = "<div class = 'alert alert-success ajax-page-alert'>'" + $('#page-title').text() + "' has been saved.</div>"
      addAlert(alert, true)

    $(".page-form").bind "ajax:error", (jqXHR, textStatus, settings, errorThrown) ->
      alert = "<div class = 'alert alert-danger ajax-page-alert alert-dismissible'><button type='button' class='close' data-dismiss='alert'><span aria-hidden='true'>&times;</span><span class='sr-only'>Close</span></button>"
      try
        alertarray = JSON.parse(textStatus.responseText)
      catch e
        alert += "An unexpected error occured during saving.</div>"
      if alertarray instanceof Array
        alert += "An error occured during saving."
        $.each alertarray, (index, value) ->
          alert += "<br/>Error: " + value
        alert += "</div>"
      addAlert(alert, false)

  $(document).ready(addPageViewSelectorCallback);
  $(document).ready();

