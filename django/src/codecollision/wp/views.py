from django.shortcuts import render_to_response, get_object_or_404
from codecollision.wp.models import Posts, TermRelationships, TermTaxonomy, Terms, Comments
from django.db import connection, transaction, connections
from datetime import datetime


# CROSSDOMAIN - required for Flash Remoting Gateway
def crossdomain(request):
    return render_to_response('crossdomain.xml')

def index(request):
    
    #data = TermTaxonomy.objects.filter(term_id__name='programming')    # FILTER on specific category
    #data = TermTaxonomy.objects.filter(taxonomy='category')             # FILTER on all categories
    
    #data = TermRelationships.objects.filter(term_taxonomy_id__in=termTaxonomy)
    #data = Posts.objects.filter(id__in=[item.object_id.id for item in termRelationship])
    
    #data = Posts.objects.only("id").filter(post_status='publish').filter(post_type='post')
    #data = Posts.objects.filter(post_status='publish').filter(post_type='post')

    fromIndex = 0
    toIndex = 4
    
    # GET IDLIST
    #data = TermRelationships.objects.select_related().filter(object_id__post_type='post', object_id__post_status='publish').order_by('-object_id__post_date_gmt').values('term_taxonomy_id__term_id__name', 'object_id__id')
    
    # GET POSTS
    data = TermRelationships.objects.select_related().filter(post__post_type='post', post__post_status='publish').order_by('-post__post_date_gmt')
    
    
    """ FILTER OUT ALL posts with the same post id (primary key) """
    postIDs = {}            # Dictionary of all seen Posts.id
    distinctPosts = []      # Filtered List of DISTINCT Posts.id
    # For each row in data querySet
    for item in data :  
        # If post.id is NEW add to distinctPosts and add key to postIDs
        if item.post.id not in postIDs :
            postIDs[item.post.id] = True
            distinctPosts.append(item)
            
            
    # GET CATEGORIES
    #data = TermTaxonomy.objects.select_related().filter(count__gt=0).order_by('term_id__name').values('term_id__term_id', 'term_id__name', 'term_id__slug', 'taxonomy', 'count')

    # GET SINGLE POST
    #data = Posts.objects.filter(post_status='publish').get(post_name='about-page')
    
    # GET COMMENT COUNT
    #data = Posts.objects.values('comment_count').get(id=13)
    
    # GET COMMENTS
    #data = Comments.objects.filter(comment_post_id=13, comment_approved='1').order_by('comment_date_gmt')
    
    #data = Posts.objects.get(post_name='about')
    

    
    #data = TermRelationships.objects.select_related().filter(post__post_type='post', post__post_status='publish').order_by('-post__post_date_gmt')[fromIndex:toIndex]
    

    
    return render_to_response('index.html', {'query': distinctPosts})
