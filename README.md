#  Jupyter App

Jupyter is a macOS app that can launch and close instances of the Jupyter Notebook server. When you launch the app it will start a Jupyter notebook and open it in the browser. Once you quit the app, the Jupyter server will be terminated.

Also, if an instance of the Jupyter server is already running, it wil detect it and open it in the web browser instead of launching another instance.

## JupyterKit

`JupyterKit` is the core framework of the Jupyter app, it can be used to list running instances of the Jupyter Notebook server, launch new instances or terminate them.


## JupyterTool

`JupyterTool` is a command line tool that can list the running instances of Jupyter notebooks, inspect their properties and terminate them. It is powered by the `JupyterKit` framework.

