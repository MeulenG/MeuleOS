# OMOS
Project Tree: <br />
![Screenshot](./docs/OSTree.png) <br />
<div id="top"></div>

<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#Features">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
      </ul>
    </li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project
My first OS written in Assembly and C in order to learn OS Development. I dedicate all my spare-time to developing this.


<p align="right">(<a href="#top">back to top</a>)</p>



### Built With
* [osdev](https://wiki.osdev.org)
* [C](https://www.learn-c.org/)
* [MakeFile](https://makefile.site/)
* [NASM](https://nasm.us/)
* [BOCHS](https://bochs.sourceforge.io)
<p align="right">(<a href="#top">back to top</a>)</p>

## Features

I will update this part as I go on with the project.

### Prerequisites
I recommend you run the following the scripts and compile bochs from source with the given commands if you're on Linux:
* Prerequisites
  ```sh
  ./Dev.sh
  ```
* Prerequisites
  ```sh
  ./DotnetInstall.sh
  ```
* Bochs
  ```sh
    ./configure --enable-smp \
              --enable-cpu-level=6 \
              --enable-all-optimizations \
              --enable-x86-64 \
              --enable-pci \
              --enable-vmx \
              --enable-debugger \
              --enable-disasm \
              --enable-debugger-gui \
              --enable-logging \
              --enable-fpu \
              --enable-3dnow \
              --enable-sb16=dummy \
              --enable-cdrom \
              --enable-x86-debugger \
              --enable-iodebug \
              --disable-plugins \
              --disable-docbook \
              --with-x --with-x11 --with-term --with-sdl2
  ```
## Contact

Oliver Meulengracht - [Linkedin](https://www.linkedin.com/in/olivermeulengracht/) - Mollern2000@outlook.dk

Project Link: [OMOS](https://github.com/MeulenG/OMOS.git)

<p align="right">(<a href="#top">back to top</a>)</p>