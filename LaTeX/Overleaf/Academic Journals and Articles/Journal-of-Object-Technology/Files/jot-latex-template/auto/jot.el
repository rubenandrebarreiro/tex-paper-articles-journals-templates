(TeX-add-style-hook
 "jot"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("article" "10pt" "twoside")))
   (add-to-list 'LaTeX-verbatim-environments-local "lstlisting")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "lstinline")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperref")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperimage")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperbaseurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "nolinkurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "lstinline")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (TeX-run-style-hooks
    "article"
    "art10"
    "booktabs"
    "calc"
    "caption"
    "eso-pic"
    "geometry"
    "graphicx"
    "hyperref"
    "ifthen"
    "keyval"
    "listings"
    "placeins"
    "ragged2e"
    "refcount"
    "soul"
    "wrapfig"
    "xcolor")
   (TeX-add-symbols
    '("email" 1)
    '("keywords" 1)
    '("affiliation" 2)
    '("pdfauthor" 1)
    '("pdftitle" 1)
    '("runningauthor" 1)
    '("runningtitle" 1)
    '("jotdetails" 1)
    "bibname"
    "abouttheauthors"
    "acknowledgmentsname"
    "backmatter"
    "author"
    "titlefamily"
    "and"
    "thanks"
    "abouttheauthorsname")
   (LaTeX-add-labels
    "jot:firstpage"
    "jot:lastpage")
   (LaTeX-add-environments
    "fullwidth"
    "acknowledgments")
   (LaTeX-add-pagestyles
    "headings"
    "plain")
   (LaTeX-add-lengths
    "strutheight")
   (LaTeX-add-listings-lstdefinestyles
    "numbers"
    "float"))
 :latex)

