# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

PagesController = Paloma.controller('Pages/Pages');
PagesController.prototype.show = () ->

  enableSubmitButton = () ->
    $('.page-form input[type=submit]').removeAttr('disabled');
  $('#page-title').blur(enableSubmitButton)


  addPageViewSelectorCallback = () ->
    CKEDITOR.disableAutoInline = true;

    inline = (element) ->
      $(element).attr("contenteditable", true)
      CKEDITOR.inline( element, {
        toolbar:'Pure',
        on: {
          blur: enableSubmitButton
        }
      });

    window.ckeditor_inline = inline

    $("div.octopieditable").each( () ->
      inline(this)
    )

    $("#tabs").tabs({
      activate: (event, ui) ->
        if ui.newPanel.attr("contenteditable") is "false"
          for name of CKEDITOR.instances
            instance = CKEDITOR.instances[name]
            instance.destroy()  if ui.newPanel and ui.newPanel.is($(instance.element.$))
          ui.newPanel.attr("contenteditable", true)
          ui.newPanel.each( () ->
            editor = inline(this)
          )
    });
    $("#children").sortable({
      placeholder: "ui-state-highlight",
      axis: 'y',
      update: enableSubmitButton
    });
    $("#children").disableSelection();

    submitFunction = () ->
      teacher_body = $('#teacher-body').html()
      student_body = $('#student-body').html()
      title = $('#page-title').html()
      children = $("#children")
      if (children.length)
        $(this).find('.children_order').val(children.sortable('serialize'))
      $(this).find('.teacher_body').val(teacher_body)
      $(this).find('.student_body').val(student_body)
      $(this).find('.title').val(title)
      return true;


    $('.page form ').submit(submitFunction)


  $(document).ready(addPageViewSelectorCallback);
  $(document).ready()

