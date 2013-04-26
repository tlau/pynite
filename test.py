#!/usr/bin/env python

import nite

ret = nite.NiTE.initialize()
print 'Initializing NiTE, return value:', ret

t = nite.UserTracker()
ret = t.create()
print 'Create returned:', ret

nite.NiTE.shutdown()
