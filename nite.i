/*******************************************************************************
*                                                                              *
*   PrimeSense NiTE 2.0                                                        *
*   Copyright (C) 2012 PrimeSense Ltd.                                         *
*                                                                              *
*******************************************************************************/

%module nite
%include "typemaps.i"
%include "carrays.i"
%{
#include "NiTE.h"
#include "NiteCTypes.h"
#include "NiteEnums.h"
%}

/** 3D Point */
typedef struct
{
    float x, y, z;
} NitePoint3f;

/** Quaternion */
typedef struct 
{
    float x, y, z, w;
} NiteQuaternion;

/** 3D Box */
typedef struct  
{
    NitePoint3f min;
    NitePoint3f max;
} NiteBoundingBox;

/** 3D Plane */
typedef struct  
{
    NitePoint3f point;
    NitePoint3f normal;
} NitePlane;


namespace nite {
    /** Available joints in skeleton */
    typedef enum
    {
        JOINT_HEAD,
        JOINT_NECK,

        JOINT_LEFT_SHOULDER,
        JOINT_RIGHT_SHOULDER,
        JOINT_LEFT_ELBOW,
        JOINT_RIGHT_ELBOW,
        JOINT_LEFT_HAND,
        JOINT_RIGHT_HAND,

        JOINT_TORSO,

        JOINT_LEFT_HIP,
        JOINT_RIGHT_HIP,
        JOINT_LEFT_KNEE,
        JOINT_RIGHT_KNEE,
        JOINT_LEFT_FOOT,
        JOINT_RIGHT_FOOT,
    } JointType;

    /** Possible states of the skeleton */
    typedef enum
    {
        /** No skeleton - skeleton was not requested */
        SKELETON_NONE,
        /** Skeleton requested, but still unavailable */
        SKELETON_CALIBRATING,
        /** Skeleton available */
        SKELETON_TRACKED,

        /** Possible reasons as to why skeleton is unavailable */
        SKELETON_CALIBRATION_ERROR_NOT_IN_POSE,
        SKELETON_CALIBRATION_ERROR_HANDS,
        SKELETON_CALIBRATION_ERROR_HEAD,
        SKELETON_CALIBRATION_ERROR_LEGS,
        SKELETON_CALIBRATION_ERROR_TORSO

    } SkeletonState;

    /** Possible failure values */
    typedef enum
    {
        STATUS_OK,
        STATUS_ERROR,
        STATUS_BAD_USER_ID
    } Status;

    typedef enum
    {
        POSE_PSI,
        POSE_CROSSED_HANDS
    } PoseType;


    /**
    The NiTE class is a static entry point to the library.
    Through it you can initialize the library, as well as create User Trackers and Hand Trackers.
    */
    class NiTE
    {
    public:
        static Status initialize();
        static void shutdown();
    private:
        NiTE();
    };

    // UserTracker
    /** UserId is a persistent ID for a specific user.  While the user is
     * known, it will have the same ID.
    */
    typedef short int UserId;

    class Point3f : public NitePoint3f
    {
    public:
        Point3f()
        {
            x = y = z = 0.0f;
        }
        Point3f(float x, float y, float z)
        {
            this->set(x, y, z);
        }
        Point3f(const Point3f& other)
        {
            *this = other;
        }

        void set(float x, float y, float z)
        {
            this->x = x;
            this->y = y;
            this->z = z;
        }

    };

    class Plane : public NitePlane
    {
    public:
        Plane()
        {
            this->point = Point3f();
            this->normal = Point3f();
        }
        Plane(const Point3f& point, const Point3f& normal)
        {
            this->point = point;
            this->normal = normal;
        }
    };
    class Quaternion : public NiteQuaternion
    {
    public:
        Quaternion()
        {
            x = y = z = w = 0;
        }
        Quaternion(float w, float x, float y, float z)
        {
            this->x = x;
            this->y = y;
            this->z = z;
            this->w = w;
        }
    };

    class BoundingBox : public NiteBoundingBox
    {
    public:
        /* TL: This constructor is not defined in the library */
/*        BoundingBox(); */
        BoundingBox(const Point3f& min, const Point3f& max);
    };

    /**
    Provides a simple array class used throughout the API. Wraps a primitive array
    of objects, holding the elements and their count.
    */

