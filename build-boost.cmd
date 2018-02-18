@echo off

e:
SET REPO_BASE_FOLDER=e:\WorkSpace
SET TAG_BOOST=boost-1.66.0
SET PATH_BOOST=boost
SET MODULES=--with-system --with-filesystem --with-date_time --with-regex

rem Directory to boost root
set boost_dir=%REPO_BASE_FOLDER%\%PATH_BOOST%

rem Number of cores to use when building boost
set cores=%NUMBER_OF_PROCESSORS%

rem What toolset to use when building boost.

rem Visual Studio 2012 -> set msvcver=msvc-11.0
rem Visual Studio 2013 -> set msvcver=msvc-12.0
rem Visual Studio 2015 -> set msvcver=msvc-14.0
rem Visual Studio 2017 -> set msvcver=msvc-14.1

set msvcver=msvc-14.1

IF EXIST %boost_dir% GOTO BUILD_BOOST
pushd %REPO_BASE_FOLDER%
echo Cloning boost ...
rem git clone --recursive --branch %TAG_BOTAN% --depth 3 https://github.com/randombit/botan.git %PATH_BOTAN%
rem git clone --recursive --branch %TAG_BOOST% --depth=1 https://github.com/boostorg/boost.git %PATH_BOOST%
REM git clone --recursive --branch %TAG_BOOST% --depth 1 https://github.com/boostorg/boost.git %PATH_BOOST%
git clone --branch %TAG_BOOST% https://github.com/boostorg/boost.git %PATH_BOOST%

pushd %boost_dir%
git submodule update --init libs/range libs/core/ libs/assert/ libs/type_traits/ libs/iterator libs/winapi/ libs/mpl/ libs/preprocessor libs/smart_ptr libs/static_assert libs/throw_exception libs/io libs/functional libs/predef libs/detail/ libs/utility/ libs/system/ libs/filesystem/ libs/asio/ libs/bind/ libs/config/ tools/build

REM next modules are required for date_time:
git submodule update --init libs/date_time libs/type_index libs/any libs/regex libs/function libs/algorithm libs/lexical_cast libs/concept_check libs/numeric libs/integer libs/array libs/container libs/move libs/math libs/tokenizer
popd

popd

:BUILD_BOOST
IF EXIST %boost_dir%\stage\lib\*.lib GOTO END_BOOST
pushd %boost_dir%
rem Start building boost
echo Building %boost_dir% with %cores% cores using toolset %msvcver%.

call bootstrap.bat
b2 headers 
rem Static libraries
b2 -j%cores% toolset=%msvcver% variant=release,debug address-model=64 architecture=x86 link=static threading=multi runtime-link=shared %MODULES% --build-type=minimal stage --stagedir=stage/x64
REM: for 32-bit version uncomment next line:
rem b2 -j%cores% toolset=%msvcver% variant=release,debug address-model=32 architecture=x86 link=static threading=multi runtime-link=shared %MODULES% --build-type=minimal stage --stagedir=stage/win32

rem Build DLLs
rem b2 -j%cores% toolset=%msvcver% variant=release,debug address-model=32 architecture=x86 link=shared threading=multi runtime-link=shared %MODULES% stage --stagedir=stage/win32

popd

:END_BOOST

