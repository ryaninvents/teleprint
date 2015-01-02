Backbone = require 'backbone'
THREE = require 'three'
require '../OrbitControls'

module.exports =
Printer3DView = Backbone.View.extend
  initialize: ->
    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera(75, 1, 0.1, 1000)
    @renderer = new THREE.WebGLRenderer
      alpha: true
    @renderer.setSize 400, 400
    geometry = new THREE.BoxGeometry 1,0.001,1
    material = new THREE.MeshBasicMaterial
      color: '#DC6A6A'
    brass = new THREE.MeshBasicMaterial
      color: '#F2C61F'
    nozzGeom = new THREE.CylinderGeometry .02, 0, .02, 12
    cube = new THREE.Mesh geometry, material
    nozzle = new THREE.Mesh nozzGeom, brass
    nozzle.position.y = 0.01
    @scene.add cube
    @scene.add nozzle
    @camera.position.z = 1.5
    @camera.position.x = 0.3
    @camera.position.y = 0.7

  render: ->
    @$el.html('').append $ @renderer.domElement
    @$el.css
      'text-align': 'center'

    controls = new THREE.OrbitControls @camera, @$el[0]
    controls.damping = 0.2
    render = =>
      @renderer.render @scene, @camera
    controls.addEventListener 'change', render
    render()
    @
