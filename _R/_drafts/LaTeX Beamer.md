LaTeX Beamer

https://martin-thoma.com/latex-beamer/

In a recent presentation at work, a colleague inquired me why my presentation was quality superior compared to those made with PowerPoint? Even using small letters, graphs typeset with Latex were much more gleaming.   

You can use versioning (GIT, SVN, ...)You can use your favorite editor!When you've created an animation with TikZ, you can easily go one step back an go through it as fast as it is apropriate!Good separation of presentation and contentIt compiles to PDFEverybody can open itIt always looks the same (no moved elements or hidden bullet points)You can use math mode ☺No need to buy anything. It's free and OpenSource.A big community (StackExchange (http://tex.stackexchange.com/questions/tagged/beamer) and LateX- Community (http://www.latex-community.org/forum/viewforum.php?f=3)) helps you, when you got questions.I’ll now introduce you to the basics of LaTeX beamer presentations. If you only look for example, please go to my GitHub LaTeX Repository (https://github.com/MartinThoma/LaTeX-examples/tree/master/presentations).

### Basics 
This is a basic presentation:

 \documentclass{beamer} \usetheme{Frankfurt} \usepackage{hyperref} \usepackage[utf8]{inputenc} % this is needed for german umlauts \usepackage[english]{babel} % this is needed for german umlauts \usepackage[T1]{fontenc}    % this is needed for correct output                             % of umlauts in pdf \begin{document} \title{The title of your presentation} \subtitle{A subtitle} \author{Martin Thoma} \date{25. March 2013} \subject{Computer Science} \frame{\titlepage} \section{Introduction} \subsection{A subsection!} \begin{frame}{Slide title}     Slide content \end{frame} \end{document}
 

### StyleIf you want to create nice-looking presentations like this one (../images/2013/03/tutorium-05.pdf) or that one (../images/2013/03/google-presentation.pdf), you should probably adjust the style. Here is an overview of the default ones that LaTeX has: Beamer theme gallery (http://deic.uab.es/~iblanes/beamer_gallery/) or here (http://latex.simon04.net/).The important commands for changing the appearance, that should get included just after documentclass, are: \usetheme{Frankfurt} \usecolortheme{default}

#### Sections and subsections 
(../images/2013/03/latex-Take a look at the slides I’ve included above. Do you notice the little bubbles at the bottom that indicate how many slides are left?You get the text over the bubbles with \section{Your text} and the bubbles with frame , but you need at least one \subsection{bla} ! When you make more than one subsection, the frame-bubbles that belong to the sameminted.png)one get highlighted.



### Reveal information ¶You might want to try those commands to hide and reveal information:\pause\uncover\visible\onslide and \only



Note that the numbers work like \uncover<n-m>{ELEMENT} . If no m is specified, ELEMENT is visible until end ofthis frame.When you have a list and you want to uncover it element by element, you can use this:


 \begin{itemize}[<+->]     \item one\item two     \item three \end{itemize}
 
 ### Blocks
 You can use block , exampleblock or alertblock inside your frame: \begin{exampleblock}{Test}   This is my text. \end{exampleblock}
 
 
 It looks like this:
 
 
 ### Images
 
 Quite often, you want to have one big image.You need \usepackage{graphicx} in your preamble.

This is how you get the image it: \begin{frame}{My frame title}     \includegraphics[width=\textwidth, height=0.8\textheight, keepaspectratio]{../relative/pa\end{frame}

### Further reading
