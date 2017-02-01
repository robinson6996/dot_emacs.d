;;; Compiled snippets and support files for `cc-mode'
;;; Snippet definitions:
;;;
(yas-define-snippets 'cc-mode
		     '(("struct" "struct ${1:name} {\n    $0\n};\n" "struct ... { ... }" nil nil nil "/home/richart/.emacs.d/snippets/cc-mode/struct" nil nil)
		       ("once" "#ifndef ${1:__AKANTU_`(upcase (file-name-nondirectory (file-name-sans-extension (buffer-file-name))))`_`(upcase (file-name-extension (buffer-file-name)))`__}\n#define $1\n\n$0\n\n#endif /* $1 */\n" "#ifndef XXX; #define XXX; #endif" nil nil nil "/home/richart/.emacs.d/snippets/cc-mode/once" nil nil)
		       ("mlc" "/* ${1:$(make-string (- 77 (- (point) (point-at-bol))) ?-)} */\n/* ${1:Title}${1:$(make-string (- 74 (string-width text)) ?\\ )} */\n/* ${1:$(make-string (- 77 (- (point) (point-at-bol))) ?-)} */\n$0" "/* --- */ /* ...     */ /* --- */" nil nil
			((yas/indent-line 'fixed)
			 (yas/wrap-around-region 'nil))
			"/home/richart/.emacs.d/snippets/cc-mode/mlc" nil nil)
		       ("main" "int main(int argc, char *argv[]) {\n  akantu::initialize(&argc, &argv);\n\n  $0\n\n  akantu::finalize();\n\n  return EXIT_SUCCESS;\n}\n" "int main(argc, argv) { ... }" nil nil nil "/home/richart/.emacs.d/snippets/cc-mode/main" nil nil)
		       ("lc" "/* ${1:$(make-string (- 77 (- (point) (point-at-bol))) ?-)} */\n$1\n" "/* --- */" nil nil nil "/home/richart/.emacs.d/snippets/cc-mode/lc" nil nil)
		       ("inc.1" "#include <$1>\n" "#include <...>" nil nil nil "/home/richart/.emacs.d/snippets/cc-mode/inc.1" nil nil)
		       ("inc" "#include \"$1\"\n" "#include \"...\"" nil nil nil "/home/richart/.emacs.d/snippets/cc-mode/inc" nil nil)
		       ("if.1" "if (${1:condition}) $0" "if (...) ..." nil nil nil "/home/richart/.emacs.d/snippets/cc-mode/if.1" nil nil)
		       ("if" "if (${1:condition}) {\n    $0\n}\n" "if (...) { ... }" nil nil nil "/home/richart/.emacs.d/snippets/cc-mode/if" nil nil)
		       ("\\filea" "/**\n * @file   ${1:`(file-name-nondirectory(buffer-file-name))`}\n *\n * @author `(user-full-name)`\n *\n * @date creation  `(format-time-string \"%a %b %d %Y\" (current-time))`\n *\n * @brief ${2:A Documented file.}\n *\n * @section LICENSE\n *\n * Copyright (©) 2010-2011 EPFL (Ecole Polytechnique Fédérale de Lausanne)\n * Laboratory (LSMS - Laboratoire de Simulation en Mécanique des Solides)\n *\n * Akantu is free  software: you can redistribute it and/or  modify it under the\n * terms  of the  GNU Lesser  General Public  License as  published by  the Free\n * Software Foundation, either version 3 of the License, or (at your option) any\n * later version.\n *\n * Akantu is  distributed in the  hope that it  will be useful, but  WITHOUT ANY\n * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR\n * A  PARTICULAR PURPOSE. See  the GNU  Lesser General  Public License  for more\n * details.\n *\n * You should  have received  a copy  of the GNU  Lesser General  Public License\n * along with Akantu. If not, see <http://www.gnu.org/licenses/>.\n *\n */\n" "File description" nil
			("doxygen")
			nil "/home/richart/.emacs.d/snippets/cc-mode/file_description" nil nil)
		       ("do" "do {\n    $0\n} while (${1:condition});\n" "do { ... } while (...)" nil nil nil "/home/richart/.emacs.d/snippets/cc-mode/do" nil nil)))


;;; Do not edit! File generated at Tue Dec 20 16:28:02 2016
