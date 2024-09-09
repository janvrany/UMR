# UMR - a framework for AoT compilation of Smalltalk systems

*UMR* is an experimental implementation of AoT component within larger *Smalltalk-25 project* (described in our [Towards a Dynabook for verified VM construction][1] paper).

Its goals and design are influenced by [*Open Implementations and Metaobject Protocols* by Kiczales and Paepcke][2], Modtalk and work of [Pimás, et al.][3] and lessons learned from these projects.

*UMR* uses [Tinyrossa][4] as its compilation technology.

## Beware...

...that "nothing works!" *UMR* is in early stages of development and code is changing dramatically.

## How to load...

### ...into Pharo

The easiest way to try out *UMR* is to use provided
makefile that automatically downloads all the dependencies
(including Pharo) and builds an image with everything loaded:

    git clone --recurse-submodules https://github.com/janvrany/UMR.git
    cd UMR/bootstrap/pharo
    make run


### ...into Smalltalk/X

Just like with Pharo, the easiest way to try out *UMR* in Smalltalk/X is
to use provided makefile:

    git clone --recurse-submodules https://github.com/janvrany/UMR.git
    cd UMR/bootstrap/stx
    make run


[1]: https://doi.org/10.1016/j.cola.2024.101275
[2]: https://www.researchgate.net/publication/200040398_Open_Implementations_and_Metaobject_Protocols
[3]: https://programming-journal.org/2024/8/5/
[4]: https://github.com/janvrany/Tinyrossa
