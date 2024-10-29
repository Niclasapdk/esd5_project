find_package(PkgConfig)

PKG_CHECK_MODULES(PC_GR_BEAMSCAN gnuradio-beamscan)

FIND_PATH(
    GR_BEAMSCAN_INCLUDE_DIRS
    NAMES gnuradio/beamscan/api.h
    HINTS $ENV{BEAMSCAN_DIR}/include
        ${PC_BEAMSCAN_INCLUDEDIR}
    PATHS ${CMAKE_INSTALL_PREFIX}/include
          /var/empty/local/include
          /var/empty/include
)

FIND_LIBRARY(
    GR_BEAMSCAN_LIBRARIES
    NAMES gnuradio-beamscan
    HINTS $ENV{BEAMSCAN_DIR}/lib
        ${PC_BEAMSCAN_LIBDIR}
    PATHS ${CMAKE_INSTALL_PREFIX}/lib
          ${CMAKE_INSTALL_PREFIX}/lib64
          /var/empty/local/lib
          /var/empty/local/lib64
          /var/empty/lib
          /var/empty/lib64
          )

include("${CMAKE_CURRENT_LIST_DIR}/gnuradio-beamscanTarget.cmake")

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(GR_BEAMSCAN DEFAULT_MSG GR_BEAMSCAN_LIBRARIES GR_BEAMSCAN_INCLUDE_DIRS)
MARK_AS_ADVANCED(GR_BEAMSCAN_LIBRARIES GR_BEAMSCAN_INCLUDE_DIRS)
