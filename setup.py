from pathlib import Path
from Cython.Build import cythonize
from setuptools import find_packages, setup
import os

# -----------------------------------------------------------------------------
# Ignore SETUPTOOLS_SCM_PRETEND_VERSION for cchecksum builds.
# This environment variable is sometimes set by downstream projects (e.g., for
# dry runs or CI version overrides). If it is present during a dependency build,
# it can cause cchecksum to be built with the wrong version metadata, leading to
# install failures and version mismatches on PyPI. We only want to use this env
# var if we are building cchecksum as the top-level project, not as a dependency.
# -----------------------------------------------------------------------------
if os.environ.get("SETUPTOOLS_SCM_PRETEND_VERSION"):
    if Path.cwd().resolve() != Path(__file__).parent.resolve():
        del os.environ["SETUPTOOLS_SCM_PRETEND_VERSION"]

with open("requirements.txt", "r") as f:
    requirements = list(map(str.strip, f.read().split("\n")))[:-1]

this_directory = Path(__file__).parent
long_description = (this_directory / "README.md").read_text()

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
    long_description=long_description,
    long_description_content_type="text/markdown",
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
        "cchecksum/**/*.pyx",
        compiler_directives={
            "language_level": 3,
            "embedsignature": True,
            "linetrace": False,
        },
    ),
    zip_safe=False,
)
