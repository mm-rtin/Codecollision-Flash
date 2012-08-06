# Django settings for codecollision project.

DEBUG = True 
TEMPLATE_DEBUG = DEBUG

ADMINS = (
	('hexvector', 'michael@hexvector.net'),
)

MANAGERS = ADMINS

INTERNAL_IPS = (
	'127.0.0.1', 
	'72.201.108.53',
)

DATABASES = {
    'default': {
	    'ENGINE': 'django.db.backends.mysql',
	    'NAME': 'hexvector_log_wp',
	    'USER': 'hexvector_log_wp',
	    'PASSWORD': '&Mdolcs&xgjB',
	    'HOST': '',
	    'PORT': '',
    },
    'django': {
		'ENGINE': 'django.db.backends.postgresql_psycopg2', 	# Add 'postgresql_psycopg2', 'postgresql', 'mysql', 'sqlite3' or 'oracle'.
		'NAME': 'hexvector_django',					  		# Or path to database file if using sqlite3.
		'USER': 'hexvector_django',					  		# Not used with sqlite3.
		'PASSWORD': 'jusnwIOWNII15483&^%@)',				  	# Not used with sqlite3.
		'HOST': '',					 						# Set to empty string for localhost. Not used with sqlite3.
		'PORT': '',					 						# Set to empty string for default. Not used with sqlite3.
    } 
}

DATABASE_ROUTERS = ['codecollision.dbrouter.dbrouter',]


MIDDLEWARE_CLASSES = (
    'django.middleware.common.CommonMiddleware',
)

# Local time zone for this installation. Choices can be found here:
# http://en.wikipedia.org/wiki/List_of_tz_zones_by_name
# although not all choices may be available on all operating systems.
# On Unix systems, a value of None will cause Django to use the same
# timezone as the operating system.
# If running in a Windows environment this must be set to the same as your
# system time zone.
TIME_ZONE = 'America/Phoenix'

# Language code for this installation. All choices can be found here:
# http://www.i18nguy.com/unicode/language-identifiers.html
LANGUAGE_CODE = 'en-us'

SITE_ID = 1

# If you set this to False, Django will make some optimizations so as not
# to load the internationalization machinery.
USE_I18N = True

# If you set this to False, Django will not format dates, numbers and
# calendars according to the current locale
USE_L10N = True

# Absolute path to the directory that holds media.
# Example: "/home/media/media.lawrence.com/"
MEDIA_ROOT = ''

# URL that handles the media served from MEDIA_ROOT. Make sure to use a
# trailing slash if there is a path component (optional in other cases).
# Examples: "http://media.lawrence.com", "http://example.com/media/"
MEDIA_URL = 'http://media.codecollision.com'

# URL prefix for admin media -- CSS, JavaScript and images. Make sure to use a
# trailing slash.
# Examples: "http://foo.com/media/", "/media/".
ADMIN_MEDIA_PREFIX = 'http://app.codecollision.com/media/admin/'

# Make this unique, and don't share it with anybody.
SECRET_KEY = 'o!ucb+ykvq628h@_ci8nk)0f^*8r1j+hahdrwqn67+$roh*&52'

# List of callables that know how to import templates from various sources.
TEMPLATE_LOADERS = (
    'django.template.loaders.filesystem.Loader',
    'django.template.loaders.app_directories.Loader',
#     'django.template.loaders.eggs.Loader',
)

MIDDLEWARE_CLASSES = (
    'django.middleware.common.CommonMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    #'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'debug_toolbar.middleware.DebugToolbarMiddleware',
    #'django.middleware.http.SetRemoteAddrFromForwardedFor',
)

ROOT_URLCONF = 'codecollision.urls'

TEMPLATE_DIRS = (
    '/home/hexvector/webapps/django2/codecollision/polls/templates',
    '/home/hexvector/webapps/django2/codecollision/wp/templates',
    # Put strings here, like "/home/html/django_templates" or "C:/www/django/templates".
    # Always use forward slashes, even on Windows.
    # Don't forget to use absolute paths, not relative paths.
)

INSTALLED_APPS = (
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.sites',
    'django.contrib.messages',
    # Uncomment the next line to enable the admin:
    'django.contrib.admin',
    'codecollision.polls',
    'codecollision.wp',
    'debug_toolbar',
)


EMAIL_HOST = 'smtp.webfaction.com'
EMAIL_HOST_USER = 'hexvector'
EMAIL_HOST_PASSWORD = 'password'
DEFAULT_FROM_EMAIL = 'server@codecollision.com'
SERVER_EMAIL = 'server@codecollision.com'
