from setuptools import setup, find_packages

setup(
    name='process_model',
    version='0.1.0',
    packages=find_packages(where='src'),
    package_dir={"": "src"},
    include_package_data=True,
    install_requires=[
        'Click',
        'tensorflow',
        'jinja2',
    ],
    entry_points={
        'console_scripts': [
            'process_model = process_model.process_model:main',
        ],
    },
)
