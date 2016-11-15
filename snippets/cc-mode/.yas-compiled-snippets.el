;;; Compiled snippets and support files for `cc-mode'
;;; Snippet definitions:
;;;
(yas-define-snippets 'cc-mode
                     '(("do" "do {\n    $0\n} while (${1:condition});\n" "do { ... } while (...)" nil nil nil nil nil nil)
                       ("for" "for (${1:UInt ${2:i} = 0}; ${3:$2 < N}; ${4:++$2}) {\n    $0\n}\n" "for (...; ...; ...) { ... }" nil nil nil nil nil nil)
                       ("for" "for ($1; ${2:it} != ${3:end}; ${4:++$2}) {\n  $0\n}" "for (; it != end; ++it) { ... }" nil nil nil nil nil nil)
                       ("if" "if (${1:condition}) {\n    $0\n}\n" "if (...) { ... }" nil nil nil nil nil nil)
                       ("if.1" "if (${1:condition}) $0" "if (...) ..." nil nil nil nil nil nil)
                       ("inc" "#include \"$1\"\n" "#include \"...\"" nil nil nil nil nil nil)
                       ("inc.1" "#include <$1>\n" "#include <...>" nil nil nil nil nil nil)
                       ("lc" "/* ${1:$(make-string (- 77 (- (point) (point-at-bol))) ?-)} */\n$1\n" "/* --- */" nil nil nil nil nil nil)
                       ("main" "int main(int argc, char *argv[]) {\n  akantu::initialize(&argc, &argv);\n\n  $0\n\n  akantu::finalize();\n\n  return EXIT_SUCCESS;\n}\n" "int main(argc, argv) { ... }" nil nil nil nil nil nil)
                       ("mlc" "/* ${1:$(make-string (- 77 (- (point) (point-at-bol))) ?-)} */\n/* ${1:Title}${1:$(make-string (- 74 (string-width text)) ?\\ )} */\n/* ${1:$(make-string (- 77 (- (point) (point-at-bol))) ?-)} */\n$0" "/* --- */ /* ...     */ /* --- */" nil nil
                        ((yas/indent-line 'fixed)
                         (yas/wrap-around-region 'nil))
                        nil nil nil)
                       ("once" "#ifndef ${1:__AKANTU_`(upcase (file-name-nondirectory (file-name-sans-extension (buffer-file-name))))`_`(upcase (file-name-extension (buffer-file-name)))`__}\n#define $1\n\n$0\n\n#endif /* $1 */\n" "#ifndef XXX; #define XXX; #endif" nil nil nil nil nil nil)
                       ("struct" "struct ${1:name} {\n    $0\n};\n" "struct ... { ... }" nil nil nil nil nil nil)))


;;; Do not edit! File generated at Tue Mar 31 11:34:27 2015
