=================
MOD_WSGI (HEROKU)
=================

The ``mod_wsgi-packages-heroku`` package is a companion package for
Apache/mod_wsgi. It provides a means of building Apache binaries using
Docker which can be posted up to S3 and then pulled down when deploying
sites to Heroku. This then permits the running of a custom installation
of Apache/mod_wsgi on Heroku sites, overriding the default version which
is supplied with the Heroku Python cartridges.

Building Apache/mod_wsgi
------------------------

Check out this repository from github and run within it::

    docker build -t mod_wsgi-packages-heroku .

This will create a Docker image with a prebuilt installation of Apache
within it.

Once built you need to upload that prebuilt Apache installation up to an
S3 bucket you control. To do that run::

    docker run -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
               -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
               -e S3_BUCKET_NAME=YOUR-BUCKET-NAME \
               mod_wsgi-packages-heroku

This assumes you have your AWS access and secret key defined in environment
variables of the user you are running the command as.

You should also replace ``YOUR-BUCKET-NAME`` with the actual name of the S3
bucket you have and which you are going to use to hold the tar ball for the
prebuilt version of Apache.

Using prebuilt binaries
-----------------------

Although this package provides the means to build up the Apache binaries,
you don't actually need do this yourself. This is because when you install
the mod_wsgi package from PyPi it will automatically install a set of
prebuilt binaries to Heroku for you automatically.

So if you are not concerned that you are installing binaries built by
someone else, simply install the mod_wsgi package from PyPi by listing the
``mod_wsgi`` package as a dependency in your ``setup.py`` file or in your
``requirements.txt`` file.

Using your own binaries
-----------------------

If wish to use this package to compile and host your own binaries, you will
need to configure the ``mod_wsgi`` package when installed to use your
versions.

To do that, if using the same name for the prebuilt binary tarball as the
``mod_wsgi`` package is expecting to find, all you need do is override the
name of the S3 bucket from which the binaries will be pulled. This is done
by setting an environment variable using the ``heroku config:set`` command.

For example, if the name of your Heroku application is ``myapp`` and the
name of your S3 bucket is ``mybucket``, use::

    heroku config:set MOD_WSGI_REMOTE_S3_BUCKET_NAME=mybucket

Once this is done you can then deploy your web application to Heroku.

If you wanted to change the name of the tarball file, you can also set::

    heroku config:set MOD_WSGI_REMOTE_PACKAGES_NAME=mypackages.tar.gz

Running mod_wsgi-express
------------------------

With the ``mod_wsgi`` package and the Apache binaries being installed, then
you only need to override the standard way that Heroku starts up the web
server so that ``mod_wsgi-express`` is used.

To do that, edit the file ``Procfile`` and set::

    web: mod_wsgi-express wsgi.py --log-to-terminal --port $PORT

where ``wsgi.py`` is the relative file system path to the WSGI script file
containing the WSGI application entry point.

For further details on other options for referring to a WSGI application
see the ``mod_wsgi-express`` documentation.

Restrictions on Heroku
----------------------

For ``mod_wsgi-express`` to work on a target platform, that platform must
provide dynamically loadable, shared library variants, of the Python runtime
libraries.

At this time Heroku doesn't provide such shared libraries for all Python
runtimes they provide. The only runtime that it is known they currently
provide them for is Python 3.4.1. As a result, you must be using Python
3.4.1 and have set ``python-3.4.1`` in the ``runtime.txt`` file that
controls which Python runtime Heroku will use.

Comments from Heroku suggest that they may discontinue providing shared
libraries even for Python 3.4.1. If that is the case then it will be
impossible to use ``mod_wsgi-express`` at all on Heroku.

If you want to see continued support for ``mod_wsgi-express`` and the
addition of support for Python 2.7, then you will need to raise it directly
with Heroku.
