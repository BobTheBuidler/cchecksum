# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

import os
import sys

from sphinx.util import logging


project = "cchecksum"
copyright = "2024, BobTheBuidler"
author = "BobTheBuidler"

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    "sphinx.ext.autodoc",
    "sphinx.ext.viewcode",
    "sphinx.ext.napoleon",
    "sphinx.ext.intersphinx",
]

templates_path = ["_templates"]
exclude_patterns = [
    "_build",
    "Thumbs.db",
    ".DS_Store",
]

# Looks for objects in documentation of external libraries
intersphinx_mapping = {
    "eth_typing": ("https://eth-typing.readthedocs.io/en/stable/", None),
    "eth_utils": ("https://eth-utils.readthedocs.io/en/stable/", None),
    "python": ("https://docs.python.org/3", None),
}

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = "sphinx_rtd_theme"
html_static_path = ["_static"]

autodoc_default_options = {
    # "undoc-members": True,
    "special-members": True,
    "inherited-members": True,
    "member-order": "groupwise",
}
autodoc_typehints = "description"
# Don't show class signature with the class' name.
autodoc_class_signature = "separated"

automodule_generate_module_stub = True

sys.path.insert(0, os.path.abspath("./cchecksum"))
