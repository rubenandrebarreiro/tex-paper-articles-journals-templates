% $Id$
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{jot}[%
    2010/05/01 0.1
    (c) 2010 Damien Pollet, Inria / Univ. Lille 1, France
]

\ProcessOptions\relax

\LoadClass[10pt,twoside]{article}

\RequirePackage{booktabs}
\RequirePackage{calc}
\RequirePackage{caption}    % captionsetup
\RequirePackage{eso-pic}    % banner on 1st page
\RequirePackage{geometry}
\RequirePackage{graphicx}
\RequirePackage{hyperref}
\RequirePackage{ifthen}
\RequirePackage{keyval}
\RequirePackage{listings}
\RequirePackage{placeins}   % floats before appendices
\RequirePackage{ragged2e}   % \RaggedRight... better ragged text
\RequirePackage{refcount}   % number of last page
\RequirePackage{soul}       % nice spaced small caps
\RequirePackage{wrapfig}    % author pictures
\RequirePackage{xcolor}
% \RequirePackage[grid,texcoord]{eso-pic}
% \RequirePackage{varioref}

%%%% user commands
\@onlypreamble{\title}          % \title{...}
\@onlypreamble{\author}         % \author[affiliation={a1,a2}, photo=file.jpg]{First Last}{bio & contact info}
\@onlypreamble{\affiliation}    % \affiliation{a1}{description}

\@onlypreamble{\jotdetails}     % \jotdetails{key=value}
                                % possible keys:
                                % year, volume, number, doi, url, dates received/published/revised...

\@onlypreamble{\runningtitle}   % override title/author for headers
\@onlypreamble{\runningauthor}
\@onlypreamble{\pdftitle}       % override running title/author for PDF metadata
\@onlypreamble{\pdfauthor}

%%%% Publication information

