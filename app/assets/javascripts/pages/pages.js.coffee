# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
PagesController = Paloma.controller('Pages/Pages');
PagesController.prototype.show = () ->

  enableSubmitButton = () ->
    $('.page-form input[type=submit]').removeAttr('disabled');
  $('#page-title').blur(enableSubmitButton)
  $('#visibility-select').change(enableSubmitButton)

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
    $("#children").find(".octopisortable").each(() ->
      $(this).sortable({
        placeholder: "ui-state-highlight",
        axis: 'y',
        update: enableSubmitButton
      });
      $(this).disableSelection();
    )

    disableLaplayaChild = () ->
      $(this).find('input,select,a,abbr').attr('disabled','')
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
        return true;
      else
        alert "Title cannot be blank"
        return false


    $('#laplaya_task_demo').each(demoCheckboxListener)
    $('#laplaya_task_demo').change(demoCheckboxListener)
    $('form.page-form').submit(submitFunction)
    $('#laplaya_task_demo').change(enableSubmitButton)


  $(document).ready(addPageViewSelectorCallback);
  $(document).ready();

