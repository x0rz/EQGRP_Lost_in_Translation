select u.name owner_name, l.*
from link$ l, user$ u
where u.user# = l.owner#