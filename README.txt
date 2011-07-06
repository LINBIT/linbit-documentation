Notes for DRBD Documentation Maintainers
========================================

Checking out the documentation sources
--------------------------------------

The documentation sources live in the public DRBD git repository at
git.linbit.com. You check them out using the following git command:

-----------------------------------
git clone git://git.linbit.com/drbd-documentation
-----------------------------------

This will create a local copy of the documentation sources in a
subdirectory named "drbd-documentation" which git automatically
creates in your current working directory. Be sure to frequently
update your documentation sources with the following commands:

-----------------------------------
cd drbd-documentation
git pull
-----------------------------------

When you have made changes, please commit them in your local
checkout. Group changes that "logically" belong together in one
commit, and be sure to include an informative commit message:

-----------------------------------
git add <files you wish to include in your commit>
git commit
-----------------------------------


Building the documentation
--------------------------

The DRBD documentation uses makedoc, a GNU Autotools based document
processing toolchain. makedoc is hosted here:

http://github.com/fghaas/makedoc

Once you have created a makedoc checkout, run the following commands
from the root of the DRBD documentation tree (i.e., from the directory
that contains the file you are reading now):

-----------------------------------
make MAKEDOC=/path/to/your/makedoc/checkout
./autogen.sh
./configure
cd <subdirectory>
make <document>.<target format>
-----------------------------------

makedoc is highly configurable; check ./configure --help for supported
options.

For example, in order to build the DRBD User's Guide in PDF form, this
is what you would do after running ./configure:

-----------------------------------
cd users-guide
make drbd-users-guide.pdf
-----------------------------------


Modifying and maintaining the documentation
-------------------------------------------

In order to modify the documentation, all you need is the text editor
of your choice, and the git version control system. The documentation
syntax is AsciiDoc; see http://www.methods.co.nz/asciidoc/ for details
on this format.


Submitting documentation patches
--------------------------------

If you modify the documentation, please subscribe to the drbd-dev
mailing list at http://lists.linbit.com/listinfo/drbd-dev and start
sending patches to drbd-dev@lists.linbit.com.

Please submit patches in a format that makes it easy for us to apply
them to the repository:

-----------------------------------
git pull
git format-patch origin
git send-email --to=drbd-dev@lists.linbit.com *.patch
-----------------------------------
