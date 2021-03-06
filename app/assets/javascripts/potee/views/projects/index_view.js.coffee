Potee.Views.Projects ||= {}

class Potee.Views.Projects.IndexView extends Backbone.View
  initialize: (options)->
    @timeline = options.timeline_view
    @projects = options.projects
    @dashboard = options.dashboard
    @$projects = $('#projects')

    @selected_project_view = undefined
    @_shown = false

  resetWidth: (width) =>
    @$el.css 'width', width # @timeline.width()

  buildProjectView: (project) ->
    view = new Potee.Views.Projects.ProjectView
      model : project

    @listenTo view, 'before:close', =>
      @$el.sortable "refresh"

    view

  # По высоте проект вообще виден?
  isProjectViewedVertically: (project) ->
    # Используем координаты проекта вместо title
    # потому что иначе при пеерключении из week в day
    # левые titles сразу не показываются
    # project_top_point = project.view.titleView.$el.offset().top
    #
    project_top_point = project.view.$el.offset().top
    project_bot_point = project_top_point+project.view.titleView.$el.height() - 45

    project_top_point >= @top() and project_bot_point <= @bottom()

  addAll: =>
    @projects.each (project, i) => @addOne(project, false)

  totalHeight: ->
    height = @projects.length * @$('.project').height()

    console.log 'totalHeight', height

    return height

  insertToPosition: (project, position) =>
    view = @buildProjectView project
    some_project = $ ".project:eq(" + position + ")"
    some_project.before view.render().$el
    view.bounce() if view.isNew()

    PoteeApp.trigger 'projects:reorder'
    view

  addOne: (project, prepend) =>
    view = @buildProjectView project
    if prepend
      @$el.prepend view.render().el
    else
      @$el.append view.render().el
    view.bounce() if view.isNew()

    view

  resetScale: =>
    @scrollToCurrentDate()
    @projects.each (project) =>
      project.view.resetScale()
    PoteeApp.trigger 'projects:reset_scale'

  render: ->
    @addAll()
    @scrollToCurrentDate()
    @scrollToLastScrollTop()

    # Перемещаемся на текущее место
    #PoteeApp.commands.setHandler 'gotoCurrentDate'
    @$el.sortable
      axis: "y",
      containment: "parent",
      distance: 20,
      opacity: 0.5,
      update: (event, ui, b) =>
        Backbone.pEvent.trigger 'savePositions'
        @resetTitles()
      sort: =>
        @resetTitles()
      change: =>
        @resetTitles()

    @_bindes()

    # Нужно сбросить titles. Потому что они рендерились когда
    # проекты еще не были в DOM-е и не могли рассчитать свои координаты
    @resetTitles()

    @

  resetTitles: ->
    @projects.each (project) -> project.view.titleView.reset()

  _bindes: ->
    # Корректируем sticky titles при вертикальном скроллинге
    # TODO Пусть sticky titles сами вешаются на on 'render' списка проектов
    $('#projects').bind 'scroll', (e) -> PoteeApp.vent.trigger 'projects:scroll', e

    @projects.bind 'reset', @addAll

    @listenTo @dashboard, 'change:pixels_per_day', @resetScale
    PoteeApp.seb.on 'timeline:reset_width', @resetWidth

  scrollTopAndCallback: (callback) ->
    scrollTop = @$projects.scrollTop()
    if scrollTop > 100
      @$projects.animate scrollTop: 0, {
        easing: 'easeOutQuart'
        always: callback
      }
    else
      @$projects.scrollTop 0 if scrollTop > 0
      callback()

  top: ->
    @$el.offset().top

  bottom: ->
    @$el.height() + @top()

  scrollTop: (arg = undefined) ->
    if arg?
      @$el.parent().scrollTop arg
    else
      @$el.parent().scrollTop()

  scrollToProjectView: (project_view) =>
    return unless project_view?
    y = project_view.y() - @$el.parent().height()/2 + project_view.$el.height()
    console.log 'scroll_to', @scrollTop(),  y
    @$projects.animate
      easing: 'easeOutQuart'
      scrollTop: y

  scrollToLastScrollTop: ->
    @$el.parent().scrollTop @dashboard.get('scroll_top')

  scrollToMoment: (moment) ->
    window.hs.intentionalScroll @timeline.middleOffsetOf moment

  scrollToCurrentDate: ->
    # Отключаем автоматическое обновление даты по скроллингу
    @scrollToMoment window.dashboard.getCurrentDate()
