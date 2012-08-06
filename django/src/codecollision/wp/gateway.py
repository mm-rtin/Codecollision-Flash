from pyamf.remoting.gateway.django import DjangoGateway, pyamf

from django.core.exceptions import ObjectDoesNotExist
from datetime import datetime

from codecollision.wp.models import Posts, Comments, TermRelationships, TermTaxonomy, Terms

""" GET POSTS ID LIST """
def getPostIDList(request, type):
	idList = TermRelationships.objects.select_related().filter(post__post_type=type, post__post_status='publish').order_by('-post__post_date_gmt').values('term_taxonomy__term__name', 'post__id')
	return idList

""" GET POSTS """
def getPosts(request, category, offset, rows):
	
	if category == 'all' :
		data = TermRelationships.objects.select_related().filter(post__post_type='post', post__post_status='publish').order_by('-post__post_date_gmt')
	else:
		data = TermRelationships.objects.select_related().filter(post__post_type='post', post__post_status='publish', term_taxonomy__term__name=category).order_by('-post__post_date_gmt')
	
	""" FILTER OUT ALL posts with the same post id (primary key) """
	postIDs = {}			# Dictionary of all seen Posts.id
	distinctPosts = []	  	# Filtered List of DISTINCT Posts.id
	# For each row in data querySet
	for item in data :  
		# If post.id is NEW add to distinctPosts and add key to postIDs
		if item.post.id not in postIDs :
			postIDs[item.post.id] = True
			distinctPosts.append(item)

	""" GET ONLY POSTS within offset and rows """			
	slicedPosts = distinctPosts[offset:rows+offset]
		
	return slicedPosts

""" GET CATEGORIES """
def getCategories(request):
	categories = TermTaxonomy.objects.select_related().filter(count__gt=0).order_by('term__name').values('term__term_id', 'term__name', 'term__slug', 'taxonomy', 'count')
	return categories

""" GET SINGLE POST """
def getSinglePost(request, postName):
	singlePost = TermRelationships.objects.select_related().filter(post__post_name=postName)
	return singlePost

""" GET PAGE """
def getPage(request, pageName):
	 page = Posts.objects.get(post_name=pageName)
	 return page

""" GET COMMENTS """
def getComments(request, postID, commentID):
	
	if commentID > 0:
		comments = Comments.objects.filter(comment_post_id=postID, comment_approved='1', comment_id__gt=commentID).order_by('comment_order')
	else:
		comments = Comments.objects.filter(comment_post_id=postID, comment_approved='1').order_by('comment_order')
	
	return comments
  
""" SUBMIT COMMENT """
def submitComment(request, postID, commentContent, author, url, parentID):

	ip = request.META['HTTP_X_FORWARDED_FOR']
	utcdate = datetime.utcnow()
	userAgent = request.META['HTTP_USER_AGENT']
	
	# GET POST tuple with postID
	post = Posts.objects.get(id=postID)
	# increment comment_count in Post tuple
	post.comment_count += 1
	post.save()
	
	if parentID == 0:
		commentOrder = (Comments.objects.count() + 1) * 1000
	else:
		commentOrder = Comments.objects.get(comment_id=parentID).comment_order + Comments.objects.filter(comment_parent=parentID).count() + 1
	
	# CREATE COMMENT
	comment = Comments(comment_post_id = post, comment_author = author, comment_author_url = url, comment_author_ip = ip, comment_date = utcdate, comment_date_gmt = utcdate, comment_content = commentContent, comment_karma = 0, comment_approved = 1, comment_agent = userAgent, comment_type = '', comment_parent = parentID, comment_order = commentOrder)
	comment.save()
	
	return True
	
gw = DjangoGateway({
	"wpService.getPostIDList": getPostIDList,
	"wpService.getPosts": getPosts,
	"wpService.getCategories": getCategories,
	"wpService.getSinglePost": getSinglePost,
	"wpService.getPage": getPage,
	"wpService.getComments": getComments,
	"wpService.submitComment": submitComment,
})


