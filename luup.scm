;;; luup.scm
;;;
;;; Make Luup requests to MiOS devices via HTTP.
;;;
;;; Copyright (c) 2010 Drew Hess <dhess-src@bothan.net>.
;;;
;;; Permission is hereby granted, free of charge, to any person
;;; obtaining a copy of this software and associated documentation
;;; files (the "Software"), to deal in the Software without
;;; restriction, including without limitation the rights to use,
;;; copy, modify, merge, publish, distribute, sublicense, and/or sell
;;; copies of the Software, and to permit persons to whom the
;;; Software is furnished to do so, subject to the following
;;; conditions:
;;;
;;; The above copyright notice and this permission notice shall be
;;; included in all copies or substantial portions of the Software.
;;;
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
;;; OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
;;; HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
;;; WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;;; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
;;; OTHER DEALINGS IN THE SOFTWARE.

(module luup (get-status
              get-scenes
              find-scene
              scene-id
              active-scene?
              run-scene)

  (import chicken)
  (import scheme)
  (use srfi-1)
  (use uri-common)
  (use http-client)
  (use json)
  (use data-structures)

;;; This defaults to ";" in http-client and intarweb, but doesn't
;;; pretty much every web API use "&" ?

  (form-urlencoded-separator "&")

;;;
;;; Utilities.
;;;

;;; Fix up json-read so that it delivers JSON objects as alists, not
;;; vectors.

  (define (json-read-fixup jro)
    (cond ((null? jro) jro)
          ((vector? jro) (json-read-fixup (vector->list jro)))
          ((pair? jro) (cons (json-read-fixup (car jro))
                             (json-read-fixup (cdr jro))))
          (else jro)))

  (define (lookup key alist)
    (alist-ref key alist string=? #f))

;;;
;;; Base functionality and "verbs."
;;;

  (define base-uri
    (uri-reference "http://squirrelgirl.internal:49451/data_request"))

;;; Supported request IDs.

  (define status-id "lu_status")
  (define action-id "lu_action")

;;; Make a query URI using a request ID and an alist for the query
;;; parameters. Output format is always specified as JSON.

  (define (make-query-uri request-id params)
    (update-uri base-uri
                query: (append (list (cons "id" request-id)
                                     '(output_format . "json"))
                               params)))

;;; Make a status request URI. Use '() for params for a general status
;;; request, otherwise specify a device number or UDN.

  (define (make-status-uri params)
    (make-query-uri status-id params))

;;; Make an action request URI.

  (define (make-action-uri params)
    (make-query-uri action-id params))

;;; Send a request to the Vera, return the result as parsed JSON.

  (define (send-request uri)
    (json-read-fixup (with-input-from-request uri #f json-read)))

;;;
;;; Device status.
;;;

;;; Returns status of all devices and jobs as an sexp.

  (define (get-status) (send-request (make-status-uri '())))

;;;
;;; Actions.
;;;

;;; Perform an action. The action-specific parameters must be passed
;;; in as an alist.

  (define (perform-action params) (send-request (make-action-uri params)))

;;;
;;; Scene management.
;;;

;;; Returns a list of scenes.

  (define (get-scenes)
    (cdr (assoc "scenes" (get-status))))

;;; Find a scene by name, or return #f if no match.
;;;
;;; XXX dhess - Why is the scene name property named "XXXXXX"? I have no idea.

  (define (find-scene name)
    (find (lambda (scene)
            (string=? (lookup "XXXXXX" scene) name))
          (get-scenes)))

;;; Return the ID of the given scene, or #f if it's not a scene.

  (define (scene-id scene)
    (lookup "id" scene))

;;; Is the scene active?

  (define (active-scene? scene)
    (lookup "active" scene))

;;; Run the scene.
;;;
;;; Note that there is no "un-run scene" functionality in MiOS. Just
;;; deactivate (or activate, as appropriate) one of the devices in the
;;; scene to deactivate the scene.
;;;
;;; Implementation note: scenes are run by sending the RunAction
;;; action to the Luup scene manager, which is always device # 2.

  (define (run-scene scene)
    (perform-action
     (list '("DeviceNum" . 2)
           '("serviceId" . "urn:micasaverde-com:serviceId:HomeAutomationGateway1")
           '("action" . "RunScene")
           (cons "SceneNum" (scene-id scene)))))
  )
