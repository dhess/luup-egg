;;; scene-status.scm
;;;
;;; A command to determine a scene's status (active or not).
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

(use luup)
(use args)
(use files)

(define opts
  (list (args:make-option (h help) #:none "Display this message"
                          (usage))))

(define (usage)
  (with-output-to-port (current-error-port)
    (lambda ()
      (print "Return a scene's status on a Luup-enabled MiOS device.")
      (newline)
      (print "If the scene name contains a space, use quotes around it.")
      (print "Scene names are case-sensitive.")
      (newline)
      (print "usage: " (pathname-file (car (argv))) " [options] scene-name")
      (newline)
      (print (args:usage opts))))
  (exit 1))

(define (exit-with-error code msg)
  (with-output-to-port (current-error-port)
    (lambda ()
      (print msg)))
  (exit code))

(receive (options operands)
    (args:parse (command-line-arguments) opts)
  (cond ((not (= 1 (length operands)))
         (usage))
        (else
         (let* ((scene-name (car operands))
                (scene (find-scene scene-name)))
           (if (not scene)
               (exit-with-error 1 (string-append "Can't find a scene named '" scene-name "'"))
               (begin
                 (if (active-scene? scene)
                     (print "active")
                     (print "inactive"))
                 (exit 0)))))))
