PagesController = Paloma.controller('StudentPortal/Pages');
PagesController.prototype.assessment_task = () ->

  $(".answer-input").change ->
    parent_box = $(this).closest(".question-box")
    ansArray = []
    parent_box.find(".answer-input").each ->
      ansArray.push parseInt($(this).val())  if $(this).prop("checked") is true

    parent_box.find(".question-input").val JSON.stringify(ansArray)

PagesController.prototype.module_page = () ->

  $("#change-module").change ->
    $(this).attr "action", $("#change-module option:selected").val()
