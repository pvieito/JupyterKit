#  Jupyter App

Jupyter is a macOS app that can launch and close instances of the Jupyter Notebook server. When you launch the app it will run Jupyter from `/usr/local/bin/jupyter`. Once you quit the app, the server will be terminated.

Also, if an instance of the Jupyter server is already running, it wil detect it and open it in the web browser instead of launching another instance.

## JupiterKit

`JupiterKit` is the core framework of the Jupyter app, it can be used to detect running instances of the Jupyter Notebook server, launch new instances or terminate them.