    template <class T> class Array {
    public:
        /**
        Default constructor. Creates an empty Array and sets the element count to zero.
        */
        Array() : m_size(0), m_data(NULL) {}
        /**
        Setter function for data. Causes this Array to wrap an existing primitive array
        of specified type.
        @param [in] T Type of objects the Array will contain
        @param [in] data Pointer to first object in list
        @param [in] size Number of objects in list
        */
        void setData(int size, T* data) {m_data = data; m_size = size;}
        /**
        Getter function for the Array size.
        @returns Current number of elements in the Array.
        */
        %rename(__len__) getSize;
        int getSize() const {return m_size;}
        /**
        Check if there are any elements in the Array
        @returns true if there are elements in the Array, false otherwise.
        */
        bool isEmpty() const {return m_size == 0;}


    private:
        Array(const Array&);
        Array& operator=(const Array&);

        int m_size;
        T* m_data;
    };


    /**
    Describe the current state of the pose detection for a specific pose on a specific user
    */
    class PoseData : protected NitePoseData
    {
    public:
        /**
        Get the type of this pose
        */
        PoseType getType() const {return (PoseType)type;}

        /**
        Check if the user is currently in that pose
        */
        bool isHeld() const {return (state & NITE_POSE_STATE_IN_POSE) != 0;}
        /**
        Check if the user has entered the pose in this frame.
        */
        bool isEntered() const {return (state & NITE_POSE_STATE_ENTER) != 0;}
        /**
        Check if the user has exited the pose in this frame.
        */
        bool isExited() const {return (state & NITE_POSE_STATE_EXIT) != 0;}
    };

    /**
    Supplies a map, its size corresponding with the input frame.
    For each pixel, it holds the UserId of the user who occupies that pixel.
    UserId 0 signifies the background - no user detected there.
    */
    class UserMap : private NiteUserMap
    {
    public:
        /**
        Get the pixels as an array, size y*stride
        */
        const UserId* getPixels() const {return pixels;}
        /**
        Get the width of the UserMap in pixels.
        */
        int getWidth() const {return width;}
        /**
        Get the height of the UserMap in pixels.
        */
        int getHeight() const {return height;}
        /**
        Get the stride - the width of the UserMap in bytes.
        */
        int getStride() const {return stride;}

        friend class UserTrackerFrameRef;
    };

    /**
    Describes a specific joint of the skeleton of a specific user
    */
    class SkeletonJoint : private NiteSkeletonJoint
    {
    public:
        /**
        Get the type of the joint
        */
        JointType getType() const {return (JointType)jointType;}
        /**
        Get the current position of the joint
        */
        const Point3f& getPosition() const {return (Point3f&)position;}
        /**
        How sure is NiTE about that position? (between 0 and 1)
        */
        float getPositionConfidence() const {return positionConfidence;}
        /**
        Get the current orientation of the joint
        */
        const Quaternion& getOrientation() const {return (Quaternion&)orientation;}
        /**
        How sure is NiTE about that orientation (between 0 and 1)
        */
        float getOrientationConfidence() const {return orientationConfidence;}
    };
    /**
    Describes a full skeleton of a user
    */
    class Skeleton : private NiteSkeleton
    {
    public:
        /**
        Get a specific joint of the skeleton
        */
        const SkeletonJoint& getJoint(JointType type) const {return (SkeletonJoint&)joints[type];}
        /**
        Get the state of the skeleton
        */
        SkeletonState getState() const {return (SkeletonState)state;}
    };

    /**
    Provides the current information available about a specific user
    */
    class UserData : private NiteUserData
    {
    public:
        /**
        Get the ID of the user. This ID is persistent (i.e., will stay the same int following frames)
        */
        UserId getId() const {return id;}
        /**
        Get a bounding box (in depth coordinates), surrounding the user in the UserMap
        */
        const BoundingBox& getBoundingBox() const;
        /**
        Get the center of mass of the user (in world coordinates)
        */
        const Point3f& getCenterOfMass() const;
        /**
        Check if this is the first frame that this user is available.
        */
        bool isNew() const;
        /**
        Check if the user is currently visible in the field of view
        */
        bool isVisible() const;
        /**
        Check if the user is lost. This will happen once, in the first frame in which the user was declared lost.
        This user will not be provided in consequential frames
        */
        bool isLost() const;

        /**
        Get the full skeleton of this user
        */
        const Skeleton& getSkeleton() const;

        /**
        Get all information about a specific pose for this user
        */
        const PoseData& getPose(PoseType type) const;
    };

    /* TL: we must declare this in order to be able to access the array of userdata objects
     * returned by getUsers */
    %template(userDataArray) Array<UserData>;

    /** Snapshot of the User Tracker algorithm. It holds all the users
     * identified at this time, including their position, skeleton and such, as
     * well as the floor plane */
    class UserTrackerFrameRef
    {
    public:
        UserTrackerFrameRef();
        ~UserTrackerFrameRef();