\newcommand\jot@doiderefaddress{http://dx.doi.org/}
\newcommand\jot@doijournalprefix{10.5381}
\newcommand\jot@articledoiaddress{\jot@doiderefaddress\jot@doi}
\newcommand\jot@journaldoiaddress{\jot@doiderefaddress\jot@journaldoi} % not used
\newcommand\jot@journalname{Journal of Object Technology}
\newcommand\jot@journaladdress{http://www.jot.fm/}
\newcommand{\jot@cclicenseurl}{http://creativecommons.org/licenses/by/4.0/}
\newcommand{\jot@publisher}{AITO --- Association Internationale pour les Technologies Objets}
\newcommand{\jot@copyright}{\copyright\,JOT 2011}
\newcommand{\jot@licenseurl}{\jot@journaladdress/copyright.html}

% Initialize properties to default values
\let\jot@year\@empty
\let\jot@volume\@empty
\let\jot@number\@empty
\let\jot@articleno\@empty
\let\jot@received\@empty
\let\jot@published\@empty
\let\jot@revised\@empty
\let\jot@license\@empty
\newcommand{\jot@declaredfirstpage}{1}
\let\jot@doi\@empty
\newcommand{\jot@url}{\jot@journaladdress}

% Declare keys for \jotdetails
\define@key{jot@details@keys}{year}{\renewcommand{\jot@year}{#1}}
\define@key{jot@details@keys}{volume}{\renewcommand{\jot@volume}{#1}}
\define@key{jot@details@keys}{number}{\renewcommand{\jot@number}{#1}}
\define@key{jot@details@keys}{articleno}{\renewcommand{\jot@articleno}{#1}}
\define@key{jot@details@keys}{received}{\renewcommand{\jot@received}{#1}}
\define@key{jot@details@keys}{published}{\renewcommand{\jot@published}{#1}}
\define@key{jot@details@keys}{revised}{\renewcommand{\jot@revised}{#1}}
\define@key{jot@details@keys}{license}{\renewcommand{\jot@license}{#1}}
\define@key{jot@details@keys}{firstpage}{\renewcommand{\jot@declaredfirstpage}{#1}}
\define@key{jot@details@keys}{doi}{\renewcommand{\jot@doi}{#1}}
\define@key{jot@details@keys}{doisuffix}{\renewcommand{\jot@doi}{\jot@doijournalprefix/#1}}
\define@key{jot@details@keys}{url}{\renewcommand{\jot@url}{#1}}

% argument is a comma seperated list of the type "volume=6,year=8,..."
% If we have details of section we are interested in, process it
\newcommand{\jotdetails}[1]{\setkeys{jot@details@keys}{#1}}


%%%% Article metadata

% metadata setters, to override default values set by \author and \title
\newcommand{\runningtitle}[1]{\renewcommand\jot@runningtitle{#1}}
\newcommand{\runningauthor}[1]{\renewcommand\jot@runningauthor{#1}}
\newcommand{\pdftitle}[1]{\renewcommand{\jot@pdftitle}{#1}}
\newcommand{\pdfauthor}[1]{\renewcommand{\jot@pdfauthor}{#1}}

\newcommand\jot@pageprefix{%
    \ifx\jot@articleno\@empty\@empty\else\jot@articleno:\fi}

\newcommand\jot@doiorurl{%
    \ifx\jot@doi\@empty \jot@url \else \jot@articledoiaddress \fi}
\newcommand\jot@doiorurlhref{%
    \ifx\jot@doi\@empty
        Available at \url{\jot@url}%
    \else
        \href{\jot@articledoiaddress}{\nolinkurl{doi:\jot@doi}}
    \fi}

\newcommand\jot@runningtitle{\jot@title}
\newcommand\jot@runningauthor{}
\newcommand\jot@firstpage{\getpagerefnumber{jot:firstpage}}
\newcommand\jot@lastpage{\getpagerefnumber{jot:lastpage}}
\newcommand\jot@runningcitation{%
    \href{\jot@doiorurl}{\jot@journalname
        \ifx\jot@volume\@empty \else , vol.~\jot@volume\fi
        \ifx\jot@number\@empty \else , no.~\jot@number\fi
        \ifx\jot@year\@empty \else , \jot@year\fi}}

% setting author info

% we're assembling the info into these token lists
\def\jot@authors{\@empty}
\def\jot@authorbios{\@empty}
\def\jot@affiliations{\@empty}
\def\jot@addto@authors{\g@addto@macro\jot@authors}
\def\jot@addto@authorbios{\g@addto@macro\jot@authorbios}

% setup counters for generating author/affiliation links
\newcounter{jot@numauthors}\setcounter{jot@numauthors}{0}
\newcounter{jot@numaffiliations}\setcounter{jot@numaffiliations}{0}
\newtoks\jot@tmp@aff
\newtoks\jot@tmp@pic

% parsing the key/val argument of \author
\newif\ifjot@authorbio@nowrap
\define@key{jot@author@keys}{affiliation}[\@empty]{\jot@tmp@aff\expandafter{#1}}
\define@key{jot@author@keys}{photo}[\@empty]{\jot@tmp@pic\expandafter{#1}}
\define@key{jot@author@keys}{nowrap}[true]{\csname jot@authorbio@nowrap#1\endcsname}

% Handle CC licensing
\newcommand{\jot@ccby}{ccby}
\newcommand{\jot@ccbynd}{ccbynd}
\newcommand{\jot@ccbyncnd}{ccbyncnd}
\newcommand\jot@expandedlicense{%
    \ifx\jot@license\@empty%
      \ClassWarning{jot.cls}{No license specified.}%
    \else%
      \ifx\jot@license\jot@ccby%
        \href{http://creativecommons.org/licenses/by/4.0/}{Attribution 4.0 International (CC BY 4.0)}%
      \else%
        \ifx\jot@license\jot@ccbynd%
          \href{http://creativecommons.org/licenses/by-nd/4.0/}{Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)}%
        \else%
          \ifx\jot@license\jot@ccbyncnd%
            \href{https://creativecommons.org/licenses/by-nc-nd/4.0/}{Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)}%
          \else%
            \ClassWarning{jot.cls}{Unknown license specified.}%
          Unknown license.%
          \fi%
        \fi%
      \fi%
    \fi}

% declare an author: \author[photo=...,affiliation=...]{name}{bio}
\let\orig@author\author % original \author setter, for layout
\newcommand{\jot@needslong@author}[3][]{%
    \addtocounter{jot@numauthors}{1}%
    \edef\jot@tmp@id{\roman{jot@numauthors}}%
    \ifnum 1<\value{jot@numauthors} % not the 1st
        \g@addto@macro\jot@authors{\and}%
        \g@addto@macro\jot@runningauthor{\running@and}%
    \fi
    \g@addto@macro\jot@runningauthor{#2}%
    \jot@tmp@aff{\@empty}\jot@tmp@pic{\@empty}%
    \jot@authorbio@nowrapfalse
    \setkeys{jot@author@keys}{#1}%
    \ifx\the\jot@tmp@aff\@empty \ClassWarning{jot.cls}{No affiliation given for #2}\fi
    \ifx\the\jot@tmp@pic\@empty \ClassWarning{jot.cls}{No photo given for #2}\fi
    % meh, I want proper quasi-quoting...
    \jot@addto@authors{\jot@format@author}%
    \expandafter\jot@addto@authors\expandafter{\expandafter{\jot@tmp@id}}%
    \jot@addto@authors{{#2}}%
    \expandafter\jot@addto@authors\expandafter{\expandafter{\the\jot@tmp@aff}}%
    \jot@addto@authors{{#3}}
    \ifjot@authorbio@nowrap
        \jot@addto@authorbios{\jot@format@shortauthorbio}%
    \else
        \jot@addto@authorbios{\jot@format@authorbio}%
    \fi
    \expandafter\jot@addto@authorbios\expandafter{\expandafter{\jot@tmp@id}}%
    \jot@addto@authorbios{{#2}}%
    \expandafter\jot@addto@authorbios\expandafter{\expandafter{\the\jot@tmp@pic}}%
    \jot@addto@authorbios{{#3}}%
}
\long\def\author{\jot@needslong@author}
\def\thanks{\ClassWarning{jot.cls}{Use the acknowledgments environment instead of \protect\thanks}\@gobble}

% declare an affiliation: \affiliation{id}{details}
\newcommand{\affiliation}[2]{%
    \addtocounter{jot@numaffiliations}{1}%
    \expandafter\def\csname jot@affiliation@#1\endcsname{#2}%
    \expandafter\edef\csname jot@affiliationnum@#1\endcsname{\alph{jot@numaffiliations}}%
    % \ClassWarning{jot.cls}{New affiliation \csname jot@affiliationnum@#1\endcsname: #1}
    \g@addto@macro\jot@affiliations{\jot@format@affiliation{#1}}%
    \define@key{jot@affiliation@keys}{#1}[#1]{\jot@ref@affiliation{#1}}%
}

% setting title
\let\orig@title\title
\renewcommand{\title}[2][\@empty]{%
    \ifx#1\@empty
        \renewcommand\jot@runningtitle{#2}
    \else
        \renewcommand\jot@runningtitle{#1}
    \fi
    \orig@title{#2}
}


%%%% Layout & typography

\geometry{
    % showframe,
    a4paper,
    % letterpaper,
    % asymmetric,
    body={13cm,21cm}, %golden ratio    2x ratio: body={12cm,24cm},
    top=3.5cm, centering,%inner=3cm,
    ignoreall, marginpar=30mm, marginparsep=5mm, %marginpar=42mm, marginparsep=6mm,
    head=10mm, headsep=15mm, foot=15mm,
    columnsep=5mm
}

\setlength{\intextsep}{.5ex} % for wrapfig

\definecolor{internallinkcolor}{rgb}{0,0,0}
\definecolor{externallinkcolor}{rgb}{0,0,0}

\hypersetup{
    breaklinks,
    colorlinks,
    urlcolor=externallinkcolor,
    linkcolor=internallinkcolor,
    filecolor=externallinkcolor,
    citecolor=internallinkcolor,
}



\let\titlefamily\sffamily


% page headers & footers
\pagenumbering{arabic}

\newcommand\jot@headfootsetup{\let\thanks\@gobble\footnotesize}

\renewcommand{\ps@headings}{%
    \renewcommand{\@oddhead}{\titlefamily
        \hfil{\jot@headfootsetup\jot@runningtitle\quad\textperiodcentered\quad}\thepage}%
    \renewcommand{\@evenhead}{\titlefamily
        \thepage{\jot@headfootsetup\quad\textperiodcentered\quad\jot@runningauthor}\hfil}%
    \renewcommand{\@oddfoot}{\titlefamily\hfil{\jot@headfootsetup\jot@runningcitation}\hfil}%
    \renewcommand{\@evenfoot}{\titlefamily\hfil{\jot@headfootsetup\jot@runningcitation}\hfil}%
}

\renewcommand{\ps@plain}{%
    \renewcommand{\@evenhead}{}
    \renewcommand{\@oddhead}{}
    \renewcommand{\@evenfoot}{}
    \renewcommand{\@oddfoot}{%
        \titlefamily
        \hfil
        \begin{minipage}[t]{\textwidth}\jot@headfootsetup\raggedright
            \let\jot@format@author\jot@name@author
            \let\and\running@and
            \let\\\relax
            \jot@authors.\quad
            \emph{\jot@title}.\quad
            Licensed under \jot@expandedlicense.\quad
            In \jot@runningcitation, pages~\jot@pageprefix\jot@firstpage--\jot@lastpage.\quad
            \jot@doiorurlhref
        \end{minipage}%
        \hfil
    }%
}

\pagestyle{headings}

%% sectioning

\renewcommand\section{\@startsection{section}{1}{\z@}%
        {-3.5ex \@plus -1ex \@minus -.2ex}%
        {2.3ex \@plus.2ex}%
        {\normalfont\Large\titlefamily}}
\renewcommand\subsection{\@startsection{subsection}{2}{\z@}%
        {-3.25ex\@plus -1ex \@minus -.2ex}%
        {1.5ex \@plus .2ex}%
        {\normalfont\large\titlefamily}}
\renewcommand\subsubsection{\@startsection{subsubsection}{3}{\z@}%
        {-2.5ex\@plus -1ex \@minus -.2ex}%
        {1ex \@plus .2ex}%
        {\normalfont\normalsize\titlefamily}}
\renewcommand\paragraph{\@startsection{paragraph}{4}{\z@}%
        {2.5ex \@plus1ex \@minus.2ex}%
        {-1em}%
        {\normalfont\normalsize\bfseries}}
\renewcommand\subparagraph{\@startsection{subparagraph}{5}{\parindent}%
        {3.25ex \@plus1ex \@minus .2ex}%
        {-1em}%
        {\normalfont\normalsize\bfseries}}

%% floats

\newenvironment{fullwidth}
    {\list{}{%
            \leftmargin-2cm
            \rightmargin\leftmargin}
        \item\relax}
    {\endlist}

\captionsetup{
    format=plain,
    indention=1.5em,
    labelsep=endash,
    justification=RaggedRight,
    font={normalfont,small},
    labelfont=sf, % same as \titlefamily
}
\captionsetup[listings]{position=above}

\lstset{
    basicstyle={\ttfamily},
    columns=fullflexible,
    captionpos=b,
    abovecaptionskip=\medskipamount,
    % gobble=4,
    % escapeinside={_}{_},
    % escapebegin={\rmfamily\textlangle\itshape},
    % escapeend={\upshape\textrangle},
}
\lstdefinestyle{numbers}{
    numbers=left,
    numberstyle={\sffamily\footnotesize},
    numbersep=5mm,
}
\lstdefinestyle{float}{
    float=tb,
    frame=tb,
    % backgroundcolor=\color{lightgray}
}
%% title page and typesetting author info

%% short way to typeset \and for headers & metadata
\def\running@and{, }

\def\@mysplit#1/#2\@nil{%
  \rlap{\hskip0.1ex\setkeys{jot@affiliation@keys}{#1}}
  \ifx#2\@empty\else\rlap{\hskip0.2ex\raisebox{0.4em}{\footnotesize ,}\hskip0.2ex\setkeys{jot@affiliation@keys}{#2}}\fi}
\newcommand\jot@name@author[4]{#2}
\newcommand\jot@format@author[4]{% id, name, affiliations, bio
    \ifx #4\relax % meh, {} is not \@empty ??
        \relax #2%
    \else
        \hyperlink{jot:authorbio:#1}{#2}%
    \fi
    % list of footnote-like links to affiliations
    \ifx#3\@empty\else\rlap{\setkeys{jot@affiliation@keys}{#3}}\fi}

\newcommand\jot@ref@affiliation[1]{%
    \hyperlink{jot:affiliation:#1}{\strut\textsuperscript{\csname jot@affiliationnum@#1\endcsname}}}
\newcommand\jot@format@affiliation[1]{% id
    \item[\csname jot@affiliationnum@#1\endcsname.\,]%
    \hypertarget{jot:affiliation:#1}{\csname jot@affiliation@#1\endcsname}}

\newlength{\strutheight}
\newcommand\jot@format@authorbio[4]{%
    \ifx #4\relax % meh, {} is not \@empty ??
        \relax
    \else
        \settoheight{\strutheight}{\strut}%
        \noindent
        \ifx #3\@empty\relax\else
            \begin{wrapfigure}{l}{2.5cm}%
                \raisebox{\intextsep+\strutheight-\height}
                         [\strutheight]
                         [\height-\strutheight-\intextsep]
                         {\includegraphics[width=2.5cm]{#3}}%
            \end{wrapfigure}%
        \fi
        \strut\hypertarget{jot:authorbio:#1}{\let\thanks\@gobble\textbf{#2}}\ \ignorespaces
        #4\par
        \bigskip
    \fi
}
\newcommand\jot@format@shortauthorbio[4]{%
    \ifx #4\relax % meh, {} is not \@empty ??
        \relax
    \else
        \noindent
        \ifx #3\@empty
            \hypertarget{jot:authorbio:#1}{\let\thanks\@gobble\textbf{#2}}\ \ignorespaces
            #4
        \else
            \raisebox{-\height}{\includegraphics[width=2.5cm]{#3}}%
            \hspace{5mm}%
            \raisebox{-\height}{\begin{minipage}[t]{\textwidth-3cm}
                \noindent\strut
                \hypertarget{jot:authorbio:#1}{\let\thanks\@gobble\textbf{#2}}\ \ignorespaces
                #4
            \end{minipage}}%
        \fi
        \par
        \bigskip
    \fi
}

\providecommand{\bibname}{References} % it's a babel addition
\let\orig@bibliography\bibliography
\renewcommand\bibliography[1]{
    \phantomsection
    \addcontentsline{toc}{section}{\bibname}
    \orig@bibliography{#1}}
\def\@openbib@code{\itemsep\z@\RaggedRight}

\def\abouttheauthorsname{About the author\ifnum 1<\value{jot@numauthors}s\fi}
\newcommand{\abouttheauthors}{%
    \phantomsection
    \addcontentsline{toc}{section}{\abouttheauthorsname}
    \section*{\abouttheauthorsname}
    \jot@authorbios}

\newcommand\acknowledgmentsname{Acknowledgments}
\newenvironment{acknowledgments}
    {\paragraph*{\acknowledgmentsname}}
    {}

\renewcommand{\@maketitle}{%
    \setcounter{page}{\jot@declaredfirstpage}%
    \label{jot:firstpage}%
    \AddToShipoutPicture*{%
        \setlength\unitlength{1mm}%
        \AtPageUpperLeft{%
            % \put(8,-8){\makebox(0,0)[lt]{\includegraphics[scale=.75]{jot-sig}}}%
            % \put(175,-30){\makebox(0,0)[cc]{\includegraphics[width=3cm]{jot-uml}}}%
            \put(105,-18){\makebox(0,0)[ct]{\parbox{\textwidth}{\centering
                {\Large
                    % \raisebox{.8ex-.5\height}{\includegraphics[height=.8\baselineskip]{jot-umlsquare}}\quad
                    \null\rmfamily\caps\jot@journalname}\\
                \smallskip
                \small\sffamily Published by \jot@publisher\\
                \url{\jot@journaladdress}
                }}}}}%
    \null
    \vskip 3em%
    \begin{center}%
        \let \footnote \thanks
        {\Huge\titlefamily \@title \par}%
        \vskip 1.5em%
        {\large
            \lineskip .75em%
            \begin{tabular}[t]{c}%
                \@author
            \end{tabular}\par}%
        \vskip 1em%
    \end{center}%
    \list{}{%
            \rightmargin    \leftmargin
            \advance\leftmargin 1.5em
            \listparindent  \z@
            \itemindent     \listparindent
            \labelwidth     1em%
            \labelsep       .5em%
            \parsep         \z@
            \itemsep        1ex}%
        \jot@affiliations
    \endlist
    \par
    \vskip 1.5em
}

\renewenvironment{abstract}
    {\quotation\noindent{\titlefamily Abstract}\quad\ignorespaces}
    {\endquotation}

\newcommand{\keywords}[1]{%
    \begin{quotation}\noindent{\titlefamily Keywords}\quad\ignorespaces
    #1%
    \end{quotation}}

\newcommand{\backmatter}{%
     \FloatBarrier
     \appendix}

% document hooks
\AtBeginDocument{%
    \let\jot@title\@title
    \orig@author{\jot@authors}%
    \hypersetup{% Embed PDF metadata after user has set it in preamble.
        pdfauthor=\jot@runningauthor,
        pdftitle=\jot@runningtitle,
        pdfsubject=\jot@journalname,
    }%
    \date{}% should customize \maketitle
    \maketitle
    \raggedbottom
}
\AtEndDocument{%
    \label{jot:lastpage}%
    \vfill
    % \centering
    % \includegraphics[height=\baselineskip]{jot-umlsquare}%
}

% various convenience markup
\newcommand{\email}[1]{\href{mailto:#1}{\nolinkurl{#1}}}

%% varioref:
% \labelformat{section}{\textsection\,#1}
% \labelformat{subsection}{\textsection\,#1}
% \labelformat{subsubsection}{\textsection\,#1}
% \labelformat{figure}{figure\,#1}
% \labelformat{table}{table\,#1}
