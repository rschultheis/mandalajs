// Generated by CoffeeScript 1.3.3
(function() {
  var CirclesModel, CirclesView, GenericDrawer, MandalaControlsView, MandalaModel, StarsModel, StarsView, XModel, XView, get_change_object;

  GenericDrawer = Backbone.View.extend({
    model: null,
    template_locator: null,
    draw: function() {
      return null;
    },
    mandala_model: null,
    canvas: null,
    mandala_control: null,
    name: null,
    initialize: function(init_obj) {
      this.name = init_obj != null ? init_obj.name : void 0;
      this.setup_model();
      return this.render();
    },
    render: function() {
      var template;
      template = _.template($(this.template_locator).html(), this.model.toJSON());
      return this.$el.html(template);
    },
    events: {
      "change input": "control_changed",
      "click  input[type=button]": "control_changed"
    },
    control_changed: function(evt) {
      var chg_obj, element_value, name;
      name = evt.currentTarget.name;
      element_value = evt.currentTarget.value;
      chg_obj = get_change_object(name, element_value);
      this.model.set(chg_obj);
      if (!this.mandala_model.get('animating')) {
        return this.mandala_control.draw();
      }
    },
    draw_crosshairs: function() {
      var mattrs;
      console.log("crosshairs");
      mattrs = this.mandala_model.attributes;
      this.canvas.beginPath();
      this.canvas.moveTo(0, mattrs.mid.y);
      this.canvas.lineTo(mattrs.mid.x, mattrs.mid.y);
      this.canvas.lineTo(mattrs.mid.x, 0);
      return this.canvas.stroke();
    }
  });

  XModel = Backbone.Model.extend({
    defaults: {
      num_circles: 8
    }
  });

  XView = GenericDrawer.extend({
    template_locator: '#x-template',
    setup_model: function() {
      return this.model = new XModel;
    },
    draw: function() {
      var attrs, i, j, mattrs, rotate_amt, step, _i, _j, _ref, _ref1;
      this.draw_crosshairs();
      attrs = this.model.attributes;
      mattrs = this.mandala_model.attributes;
      this.canvas.save();
      this.canvas.translate(200, 200);
      for (i = _i = 1, _ref = attrs.num_circles; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
        step = 2.0 * Math.PI / (i * 3);
        for (j = _j = 1, _ref1 = i * 3; 1 <= _ref1 ? _j <= _ref1 : _j >= _ref1; j = 1 <= _ref1 ? ++_j : --_j) {
          this.canvas.save();
          this.canvas.beginPath();
          rotate_amt = (function() {
            switch (i % 2) {
              case 0:
                return j * step + mattrs.offset;
              case 1:
                return -(j * step + mattrs.offset);
            }
          })();
          this.canvas.rotate(rotate_amt);
          this.canvas.fillStyle = (function() {
            switch (j % 3) {
              case 0:
                return "rgba(200, 0, 0, 0.3)";
              case 1:
                return "rgba(0, 200, 0, 0.3)";
              case 2:
                return "rgba(0, 0, 200, 0.3)";
            }
          })();
          this.canvas.arc(0, i * 20, i * 10, 0, 2.8 * Math.PI, false);
          this.canvas.fill();
          this.canvas.restore();
        }
      }
      return this.canvas.restore();
    }
  });

  CirclesModel = Backbone.Model.extend({
    defaults: {
      num_circles: 100,
      x_radius: 400,
      y_radius: 400,
      radii: 400
    }
  });

  CirclesView = GenericDrawer.extend({
    template_locator: '#circles-template',
    setup_model: function() {
      return this.model = new CirclesModel;
    },
    draw: function() {
      var angle, i, mid, num_circles, offset, radii, x, x_radius, y, y_radius, _i, _results;
      mid = this.mandala_model.get('mid');
      offset = this.mandala_model.get('offset');
      num_circles = this.model.get('num_circles');
      x_radius = this.model.get('x_radius');
      y_radius = this.model.get('y_radius');
      radii = this.model.get('radii');
      _results = [];
      for (i = _i = 1; 1 <= num_circles ? _i <= num_circles : _i >= num_circles; i = 1 <= num_circles ? ++_i : --_i) {
        angle = ((2.0 * Math.PI / num_circles) * i) + offset;
        x = x_radius * Math.sin(angle);
        y = y_radius * Math.cos(angle);
        this.canvas.beginPath();
        this.canvas.arc(mid.x + x, mid.y + y, radii, 0, 2.0 * Math.PI);
        _results.push(this.canvas.stroke());
      }
      return _results;
    }
  });

  StarsModel = Backbone.Model.extend({
    defaults: {
      points: 60,
      inner_radius: 100,
      outer_radius: 200
    }
  });

  StarsView = GenericDrawer.extend({
    template_locator: '#stars-template',
    setup_model: function() {
      return this.model = new StarsModel;
    },
    draw: function() {
      var attrs, i, mattrs, midx, midy, point, step, _i, _ref;
      mattrs = this.mandala_model.attributes;
      attrs = this.model.attributes;
      midx = mattrs.mid.x;
      midy = mattrs.mid.y;
      step = 2.0 * Math.PI / (2 * attrs.points);
      this.canvas.beginPath();
      for (i = _i = 1, _ref = attrs.points; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
        point = {
          x: midx + (attrs.inner_radius * Math.cos((2 * i - 1) * step + mattrs.offset)),
          y: midy + (attrs.inner_radius * Math.sin((2 * i - 1) * step + mattrs.offset))
        };
        this.canvas.lineTo(point.x, point.y);
        point = {
          x: midx + (attrs.outer_radius * Math.cos((2 * i) * step - mattrs.offset)),
          y: midy + (attrs.outer_radius * Math.sin((2 * i) * step - mattrs.offset))
        };
        this.canvas.lineTo(point.x, point.y);
      }
      point = {
        x: midx + (attrs.inner_radius * Math.cos(step + mattrs.offset)),
        y: midy + (attrs.inner_radius * Math.sin(step + mattrs.offset))
      };
      this.canvas.lineTo(point.x, point.y);
      return this.canvas.stroke();
    }
  });

  get_change_object = function(name, element_value) {
    return JSON.parse((function() {
      switch (name) {
        case 'animating':
          if (element_value === 'Stop') {
            return "{\"" + name + "\": false }";
          } else {
            return "{\"" + name + "\": true }";
          }
          break;
        default:
          if (/^[-+]?\d+\.\d+$/.test(element_value)) {
            return "{\"" + name + "\":" + parseFloat(element_value, 10) + "}";
          } else if (/^[-+]?\d+$/.test(element_value)) {
            return "{\"" + name + "\":" + parseInt(element_value, 10) + "}";
          } else {
            return "{\"" + name + "\":\"" + element_value + "\"}";
          }
      }
    })());
  };

  MandalaModel = Backbone.Model.extend({
    defaults: {
      height: 400,
      width: 400,
      step: 0.008,
      offset: 0.0,
      animating: false
    },
    initialize: function() {
      return this.calculate_dimensional_attributes();
    },
    calculate_dimensional_attributes: function() {
      return this.set({
        mid: {
          x: Math.floor(this.get('width') / 2),
          y: Math.floor(this.get('height') / 2)
        },
        avg: Math.floor((this.get('width') + this.get('height')) / 2)
      });
    },
    increment: function() {
      return this.set('offset', this.get('offset') + this.get('step'));
    }
  });

  MandalaControlsView = Backbone.View.extend({
    el: '#wrapper',
    model: new MandalaModel,
    components: [],
    initialize: function() {
      this.controls_id = 0;
      this.mandala_controls_container = $('#mandala-controls');
      this.render();
      this.drawer_controls_container = $('#drawer-controls');
      this.canvas_el = $('#mandala-canvas').get(0);
      this.canvas = this.canvas_el.getContext('2d');
      this.toggler = $('input[name=animating]');
      this.add_control('experiment');
      this.model.bind('change', this.model_changed, this);
      this.model_changed();
      return this.draw();
    },
    add_drawer: function() {
      var type;
      type = $("option:selected", $('#drawer-to-add')).text();
      console.log('adding ' + type);
      this.add_control(type);
      if (!this.model.get('animating')) {
        return this.draw();
      }
    },
    remove_control: function(evt) {
      var name;
      name = evt.currentTarget.name;
      _.each(this.components, function(comp) {
        if (comp.name === name) {
          return $(comp.el).parent().remove();
        }
      });
      this.components = _.reject(this.components, function(comp) {
        return comp.name === name;
      });
      return this.draw();
    },
    add_control: function(type) {
      var container, id, init_obj, jid, new_component;
      this.controls_id = this.controls_id + 1;
      id = 'drawer-' + this.controls_id;
      jid = '#' + id + '-controls';
      container = _.template($('#drawer-container-template').html(), {
        id: id
      });
      this.drawer_controls_container.append(container);
      init_obj = {
        el: jid,
        name: id
      };
      new_component = (function() {
        switch (type) {
          case 'experiment':
            return new XView(init_obj);
          case 'circles':
            return new CirclesView(init_obj);
          case 'stars':
            return new StarsView(init_obj);
          default:
            return console.log('ERROR: unknown type of drawer: ' + type);
        }
      })();
      new_component.mandala_model = this.model;
      new_component.canvas = this.canvas;
      new_component.reset_canvas = this.draw;
      new_component.mandala_control = this;
      return this.components.push(new_component);
    },
    render: function() {
      var template;
      template = _.template($('#mandala-template').html(), this.model.toJSON());
      return this.mandala_controls_container.html(template);
    },
    events: {
      "change .model": "control_changed",
      "click  .model[type=button]": "control_changed",
      "click  #add-new-drawer": "add_drawer",
      "click  .remove-mandala-control": "remove_control"
    },
    control_changed: function(evt) {
      var chg_obj, element_value, name;
      name = evt.currentTarget.name;
      element_value = evt.currentTarget.value;
      chg_obj = get_change_object(name, element_value);
      return this.model.set(chg_obj);
    },
    model_changed: function() {
      if (this.model.get('animating')) {
        return this.go();
      } else {
        return this.stop();
      }
    },
    go: function() {
      var _this = this;
      if (!this.animate_interval) {
        this.animate_interval = setInterval((function() {
          _this.draw();
          return _this.model.increment();
        }), 1000.0 / 30.0);
      }
      return this.toggler.attr('value', 'Stop');
    },
    stop: function() {
      if (this.animate_interval) {
        clearInterval(this.animate_interval);
      }
      this.animate_interval = null;
      return this.toggler.attr('value', 'Start');
    },
    draw: function() {
      var component, _i, _len, _ref, _results;
      this.canvas.clearRect(0, 0, this.model.get('height'), this.model.get('width'));
      _ref = this.components;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        component = _ref[_i];
        _results.push(component.draw());
      }
      return _results;
    }
  });

  $(window).ready(function() {
    var m;
    return m = new MandalaControlsView;
  });

}).call(this);
