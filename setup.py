import distutils
import sys
from Cython.Build import cythonize
from setuptools import find_packages, setup

with open("requirements.txt", "r") as f:
    requirements = list(map(str.strip, f.read().split("\n")))[:-1]

try:
    setup(
        name="cchecksum",
        packages=find_packages(),
        use_scm_version={
            "root": ".",
            "relative_to": __file__,
            "local_scheme": "no-local-version",
            "version_scheme": "python-simplified-semver",
        },
        description="A ~8x faster drop-in replacement for eth_utils.to_checksum_address. Raises the exact same Exceptions. Implemented in C.",
        author="BobTheBuidler",
        author_email="bobthebuidlerdefi@gmail.com",
        url="https://github.com/BobTheBuidler/cchecksum",
        license="MIT",
        install_requires=requirements,
        setup_requires=["setuptools_scm", "cython"],
        python_requires=">=3.8,<4",
        package_data={
            "cchecksum": ["py.typed", "*.pxd", "**/*.pxd"],
        },
        include_package_data=True,
        ext_modules=cythonize(
            (
                "cchecksum/_checksum_old.pyx"
                if sys.version_info < (3, 11)
                else "cchecksum/_checksum_new.pyx"
            ),
            compiler_directives={
                "language_level": 3,
                "embedsignature": True,
                "linetrace": False,
            },
        ),
        zip_safe=False,
    )
except distutils.compilers.C.errors.CompileError as e:
    if "Try to install the project normally, without using the editable mode." not in str(e):
        raise
    raise distutils.compilers.C.errors.CompileError(
        """Looks like you haven't properly installed the header files and static libraries for python dev. 
        Use your package manager to install them system-wide.

        For apt (Ubuntu, Debian...):

        sudo apt-get install python-dev   # for python2.x installs
        sudo apt-get install python3-dev  # for python3.x installs

        For yum (CentOS, RHEL...):

        sudo yum install python-devel    # for python2.x installs
        sudo yum install python3-devel   # for python3.x installs

        For dnf (Fedora...):

        sudo dnf install python2-devel  # for python2.x installs
        sudo dnf install python3-devel  # for python3.x installs

        For zypper (openSUSE...):

        sudo zypper in python-devel   # for python2.x installs
        sudo zypper in python3-devel  # for python3.x installs

        For apk (Alpine...):

        # This is a departure from the normal Alpine naming
        # scheme, which uses py2- and py3- prefixes
        sudo apk add python2-dev  # for python2.x installs
        sudo apk add python3-dev  # for python3.x installs

        For apt-cyg (Cygwin...):

        apt-cyg install python-devel   # for python2.x installs
        apt-cyg install python3-devel  # for python3.x installs"""
    ) from e
