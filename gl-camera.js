/**
 * gl-camera -- Copyright (c) 2016 Jens G. Magnus
 * @author Jens G. Magnus
 */

import {mat4, vec2, vec3, quat} from 'gl-matrix';

export default class Camera {
    /**
     * Constructs a camera with an element. The elements size is used to
     * calculate the projection matrices. The camera will listen to mouse
     * and touch events emitted by this element.
     */
    constructor(element, settings) {
        this._element = element;

        /* Default values */
        this._smoothingThreshold = 0.0001;

        /* Distance settings (e.g. scrolling) */
        this._distanceSpringiness = 50.0;
        this._distanceSensitivity = 0.005;
        this._currentDistance = 600.0;
        this._targetDistance = 600.0;

        /* Translation settings (e.g. panning of the camera) */
        this._translationSpringiness = 15.0;
        this._translationSensitivity = 0.005;
        this._currentPosition = vec3.create();
        this._targetPosition = vec3.create();

        /* Rotation settings */
        this._rotationSpringiness = 15.0
        this._rotationSensitivity = 0.005;
        this._limitPitch = true;
        this._minPitch = -Math.PI / 2.0;
        this._maxPitch = -Math.PI / 2.0;
        this._currentRotation = vec3.fromValues(0.35, -0.35, 0.0);
        this._targetRotation = vec3.fromValues(0.35, -0.35, 0.0);
        this._rotationMatrix = ((self) => {
            let qy = quat.create();
            let qp = quat.create();
            quat.rotateZ(qy, qy, -self._currentRotation[1]);
            quat.rotateX(qp, qp,  self._currentRotation[0]);
            let qc = quat.multiply(quat.create(), qy, qp);
            return mat4.fromQuat(mat4.create(), qc);
        })(this);

        /* Mouse */
        this._LEFT_MOUSE_BUTTON = 0;
        this._MIDDLE_MOUSE_BUTTON = 1;
        this._RIGHT_MOUSE_BUTTON = 2;
        this._lastMouseX = 0.0;
        this._lastMouseY = 0.0;
        this._currentMouseX = 0.0;
        this._currentMouseY = 0.0;

        /* Touch */
        this._lastTouch1 = vec2.create();
        this._lastTouch2 = vec2.create();
        this._currentTouch1 = vec2.create();
        this._currentTouch2 = vec2.create();

        this.oncameraupdate = null;
        this._mouseCapture = false;

        this._updateCameraInterval = null;

        this._bindMouseAndTouchEvents();
    }

    /**
     * Binds the mouse and touch events of the element
     */
    _bindMouseAndTouchEvents() {
        var self = this;

        /* Mouse events */
        this._element.addEventListener("mousedown", (ev) => {
            self._onMouseDown(ev);
        }, false);
        this._element.addEventListener("mouseup", (ev) => {
            self._onMouseUp(ev);
        }, false);
        this._element.addEventListener("mouseleave", (ev) => {
            self._onMouseUp(ev);
        }, false);
        this._element.addEventListener("mousemove", (ev) => {
            self._onMouseMove(ev);
        }, false);

        /* Scroll event */
        this._element.addEventListener("wheel", (ev) => {
            self._onWheel(ev);
        }, false);

        /* Touch events */
        this._element.addEventListener("touchstart", (ev) => {
            self._onTouchStart(ev);
        }, false);
        this._element.addEventListener("touchend", (ev) => {
            self._onTouchEnd(ev);
        }, false);
        this._element.addEventListener("touchmove", (ev) => {
            self._onTouchMove(ev);
        }, false);

        /* Context menu event, this will cause the context menu
           to no longer pop up on right clicks. */
        this._element.oncontextmenu = (ev) => {
            ev.preventDefault();
            return false;
        }
    }

    /**
     * Sets the oncameraupdate callback to the callback provided. The
     * same effect can be acheived by just setting the oncameraupdate
     * member directly.
     */
    setOnCameraUpdate(cb) {
        this.oncameraupdate = cb;
    }

    /**
     * Gets the current size of the element used by this camera and the
     * element relative mouse location.
     */
    _getElementSizeAndRelativeMouseLocation(ev) {
        let rect = this._element.getBoundingClientRect();
        let left = rect.left + window.pageXOffset;
        let right = rect.right + window.pageXOffset;
        let top = rect.top + window.pageYOffset;
        let bottom = rect.bottom + window.pageYOffset;
        let width = right - left;
        let height = bottom - top;
        let x = ev.clientX - left;
        let y = ev.clientY - top;
        return { width: width, height: height, x: x, y: y };
    }

    /**
     * Touch start handler
     */
    _onTouchStart(ev) {
        ev.preventDefault();
        if (ev.touches.length == 1) {
            let M = _getElementSizeAndRelativeMouseLocation(ev.touches[0]);
            vec2.set(this._lastTouch1, M.x, M.y);
            vec2.copy(this._currentTouch1, this._lastTouch1);
        }
        else {
            let M1 = _getElementSizeAndRelativeMouseLocation(ev.touches[0]);
            let M2 = _getElementSizeAndRelativeMouseLocation(ev.touches[1]);
            vec2.set(this._lastTouch1, M1.x, M1.y);
            vec2.set(this._lastTouch2, M2.x, M2.y);
            vec2.copy(this._currentTouch1, this._lastTouch1);
            vec2.copy(this._currentTouch2, this._lastTouch2);
        }
    }

    /**
     * Touch end handler
     */
    _onTouchEnd(ev) {
        ev.preventDefault();
    }

    /**
     * Touch move handler
     */
     _onTouchMove(ev) {
         ...
     }

     /**
      * Wheel event handler
      */
     _onWheel(ev) {
         ...
     }

     /**
      * Mouse down handler
      */
     _onMouseDown(ev) {
         ...
     }

     /**
      * Mouse up handler
      */
     _onMouseUp(ev) {
         ...
     }

     /**
      * Mouse down handler
      */
     _onMouseMove(ev) {
         ...
     }

     /**
      * Adds the input rotation to the target rotation
      */
     _addRotationInput(x, y) {
         ...
     }

     /**
      * Adds the input to the current position relative to the rotation
      */
     _addTranslationInput(x, y) {
         ...
     }

     /**
      * Calculates the new camera state
      */
     _updateCamera(deltaTime) {
         ...
     }

     /**
      * Returns the camera matrix, that is the view projection matrix
      */
     getCameraMatrix() {
         ...
     }

     /**
      * Returns the view matrix.
      */
     getViewMatrix() {
         ...
     }
}
