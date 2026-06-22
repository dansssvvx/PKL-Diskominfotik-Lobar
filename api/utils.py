from .models import ActivityLog

def log_activity(request, action, entity_type=None, entity_id=None, old_value=None, new_value=None):
    """
    Utility function to record user activities.
    """
    user = request.user if request.user.is_authenticated else None
    
    # Get IP address
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        ip = x_forwarded_for.split(',')[0]
    else:
        ip = request.META.get('REMOTE_ADDR')
        
    user_agent = request.META.get('HTTP_USER_AGENT', '')

    ActivityLog.objects.create(
        user=user,
        action=action,
        entity_type=entity_type,
        entity_id=entity_id,
        old_value=old_value,
        new_value=new_value,
        ip_address=ip,
        user_agent=user_agent
    )
