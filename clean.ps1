Remove-Item -Path "$PSScriptRoot/py/*pb2*" -Force -Recurse

Remove-Item -Path "$PSScriptRoot/generated" -Force -Recurse

Remove-Item -Path "$PSScriptRoot/build" -Force -Recurse