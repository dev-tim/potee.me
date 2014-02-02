class Potee.Controllers.NewProject
  constructor: (options) ->
    @projects_view = options.projects_view
    @dashboard_view = options.dashboard_view
    @$projects = $('#projects')
    $('#new-project-link').bind 'click', @link
    $('#dashboard').bind 'dblclick', @dblclick

    PoteeApp.vent.on 'new_project', @_newProject

  dblclick: (e)=>
    return true if PoteeApp.reqres.request 'current_form:editing?'

    x = e.pageX - window.dashboard_view.left()

    # определяем дату по месту клика
    date = window.timeline_view.momentAt x
    position = @_getClickPosition(e)

    @_newProject date, position

    return false

  # Вынести в роутер?
  link: (e) =>
    # TODO if window.dashboard.get('scale') == 'year'
      #window.dashboard.set 'scale', 'month'

    # TODO вынести в обсервер
    $('#project_new').addClass('active')

    return false

  _newProject: (startFrom = window.dashboard.getCurrentMoment(), position = 0) =>
    scrollTop = @$projects.scrollTop()
    if scrollTop > 100
      @$projects.animate scrollTop: 0, {
        easing: 'easeOutQuart'
        always: =>
          @_buildProject startFrom, position
      }
    else
      @$projects.scrollTop 0 if scrollTop > 0
      @_buildProject startFrom, position


  _buildProject: (startFrom, position) =>
      project = new Potee.Models.Project {}, {}, startFrom
      projects_count = window.projects.length

      if position > 0 and position < projects_count
        project_view = @projects_view.insertToPosition project, position
      else
        project_view = @projects_view.addOne project, (position < projects_count)


  _getClickPosition: (e) ->
    # определяем вертикльную позицию клика относительно блока projects
    project_height = $('.project').height()
    topScroll = @$projects.scrollTop()
    topOffset = @$projects.offset().top
    topshift = e.pageY - topOffset + topScroll

    return Math.round topshift/project_height
