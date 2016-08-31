canvas = null
gl = null
cubeVerticesBuffer = null
cubeVerticesIndexBuffer = null
shaderProgram = null
vertexPositionAttribute = null

init = () ->
  canvas = document.getElementById "glcanvas"
  canvas.width = document.body.clientWidth
  canvas.height = document.body.clientHeight
  document.body.onresize = onResize
  initWebGL()
  if gl
    glCamera.bindMouseEvents canvas

    initBuffers()
    initShaders()

    gl.clearColor 0.0, 0.0, 0.0, 1.0
    gl.clearDepth 1.0
    gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT

    glCamera.setDrawCallback drawScene
    drawScene()

initWebGL = () ->
    try
        gl = (canvas.getContext "webgl") or canvas.getContext "experimental-webgl"
    catch error
        console.log error

    unless gl
        alert "Unable to initialize WebGL. Your browser may not suppert it."
        gl = null

onResize = () ->
  canvas.width = document.body.clientWidth
  canvas.height = document.body.clientHeight
  gl.viewport 0, 0, canvas.width, canvas.height
  drawScene()

drawScene = () ->
  gl.clearColor 0.0, 0.0, 0.0, 1.0
  gl.clearDepth 1.0
  gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT
  gl.enable gl.CULL_FACE
  gl.cullFace gl.BACK
  gl.useProgram shaderProgram
  gl.uniformMatrix4fv (gl.getUniformLocation shaderProgram, "MVP"), false, glCamera.getCameraMatrix()
  gl.bindBuffer gl.ARRAY_BUFFER, cubeVerticesBuffer
  gl.vertexAttribPointer vertexPositionAttribute, 3, gl.FLOAT, false, 0, 0
  gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, cubeVerticesIndexBuffer
  gl.drawElements gl.TRIANGLES, 36, gl.UNSIGNED_SHORT, 0

initBuffers = () ->
  cubeVerticesBuffer = gl.createBuffer()
  gl.bindBuffer gl.ARRAY_BUFFER, cubeVerticesBuffer
  vertices = [
    -1.0, -1.0,  1.0,
     1.0, -1.0,  1.0,
     1.0,  1.0,  1.0,
    -1.0,  1.0,  1.0,
    -1.0, -1.0, -1.0,
    -1.0,  1.0, -1.0,
     1.0,  1.0, -1.0,
     1.0, -1.0, -1.0,
    -1.0,  1.0, -1.0,
    -1.0,  1.0,  1.0,
     1.0,  1.0,  1.0,
     1.0,  1.0, -1.0,
    -1.0, -1.0, -1.0,
     1.0, -1.0, -1.0,
     1.0, -1.0,  1.0,
    -1.0, -1.0,  1.0,
     1.0, -1.0, -1.0,
     1.0,  1.0, -1.0,
     1.0,  1.0,  1.0,
     1.0, -1.0,  1.0,
    -1.0, -1.0, -1.0,
    -1.0, -1.0,  1.0,
    -1.0,  1.0,  1.0,
    -1.0,  1.0, -1.0
  ]
  gl.bufferData gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW

  cubeVerticesIndexBuffer = gl.createBuffer()
  gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, cubeVerticesIndexBuffer
  cubeVertexIndices = [
    0,  1,  2,      0,  2,  3,
    4,  5,  6,      4,  6,  7,
    8,  9,  10,     8,  10, 11,
    12, 13, 14,     12, 14, 15,
    16, 17, 18,     16, 18, 19,
    20, 21, 22,     20, 22, 23
  ]
  gl.bufferData gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(cubeVertexIndices), gl.STATIC_DRAW

initShaders = () ->
    fragmentShader = getShader gl, "shader-fs"
    vertexShader = getShader gl, "shader-vs"

    shaderProgram = gl.createProgram()
    gl.attachShader shaderProgram, vertexShader
    gl.attachShader shaderProgram, fragmentShader
    gl.linkProgram shaderProgram

    if !gl.getProgramParameter shaderProgram, gl.LINK_STATUS
        alert "Unable to initialize the shader program: " + gl.getProgramInfoLog shaderProgram

    gl.useProgram shaderProgram

    vertexPositionAttribute = gl.getAttribLocation shaderProgram, "VertexPosition"
    gl.enableVertexAttribArray vertexPositionAttribute

getShader = (gl, id) ->
    shaderScript = document.getElementById id
    return null if !shaderScript

    theSource = ""
    currentChild = shaderScript.firstChild
    while currentChild
        if currentChild.nodeType == currentChild.TEXT_NODE
            theSource += currentChild.textContent
        currentChild = currentChild.nextSibling

    shader = null

    if shaderScript.type == "x-shader/x-fragment"
        shader = gl.createShader gl.FRAGMENT_SHADER
    else if shaderScript.type == "x-shader/x-vertex"
        shader = gl.createShader gl.VERTEX_SHADER
    else
        return null

    gl.shaderSource shader, theSource
    gl.compileShader shader

    if !gl.getShaderParameter shader, gl.COMPILE_STATUS
        alert "An error occurred compiling the shaders: " + gl.getShaderInfoLog shader
        return null

    shader

window.glContext =
  init: init
