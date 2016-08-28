canvas = null
gl = null

init = () ->
  canvas = document.getElementById "glcanvas"
  initWebGL()
  if gl
    glCamera.bindMouseEvents canvas

    gl.clearColor 0.0, 0.0, 0.0, 1.0
    gl.clearDepth 1.0
    gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT

initWebGL = () ->
    try
        gl = (canvas.getContext "webgl") or canvas.getContext "experimental-webgl"
    catch error
        console.log error

    unless gl
        alert "Unable to initialize WebGL. Your browser may not suppert it."
        gl = null

window.glContext =
  init: init
