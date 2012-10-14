Potee.Views.Projects ||= {}

class Potee.Views.Projects.ProjectView extends Backbone.View
  template: JST["backbone/templates/projects/project"]
  tagName: "div"
  className: 'project'

  initialize: ->
    @model.view = this

  events:
    "click .title" : "edit"
    "click .progress .bar" : "add_event"

  add_event: (js_event) ->
    datetime = window.router.dashboard.datetime_by_x_coord(@model, js_event.clientX)
    projectEvents = new Potee.Collections.EventsCollection(project: @model)
    event = projectEvents.create(
      title: "Title of your event",
      date: datetime,
      time: datetime,
      project_id: @model.id)
    event_view = new Potee.Views.Events.EventView
      model: event,
      x: js_event.offsetX

    el = event_view.render().$el
    @$el.append el
    el.effect('bounce', {times: 3}, 100)



  edit: (e)->
    e.stopPropagation()
    @setTitleView 'edit'

  bounce: ->
    @$el.effect('bounce', {times: 5}, 200)

  destroy: () ->
    window.projects.remove @model
    # @model.destroy()
    @$el.slideUp('fast', ->
      @remove
    )

    return false


  # Project's line left margin (when does it start)
  setLeftMargin: ->
    @$el.css('margin-left', @leftMargin())

  leftMargin: ->
    dashboardStart = moment(window.dashboard.min_with_span())
    offsetInDays = moment(@model.started_at).diff(dashboardStart, "days")
    return offsetInDays * window.dashboard.pixels_per_day

  # Project's line width
  setDuration: ->
    @$el.css('width', @width())

  width: ->
    return @model.duration() * window.dashboard.pixels_per_day

  setTitleView: (state)->

    if @titleView
      @titleEl = undefined
      @titleView.remove()

    switch state
      when 'show' then title_view_class = Potee.Views.Titles.ShowView
      when 'edit' then title_view_class = Potee.Views.Titles.EditView
      when 'new'  then title_view_class = Potee.Views.Titles.NewView

    options =
      project_view: this
      model: @model

    if @titleEl
      options['el'] = @titleEl

    @titleView = new title_view_class options
    @titleView.render()

    if !@titleEl
      @titleEl = @titleView.el
      @$el.append @titleEl

    @$el.find('input#title').focus()

    @bounce() if state == 'new'

  render: ->
    @titleEl = undefined
    # TODO Вынести progressbar в отдельную вьюху?

    @$el.html(@template(@model.toJSON() ))
    @$el.attr('id', @model.cid)
    @$el.addClass('project-color-'+@model.get('color_index'))

    @model.projectEvents.each((event)=>
      event_view = new Potee.Views.Events.EventView(model: event)
      @$el.append(event_view.render().el)
    )

    @setTitleView('show')

    @setLeftMargin()
    @setDuration()

    @$el.resizable(
      grid: window.dashboard.pixels_per_day,
      stop: (event, ui) =>
        @durationChanged(ui.size.width)
    )
    return this

  durationChanged: (width) ->
    duration = Math.round(width / window.dashboard.pixels_per_day)
    @model.setDuration(duration)

    totalWidth = @width() + @leftMargin()
    if totalWidth > window.dashboard.width()
      dashboard.findStartEndDate()
      dashboard.view.update()

