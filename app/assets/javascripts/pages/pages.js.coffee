# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

addPageViewSelectorCallback = () ->
  inline = (element) ->
    CKEDITOR.inline( element, {
      toolbar:'Pure'
    });

  $("div[octopieditable='true']").each( () ->
    $(this).attr("contenteditable", true)
    inline(this)
  )

  $("#tabs").tabs({
    activate: (event, ui) ->
      if ui.newPanel.attr("contenteditable") is "false"
        for name of CKEDITOR.instances
          instance = CKEDITOR.instances[name]
          instance.destroy  if ui.newPanel and ui.newPanel is instance.element.$
        ui.newPanel.attr("contenteditable", true)
        inline(ui.newPanel)
  });
  $("#children").sortable({
    placeholder: "ui-state-highlight",
    axis: 'y',
    update: ->
      $.post($(this).data('update-url'), $(this).sortable('serialize'))
  });
  $("#children").disableSelection();
  $('#mysubmit').click( ->
  #  my_title = $('.')
    teacher_body = $('#teacher-body').html()
    student_body = $('#student-body').html()
    my_data = {'id': 'test', curriculum_page: {'teacher_body': teacher_body, 'student_body': student_body}}
    $.ajax({
      type: "POST",
      url: $(".curriculum_page").data("update-url"),
      data: my_data,
      contentType : 'application/json'

    })
  )


$(document).ready(addPageViewSelectorCallback);
$(document).on('page:load', addPageViewSelectorCallback);

