Potee.Views.Projects ||= {}

class Potee.Views.Projects.IndexView extends Backbone.View
  template: JST["backbone/templates/projects/index"]

  tagName: 'div'
  id: 'projects'

  initialize: () ->
    @options.projects.bind('reset', @addAll)
    @render()

  addAll: =>
    @options.projects.each(@addOne)

  addOne: (project, prepend) =>
    view = new Potee.Views.Projects.ProjectView
      model : project
    if prepend
      @$el.prepend view.render().el
    else
      @$el.append view.render().el
    view

  render: ->
    @addAll()
    this

  newProject: ->
    project = new Potee.Models.Project
    project_view = @addOne project, true
    project_view.setTitleView 'new'


