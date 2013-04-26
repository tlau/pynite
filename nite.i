/*******************************************************************************
*                                                                              *
*   PrimeSense NiTE 2.0                                                        *
*   Copyright (C) 2012 PrimeSense Ltd.                                         *
*                                                                              *
*******************************************************************************/

%module nite
%{
#include "NiTE.h"
#include "NiteEnums.h"
%}

namespace nite {
    /** Possible failure values */
    typedef enum
    {
        STATUS_OK,
        STATUS_ERROR,
        STATUS_BAD_USER_ID
    } Status;
 
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
    /**
    UserId is a persistent ID for a specific user.
    While the user is known, it will have the same ID.
    */
    typedef short int UserId;

    /**
    This is the main object of the User Tracker algorithm.
    Through it all the users are accessible.
    */
    class UserTracker
    {
    public:

        UserTracker();
        ~UserTracker();

        Status create(openni::Device* pDevice = NULL);

        void destroy();
    };

};

