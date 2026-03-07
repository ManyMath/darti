cmake_minimum_required(VERSION 3.10)

include("../cargokit/cmake/cargokit.cmake")
apply_cargokit(${PROJECT_NAME} ../arti-ffi arti_ffi "")

# Export the built library so Flutter bundles it alongside the executable.
set(arti_bundled_libraries "${${PROJECT_NAME}_cargokit_lib}" PARENT_SCOPE)
