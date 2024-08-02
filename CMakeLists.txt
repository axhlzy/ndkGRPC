cmake_minimum_required (VERSION 3.22.1)

project(server)

if(CMAKE_BUILD_TYPE MATCHES Debug)
    # add_definitions(-DDEBUG_PROJECT)
endif()

set(CMAKE_C_STANDARD 17)
set(CMAKE_CXX_STANDARD 17)

message(STATUS ${CMAKE_SYSTEM_NAME})

# source
# file(GLOB_RECURSE SOURCES src/*.cpp)

# proto
file(GLOB_RECURSE SOURCES_PROTO generated/*.cc)
include_directories(generated)

set(COMMON "-fPIC -w -o0 -g")
# set(COMMON "-fPIC -w -o3")
SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${COMMON}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${COMMON}")

if(MSVC)
    add_compile_options(/fdeclspec)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    add_compile_options(-fdeclspec)
endif()

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/bin)

add_executable(server src/server.cpp ${SOURCES_PROTO})
target_include_directories(server PUBLIC ${HEADERS})

add_executable(client src/client.cpp ${SOURCES_PROTO})
target_include_directories(client PUBLIC ${HEADERS})

if(ANDROID)
    find_library(log-lib log)
    target_link_libraries(server ${log-lib})
    target_link_libraries(client ${log-lib})
else()
    message(FATAL_ERROR "Android LIBLOG NOT FOUND")
endif()

if(NOT EXISTS "${CMAKE_SOURCE_DIR}/build/Release/generators/conan_toolchain.cmake")
    if(EXISTS "${CMAKE_SOURCE_DIR}/prebuild.ps1")
        message(STATUS "conan_toolchain.cmake not found, running prebuild.ps1...")
        execute_process(
            COMMAND powershell -NoProfile -ExecutionPolicy Bypass -File "${CMAKE_SOURCE_DIR}/prebuild.ps1"
            RESULT_VARIABLE result
        )
        if(NOT ${result} EQUAL 0)
            message(FATAL_ERROR "prebuild.ps1 execution failed with code ${result}")
        endif()
    else()
        message(FATAL_ERROR "conan_toolchain.cmake not found and prebuild.ps1 script is missing.")
    endif()
endif()
include(build/Release/generators/conan_toolchain.cmake)

find_package(Protobuf REQUIRED)

find_package(gRPC REQUIRED)

target_compile_options(server PUBLIC -fvisibility=default)
target_compile_options(client PUBLIC -fvisibility=default)
target_link_options(server PUBLIC -Wl,-E)
target_link_options(client PUBLIC -Wl,-E)

target_link_libraries(server gRPC::grpc++ gRPC::grpc++_reflection gRPC::gpr gRPC::grpc gRPC::grpc++ protobuf::libprotoc protobuf::libprotobuf)
target_link_libraries(client gRPC::grpc++ gRPC::grpc++_reflection gRPC::gpr gRPC::grpc gRPC::grpc++ protobuf::libprotoc protobuf::libprotobuf)

function(generate_symbol_files TARGET_NAME)
    if(EXISTS ${CMAKE_BINARY_DIR}/${TARGET_NAME}.sym)
        file(REMOVE ${CMAKE_BINARY_DIR}/${TARGET_NAME}.sym)
    endif()
    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} --only-keep-debug $<TARGET_FILE:${TARGET_NAME}> $<TARGET_FILE_DIR:${TARGET_NAME}>/${TARGET_NAME}.sym
        COMMAND ${CMAKE_OBJCOPY} --strip-debug $<TARGET_FILE:${TARGET_NAME}>
        COMMAND ${CMAKE_OBJCOPY} --add-gnu-debuglink=$<TARGET_FILE_DIR:${TARGET_NAME}>/${TARGET_NAME}.sym $<TARGET_FILE:${TARGET_NAME}>
        COMMENT "Generating symbol file and stripping symbols from target ${TARGET_NAME}"
    )
endfunction()

if(CMAKE_BUILD_TYPE STREQUAL Release)
    if(NOT DEFINED CMAKE_OBJCOPY)
        message(FATAL_ERROR "CMAKE_OBJCOPY is not defined. Please set CMAKE_OBJCOPY to the path of objcopy tool.")
    endif()
    generate_symbol_files(server)
    generate_symbol_files(client)
endif()
