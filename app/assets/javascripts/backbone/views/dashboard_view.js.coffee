class Potee.Views.DashboardView extends Backbone.View
  # id: 'dashboard'
  # tagName: 'div'

  initialize: (options)->
    @model.view = this
    @setElement($('#dashboard'))
    @update()


  setScale: (scale) ->
    @activateScale scale
    @timeline_view.setScale scale
    @update()

  activateScale: (scale) ->
    $('#scale-nav li').removeClass('active')
    $("#scale-#{scale}").addClass('active')

  resetWidth: ->
    @model.findStartEndDate()

    viewportWidth = $('#viewport').width()
    if viewportWidth > @model.width()
      @model.setWidth(viewportWidth)

    @$el.css('width', @model.width())

  render: ->
    # @timeline_zoom_view = new Potee.Views.TimelineZoomView

    @timeline_view ||= new Potee.Views.TimelineView
      dashboard: @model
      dashboard_view: this

    @timeline_view.render()
    @$el.append @timeline_view.el

    @projects_view = new Potee.Views.Projects.IndexView
      projects: @model.projects

    @$el.append @projects_view.el
    return this

  update: ->
    $(@el).html('')
    @resetWidth()
    @render()
    @scrollToToday()
    return

  scrollToToday: ->
    switch @model.get("scale")
      when "days"
        today = moment()
      when "weeks"
        today = moment().day(0)
      when "month"
        today = moment().startOf("month")

    offset = today.diff(moment(@model.min_with_span()), "days") * @model.pixels_per_day
    $('#viewport').scrollLeft(offset)
