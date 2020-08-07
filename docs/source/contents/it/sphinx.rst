======
Sphinx
======

.. highlight:: console

Install
=======

https://docs.readthedocs.io/en/stable/intro/getting-started-with-sphinx.html
https://www.sphinx-doc.org/en/master/

::

    jmoreira@devbox:~/projects$ git clone https://github.com/joaomnmoreira/abizi.xyz.git
    jmoreira@devbox:~/projects$ cd abizi.xyz/
    jmoreira@devbox:~/projects/abizi.xyz$ cd docs/
    jmoreira@devbox:~/projects/abizi.xyz/docs$ source /opt/sportmultimedia/Venv/abizi/bin/activate
    (abizi) jmoreira@devbox:~/projects/abizi.xyz/docs$ sphinx-quickstart
    > Separate source and build directories (y/n) [n]: y
    > Project name: Geek Stuff
    > Author name(s): Joao Moreira
    > Project release []: 0.0.1
    > Project language [en]:

- Added extension for GitHubPages in conf.py

::

    extensions = ['sphinx.ext.githubpages']

- Build Documentation (build folder)

::

    (abizi) jmoreira@devbox:~/projects/abizi.xyz/docs$ make html

- Delete Build Folder

::

    (abizi) jmoreira@devbox:~/projects/abizi.xyz/docs$ make clean

Cheat Sheets
============

- `sphinx-doc.org <https://www.sphinx-doc.org/en/latest/contents.html>`__
- `rest-sphinx-memo <https://rest-sphinx-memo.readthedocs.io/>`__
- `docs.typo3.org <https://docs.typo3.org/m/typo3/docs-how-to-document/master/en-us/WritingReST/Index.html>`__
- `thomas-cokelaer.info <https://thomas-cokelaer.info/tutorials/sphinx/rest_syntax.html>`__
- `Openalea documentation <http://openalea.gforge.inria.fr/doc/openalea/doc/_build/html/source/sphinx/rest_syntax.html>`__

Extensions
==========

- `sphinx-copybutton <https://sphinx-copybutton.readthedocs.io/en/latest/>`__

GitHub Pages
============