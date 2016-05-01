{ Template } = require 'meteor/templating'
{ ReactiveVar } = require 'meteor/reactive-var'

require './main.jade'

TemplateTwoWayBinding.getter = (variable) ->
  # this - Template.instance()
  return @state[variable]()

TemplateTwoWayBinding.setter = (variable, value) ->
  # best place for external data validation (SimpleSchema, Astronomy etc.)
  TemplateControllerModelMap.validateOne.call @, variable, value
  @state[variable](value)
  return

TemplateController 'demo',
  onCreated: ->
    TemplateControllerModelMap.init.call @, NodeSchema.namedContext(@view.name),
      'head': 'fieldHead'
      'body': 'fieldBody'
  onRendered: ->
    TemplateTwoWayBinding.rendered.call @
    @autorun =>
      if @state.nodeId()
        doc = Nodes.findOne(@state.nodeId())
        for variable, fieldName of @modelMap
          @state[variable] doc[fieldName]
      else
        for variable of @modelMap
          @state[variable] ''
  state:
    nodeId: null
  helpers:
    nodes: ->
      Nodes.find()
  events:
    'click a.node': (e) ->
      @state.nodeId @$(e.target).data('node-id') or false
      return false
    'submit form': ->
      data = TemplateControllerModelMap.getValidData.call @
      return false if not data
      # save data
      if @state.nodeId()
        Nodes.update @state.nodeId(), $set: data
      else
        @state.nodeId(Nodes.insert data)
      return false