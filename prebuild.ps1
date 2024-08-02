Set-Location -Path $PSScriptRoot

& conan install . -pr android --build=missing

# 注意 protoc 的版本一定是和当前依赖库的版本一致的，最好就直接使用源码编译的bin和lib
# grpc_cpp_plugin 的版本影响不大
# protobuf/3.21.12
# grpc/1.54.3

$protoc = "C:\Users\admin\.conan2\p\proto8625022988b17\p\bin\protoc.exe" 
$grpc_cpp_plugin = "C:\Users\admin\.conan2\p\grpc4cef018791af5\p\bin\grpc_cpp_plugin.exe"
$grpc_python_plugin = "C:\Users\admin\.conan2\p\grpc4cef018791af5\p\bin\grpc_python_plugin.exe"
$generatedDir = "generated"

# C++
if (-Not (Test-Path -Path $generatedDir)) {
    New-Item -ItemType Directory -Path $generatedDir
}
& $protoc -I=proto --grpc_out=generated --plugin=protoc-gen-grpc=$grpc_cpp_plugin proto/helloworld.proto
& $protoc -I=proto --cpp_out=generated proto/helloworld.proto

# Python
if (-Not (Test-Path -Path py)) {
    New-Item -ItemType Directory -Path py
}
& $protoc -I=proto --python_out=py proto/helloworld.proto
& $protoc -I=proto --grpc_out=py --plugin=protoc-gen-grpc=$grpc_python_plugin proto/helloworld.proto

# Node
if (-Not (Test-Path -Path node)) {
    New-Item -ItemType Directory -Path node
}
Push-Location node
& npm install @grpc/grpc-js @grpc/proto-loader
& node client.js
Pop-Location

Pop-Location




# include(default)

# [settings]
# os=Android
# os.api_level=27
# arch=armv8
# compiler=clang
# compiler.version=17
# compiler.libcxx=c++_static
# compiler.cppstd=14

# [conf]
# tools.android:ndk_path=....../ndk/26.1.10909125
# tools.cmake.cmaketoolchain:generator=Ninja

# [tool_requires]
# ninja/[*]