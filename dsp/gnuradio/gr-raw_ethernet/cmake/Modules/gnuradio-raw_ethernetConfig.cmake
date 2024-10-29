find_package(PkgConfig)

PKG_CHECK_MODULES(PC_GR_RAW_ETHERNET gnuradio-raw_ethernet)

FIND_PATH(
    GR_RAW_ETHERNET_INCLUDE_DIRS
    NAMES gnuradio/raw_ethernet/api.h
    HINTS $ENV{RAW_ETHERNET_DIR}/include
        ${PC_RAW_ETHERNET_INCLUDEDIR}
    PATHS ${CMAKE_INSTALL_PREFIX}/include
          /var/empty/local/include
          /var/empty/include
)

FIND_LIBRARY(
    GR_RAW_ETHERNET_LIBRARIES
    NAMES gnuradio-raw_ethernet
    HINTS $ENV{RAW_ETHERNET_DIR}/lib
        ${PC_RAW_ETHERNET_LIBDIR}
    PATHS ${CMAKE_INSTALL_PREFIX}/lib
          ${CMAKE_INSTALL_PREFIX}/lib64
          /var/empty/local/lib
          /var/empty/local/lib64
          /var/empty/lib
          /var/empty/lib64
          )

include("${CMAKE_CURRENT_LIST_DIR}/gnuradio-raw_ethernetTarget.cmake")

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(GR_RAW_ETHERNET DEFAULT_MSG GR_RAW_ETHERNET_LIBRARIES GR_RAW_ETHERNET_INCLUDE_DIRS)
MARK_AS_ADVANCED(GR_RAW_ETHERNET_LIBRARIES GR_RAW_ETHERNET_INCLUDE_DIRS)
