'use strict'

class IG.Views.CardsShow extends Backbone.Marionette.ItemView
  tagName: 'li'
  className: 'm-card'

  initialize: ->
    _.bindAll @, 'render'
    @template = 'cards/show'

  render: ->
    super()
    # set 'draggable' attribute on li.m-card
    $(@el).attr 'draggable', "#{@model.draggable()}"

  events:
    # the implicit selector is li.m-card' and afaik there's no way to listen only to events on li.m-card[draggable="true"]
    'dragstart': 'handleDragStart'
    'dragenter': 'handleDragEnter'
    'dragover':  'handleDragOver'
    'dragleave': 'handleDragLeave'
    'dragend':   'handleDragEnd'
    'drop':      'handleDrop'


  getDragTarget: ($dragEventTarget) ->
    if $dragEventTarget.hasClass('m-card')
      $dragTarget = $dragEventTarget
    else
      $parent = $dragEventTarget.parent('.m-card')
      if $parent.length
        $dragTarget = $parent
    $dragTarget

  handleDragStart: (event) ->
    return false unless @model.draggable()
    IG.currentlyDraggedCard = @model
    console.log 'started dragging'
    $(@el).addClass 'low-opacity'
    # don't think i'll need these, though recommended here: http://www.html5rocks.com/en/tutorials/dnd/basics (they use them to switch the labels of a dragged element and the element it's dropped on)
    # event.dataTransfer = event.originalEvent.dataTransfer
    # event.dataTransfer.effectAllowed = 'move'
    # event.dataTransfer.setData 'text/html', @innerHTML

  handleDragEnter: (event) ->
    # prevent dropping on self
    return if @model == IG.currentlyDraggedCard
    # prevent dropping on un-open cards
    return unless @model.isDropTargetFor(IG.currentlyDraggedCard)
    @getDragTarget($ event.target).addClass 'drop-hovered'

  handleDragOver: (event) ->
    # don't think i'll need these
    # event.dataTransfer = event.originalEvent.dataTransfer
    # event.dataTransfer.dropEffect = 'move'

    # the following two lines are mandatory for the 'drop' event to fire
    event.preventDefault()
    return false

  handleDragLeave: (event) ->
    @getDragTarget($ event.target).removeClass 'drop-hovered'

  handleDragEnd: (event) ->
    $(@el).removeClass 'low-opacity'
    IG.currentlyDraggedCard = undefined

  handleDrop: (event) ->
    event.stopPropagation()
    event.preventDefault()
    return unless @model.isDropTargetFor(IG.currentlyDraggedCard)
    console.log 'DROPPED'
    IG.currentlyDraggedCard.moveTo @model.get('column')
    @getDragTarget($ event.target).removeClass 'drop-hovered'
    IG.currentlyDraggedCard = undefined


  # custom function to put some additional meat on 'this' used in the CardsShow template
  # manually adding the output of certain functions that would otherwise
  # not be accessible from the template
  # cf.: http://stackoverflow.com/a/10779124 and
  # http://derickbailey.github.com/backbone.marionette/docs/backbone.marionette.html
  serializeData: ->
    jsonData = @model.toJSON()
    jsonData.humanReadableShort = @model.humanReadableShort()
    jsonData.imagePath = @model.imagePath()
    jsonData.draggable = @model.draggable()
    jsonData
