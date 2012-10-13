class Potee.Models.Dashboard extends Backbone.Model
  pixels_per_day: 40
  pixels_per_day_excluding_border: 39
  spanDays: 3

  defaults:
    scale: 'days'

  initialize: (@projects) ->
    @findStartEndDate()
    @scale = "days" # by default
    return

  # По списку проектов находит крайние левую и правые даты
  findStartEndDate: ->
    min = @projects.first().started_at
    max = @projects.first().finish_at

    @projects.each((project)=>
        if project.started_at < min
          min = project.started_at

        if project.finish_at > max
          max = project.finish_at
    )

    @min = moment(min).toDate()
    @max = moment(max).toDate()

    @days = moment(@max).diff(moment(@min), "days") + @spanDays*2

    return

  min_with_span: () ->
    moment(@min).clone().subtract('days', @spanDays).toDate()

  max_with_span: () ->
    moment(@max).clone().add('days', @spanDays).toDate()

  # Возвращает индекс элемента
  #
  # @param [Date] date дата
  # @param [String] input формат (days - дни, months - месяцы, weeks - недели)
  indexOf: (date, input) ->
    index = moment(date).diff(moment(@min), input)
    if input == "days"
      index = index + @spanDays
    index
