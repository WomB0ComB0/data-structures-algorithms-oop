from setuptools import setup, find_packages

setup(
    name="dsa-python",
    version="0.1.0",
    packages=find_packages(),
    install_requires=[
        "pytest>=7.0.0",
        "black>=23.0.0",
        "mypy>=1.0.0",
    ],
)
