class dbrouter(object):

    # READ - for all apps EXCEPT wp (wordpress) use django PostgreSQL
    def db_for_read(self, model, **hints):
        if model._meta.app_label != 'wp':
            return 'django'
        return None

    # WRITE - for all apps EXCEPT wp (wordpress) use django PostgreSQL
    def db_for_write(self, model, **hints):
        if model._meta.app_label != 'wp':
            return 'django'
        return None

    def allow_relation(self, obj1, obj2, **hints):
        if obj1._meta.app_label != 'wp' or obj2._meta.app_label != 'wp':
            return True
        return None

    def allow_syncdb(self, db, model):
        if db == 'django':
            return model._meta.app_label != 'wp'
        elif model._meta.app_label == 'wp':
            return False
        return None

