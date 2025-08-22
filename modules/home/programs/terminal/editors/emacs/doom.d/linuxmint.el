;;; linuxmint.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2022 Ahmet Cemal Özgezer
;;
;; Author: Ahmet Cemal Özgezer <ozgezer@gmail.com>
;; Maintainer: Ahmet Cemal Özgezer <ozgezer@gmail.com>
;; Created: December 13, 2022
;; Modified: December 13, 2022
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex tools unix vc wp
;; Homepage: https://github.com/linuxmint/linuxmint
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:


(after! projectile
  (projectile-register-project-type 'cp1200 '("audis_linux" "audis_tools" "audis_utils" "cp1200" "cp1500" "le_nbg2")
                                    :compilation-dir "cp1200/cp1243-1/csd"
                                    :compile "make all_targets")
  (projectile-register-project-type 'cp1200dt '("proj.default.ini")
                                    :project-file "proj.default.ini"
                                    :compilation-dir "cp1200/cp1243-1/csd"
                                    :compile "make all_targets"))

(provide 'linuxmint)
;;; linuxmint.el ends here
