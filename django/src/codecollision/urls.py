from django.conf.urls.defaults import *
from django.contrib import admin

from codecollision.polls.models import Poll
from codecollision.wp import gateway

admin.autodiscover()

info_dict = {
	'queryset': Poll.objects.all(),
}


urlpatterns = patterns('',
    # Example:
    # (r'^codecollision/', include('codecollision.foo.urls')),

    # POLLS - learning app
    (r'^polls/$', 'codecollision.polls.views.index'),
    (r'^polls/(?P<poll_id>\d+)/$', 'codecollision.polls.views.detail'),
    (r'^polls/(?P<poll_id>\d+)/results/$', 'codecollision.polls.views.results'),
    (r'^polls/(?P<poll_id>\d+)/vote/$', 'codecollision.polls.views.vote'),

    # WP - wordpress access app
    (r'^wp/$', 'codecollision.wp.views.index'),
    (r'^gateway/$', 'codecollision.wp.gateway.gw'),
    (r'^crossdomain.xml$', 'codecollision.wp.views.crossdomain'),
 
    # ADMIN
    (r'^admin/', include(admin.site.urls)),
)
