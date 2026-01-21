from pathlib import Path
from Cython.Build import cythonize
from setuptools import Extension, find_packages, setup
from setuptools.command.build_ext import build_ext

classifiers=[
    "Intended Audience :: Developers",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.9",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
    "Programming Language :: Python :: 3.13",
    "Programming Language :: Python :: 3.14",
    "Programming Language :: Python :: Implementation :: CPython",
    "Operating System :: OS Independent",
    "Topic :: Software Development :: Libraries",
]

with open("requirements.txt", "r") as f:
    requirements = list(map(str.strip, f.read().split("\n")))[:-1]

this_directory = Path(__file__).parent
long_description = (this_directory / "README.md").read_text()

sources = ["cchecksum/_checksum.pyx", "cchecksum/keccak.c"]
extension = Extension("cchecksum._checksum", sources=sources, include_dirs=["cchecksum"])


class BuildExt(build_ext):
    def build_extensions(self):
        compiler_type = self.compiler.compiler_type
        opt_flag = "/O2" if compiler_type == "msvc" else "-O3"
        for ext in self.extensions:
            extra = list(ext.extra_compile_args or [])
            if opt_flag not in extra:
                extra.append(opt_flag)
            ext.extra_compile_args = extra
        super().build_extensions()


setup(
    name="cchecksum",
    packages=find_packages(),
    version="0.4.0",
    description="An ~18x faster drop-in replacement for eth_utils.to_checksum_address. Raises the exact same Exceptions. Implemented in C.",
    long_description=long_description,
    long_description_content_type="text/markdown",
    author="BobTheBuidler",
    author_email="bobthebuidlerdefi@gmail.com",
    url="https://github.com/BobTheBuidler/cchecksum",
    license="MIT",
    install_requires=requirements,
    python_requires=">=3.9,<4",
    package_data={"cchecksum": ["py.typed", "*.pxd", "**/*.pxd"]},
    include_package_data=True,
    classifiers=classifiers,
    ext_modules=cythonize([extension], compiler_directives={"language_level": 3, "embedsignature": True, "linetrace": False}),
    zip_safe=False,
    cmdclass={"build_ext": BuildExt},
)