        UserTrackerFrameRef(const UserTrackerFrameRef& other) : m_pFrame(NULL)
        {
            *this = other;
        }

        bool isValid() const
        {
            return m_pFrame != NULL;
        }

        void release()
        {
            if (m_pFrame != NULL)
            {
                niteUserTrackerFrameRelease(m_userTrackerHandle, m_pFrame);
            }
            m_pFrame = NULL;
            m_userTrackerHandle = NULL;
        }

        const UserData* getUserById(UserId id) const
        {
            for (int i = 0; i < m_users.getSize(); ++i)
            {
                if (m_users[i].getId() == id)
                {
                    return &m_users[i];
                }
            }
            return NULL;
        }

        /**
        Get an Array of all the users available in this frame
        */
        const Array<UserData>& getUsers() const {return m_users;}

        /**
        How sure is NiTE about that floor plane? (between 0 and 1)
        */
        float getFloorConfidence() const {return m_pFrame->floorConfidence;}
        /**
        Get the floor plane
        */
        const Plane& getFloor() const {return (const Plane&)m_pFrame->floor;}

        /**
        Get the depth frame that originated this output
        */
        openni::VideoFrameRef getDepthFrame() {return m_depthFrame;}
        /**
        Get the segmentation of the scene
        */
        const UserMap& getUserMap() const {return static_cast<const UserMap&>(m_pFrame->userMap);}
        /**
        Get the timestamp in which this frame was processed.
        Timestamp is provided in microseconds
        */
        uint64_t getTimestamp() const {return m_pFrame->timestamp;}

        int getFrameIndex() const {return m_pFrame->frameIndex;}
    private:
        friend class User;
        friend class UserTracker;

        Array<UserData> m_users;

        void setReference(NiteUserTrackerHandle userTrackerHandle, NiteUserTrackerFrame* pFrame)
        {
            release();
            m_userTrackerHandle = userTrackerHandle;
            m_pFrame = pFrame;
            m_depthFrame._setFrame(pFrame->pDepthFrame);
            m_users.setData(m_pFrame->userCount, (UserData*)m_pFrame->pUser);
            
        }

        NiteUserTrackerFrame* m_pFrame;
        NiteUserTrackerHandle m_userTrackerHandle;
        openni::VideoFrameRef m_depthFrame;
    };


    /** This is the main object of the User Tracker algorithm.  Through it all
     * the users are accessible.
    */
    class UserTracker
    {
    public:

        UserTracker();
        ~UserTracker();

        Status create(openni::Device* pDevice = NULL);

        void destroy();

        /** Get the next snapshot of the algorithm */
        Status readFrame(UserTrackerFrameRef* pFrame);

        bool isValid() const;

        /** Control the smoothing factor of the skeleton joints. Factor should be between 0 (no smoothing at all) and 1 (no movement at all) */
        Status setSkeletonSmoothingFactor(float factor);
        float getSkeletonSmoothingFactor() const;

        /** Request a skeleton for a specific user */
        Status startSkeletonTracking(UserId id);
        /** Inform the algorithm that a skeleton is no longer required for a specific user */
        void stopSkeletonTracking(UserId id);

        /** Start detecting a specific gesture */
        Status startPoseDetection(UserId user, PoseType type);
        
        /** Stop detecting a specific gesture */
        void stopPoseDetection(UserId user, PoseType type);

        /*
        void addListener(Listener* pListener);
        void removeListener(Listener* pListener);
        */

        /**
        Skeleton joint position is provided in a different set of coordinates than the depth coordinates.
        While the depth coordinates are projective, the joint is provided in real world coordinates, i.e. number of millimeters from the sensor.
        This function enables conversion from the joint coordinates to the depth coordinates. This is useful, for instance, to match the joint on the depth.
        */
        Status convertJointCoordinatesToDepth(float x, float y, float z, float* pOutX, float* pOutY) const;
        /**
        Skeleton joint position is provided in a different set of coordinates than the depth coordinates.
        While the depth coordinates are projective, the joint is provided in real world coordinates, i.e. number of millimeters from the sensor.
        This function enables conversion from the depth coordinates to the joint coordinates. This is useful, for instance, to allow measurements.
        */
        Status convertDepthCoordinatesToJoint(int x, int y, int z, float* pOutX, float* pOutY) const;

    };


};

%extend nite::Array<nite::UserData> {
    nite::UserData __getitem__(unsigned int i) {
        return (*($self))[i];
    }
}
