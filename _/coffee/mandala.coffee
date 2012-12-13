#
# DRAWERS
# - here is the code that draws on the cavas
# - Each drawer has 2 classes
# -- A Model, which matches some fields on it's view template
# -- A View, whitch handles the drawing, and updating of the model

# GENERIC drawer - all commmon drawer functionality goes here
GenericDrawer = Backbone.View.extend
  #these must be overriden by drawer
  model: null
  template_locator: null

  #and override this function!
  draw: () ->
    null

  #these are set automatically by support code (do not override)
  mandala_model: null
  canvas: null
  mandala_control: null
  
  initialize: ->
    @render()

  render: ->
    template = _.template($(@template_locator).html(), @model.toJSON())
    this.$el.html(template)

  events:
    "change input"              : "control_changed"
    "click  input[type=button]" : "control_changed"

  control_changed: (evt) ->
    name  = evt.currentTarget.name
    element_value = evt.currentTarget.value
    chg_obj = get_change_object(name, element_value)
    @model.set chg_obj
    @mandala_control.draw() unless @mandala_model.get('animating')

  draw_crosshairs: () ->
    console.log "crosshairs"
    mattrs = @mandala_model.attributes
    @canvas.beginPath()
    @canvas.moveTo(0, mattrs.mid.y)
    @canvas.lineTo(mattrs.mid.x, mattrs.mid.y)
    @canvas.lineTo(mattrs.mid.x, 0)
    @canvas.stroke()


# CIRCLES drawer
CirclesModel = Backbone.Model.extend
  defaults:
    num_circles: 100
    x_radius: 400
    y_radius: 400
    radii: 400

CirclesView = GenericDrawer.extend
  model: new CirclesModel
  template_locator: '#circles-template'

  draw: () ->
    #get everything we need from the mandala view/model upfront
    mid    = @mandala_model.get('mid')
    offset = @mandala_model.get('offset')
    num_circles = @model.get('num_circles')
    x_radius = @model.get('x_radius')
    y_radius = @model.get('y_radius')
    radii = @model.get('radii')

    for i in [1..num_circles]
      angle = ((2.0 * Math.PI / num_circles) * i) + offset
      x = x_radius * Math.sin(angle)
      y = y_radius * Math.cos(angle)
      @canvas.beginPath()
      @canvas.arc(mid.x + x, mid.y + y, radii, 0, 2.0 * Math.PI)
      @canvas.stroke()

# STAR drawer
StarsModel = Backbone.Model.extend
  defaults:
    points: 60
    inner_radius: 100
    outer_radius: 200

StarsView = GenericDrawer.extend
  model: new StarsModel
  template_locator: '#stars-template'

  draw: () ->
    #@draw_crosshairs()
    mattrs    = @mandala_model.attributes
    attrs     = @model.attributes
    midx = mattrs.mid.x
    midy = mattrs.mid.y

    step = (2.0 * Math.PI / ((2 * attrs.points)))

    @canvas.beginPath()
    for i in [1..attrs.points]
      point =
        x: midx + (attrs.inner_radius * Math.cos((2*i-1) * step + mattrs.offset))
        y: midy + (attrs.inner_radius * Math.sin((2*i-1) * step + mattrs.offset))
      @canvas.lineTo(point.x, point.y)
      
      point =
        x: midx + (attrs.outer_radius * Math.cos((2*i) * step - mattrs.offset))
        y: midy + (attrs.outer_radius * Math.sin((2*i) * step - mattrs.offset))
      @canvas.lineTo(point.x, point.y)

    #close the star with the last line
    point =
      x: midx + (attrs.inner_radius * Math.cos(step + mattrs.offset))
      y: midy + (attrs.inner_radius * Math.sin(step + mattrs.offset))
    @canvas.lineTo(point.x, point.y)
    @canvas.stroke()
#
# HELPERS
# - stuff below here is all management of cavas and animation
#

#helper function is used for generating object to update a model after an input field changes
# object depends on formatting of value of input field
get_change_object = (name, element_value) ->
  JSON.parse switch name
    when 'animating'
      if element_value == 'Stop'
        "{\""+name+"\": false }"
      else
        "{\""+name+"\": true }"

    else
      #cant use typeof or instanceof here b/c those don't work for built in types !! argh
      if /^[-+]?\d+\.\d+$/.test(element_value)
        "{\""+name+"\":"+parseFloat(element_value,10)+"}"
      else if /^[-+]?\d+$/.test(element_value)
        "{\""+name+"\":"+parseInt(element_value,10)+"}"
      else
        "{\""+name+"\":\""+element_value+"\"}"


MandalaModel = Backbone.Model.extend
  defaults:
    height: 400
    width: 400
    step: 0.008
    offset: 0.0
    animating: false

  initialize: () ->
    @calculate_dimensional_attributes()

  calculate_dimensional_attributes: () ->
    @set 
      mid:
        x: Math.floor(@get('width')  / 2)
        y: Math.floor(@get('height') / 2)
      avg: Math.floor((@get('width') + @get('height')) / 2)
   
  increment: () ->
    this.set('offset', this.get('offset') + this.get('step'))

MandalaControlsView = Backbone.View.extend
  el: '#mandala-controls'
  model: new MandalaModel
  components: []

  initialize: ->
    @controls_id = 0
    @render()
  
    @drawer_controls_container = $('#drawer-controls')

    @canvas_el = $('#mandala-canvas').get(0)
    @canvas = @canvas_el.getContext('2d')
    @toggler = $('input[name=animating]')

    #@add_control('stars')
    #@add_control('circles')

    @model.bind('change', @model_changed, this)
    @model_changed()  #call once to get animating or not

    @draw()

  add_drawer: ->
    type = $("option:selected", $('#drawer-to-add')).text()
    console.log 'adding ' + type
    @add_control(type)
    @draw() unless @model.get('animating')
 
  add_control: (type) ->
    #type is ignored right now....
    @controls_id = @controls_id + 1
    id = 'drawer-' + @controls_id
    jid = '#' + id
    container = _.template($('#drawer-container-template').html(), {id: id})
    @drawer_controls_container.append(container)

    new_component = switch type
      when 'circles'
        new CirclesView el: jid
      when 'stars'
        new StarsView el: jid
      else
        console.log 'ERROR: unknown type of drawer: ' + type
    new_component.mandala_model = @model
    new_component.canvas = @canvas
    new_component.reset_canvas = @draw
    new_component.mandala_control = this
    @components.push(new_component)

  render: ->
    template = _.template($('#mandala-template').html(), @model.toJSON())
    this.$el.html(template)

  events:
    "change .model"              : "control_changed"
    "click  .model[type=button]" : "control_changed"
    "click  #add-new-drawer"     : "add_drawer"

  control_changed: (evt) ->
    name  = evt.currentTarget.name
    element_value = evt.currentTarget.value
    chg_obj = get_change_object(name, element_value)
    @model.set chg_obj

  model_changed: () ->
    if @model.get('animating')
      @go()
    else
      @stop()
  
  go: () ->
    @animate_interval = setInterval((() => 
      @draw()
      @model.increment()
    ), 1000.0/30.0) unless @animate_interval
    @toggler.attr('value', 'Stop')
  
  stop: () ->
    clearInterval(@animate_interval) if @animate_interval
    @animate_interval = null
    @toggler.attr('value', 'Start')

  draw: () ->
    @canvas.clearRect(0,0,@model.get('height'), @model.get('width'))
    for component in @components
      component.draw()


$(window).ready ->
  m = new MandalaControlsView
