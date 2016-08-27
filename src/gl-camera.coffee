
###
Author: Jens G. Magnus
###

bindMouseEvents = (canvas) ->
  canvas.onmousedown = onMouseDown
  canvas.onmouseup = onMouseUp
  canvas.onmousemove = onMouseMove

onMouseUp = (ev) ->
  ev.clientX;
  ev.clientY;

onMouseUp = (ev) ->
  #

onMouseMove = (ev) ->
  #



window.glCamera =
  bindMouseEvents: bindMouseEvents
