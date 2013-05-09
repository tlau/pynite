#!/usr/bin/env python

import nite
import sys

def main():
    ret = nite.NiTE.initialize()
    if ret != nite.STATUS_OK:
        print 'Unable to initialize NiTE!'
        sys.exit(-1)

    try:
        tracker = nite.UserTracker()
        ret = tracker.create()
        if ret != nite.STATUS_OK:
            print 'Create returned:', ret
            sys.exit(-1)
        else:
            print 'Created user tracker successfully!'

        frame = nite.UserTrackerFrameRef()
        cancel = False

        try:
            while not cancel:
                ret = tracker.readFrame(frame)
#                print 'Return from readFrame:', ret
                if ret != nite.STATUS_OK:
                    print 'Error reading frame'
                    continue

                users = frame.getUsers()
#                print 'Found users:', users
                numusers = len(users)
#                print 'Number of users:', numusers
                if numusers > 0:
                    for i in range(numusers):
                        user = users[i]
                        if user.isNew():
                            print 'USER %i APPEARED!!!' % user.getId()
                            tracker.startSkeletonTracking(user.getId())
                        else:
                            skel = user.getSkeleton()
                            print 'Skeleton:', skel

        except KeyboardInterrupt as e:
            cancel = True

    finally:
        print 'Shutting down NiTE'
        nite.NiTE.shutdown()

if __name__ == '__main__':
    main()
