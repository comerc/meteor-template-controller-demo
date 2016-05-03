{ Template } = require 'meteor/templating'
{ ReactiveVar } = require 'meteor/reactive-var'

require './main.jade'

# 5 steps for start MVVM with TemplateController

# step #1
TemplateTwoWayBinding.getter = (variable) ->
  # this - Template.instance()
  return @state[variable]

# step #2
TemplateTwoWayBinding.setter = (variable, value) ->
  # best place for external data validation (SimpleSchema, Astronomy etc.)
  TemplateControllerModelMap.validateOne.call @, variable, value
  @state[variable] = value
  return

TemplateController 'demo',
  onCreated: ->
    # step #3
    TemplateControllerModelMap.init.call @, NodeSchema.namedContext(@view.name),
      'head': 'fieldHead'
      'body': 'fieldBody'
  onRendered: ->
    # step #4
    TemplateTwoWayBinding.rendered.call @
    @autorun =>
      if @state.nodeId
        doc = Nodes.findOne @state.nodeId
        for variable, fieldName of @modelMap
          @state[variable] = doc[fieldName]
      else
        for variable of @modelMap
          @state[variable] = ''
      @state.submitMessage = ''
      @state.errorMessages = ''
  state:
    nodeId: false
    submitMessage: ''
  helpers:
    nodes: ->
      Nodes.find()
  events:
    'click a.node': (e) ->
      e.preventDefault()
      @state.nodeId = @$(e.target).data('node-id') or false
    'submit form': (e) ->
      e.preventDefault()
      # step #5
      data = TemplateControllerModelMap.getValidData.call @
      return if not data
      # save data
      if @state.nodeId
        Nodes.update @state.nodeId, $set: data,
          => @state.submitMessage = 'updated'
      else
        @state.nodeId = Nodes.insert data,
          => @state.submitMessage = 'inserted'
